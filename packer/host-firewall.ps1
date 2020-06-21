Write-Host "Weakening Windows Firewall..."
Set-NetFirewallProfile -Profile Public,Private -Enabled False