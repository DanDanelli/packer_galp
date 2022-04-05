Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Set-Service -Name sshd -StartupType 'Automatic'
Start-Service sshd
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force
Get-Service -Name ssh-agent | Set-Service -StartupType 'Automatic'
Start-Service ssh-agent
Stop-Service sshd
Start-Service sshd
Add-Content $Env:ProgramData\ssh\sshd_config "TrustedUserCAKeys __PROGRAMDATA__/ssh/trusted-user-ca-keys.pem"
