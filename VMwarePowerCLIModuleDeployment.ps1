$ErrorActionPreference = "Stop"
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted -Force
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#.net compatibility 
if ( !((Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full").Release -ge 461808) ) {

    Invoke-WebRequest -Uri "http://go.microsoft.com/fwlink/?LinkId=863262" -OutFile LatestVersionOfDotNet.exe
    ./LatestVersionOfDotNet.exe /quiet /norestart LatestVersionOfDotNet.exe
    
    Write-Host "`n"
    Write-Host "============================================================"
    Write-Host "This device needs a reboot before we can continue"
    Write-Host "============================================================"
    Write-Host "`n"
    
    exit 1

}else {

    Write-Host "`n"
    Write-Host "============================================================"
    Write-Host "This device has a current installation of .net (minimum necessary: 4.7.2). Continuing..."
    Write-Host "============================================================"
    Write-Host "`n"

}

#Powershell compatibility
if ( !($PSVersionTable.PSVersion.major -ge 5) ) {

    Write-Host "`n"
    Write-Host "============================================================"
    Write-Host "This device needs its powershell version updated."
    Write-Host "Current Version: " $PSVersionTable.PSVersion.major
    Write-Host "============================================================"
    Write-Host "`n"

    exit 1

}else {

    Write-Host "`n"
    Write-Host "============================================================"
    Write-Host "This device has a current installation of Powershell (minimum necessary: 5.1). Continuing..."
    Write-Host "============================================================"
    Write-Host "`n"

}

#Installing module
if ( !(get-installedmodule -name vmware*) ){

    try{

        Write-Host "`n"
        Write-Host "============================================================"
        Write-Host "Installing VMware PowerCLI Module."
        Write-Host "============================================================"
        Write-Host "`n"

        Install-PackageProvider -Name nuget -Force
        Install-Module -Name VMware.PowerCLI -Force

    } Catch {

        Write-Host "`n"
        Write-Host "============================================================"
        Write-Host "Cannot install Vmware PowerCLI module."
        Write-Host "============================================================"
        Write-Host "`n"

        Write-Output $_.Exception.Message

        exit 1

    }


} else {

        Write-Host "`n"
        Write-Host "============================================================"
        Write-Host "Vmware PowerCLI module is installed."
        Write-Host "============================================================"
        Write-Host "`n"

}

#Importing Module
if ( (get-installedmodule -name vmware*) -and !(get-module -name vmware*) ){

    try {

        Write-Host "`n"
        Write-Host "============================================================"
        Write-Host "Importing VMware PowerCLI Module."
        Write-Host "============================================================"
        Write-Host "`n"

        Import-Module -Name VMware.PowerCLI -Force
        Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
        Set-PowerCLIConfiguration -ParticipateInCEIP $false -Confirm:$false

    } Catch {

        Write-Host "`n"
        Write-Host "============================================================"
        Write-Host "Cannot import Vmware PowerCLI module."
        Write-Host "============================================================"
        Write-Host "`n"

        Write-Output $_.Exception.Message

        exit 1

    }

} else {

        Write-Host "`n"
        Write-Host "============================================================"
        Write-Host "Vmware PowerCLI module is imported."
        Write-Host "============================================================"
        Write-Host "`n"

}

exit 0

#make module import by default

# #create profile
# if ( !( Test-Path "C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1" ) ) {

#     Write-Host "`n"
#     Write-Host "============================================================"
#     Write-Host "System Powershell Profile does not exist, we are creating one."
#     Write-Host "============================================================"
#     Write-Host "`n"
#     New-Item -Path 'C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1' -ItemType File

# } 

# #add module to profile.
# if ( !( type 'C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1' | findstr "Import-Module -Name VMware.PowerCLI -Force | out-Null" ) ) {

#     Write-Host "`n"
#     Write-Host "============================================================"
#     Write-Host "Adding VMware PowerCLI module to profile."
#     Write-Host "============================================================"
#     Write-Host "`n"
#     echo "Import-Module -Name VMware.PowerCLI -Force | out-Null" >> 'C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1'

# }else {     
    
#     Write-Host "`n"
#     Write-Host "============================================================"
#     Write-Host "VMware PowerCLI module already present in profile."
#     Write-Host "============================================================"
#     Write-Host "`n" 

# }



# Connect-VIServer -Server 192.168.111.90 -Protocol https -User root -Password MCSsupport2010

# #DO STUFF

# Disconnect-VIServer -Confirm:$False

