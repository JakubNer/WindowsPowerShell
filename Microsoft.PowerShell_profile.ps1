$ps_root = Split-Path -Parent $MyInvocation.MyCommand.Path
$portableHome = Split-Path -Parent (Split-Path -Parent $ps_root)

(Get-PSProvider 'FileSystem').Home = $portableHome
Set-Variable -Force HOME $portableHome
$env:HOME = $portableHome

$scripts = Join-Path $ps_root 'Scripts'
$modules = Join-Path $ps_root 'Modules'
$docs = '~\documents'
$src = '~\src'
$kb = '~\Dropbox\kb'
$desktop = '~\desktop'
$wspcs = 'w:\wspc'
$tmp = '~\tmp'
$android = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'Android\sdk'

function mklink { cmd /c mklink $args }

function jj7z { iex "& 'C:\Program Files\7-Zip\7zFM.exe' $args" }

function jjscp { iex "& 'C:\Program Files (x86)\PuTTY\pscp' $args" }

function jjsudo {
    runas /profile /user:Administrator powershell
}

function jjwhich { Get-Command $args }

function grep { $input | Out-String -Stream | Select-String $args }

function jjrefreshenv {
    Set-Location $ps_root
    refreshenv
}

function jjolo {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
        [string[]] $Prompt
    )

    $continueCli = Get-Command cn -ErrorAction SilentlyContinue
    if (-not $continueCli) {
        throw "Continue CLI command 'cn' is not available on PATH. Install or expose the CLI executable first."
    }

    $continueConfig = Join-Path ([Environment]::GetFolderPath('UserProfile')) '.continue\config.yaml'
    if (-not (Test-Path -LiteralPath $continueConfig)) {
        throw "Continue configuration does not exist: $continueConfig"
    }

    $workingDirectory = (Get-Location).ProviderPath
    $sessionLog = Join-Path $workingDirectory '.jjolo.md'
    if (-not (Test-Path -LiteralPath $sessionLog)) {
        @(
            '# Continue.dev jjolo session'
            ''
            "Working directory: ``$workingDirectory``"
            ''
        ) | Set-Content -LiteralPath $sessionLog -Encoding UTF8
    }

    $initialPrompt = ($Prompt -join ' ').Trim()
    $sessionRule = @'
Use .jjolo.md in the current directory as prior conversation context when relevant. For context, read only its first 300 lines (for example, `Get-Content -LiteralPath '.jjolo.md' -TotalCount 300`); do not read or load the entire file.
This is a Windows PowerShell scripting environment. For shell commands, automation, file operations, validation, and short scripts, always use native PowerShell commands and syntax first. Do not use Bash, WSL, Unix utilities, Python, or another scripting language when PowerShell can perform the task. Use another runtime only when PowerShell cannot reasonably do it or the user explicitly requests it, and briefly state why.
Use the interactive UI to show progress, reasoning summaries, and tool activity to the user.
For every user request, update .jjolo.md before giving the final answer. Insert the newest exchange immediately below its document header. Prepend it with a direct file operation that preserves all existing content; do not use an edit tool whose read-before-edit guard would require reading the entire file. Record only these two sections: `### Prompt` containing the user's exact prompt, and `### Final response` containing exactly the final response you will give. Do not record progress, reasoning, tool activity, timestamps, status, exit codes, or other metadata in .jjolo.md.
'@

    Write-Host "Starting interactive Continue session. Conversation log: $sessionLog"
    Write-Host "Continue config: $continueConfig"
    Write-Host 'Expected default model: gpt-5.6-sol'
    Write-Host 'Node heap limit for Continue: 8192 MB'
    Write-Host 'Progress and tool activity will be visible in the Continue UI.'

    $arguments = @(
        '--config', $continueConfig
        '--auto'
        '--beta-status-tool'
        '--rule', $sessionRule
    )
    if ($initialPrompt) {
        $arguments += $initialPrompt
    }

    $previousNodeOptions = $env:NODE_OPTIONS
    try {
        $env:NODE_OPTIONS = if ($previousNodeOptions) {
            "$previousNodeOptions --max-old-space-size=8192"
        }
        else {
            '--max-old-space-size=8192'
        }
        & $continueCli.Source @arguments
    }
    finally {
        $env:NODE_OPTIONS = $previousNodeOptions
    }
}

if (($env:Path -split ';') -notcontains $scripts) {
    $env:Path += ";$scripts"
}

$ErrorActionPreference = 'SilentlyContinue'

Set-ItemProperty 'HKCU::\Software\Microsoft\Windows\CurrentVersion\Explorer' 'DisplayToastAtBottom' '0'
