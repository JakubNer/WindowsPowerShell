# Windows PowerShell profile

## Quick Start

1. Clone or sync this repository. The examples assume:

   `C:\Users\<user>\OneDrive\src\WindowsPowerShell`

2. Open Windows PowerShell and register the repository profile for every host:

   ```powershell
   $repo = Join-Path $env:USERPROFILE 'OneDrive\src\WindowsPowerShell'
   New-Item -ItemType Directory -Path (Split-Path -Parent $PROFILE.CurrentUserAllHosts) -Force | Out-Null
   ". '$repo\Profile.ps1'" | Set-Content -LiteralPath $PROFILE.CurrentUserAllHosts -Encoding UTF8
   . $PROFILE.CurrentUserAllHosts
   ```

3. Confirm that the tracked profile and commands loaded:

   ```powershell
   Get-Command jjolo
   $global:WindowsPowerShellProfileRepositoryLoaded
   ```

4. Follow [Continue/continue.md](Continue/continue.md) to restore Continue CLI configuration and Azure environment variables.

The small file at `$PROFILE.CurrentUserAllHosts` is machine-local. It sources the tracked `Profile.ps1` from this repository. `Profile.ps1` then loads `Microsoft.PowerShell_profile.ps1`, where shared aliases, functions, paths, and environment setup live.

The tracked loader has a guard, so it is safe if both an all-hosts and host-specific PowerShell profile source it.

## Continue.dev

See [Continue/continue.md](Continue/continue.md) for the `jjolo` command, headless Continue CLI usage, configuration restoration, and required Azure variable names.

## Windows startup scripts

On Windows 10 or 11, press **Win+R** and run `shell:startup` to open the Startup folder. Add shortcuts or copies of `startup.bat` and `startup.ps1` there if their legacy drive setup is required, and review their paths before use on a new machine.

## Repository layout

- `Profile.ps1`: portable loader referenced by the machine-local PowerShell profile.
- `Microsoft.PowerShell_profile.ps1`: shared interactive PowerShell configuration.
- `Scripts/`: commands added to `PATH` by the shared profile.
- `Modules/`: source-controlled PowerShell modules.
- `Continue/continue.md`: Continue.dev and Azure restoration guide.
- `Continue/config.yaml.example`: secret-free Continue configuration template.
