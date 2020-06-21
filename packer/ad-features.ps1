# http://www.rebeladmin.com/2018/10/step-step-guide-install-active-directory-windows-server-2019-powershell-guide/
# https://docs.microsoft.com/en-us/powershell/module/dfsn
Write-Host "Enabling Active Directory Features..."
Install-WindowsFeature -Name "AD-Domain-Services" -IncludeManagementTools
Write-Host "Enabling active directory DFS replication..."
Install-WindowsFeature "FS-DFS-Replication"
Write-Host "Enabling active directory DFS namespaces..."
Install-WindowsFeature "FS-DFS-Namespace"

Write-Host "Upgrading the server to a domain controller..."
$password = ConvertTo-SecureString $env:DC01_ADMINPASS -AsPlaintext -Force

# The command below will automatically reboot to computer, so you will need to create new script and provisioner block if you want to use active directory cmdlets.
Install-ADDSForest -DomainName $env:DC902_FORESTDOMAIN -DomainMode $env:DC902_DOMAINMODE -DomainNetbiosName $env:DC01_NETBIOSNAME -ForestMode $env:DC902_FORESTMODE -InstallDns -SafeModeAdministratorPassword $password -Force