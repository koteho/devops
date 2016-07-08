$gamePath           = "C:\TfsData\Build\_work\b03e695e\FLUX\develop\app\shanghaiBeauty" # 
$destPath           = "C:\inetpub\wwwroot\QA\Pasha\shanghaiBeauty"           # 

# recursively remove everything under C:\Temp\Test1
get-childitem $destPath  -recurse | % { 
    remove-item $_.FullName -recurse 
}

# recursively copy everything under $gamePath to $destPath 
get-childitem $gamePath | % { 
    copy-item $_.FullName -destination "$destPath\$_" -recurse 
}

