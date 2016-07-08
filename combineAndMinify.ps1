# TFS Post-Build Concatenation and Minification Script
# ====================================================
# Last Modified: 6/9/2016
# Copyright © 2016 Digital Gaming Corporation
# Written by Travis Vroman
#
# Arguments: 
#   -buildPath <Base Build Path> 
#   -fileNames <comma separated file names> (ex: "pixi.min.js,howler.min.js,VClient.js,flux.js,shanghaiBeauty.js")
#   -mode <string, "combined" or "minified"> - includes combined js file if "combined", otherwise uses minify

param(
    [Parameter(Mandatory=$true)][string]$buildPath,
    [Parameter(Mandatory=$true)][string[]]$fileNames,
    [Parameter(Mandatory=$true)][string]$mode,
	[Parameter(Mandatory=$true)][string]$build
    )

function Overwrite-Replace-Codes {
    param( [string]$buildPathIn, [string]$fileName, [string]$replaceCodeBegin, [string]$replaceCodeEnd, [string]$insertCode )

    [string]$rootPath = $buildPathIn.Replace("\lib","");
    Write-Host "Root path is: $rootPath"

    # TODO: convert into a reusable function later so we can do more than just the one file.
    Write-Host "Getting index file for tag replacement...";
    $indexFile = Get-Item "$rootPath\$fileName"
    [string]$indexContent = (Get-Content $indexFile) -join "`r`n"

    Write-Host "Looking for replace tag...";
    [int]$replaceStart = $indexContent.IndexOf($replaceCodeBegin)
    [int]$replaceEnd = $indexContent.IndexOf($replaceCodeEnd)
    [int]$lengthDiff = ($replaceEnd - $replaceStart) + $replaceCodeEnd.Length

    [string]$replaceToken = $indexContent.Substring( $replaceStart, $lengthDiff );
    #[string]$insertCode = '<script type="text/javascript" src="lib/game-combined.js"></script>'

    if($replaceToken -eq "") {
        throw [System.IO.FileFormatException] "Replace codes not found. $fileName file must contain '$replaceCodeBegin' and '$replaceCodeEnd' markers for include replacement.";
    } else {
        $indexContent = $indexContent.Replace($replaceToken, $insertCode);
        Write-Host "Performing replacement...";
        #overwrite the file.
        Write-Output $indexContent | Out-File -Encoding "UTF8" $indexFile;
    }
}

# BEGIN SCRIPT /////////////////////////////////////////////////////////

# Initializing Paths
[string]$combinedFileName   = 'game-combined.js';
[string]$minifiedFileName   = 'game-min.js';
[string]$javaPath           = "C:\Program Files (x86)\Java\jre1.8.0_91\bin\java.exe" # Path to Java Runtime Environment
[string]$closurePath        = "C:\Utilities\closure-compiler\compiler.jar"           # Path to Closure JS Compiler
[string]$combinedOutputPath = "$buildPath\$combinedFileName"                         # Output path and filename of combined JS file
[string]$minifiedOutputPath = "$buildPath\$minifiedFileName"                         # Output path and filename of minified version of combined JS file

New-Item $combinedOutputPath -type file -force | out-null
New-Item $minifiedOutputPath -type file -force | out-null

#Write build version to the top of the file:
Write-Host "Version: $build"
Add-Content $combinedOutputPath "var fluxBuild = '$build';`r`n";

# Concatenate all files into one (in the order they were passed, as this is important)
foreach($file in $fileNames.Split(",")){
    $finalPath = "$buildPath$file"
    Write-Host "Combining file... $finalPath"
    $item = Get-Item $finalPath
    $fileContent = Get-Content $item
    Add-Content $combinedOutputPath $fileContent
}

# Minify the resulting file
& $javaPath -jar $closurePath --js $combinedOutputPath --js_output_file $minifiedOutputPath --warning_level=QUIET

Write-Host "Concatenation and minification complete.";

# Determine which file to include based on the mode switch.
$finalTargetPath = $minifiedFileName;
if( [string]$mode -eq "combined" ) {
    $finalTargetPath = $combinedFileName;
}

# Open index.html file and replace tags with js include...
$htmlIncludeFilePath = "<script type=`"text/javascript`" src=`"lib/$finalTargetPath`"></script>";
$jsIncludeFilePath = "{ id: `"ShanghaiBeauty`", path: `"./lib/$finalTargetPath`", map: `"game`" }";
Overwrite-Replace-Codes $buildPath "index.html" '<!--REPLACE_START' 'REPLACE_END-->' $htmlIncludeFilePath;
Overwrite-Replace-Codes $buildPath "GameAssets.min.js" '/*REPLACE_START*/' '/*REPLACE_END*/' $jsIncludeFilePath;

Write-Host "Concatenation, minification, index token replacement and GameAssets.min.js token replacement completed successfully.";

# END SCRIPT /////////////////////////////////////////////////////////