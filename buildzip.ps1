param(
    [string]$builddir = $(throw "-builddir is required"),
    [string]$filename = $(throw "-filename is required.")
)
#date string
$fileDateStr = $(get-date -f yyyy.MM.dd-HH.mm.ss)

#Add Compression type
Add-Type -A 'System.IO.Compression.FileSystem'

# Create zip file
[IO.Compression.ZipFile]::CreateFromDirectory($workingFolder + $builddir, "C:\builds\" + $filename + "-" + $fileDateStr + ".zip")