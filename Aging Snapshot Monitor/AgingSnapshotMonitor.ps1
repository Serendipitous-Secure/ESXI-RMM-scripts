$ErrorActionPreference = "Stop"
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted -Force
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

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


$Server = $ENV:UDF_15
$User = "DattoRMM"
$DATTORMMPASS = $ENV:DattoRMMPass
$GuestHostname = hostname.exe
$Duration = $ENV:Duration

Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
Set-PowerCLIConfiguration -ParticipateInCEIP $false -Confirm:$false

$VIServer = Connect-VIServer -Server $Server -Protocol https -User $User -Password $DATTORMMPASS

$snapshots = get-vm -Name $GuestHostname -Server $VIServer | Get-Snapshot

#Any snapshots or none at all
if ( $snapshots.count -ge 0 ) {


    #just one or many
    if ( $snapshots -eq 1 ){
        #date compere
        $DateComp = ( ( Get-Date ) - ( Get-Date $snapshots.Created ) )


        #check age
        if ( !($DateComp.TotalSeconds -lt [int]$Duration) ) {
        
            write-host '<-Start Result->'
            write-host "STATUS=This server has 1 or more snapshots older than the outlined duration."
            write-host '<-End Result->'
            write-host '<-Start Diagnostic->'
            Write-Host "`n"
            Write-Host "============================================================"
            Write-Host "Snapshot $snapshots.Name is older than the outlined duration."
            Write-Host "============================================================"
            Write-Host "`n" 
            write-host '<-End Diagnostic->'
            Disconnect-VIServer -Confirm:$False
            & REG ADD HKEY_LOCAL_MACHINE\SOFTWARE\CentraStage /v "Custom16" /t REG_SZ /d "False" /f
            exit 1
        
        } else {

            write-host '<-Start Result->'
            write-host "STATUS=This server has NO snapshots older than the outlined duration."
            write-host '<-End Result->'
            write-host '<-Start Diagnostic->'
            Write-Host "`n"
            Write-Host "============================================================"
            Write-Host "Snapshot $snapshots.Name is NOT older than the outlined duration."
            Write-Host "============================================================"
            Write-Host "`n" 
            write-host '<-End Diagnostic->'
            Disconnect-VIServer -Confirm:$False
            & REG ADD HKEY_LOCAL_MACHINE\SOFTWARE\CentraStage /v "Custom16" /t REG_SZ /d "True" /f
            exit 0

        }
    

    #more than one; iterate
    } else {


        $AgedSnapshots = @()
        $RecentSnapshots = @()
        
        #iterate snapshots
        foreach ($snapshot in $snapshots){
        
            $DateComp = ( ( Get-Date ) - ( Get-Date $snapshot.Created ) )
        
            #sort to appropraite list    
            if ( !($DateComp.TotalSeconds -lt [int]$Duration) ) {     
        
                $AgedSnapshots += $snapshot.Name
        
            } else {        

                $RecentSnapshots += $snapshot.Name

            }
                
        }
    

        if ($RecentSnapshots.count -ne 0){
            & REG ADD HKEY_LOCAL_MACHINE\SOFTWARE\CentraStage /v "Custom16" /t REG_SZ /d "True" /f
        } else {
            & REG ADD HKEY_LOCAL_MACHINE\SOFTWARE\CentraStage /v "Custom16" /t REG_SZ /d "False" /f
        }

        
        #Decide status
        if ( $AgedSnapshots.count -ne 0 ){
            write-host '<-Start Result->'
            write-host "STATUS=This server has 1 or more snapshots older than the outlined duration."
            write-host '<-End Result->'
            
        } else {
            write-host '<-Start Result->'
            write-host "STATUS=This server has NO snapshots older than the outlined duration."
            write-host '<-End Result->'

        }


        #Write Diagnostic
        write-host '<-Start Diagnostic->'
        foreach($snapshot in $Agedsnapshots){
        
            Write-Host "`n"
            Write-Host "============================================================"
            Write-Host "Snapshot $snapshot is older than the outlined duration."
            Write-Host "============================================================"
            Write-Host "`n" 
        
        }

        foreach($snapshot in $Recentsnapshots){
        
            Write-Host "`n"
            Write-Host "============================================================"
            Write-Host "Snapshot $snapshot is NOT older than the outlined duration"
            Write-Host "============================================================"
            Write-Host "`n" 

        }

        write-host '<-End Diagnostic->'
        Disconnect-VIServer -Confirm:$False

        #Decide exit code
        if ( $AgedSnapshots.count -ne 0 ){
            exit 1
        } else {
            exit 0
        }
    

    }

#None at all
} else {

    Write-Host "`n"
    Write-Host "============================================================"
    Write-Host "This server detects no snapshots of itself."
    Write-Host "============================================================"
    Write-Host "`n"

    Disconnect-VIServer -Confirm:$False
        
    exit 0

    & REG ADD HKEY_LOCAL_MACHINE\SOFTWARE\CentraStage /v "Custom16" /t REG_SZ /d "False" /f

}

