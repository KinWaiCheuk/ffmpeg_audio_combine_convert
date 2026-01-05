param (
    [Parameter(Mandatory = $true)]
    [string]$TargetFolder
)

if (-not (Test-Path $TargetFolder)) {
    Write-Error "Folder not found: $TargetFolder"
    exit 1
}

Get-ChildItem -Path $TargetFolder -File | ForEach-Object {
    if ($_.Name -match '^batch_(\d+)_stereo(\..+)$') {
        $newName = 'batch_{0:D5}_stereo{1}' -f [int]$matches[1], $matches[2]
        if ($_.Name -ne $newName) {
            Rename-Item $_.FullName $newName
        }
    }
}