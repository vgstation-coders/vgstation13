# Ping the local DreamDaemon server until it responds
# Autodetects port by finding what dreamdaemon.exe is listening on

function Find-DreamDaemonPort {
	# check running processes, this is slow as shit because it looks at everything so erroraction should be faster
    $proc = Get-Process -Name 'dd','dreamdaemon' -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $proc) {
        return $null
    }

	# found the process, get the port
    $conn = Get-NetTCPConnection -OwningProcess $proc.Id -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($conn) {
        return $conn.LocalPort
    }
    return $null
}

function Test-Server {
    param([string]$Server = "localhost", [int]$Port)
    try {
        $client = New-Object System.Net.Sockets.TcpClient
        $asyncResult = $client.BeginConnect($Server, $Port, $null, $null)
        if (-not $asyncResult.AsyncWaitHandle.WaitOne(1000)) {
            $client.Close()
            return $false
        }
        $client.EndConnect($asyncResult)
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

$detectedPort = $null

while ($true) {
	# get whatever port dreamdaemon is on
    $port = Find-DreamDaemonPort
    if ($port) {
        Write-Host "Found DreamDaemon on port $port"
		# ping the server to make sure we can actually connect yet
        if (Test-Server -Port $port) {
            $detectedPort = $port
            break
        }
        Write-Host "Server is still starting and not responding yet, retrying"
    } else {
        Write-Host "DreamDaemon has not yet launched, retrying"
    }
    Start-Sleep -Seconds 2
}

if ($detectedPort) {
    $dsPath = "C:\Program Files (x86)\BYOND\bin\dreamseeker.exe"
    if (-not (Test-Path $dsPath)) {
        $dsPath = "C:\Program Files\BYOND\bin\dreamseeker.exe"
    }
    Start-Process $dsPath -ArgumentList "byond://localhost:$detectedPort"
}
