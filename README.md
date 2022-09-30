# winget-up

The `winget-up` utility provides a single-click solution to install and keep predefined sets of software applications up to date across devices (based on native [Windows Package Manager Client](https://github.com/microsoft/winget-cli)).

The utility allows to group applications into "package groups" and define which devices shall update/install certain software packages.

## Use case example

Let's say a user manages few Windows devices:

- "Media PC" (hostname: `my_editing_pc`) - used for media consumption and creation, and has a set of editing and viewing software applications installed
- "Desktop Workstation" (hostname: `my_desktop_workstation`) - main workstation, mixed use
- "Portable Laptop" (hostname: `my_laptop`) - used to perform only basic tasks on the go

The important applications used by the devices can be organised into a few "package groups":

- **Basic applications**, used by all devices:
  - web browser
  - document viewer
  - media player  

- **Media editing tools**, used on the "Media PC" and the "Desktop Workstation"
  - photo editing software
  - audio editing software
  - video editing software

- **SW Development tools**, used only on "Desktop Workstation" and "Portable Laptop"
  - code editor
  - version control software

- **Communication utilities**, used on "Desktop Workstation" and "Portable Laptop"
  - conferencing applications
  - chat applications

This setup translates to the following configuration:

```jsonc
{
    "host_configs": {
        "my_laptop": { // device hostname
            "package_groups": [
                "basic_apps", // package group name
                "communication_apps",
                "dev_tools"
            ]
        },
        "my_desktop_workstation": {
            "package_groups": [
                "*" // select all package groups
            ]
        },
        "my_editing_pc": {
            "package_groups": [
                "basic_apps",
                "editing_tools"
            ]
        }
    },
    "package_group_definitions": {
        "basic_apps": [
            "7zip.7zip", // application id
            "Mozilla.Firefox",
            "TheDocumentFoundation.LibreOffice",
            "VideoLAN.VLC"
        ],
        "editing_tools": [
            "Audacity.Audacity",
            "BlenderFoundation.Blender",
            "GIMP.GIMP"
        ],
        "dev_tools": [
            "Git.Git",
            "Microsoft.VisualStudioCode"
        ],
        "communication_apps": [
            "Jitsi.Meet",
            "OpenWhisperSystems.Signal"
        ]
    }
}
```

The configuration above would be stored in `config.json` file in the `winget-up` folder alongside the scripts.

The `winget-up` folder, containing the tool and the unified configuration file, can then be shared/synchronized across all devices using a synchronization tool of your choice (e.g. [Syncthing](https://syncthing.net/)).

When running the utility, the current device's hostname will be detected automatically, and the all the applications in the package groups belonging to this hostname according to the configuration will be updated.

Alternatively, instead of configuring cross-device package groups, per-device groups can be configured as well.

---

## Prerequisites

- PowerShell v5.1+
- winget v1.3+

The necessary dependencies come pre-installed on Windows 11 21H2 and Windows 10 21H1 (and newer versions).

## Configuration

Copy or rename the provided `config.json.example` file to `config.json` and replace it's contents with the relevant values (see the aforementioned use case example for config file building guidance).

### Identifying device's "hostname" string

To find out the hostname of the current device:

- open command prompt: press "Win + R", type `cmd` and press "enter"
- type `hostname` and press "enter"

### Discovering the "Application ID" string

To find out the Application ID (to be used in the configuration file):

- open command prompt: press "Win + R", type `cmd` and press "enter"
- type `winget search` followed by the application name you want to find and press "enter" to see the list of potential matches:

    ```console
    >winget search vlc
    Name                                        Id                    Version  Match        Source 
    -----------------------------------------------------------------------------------------------
    VLC                                         XPDM1ZW6815MQM        Unknown               msstore
    VLC UWP                                     9NBLGGH4VVNH          Unknown               msstore
    Video Player - Full HD Video Player for VLC 9N0DXV1TWHL2          Unknown               msstore
    VLC media player                            VideoLAN.VLC          3.0.17.4 Moniker: vlc winget
    VLC media player nightly                    VideoLAN.VLC.Nightly  4.0.0    Tag: vlc     winget
    Streamlink                                  Streamlink.Streamlink 5.0.0-1  Tag: vlc     winget
    ```

    In the example above the preferred ID would be `VideoLAN.VLC` ("winget" sources are usually preferred).

## Usage

Once `winget-up` configuration file is ready, the tool can be invoked by executing either of the following scripts:

- `run-winget-up.bat`
- `run-winget-up-as-admin.bat` (to run the updates/installations with Administrator privileges)

### Legal Notice

To allow unattended runs, `winget-up` utility will auto-accept the licenses and usage agreements for the sources and packages configured by the end-user on his behalf.  
Developers of this tool are not responsible for, nor do they grant any licenses to, the third-party sources and packages.
By using this tool you are agreeing that you have the right to use the configured packages and are agreeing with the corresponding terms of use as required by the vendors.

## Advanced usage

To test-run the utility without applying any changes, enable the `-DryRun` flag.

By default **the utility will only update the applications which are already installed** on the device.  
To install missing applications, enable the `-InstallNew` flag.

The optional flags can be enabled by either of the following methods:

- uncomment the relevant lines in the `run-winget-up.bat` launcher file:

```bat
@REM !!! To enable optional flags, uncomment the the desired lines below (by removing the '@REM ' prefix):
@REM set winget_up_flags=%winget_up_flags% -InstallNew
@REM set winget_up_flags=%winget_up_flags% -WingetUpdateFlags \"--include-unknown\"
@REM set winget_up_flags=%winget_up_flags% -DryRun
@REM set winget_up_flags=%winget_up_flags% -HostnameConfig some_hostname
@REM set winget_up_flags=%winget_up_flags% -PackageGroups some_package_group
@REM set winget_up_flags=%winget_up_flags% -ConfigFile path_to_some_config_file
```

- pass the relevant flags directly to the internal `winget-up.ps1` utility via CLI:

```console
Usage: winget-up.ps1 [-ConfigFile <string>] [-HostnameConfig <string>] [-PackageGroups <string[]>] [-InstallNew] [-DryRun] [-WingetUpdateFlags <string[]>]

Options:
  -ConfigFile             Use a custom configuration file (default is `config.json`).
  -HostnameConfig         Use a custom hostname for package group selection.
  -PackageGroups          Use a specific package group (overrides the set configured by the hostname).
  -InstallNew             Install missing packages (by default the update procedure will only affect pre-installed packages).
  -DryRun                 Do not apply any changes to the packages.
  -WingetUpdateFlags      Pass additional flags to `winget upgrade` command.
```

## Contributing

Every contribution is welcome. I'm sure the utility can be improved in many ways.

Feel free to submit a PR :)  
Issues and bugs can be filed in the [GitHub Issue
Tracker](https://github.com/scienmind/winget-up/issues).

---

For more info about the underlying `winget` utility that made this tool possible, see [winget documentation](https://learn.microsoft.com/en-us/windows/package-manager/winget/).
