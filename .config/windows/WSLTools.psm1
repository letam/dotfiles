# WSLTools.psm1 - Bridging the gap between PowerShell and WSL

$LinuxCommands = @(
    "ls", "grep", "awk", "sed", "curl", "wget", "tar", 
    "gzip", "ssh", "scp", "chmod", "chown", "df", "du", 
    "cat", "tail", "head", "less", "touch", "mkdir", "rm"
)

foreach ($cmd in $LinuxCommands) {
    # Check if the command already exists in Windows to avoid conflicts
    # If it exists (like 'curl' or 'ssh'), we prefix it or keep it native.
    # Here, we create a function so it handles arguments correctly.
    
    New-Item -Path "function:wsl-$cmd" -Value @"
        wsl $cmd `$args
"@ | Out-Null

    # Optional: Create direct aliases for commands that don't conflict
    # Warning: PowerShell has its own 'ls' (alias for Get-ChildItem). 
    # This override will make 'ls' act like Linux ls.
    Set-Alias -Name "$cmd" -Value "wsl-$cmd" -Scope Global -Force
}

# Custom helper: Quick path translation
function wsl-path {
    param([string]$path)
    wsl wslpath -u $path
}

Write-Host "WSL Aliases Loaded! (ls, grep, cat, etc. now route through WSL)" -ForegroundColor Cyan
