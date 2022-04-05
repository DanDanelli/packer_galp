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