# Ping the local DreamDaemon server until it responds
# Autodetects port by finding what dreamdaemon.exe is listening on

function Find-DreamDaemonPort {
    $connections = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | Where-Object {
        $proc = Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue
        $proc.ProcessName -in @('dd', 'dreamdaemon')
    }

    if ($connections) {
        return $connections[0].LocalPort
    }
    return $null
}

function Test-Server {
    param([string]$Server = "localhost", [int]$Port)
    try {
        $client = New-Object System.Net.Sockets.TcpClient
        $client.Connect($Server, $Port)
        $stream = $client.GetStream()

        $query = "?ping"
        $queryBytes = [System.Text.Encoding]::ASCII.GetBytes($query)
        $length = $queryBytes.Length + 6

		# Byond topic packet construction
        $packet = [byte[]]@(
            0x00, 								 # Header byte
            0x83, 								 # Header byte
            [byte](($length -shr 8) -band 0xFF), # Message body size in big endian
            [byte]($length -band 0xFF),		     # and lower byte, its an int16
            0x00, 0x00, 0x00, 0x00, 0x00	     # flag, port (unused here so 0)
        ) + $queryBytes + [byte]0x00			 # mesasge + null terminator

        $stream.Write($packet, 0, $packet.Length)
        $stream.Flush()
        $stream.ReadTimeout = 1000

        $buffer = New-Object byte[] 1024
        $read = $stream.Read($buffer, 0, 1024)

        $client.Close()
        return $read -gt 0
    } catch {
        return $false
    }
}

while ($true) {
    $port = Find-DreamDaemonPort
    if ($port) {
        Write-Host "Found DreamDaemon on port $port, feelsgoodman"
        if (Test-Server -Port $port) {
            Write-Host "DreamDaemon ready"
            break
        }
        Write-Host "Server is still starting and not responding yet, retrying"
    } else {
        Write-Host "DreamDaemon has not yet launched, retrying"
    }
    Start-Sleep -Seconds 2
}
