# Assume that if IsWindows doesn't exist, we're on Windows.
if ($IsWindows -Or !(Test-Path variable:global:IsWindows))
{
	$target = "i686-pc-windows-msvc"
}
elseif ($IsLinux)
{
	$target = "i686-unknown-linux-gnu"
}
else
{
	Write-Error "BYOND only runs on Linux or Windows, what're you even building libvg for?"
}

cargo build --release --target $target

if ($?)
{
	if (Test-Path "../libvg.dll")
	{
		Write-Host "Deleting old version of libvg in the project root."
		Remove-Item "../libvg.dll"
	}

	Copy-Item "target/$target/release/libvg.dll" ".."
}
else
{
	Write-Error "There was an error during the build."
}
