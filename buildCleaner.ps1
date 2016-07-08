# TFS Cleanup Script
# ====================================================
# Last Modified: 6/9/2016
# Copyright © 2016 Digital Gaming Corporation
# Written by Joseph Murray and Travis Vroman
#
# Arguments: 
#   -basePath <Base Cleanup Path> ex: \\apps02\build
#   -keep <number of files to keeps> ex: 50

param(
    [Parameter(Mandatory=$true)][string]$basePath,
    [Parameter(Mandatory=$true)][int]$keep
    )

# Iterate through all the sub\child directories within the $basePath
$files=(Get-ChildItem -Path $basePath | SORT Name -descending);
Write-Host "Keeping the last $keep files.";
Write-Host $files 

if($files.Count -gt $keep) {
	# Creates a new array that specifies the files to delete, a bit ugly but concise.
    $DeleteFiles = $Files[$($Files.Count - ($Files.Count - $keep))..$Files.Count]
    Write-Host $DeleteFiles;
    # ForEach loop that goes through the DeleteFile array
    ForEach($DeleteFile in $DeleteFiles) {
        $dFile = $basePath + '\' + $DeleteFile.Name
        Write-Host($dFile);
        Remove-Item $dFile -force
	}
}