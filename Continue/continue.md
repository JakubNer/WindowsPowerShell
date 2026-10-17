# Continue.dev setup

This repository source-controls the PowerShell integration and a secret-free Continue configuration template. API keys are deliberately stored as Windows user environment variables, never in Git.

## Prerequisites

- Windows PowerShell 5.1 or PowerShell 7.
- WinGet available to install Node.js when the Continue installer cannot install it through `fnm`.
- A model deployment that supports tool use.
- The Azure credentials listed below when using Azure-hosted models.

## Install Node.js and Continue CLI

The VS Code Continue extension does not necessarily install the standalone `cn` executable. First verify that Node.js and npm are available:

```powershell
node --version
npm --version
```

If they are unavailable, install the Node.js LTS release directly with WinGet:

```powershell
winget install --id OpenJS.NodeJS.LTS --exact `
    --accept-package-agreements `
    --accept-source-agreements
```

If WinGet reports that Node.js is already installed but `node` is unavailable, repair the installation with `--force`:

```powershell
winget install --id OpenJS.NodeJS.LTS --exact --force `
    --accept-package-agreements `
    --accept-source-agreements
```

Close all PowerShell and VS Code windows after Node.js is installed so they do not retain the old `PATH`. Start VS Code again from a new PowerShell window with `code .`, then open a new integrated terminal and verify `node` and `npm` again.

Install the Continue CLI globally through npm:

```powershell
npm install --global @continuedev/cli
```

Verify the CLI:

```powershell
cn --version
cn --help
```

If `node`, `npm`, or `cn` works in Windows PowerShell but not in the VS Code integrated terminal, completely exit every VS Code window and start VS Code again. Opening a new integrated terminal or using **Developer: Reload Window** may not be enough because the VS Code process inherited the old `PATH` when it started.

If `Get-Command cn` still cannot find the CLI after restarting PowerShell and VS Code, troubleshoot `PATH`.

## Restore the Continue configuration

Continue uses this machine-local file:

`C:\Users\<user>\.continue\config.yaml`

Create it from the tracked template without overwriting an existing configuration:

```powershell
$repo = Join-Path $env:USERPROFILE 'OneDrive\src\WindowsPowerShell'
$source = Join-Path $repo 'Continue\config.yaml.example'
$destination = Join-Path $env:USERPROFILE '.continue\config.yaml'
New-Item -ItemType Directory -Path (Split-Path -Parent $destination) -Force | Out-Null
if (-not (Test-Path -LiteralPath $destination)) {
    Copy-Item -LiteralPath $source -Destination $destination
}
notepad $destination
```

Replace `YOUR_AZURE_DEPLOYMENT_NAME` with the deployment used on that machine. Keep secrets referenced through environment variables; do not paste keys into YAML.

## Selecting Sol or Qwen in `jjolo`

The current `%USERPROFILE%\.continue\config.yaml` makes two chat models available:

- `gpt-5.6-sol` — Azure-hosted through the OpenAI-compatible provider.
- `qwen3.6-27b` — local model `qwen/qwen3.6-27b` at `http://localhost:1234/v1`.

A test using the live config on 2026-10-17 selected **`gpt-5.6-sol`**, so Sol is currently the initial active model.

To switch models temporarily inside an interactive `jjolo` session:

1. Start `jjolo`.
2. Enter `/model` at the Continue prompt.
3. Select `qwen3.6-27b` or `gpt-5.6-sol` from the model selector.

The selection applies to that interactive session. The `cn --model` command-line option is not the correct switch for these local YAML entries; it adds a model package from the Continue Hub and expects a hub slug such as `owner/package`.

To change which model is selected initially in future sessions, open the live configuration:

```powershell
notepad "$env:USERPROFILE\.continue\config.yaml"
```

Move the desired model entry to the top of the `models:` list. Put `qwen3.6-27b` first to default to Qwen, or `gpt-5.6-sol` first to default to Sol. Keep both entries if `/model` switching should remain available. Make the desired model the only entry if selection must be enforced rather than merely defaulted.

### Running Qwen locally with LM Studio

The `watermark-remover` Git history identifies **`qwen2.5-coder:32b`** as its former coding/planning model. It does not contain LM Studio installation or server instructions. Treat that model name as historical context: the current Continue template instead targets `qwen/qwen3.6-27b` and the two identifiers are not interchangeable.

LM Studio exposes local models through an OpenAI-compatible API. This machine has the `lms` CLI installed at `%USERPROFILE%\.lmstudio\bin\lms.exe`. Confirm the installation:

