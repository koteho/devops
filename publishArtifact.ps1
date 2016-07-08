# TFS Publish Artifact Script
# ====================================================
# Last Modified: 6/8/2016
# Copyright © 2016 Digital Gaming Corporation
# Written by Travis Vroman
#
# Arguments: 
#   -baseProjectName <The name of the base project (ex: ShanghaiBeauty)>
#   -customProjectName <The name of the sub project to publish to (ex: ShanghaiBeautyTravis)>
#   -localPath <The local path to publish from> 
#   -address <The target address to publish to (FTP)>
#   -ftpUser <FTP User to login as>
#   -ftpPass <the above FTP User's password>
#
# Command line example:
# powershell E:\Development\TFS\Tools\BuildProcessScripts\publishArtifact.ps1 -baseProjectName ShanghaiBeauty -customProjectName ShanghaiBeautyTravis -localPath: C:\Users\travisv\Desktop\ftptest -address ftp://10.75.130.83/shanghaiBeautyTravis -ftpUser DGC -ftpPass DGC1234$

param(
    [Parameter(Mandatory=$true)][string]$baseProjectName,
    [Parameter(Mandatory=$true)][string]$customProjectName,
    [Parameter(Mandatory=$true)][string]$localPath, 
    [Parameter(Mandatory=$true)][string]$address,
    [Parameter(Mandatory=$true)][string]$ftpUser, 
    [Parameter(Mandatory=$true)][string]$ftpPass
    )

# This is here to treat all errors as terminal errors. This is required for try/catch/finally statements to work properly.
$ErrorActionPreferece = "Stop"

# Try to create the folder if it does not exist. If it exists or is created, true is returned. False is returned on failure.
function Try-Create-Folder {
    param( [string]$fullPath, [System.Net.NetworkCredential]$credentials )

    #Write-Host "Attempting to create folder $fullPath...";

    [System.Net.WebRequest]$makeDirectoryRequest;
    $response;

    # Try creating the required directory.
    try {
        $makeDirectoryRequest = [System.Net.WebRequest]::Create( $fullPath );
        $makeDirectoryRequest.Credentials = $credentials;
        $makeDirectoryRequest.Method = [System.Net.WebRequestMethods+FTP]::MakeDirectory;
        $response = $makeDirectoryRequest.GetResponse();
        $response.Close()
        $response.Dispose();

        Write-Host "Created folder $fullPath.";
    } catch [System.Net.WebException] {
        [System.Net.FtpWebResponse] $resp = $_.Exception.Response;
        if( $resp.StatusCode -eq [System.Net.FtpStatusCode]::ActionNotTakenFileUnavailable ) {
            $resp.Close();
            #Write-Host "Folder $fullPath already exists.";
            return;
        } else {
            $resp.Close();
            Write-Host "ERROR: Unable to create folder $fullPath.";
            return;
        }
    }
}



# BEGIN SCRIPT /////////////////////////////////////////////////////////
Write-Host "STARTING...";

Write-Host "DEBUG:$localPath|$address|$ftpUser|$ftpPass ";

# If customProjectName != baseProjectName, find baseProjectName.html and rename it to customProjectName.html.
# This ensures compatability when V tries to launch the game.
if( $customProjectName -ne $baseProjectName ) {
    Rename-Item -path "$localPath\$baseProjectName.html" -newname "$customProjectName.html"
}

# Initializing Paths and Credentials
$files = Get-ChildItem $localPath -Recurse | where { ! $_.PSIsContainer }
[System.Net.WebClient]$ftp = New-Object System.Net.WebClient;
[System.Net.NetworkCredential]$credentials = New-Object System.Net.NetworkCredential( $ftpUser, $ftpPass );
$ftp.Credentials = $credentials

foreach( $file in $files ) {
    $directory = "";
    $source = $file.DirectoryName + "/" + $file;
    if( $file.DirectoryName.Length -gt 0 ) {
        $directory = $file.DirectoryName.Replace( $localPath, "" );
    }
    $directory += "/";
    $directory = $directory.Replace( "\", "/" );
    $fullPathStr = $address + $directory;
    if( $directory -ne "/" ) {
        Try-Create-Folder $fullPathStr $credentials;
    } else {
        #Write-Host "Root folder, nothing to create.";
    }

    $ftpCommand = $address + $directory + $file;

    $uri = New-Object System.Uri( $ftpCommand );
    Write-Host "Uploading file" $file "to $uri..."; # $file instead of $source here so we only grab the file name...
    try {
        $ftp.UploadFile( $uri, $source );
    } catch {
        Write-Host "Upload FAILED. Exception: " $_.Exception.Message;
        Break;
    } finally {
        $ftp.Dispose();
    }
}
Write-Host "Process Complete!";
# END SCRIPT /////////////////////////////////////////////////////////