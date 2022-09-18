<#
    Script description.
    TODO: add script description

    Some notes.
#>
# TODO: add support for logging

[CmdletBinding(PositionalBinding = $false)]
Param (
    [Parameter(Mandatory = $false)]
    [string]$ConfigFile,

    [Parameter(Mandatory = $false)]
    [string]$HostnameConfig = (hostname),

    [Parameter(Mandatory = $false)]
    [String[]]$PackageGroups,

    [Parameter(Mandatory = $false)]
    [switch]$InstallNew = $false,

    [Parameter(Mandatory = $false)]
    [switch]$DryRun = $false,

    [Parameter(Mandatory = $false)]
    [String[]]$WingetUpdateFlags = ""
)

function UpdatePackagesFromList {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [array] $PackageList,
        [bool] $InstallNew,
        [bool] $DryRun,
        [String[]] $WingetUpdateFlags
    )
    Write-host "`nProcessing packages: "$PackageList
    foreach ($Package in $PackageList) {
        $ListPack = winget list --exact -q $Package
        if ([String]::Join("", $ListPack).Contains($Package)) {
            Write-host "`nUpdating existing package: "$Package"..."
            if (!$DryRun) {
                winget upgrade --exact --silent $WingetUpdateFlags.Split() --id $Package
            }
        }
        else {
            if ($InstallNew) {
                Write-host "`nInstalling new package: "$Package"..."
                if (!$DryRun) {
                    winget install --exact --silent --id $Package
                }
            }
            else {
                Write-host "`nSkipping package "$Package" (package is not installed)"
            }
        }  
    }
}

if (!$ConfigFile) {
    # use default config file path
    $ConfigFile = Join-Path -Path $PSScriptRoot -ChildPath "config.json" -Resolve
}
# load data from JSON file while ignoring comments
$ConfigData = (Get-Content $ConfigFile -Raw) `
    -replace '(?m)(?<=^([^"]|"[^"]*")*)//.*' `
    -replace '(?ms)/\*.*?\*/' | ConvertFrom-Json
if (!$PackageGroups) {
    # select host-configured package group
    $PackageGroups = $ConfigData.host_config.$HostnameConfig.package_groups
}
if ($PackageGroups -eq "*") {
    # select all groups
    $PackageGroups = $ConfigData.package_group_definition.psobject.Properties.Name
}
Write-Host "Using the following parameters:" `
    "`n`tConfigFile:"$ConfigFile `
    "`n`tHostnameConfig:"$HostnameConfig `
    "`n`tPackageGroups:"$PackageGroups `
    "`n`tInstallNew:"$InstallNew `
    "`n`tDryRun:"$DryRun `
    "`n`tWingetUpdateFlags:"$WingetUpdateFlags

foreach ($PackageGroup in $PackageGroups) {
    Write-host "`nProcessing package group:"$PackageGroup
    UpdatePackagesFromList `
        -PackageList $ConfigData.package_group_definition.$PackageGroup `
        -InstallNew $InstallNew `
        -DryRun $DryRun `
        -WingetUpdateFlags $WingetUpdateFlags
}

Read-Host -Prompt "`nPress Enter to exit"
