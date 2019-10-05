Write-Verbose "Changing SA login credentials"
$sqlcmd = "ALTER LOGIN sa with password='" + $env:sa_password +"',CHECK_POLICY=OFF,CHECK_EXPIRATION=OFF" + ";ALTER LOGIN sa ENABLE;"
& sqlcmd -Q $sqlcmd