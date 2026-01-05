param (
    [Parameter(Mandatory = $true)]
    [string]$TargetFolder
)

Get-ChildItem -Path $TargetFolder -File |
Where-Object { $_.Extension -eq "" } |
ForEach-Object {
    Rename-Item $_.FullName ($_.Name + ".mp3")
}