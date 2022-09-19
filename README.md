# winget-up

The `winget-up` utility provides a single-click solution to keep sets of software applications up to date across devices (based on native [Windows Package Manager Client](https://github.com/microsoft/winget-cli)).

The utility allows to group applications into "package groups" and define which computers shall update/install certain software packages.

## Use case example

Let's say a user manages few Windows devices:

- "Media PC" (hostname: `my_editing_pc`) - used for media consumption and creation, and has a set of editing and viewing software applications installed
- "Desktop Workstation" (hostname: `my_desktop_workstation`) - main workstation, mixed use
- "Portable Laptop" (hostname: `my_thinkpad`) - used to perform only basic tasks on the go

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
    "host_config": {
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
        },
        "my_thinkpad": {
            "package_groups": [
                "basic_apps",
                "communication_apps",
                "dev_tools"
            ]
        }
    },
    "package_group_definition": {
        "basic_apps": [
            "7zip.7zip",
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
The `winget-up` folder can then be shared/synchronized across all the devices.

When running the utility the current device's hostname will be detected automatically, and the all the applications in the package groups belonging to this hostname according to the configuration will be updated.

---

## Configuration

Copy or rename the provided `config.json.example` file to `config.json` and replace it's contents with the relevant values (see the aforementioned use case example for guidance).

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

## Advanced usage

By default the utility will only update the applications if they are already preinstalled on the device.  
To install missing applications, enable the `-InstallNew` flag.

To test-run the utility without applying any changes, enable the `-DryRun` flag

The optional flags can be enabled either by uncommenting the relevant lines in the `*.bat` launcher files or by passing the flags directly to the internal `winget-up.ps1` utility via CLI:

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

---

For more info about the underlying `winget` utility that made this tool possible, see [winget documentation](https://learn.microsoft.com/en-us/windows/package-manager/winget/)
