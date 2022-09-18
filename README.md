# winget-up

Automate Software Updates and Installations on Windows OS

---

TODO: Add user-friendly guidelines for wrappers, configuration setup

---

Supported CLI flags:

```console
winget-up.ps1 [-ConfigFile <string>] [-HostnameConfig <string>] [-PackageGroups <string[]>] [-InstallNew] [-DryRun] [-WingetUpdateFlags <string[]>]
```

Find an application ID for usage in configuration file:

```console
winget search <application_name>
```

Official `winget` documentation:
[Windows Package Manager](https://learn.microsoft.com/en-us/windows/package-manager/winget/)
