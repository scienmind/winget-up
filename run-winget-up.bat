@echo off
set location="%cd%\winget-up.ps1"
set winget_up_flags=

@REM !!! To enable optional flags, uncomment the the desired lines below (by removing the '@REM ' prefix):
@REM set winget_up_flags=%winget_up_flags% -InstallNew
@REM set winget_up_flags=%winget_up_flags% -WingetUpdateFlags \"--include-unknown\"
@REM set winget_up_flags=%winget_up_flags% -DryRun
@REM set winget_up_flags=%winget_up_flags% -HostnameConfig some_hostname
@REM set winget_up_flags=%winget_up_flags% -PackageGroups some_package_group
@REM set winget_up_flags=%winget_up_flags% -ConfigFile path_to_some_config_file

powershell -command "Start-Process %run_as_admin% powershell" "'-ExecutionPolicy Bypass -File \"%location%\" %winget_up_flags%'"
