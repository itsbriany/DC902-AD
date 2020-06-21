# Quietly enable insecure winrm without a prompt.
Write-Host "Enabling insecure WinRM..."
winrm quickconfig -q
Enable-PSRemoting -Force