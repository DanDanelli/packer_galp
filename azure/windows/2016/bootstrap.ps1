Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine -Force -ErrorAction Ignore
$ErrorActionPreference = "stop"

# Set administrator password
net user packer SuperS3cr3t!!!!
wmic useraccount where "name='packer'" set PasswordExpires=FALSE

# turn off PowerShell execution policy restrictions
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope LocalMachine

# configure WinRM
winrm quickconfig -q
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="2048"}'
winrm set winrm/config/winrs '@{MaxConcurrentUsers="100"}'
winrm set winrm/config/winrs '@{MaxProcessesPerShell="0"}'
winrm set winrm/config/winrs '@{MaxShellsPerUser="0"}'
winrm set winrm/config '@{MaxTimeoutms="7200000"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service/auth '@{CredSSP="true"}'
winrm set winrm/config/client '@{TrustedHosts="*"}'


# open port 5986 in the internal Windows firewall to allow WinRM communication
netsh advfirewall firewall add rule name="WinRM 5986" protocol=TCP dir=in localport=5986 action=allow

net stop winrm
net start WinRM


Write-Output '>>> Waiting for GA Service (RdAgent) to start ...'
while ((Get-Service RdAgent).Status -ne 'Running') { Start-Sleep -s 5 }
#Write-Output '>>> Waiting for GA Service (WindowsAzureTelemetryService) to start ...'
#while ((Get-Service WindowsAzureTelemetryService) -and ((Get-Service WindowsAzureTelemetryService).Status -ne 'Running')) { Start-Sleep -s 5 }
Write-Output '>>> Waiting for GA Service (WindowsAzureGuestAgent) to start ...'
while ((Get-Service WindowsAzureGuestAgent).Status -ne 'Running') { Start-Sleep -s 5 }
Write-Output '>>> Sysprepping VM ...'
if( Test-Path $Env:SystemRoot\system32\Sysprep\unattend.xml ) {
  Remove-Item $Env:SystemRoot\system32\Sysprep\unattend.xml -Force
}
& $Env:SystemRoot\System32\Sysprep\Sysprep.exe /oobe /generalize /quiet /quit

Restart-Computer \"& {Write-Output 'restarted'"

while($true) {
$imageState = (Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\State).ImageState
Write-Output $imageState
if ($imageState -eq 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE') { break }Start-Sleep -s 10}
Write-Output '>>> Sysprep complete ...'