<#
    The winget-up utility provides a single-click solution to install and
    keep sets of software applications up to date across devices
    (based on native Windows Package Manager Client: winget).

    The utility allows to group applications into "package groups" and 
    define which devices shall update/install certain software packages.
#>

[CmdletBinding(PositionalBinding = $false)]
param (
    [Parameter(Mandatory = $false)]
    [string]$ConfigFile,

    [Parameter(Mandatory = $false)]
    [string]$HostnameConfig = (hostname),

    [Parameter(Mandatory = $false)]
    [string[]]$PackageGroups,

    [Parameter(Mandatory = $false)]
    [switch]$InstallNew = $false,

    [Parameter(Mandatory = $false)]
    [switch]$DryRun = $false,

    [Parameter(Mandatory = $false)]
    [string[]]$WingetUpdateFlags = ""
)

function UpdatePackagesFromList {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [array] $PackageList,
        [bool] $InstallNew,
        [bool] $DryRun,
        [string[]] $WingetUpdateFlags
    )
    Write-Host "`nProcessing packages: "$PackageList
    foreach ($Package in $PackageList) {
        $ListPack = winget list --accept-source-agreements --exact -q $Package
        if ([string]::Join("", $ListPack).Contains($Package)) {
            Write-Host "`nUpdating existing package: "$Package"..."
            if (!$DryRun) {
                Write-Host
                winget upgrade --exact --silent `
                    --accept-source-agreements --accept-package-agreements `
                    $WingetUpdateFlags.Split() --id $Package
            }
        }
        else {
            if ($InstallNew) {
                Write-Host "`nInstalling new package: "$Package"..."
                if (!$DryRun) {
                    winget install --exact --silent `
                        --accept-source-agreements --accept-package-agreements `
                        --id $Package
                }
            }
            else {
                Write-Host "`nSkipping package: "$Package" (package is not installed)"
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
    $PackageGroups = $ConfigData.host_configs.$HostnameConfig.package_groups
}
if ($PackageGroups -eq "*") {
    # select all groups
    $PackageGroups = $ConfigData.package_group_definitions.psobject.Properties.Name
}
Write-Host "Using the following parameters:" `
    "`n`tConfigFile:"$ConfigFile `
    "`n`tHostnameConfig:"$HostnameConfig `
    "`n`tPackageGroups:"$PackageGroups `
    "`n`tInstallNew:"$InstallNew `
    "`n`tDryRun:"$DryRun `
    "`n`tWingetUpdateFlags:"$WingetUpdateFlags

foreach ($PackageGroup in $PackageGroups) {
    Write-Host "`nProcessing package group:"$PackageGroup
    UpdatePackagesFromList `
        -PackageList $ConfigData.package_group_definitions.$PackageGroup `
        -InstallNew $InstallNew `
        -DryRun $DryRun `
        -WingetUpdateFlags $WingetUpdateFlags
}

Read-Host -Prompt "`nPress Enter to exit"