```powershell
Get-Command lms
lms --help
```

Install a suitable Qwen model through LM Studio's **Discover** tab, or search/download from the CLI:

```powershell
lms get qwen
lms ls
```

Choose a quantization that fits available RAM and VRAM. A 27B or 32B model can require substantial memory; use a smaller Qwen Coder model if necessary. After downloading, load the model interactively:

```powershell
lms load
```

Alternatively, supply the exact model key shown by `lms ls`. Assigning the configured API identifier while loading avoids a mismatch between LM Studio and Continue:

```powershell
lms load <MODEL_KEY_FROM_LMS_LS> --identifier qwen/qwen3.6-27b
```

Do not request a context length larger than the model and machine can support. If an explicit limit is needed, add `--context-length <TOKENS>` to `lms load` and set Continue's `contextLength` to the same or a smaller value.

Start the local API on loopback port 1234 and inspect its state:

```powershell
lms server start --port 1234 --bind 127.0.0.1
lms server status
lms ps
```

Using `127.0.0.1` keeps the server off the LAN. Stop it when it is not needed with `lms server stop`.

Verify the OpenAI-compatible endpoint and note the returned model `id`:

```powershell
$response = Invoke-RestMethod http://localhost:1234/v1/models
$response.data | Select-Object id, object, owned_by
```

The value of `model:` in `%USERPROFILE%\.continue\config.yaml` must match that returned `id`. Either load with `--identifier qwen/qwen3.6-27b`, as above, or change the Continue entry to the identifier LM Studio actually reports:

```yaml
- name: qwen3.6-27b
  provider: openai
  model: qwen/qwen3.6-27b
  apiBase: http://127.0.0.1:1234/v1
  roles:
    - chat
    - edit
    - apply
    - autocomplete
```

No API key is normally required for a loopback-only LM Studio server. Before selecting Qwen in Continue, both of these commands must succeed:

```powershell
lms ps
Invoke-RestMethod http://127.0.0.1:1234/v1/models
```

If the server responds but Continue fails, check that a chat model—not only an embedding model—is loaded and that the API `id`, port, and `model:` value match exactly. If the connection is refused or times out, start/restart the server. If generation runs out of memory, unload the model with `lms unload`, then load a smaller quantization, reduce context length, or reduce GPU offload.

At the time this documentation was updated, the server on this machine was running on port 1234 but `lms ps` reported **no loaded models**, and `lms ls` showed only an embedding model. Qwen therefore needs to be downloaded and loaded before the Qwen Continue entry can be used.

The line printed by `Microsoft.PowerShell_profile.ps1`—`Expected default model: gpt-5.6-sol`—is informational only. If the default is changed to Qwen, update it to `Expected default model: qwen3.6-27b` so the startup message remains accurate; this text does not control model selection.

To verify the initial model, run a minimal request using the same config:

```powershell
cn --config "$env:USERPROFILE\.continue\config.yaml" -p --silent "Reply with exactly: OK"
```

Continue's normal output does not identify the model. Diagnostic logging can reveal it, but some Continue versions include API keys in `%USERPROFILE%\.continue\logs\cn.log`; do not publish that file, and rotate any key exposed through it.

## Switching `jjolo` to GPT 6 Astra

`jjolo` loads `%USERPROFILE%\.continue\config.yaml`. It does not currently pass a model override to `cn`, so the active model comes from the `models` list in that file.

Before changing the configuration, deploy GPT 6 Astra in the Azure resource identified by `AZURE_FOUNDRY_ENDPOINT`. Record the deployment/API model identifier shown by Azure. Do not assume that the marketing or portal display name `GPT 6 Astra` is also the API identifier.

Open the live configuration:

```powershell
notepad "$env:USERPROFILE\.continue\config.yaml"
```

Change the existing Azure model entry as follows, substituting the exact Azure deployment/API identifier for `YOUR_GPT_6_ASTRA_DEPLOYMENT_ID`:

```yaml
models:
  - name: gpt-6-astra
    provider: openai
    model: YOUR_GPT_6_ASTRA_DEPLOYMENT_ID
    apiBase: ${{ secrets.AZURE_FOUNDRY_ENDPOINT }}
    apiKey: ${{ secrets.AZURE_FOUNDRY_KEY }}
    apiType: azure
    apiVersion: 2024-10-01-preview
    roles:
      - chat
      - edit
      - apply
      - autocomplete
    defaultCompletionOptions:
      contextLength: YOUR_DEPLOYMENT_CONTEXT_LIMIT
      maxTokens: YOUR_DEPLOYMENT_OUTPUT_LIMIT
```

