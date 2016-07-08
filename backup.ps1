[CmdletBinding(DefaultParameterSetName = 'None')]
Param(
[Parameter(Mandatory=$true)][string]$source,
[Parameter(Mandatory=$true)][string]$dest
)
#System Variable for backup Procedure 
 
 $date = Get-Date -Format yyyyMMdd-hhmmss 
 New-PSDrive -Name "Backup" -PSProvider Filesystem -Root $dest
 #$source = "C:\inetpub\wwwroot\QA\" 
 $destination = "backup:\$date" 
 $path = test-Path $destination 
  
  
# Backup Process started 
 
 if ($path -eq $true) { 
    write-Host "Directory Already exists" 
    Remove-PSDrive "Backup"   
    } elseif ($path -eq $false) { 
            cd backup:\ 
            mkdir $date 
            copy-Item  -Recurse $source -Destination $destination 
            $backup_log = Dir -Recurse $destination | out-File "$destination\backup_log.txt" 
            $attachment = "$destination\backup_log.txt"  
            write-host "Backup Successful!" 
            cd c:\ 
  
 Remove-PSDrive "Backup"   
 }