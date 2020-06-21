# Create AD Groups
Write-Host "Creating active directory groups..."
New-ADGroup -Name "Accounting" -GroupScope "DomainLocal"
New-ADGroup -Name "IT" -GroupScope "DomainLocal"
New-ADGroup -Name "Legends" -GroupScope "DomainLocal"

# Set a weak password policy
Write-Host "Weakening active directory default password policy..."
Set-ADDefaultDomainPasswordPolicy -Identity $env:DC902_FORESTDOMAIN -ComplexityEnabled $False -LockoutDuration 0 -LockoutObservationWindow 0 -LockoutThreshold 0

# Create AD Users
Write-Host "Installing active directory users..."
New-ADUser -GivenName Neo -Surname Springfield -Name "Neo Springfield" -SamAccountName neo.springfield -Enabled $True -AccountPassword (ConvertTo-SecureString $Env:DC902_USER1_PASSWORD -AsPlainText -force) -PasswordNeverExpires $True
New-ADUser -GivenName Aubrey -Surname Alvingham -Name "Aubrey Alvingham" -SamAccountName aubrey.alvingham -Enabled $True -AccountPassword (ConvertTo-SecureString $Env:DC902_USER2_PASSWORD -AsPlainText -force) -PasswordNeverExpires $True
New-ADUser -GivenName Leeroy -Surname Jenkins -Name "Leeroy Jenkins" -SamAccountName leeroy.jenkins -Enabled $True -AccountPassword (ConvertTo-SecureString $Env:DC902_USER3_PASSWORD -AsPlainText -force) -PasswordNeverExpires $True
New-ADUser -GivenName Egon -Surname Deighton -Name "Egon Deighton" -SamAccountName egon.deighton -Enabled $True -AccountPassword (ConvertTo-SecureString $Env:DC902_USER4_PASSWORD -AsPlainText -force) -PasswordNeverExpires $True
New-ADUser -GivenName Bob -Surname Jhonson -Name "Bob Jhonson" -SamAccountName bob.johnson -Enabled $True -AccountPassword (ConvertTo-SecureString $Env:DC902_USER5_PASSWORD -AsPlainText -force) -PasswordNeverExpires $True
New-ADUser -GivenName Mary -Surname Smith -Name "Mary Smith" -SamAccountName mary.smith -Enabled $True -AccountPassword (ConvertTo-SecureString $Env:DC902_USER6_PASSWORD -AsPlainText -force) -PasswordNeverExpires $True
New-ADUser -GivenName Demo -Surname God -Description "Welcome to DC902! You password is welcome2020!" -Name "Demo God" -SamAccountName "demo" -Enabled $True -AccountPassword (ConvertTo-SecureString $Env:DC902_USER7_PASSWORD -AsPlainText -force) -PasswordNeverExpires $True

# Associate users with groups
Write-Host "Associating active directory users with groups..."
Add-ADGroupMember -Identity Accounting -Members "bob.johnson", "mary.smith"
Add-ADGroupMember -Identity IT -Members "mary.smith"
Add-ADGroupMember -Identity "Remote Management Users" -Members "egon.deighton", "leeroy.jenkins"
Add-ADGroupMember -Identity "Legends" -Members "egon.deighton", "leeroy.jenkins", "neo.springfield", "aubrey.alvingham"

# Add users to Administrators groups
Write-Host "Adding local administrators..."
net localgroup Administrators leeroy.jenkins /add

# Disable kerberos preauthentication for some users to make them ASREP-roastable
Write-Host "Disabling kerberos preauth for certain users..."
Set-ADAccountControl -DoesNotRequirePreAuth $True -Identity "aubrey.alvingham"

# Add SPNs to the account to kerberoast
Write-Host "Adding SPNs to certain users..."
Set-ADUser -Identity "leeroy.jenkins" -ServicePrincipalNames @{Add='SuperSecureService/secureserver'}