Use limits supported by the actual deployment. Add a `reasoning` option only if the deployed model and current Continue version support it. To guarantee that `jjolo` selects Astra, make it the only entry in `models`. If other models remain available, put Astra first, but note that ordering is less explicit than using a dedicated single-model configuration.

The wrapper also prints an informational expected-model label. In `Microsoft.PowerShell_profile.ps1`, change:

```powershell
Write-Host 'Expected default model: gpt-5.6-sol'
```

to:

```powershell
Write-Host 'Expected default model: gpt-6-astra'
```

That message does not select the model; it only reports your intended default. Reload the profile and run a minimal test:

```powershell
. $PROFILE
cn --config "$env:USERPROFILE\.continue\config.yaml" -p --silent "Reply with exactly: OK"
jjolo
```

Run `jjolo` with `cn --verbose` temporarily, or inspect a newly generated Continue diagnostic entry, if you need to confirm the API model identifier. Never publish the diagnostic log: some Continue versions write API keys to it.

## Azure user environment variables

The current setup expects these variable names:

- `AZURE_OPENAI_ENDPOINT`
- `AZURE_OPENAI_KEY`
- `AZURE_FOUNDRY_ENDPOINT`
- `AZURE_FOUNDRY_KEY`

Set them for the current Windows user. Keep the actual values in a password manager:

```powershell
[Environment]::SetEnvironmentVariable('AZURE_OPENAI_ENDPOINT', 'https://YOUR-RESOURCE.openai.azure.com', 'User')
$secureKey = Read-Host 'AZURE_OPENAI_KEY' -AsSecureString
$key = [System.Net.NetworkCredential]::new('', $secureKey).Password
[Environment]::SetEnvironmentVariable('AZURE_OPENAI_KEY', $key, 'User')
Remove-Variable key, secureKey

[Environment]::SetEnvironmentVariable('AZURE_FOUNDRY_ENDPOINT', 'https://YOUR-RESOURCE.services.ai.azure.com', 'User')
$secureKey = Read-Host 'AZURE_FOUNDRY_KEY' -AsSecureString
$key = [System.Net.NetworkCredential]::new('', $secureKey).Password
[Environment]::SetEnvironmentVariable('AZURE_FOUNDRY_KEY', $key, 'User')
Remove-Variable key, secureKey
```

Open a new terminal after setting user environment variables. Check only their presence, not their values:

```powershell
'AZURE_OPENAI_ENDPOINT','AZURE_OPENAI_KEY','AZURE_FOUNDRY_ENDPOINT','AZURE_FOUNDRY_KEY' |
    ForEach-Object { [pscustomobject]@{ Name = $_; Present = [bool][Environment]::GetEnvironmentVariable($_, 'User') } }
```

## Interactive `jjolo` command

The source-controlled profile provides an interactive wrapper around the Continue CLI. Start with or without an initial prompt:

```powershell
jjolo "Fix the project"
jjolo
```

It starts one interactive Continue session with the equivalent configuration and permissions:

```powershell
cn --config "$env:USERPROFILE\.continue\config.yaml" --auto --beta-status-tool
```

Continue's interactive UI displays progress and tool activity. Press **Ctrl+C** to cancel or exit according to the CLI's current controls. The wrapper uses normal foreground execution—no background process is left running.

The wrapper creates `jjolo.md` in the directory where it was invoked when that file does not exist. A session rule tells Continue to insert each prompt and final response immediately below the document header. Progress, tool activity, timestamps, statuses, and exit codes should not be written to that log. The log is supplied to later turns as prior conversation context.

Run `jjolo` from the repository that Continue should work on. File references can be included in prompts:

```powershell
Set-Location C:\path\to\project
jjolo "Read @src/app.ts and fix the reported error"
```

`--auto` permits tool execution and file modification without interactive approval. Use it only in trusted repositories and review the resulting diff. Add `jjolo.md` to a project's `.gitignore` if the session log should remain local.

## New-machine checklist

1. Sync this repository to `OneDrive\src\WindowsPowerShell`.
2. Complete the README **Quick Start** to register `Profile.ps1`.
3. Install Node.js and the Continue CLI as described above, then verify that `node`, `npm`, and `cn` are available on `PATH`.
4. Copy `Continue/config.yaml.example` to `%USERPROFILE%\.continue\config.yaml` and set the deployment name.
5. Restore the four Azure user environment variables from a password manager.
6. Open a new terminal and run `Get-Command jjolo`.
7. Test with `jjolo "Inspect this repository and report its Git status without changing files"`.
