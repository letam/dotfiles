# PowerShell conversion of the provided Zsh git helpers
# Intended for use in $PROFILE or dot-sourced script

# -----------------------------
# Git version detection
# -----------------------------
$GitVersion = $null
try {
    $GitVersion = (git version).Split(' ')[2]
} catch {}

function Test-GitVersionAtLeast([string]$Min) {
    if (-not $GitVersion) { return $false }
    return ([version]$GitVersion -ge [version]$Min)
}

# -----------------------------
# Branch helpers
# -----------------------------
function git_develop_branch {
    git rev-parse --git-dir *> $null 2>&1 || return
    foreach ($b in 'dev','devel','develop','development') {
        if (git show-ref -q --verify "refs/heads/$b") { return $b }
    }
    'develop'
}

function git_main_branch {
    git rev-parse --git-dir *> $null 2>&1 || return

    $refs = @()
    foreach ($scope in 'heads','remotes/origin','remotes/upstream') {
        foreach ($name in 'main','trunk','mainline','default','stable','master') {
            $refs += "refs/$scope/$name"
        }
    }

    foreach ($ref in $refs) {
        if (git show-ref -q --verify $ref) {
            return ($ref.Split('/')[-1])
        }
    }

    foreach ($remote in 'origin','upstream') {
        try {
            $r = git rev-parse --abbrev-ref "$remote/HEAD" 2>$null
            if ($r -like "$remote/*") { return $r.Substring($remote.Length+1) }
        } catch {}
    }

    'master'
}

function git_current_branch {
    git rev-parse --abbrev-ref HEAD
}

# -----------------------------
# Functions
# -----------------------------
function grename($old,$new) {
    if (-not $old -or -not $new) {
        Write-Host "Usage: grename old_branch new_branch"
        return
    }
    git branch -m $old $new
    if (git push origin :$old) {
        git push --set-upstream origin $new
    }
}

function gunwipall {
    $commit = git log --grep='--wip--' --invert-grep --max-count=1 --format=format:%H
    if ($commit -and $commit -ne (git rev-parse HEAD)) {
        git reset $commit
    }
}

function work_in_progress {
    if (git log -n 1 2>$null | Select-String '--wip--') {
        'WIP!!'
    }
}

function gbda {
    $main = git_main_branch
    $dev  = git_develop_branch
    git branch --no-color --merged |
        Where-Object { $_ -notmatch "^[*+]" } |
        Where-Object { $_.Trim() -notin @($main,$dev) } |
        ForEach-Object { git branch -d $_.Trim() }
}

function gdnolock {
    git diff @args ':(exclude)package-lock.json' ':(exclude)*.lock'
}

function ggu($branch) {
    if (-not $branch) { $branch = git_current_branch }
    git pull --rebase origin $branch
}

function ggl($branch) {
    if (-not $branch) { $branch = git_current_branch }
    git pull origin $branch
}

function ggf($branch) {
    if (-not $branch) { $branch = git_current_branch }
    git push --force origin $branch
}

function ggfl($branch) {
    if (-not $branch) { $branch = git_current_branch }
    git push --force-with-lease origin $branch
}

function ggp($branch) {
    if (-not $branch) { $branch = git_current_branch }
    git push origin $branch
}

# -----------------------------
# Aliases
# -----------------------------
Set-Alias g git
Set-Alias ga 'git add'
Set-Alias gaa 'git add --all'
Set-Alias gco 'git checkout'
Set-Alias gcb 'git checkout -b'
Set-Alias gcm { git checkout (git_main_branch) }
Set-Alias gcd { git checkout (git_develop_branch) }
Set-Alias gb 'git branch'
Set-Alias gba 'git branch --all'
Set-Alias gbd 'git branch -d'
Set-Alias gbl 'git blame -w'
Set-Alias gl 'git pull'
Set-Alias gp 'git push'
Set-Alias gpf 'git push --force'
Set-Alias gst 'git status'
Set-Alias gss 'git status --short'
Set-Alias gsb 'git status --short --branch'
Set-Alias gd 'git diff'
Set-Alias gdca 'git diff --cached'
Set-Alias gds 'git diff --staged'
Set-Alias gcl 'git clone --recurse-submodules'
Set-Alias gclean 'git clean -id'
Set-Alias grb 'git rebase'
Set-Alias grba 'git rebase --abort'
Set-Alias grbc 'git rebase --continue'
Set-Alias grbi 'git rebase -i'
Set-Alias grbm { git rebase (git_main_branch) }
Set-Alias grbd { git rebase (git_develop_branch) }
Set-Alias gm 'git merge'
Set-Alias gma 'git merge --abort'
Set-Alias gms 'git merge --squash'
Set-Alias gsw 'git switch'
Set-Alias gswm { git switch (git_main_branch) }
Set-Alias gswd { git switch (git_develop_branch) }

if (Test-GitVersionAtLeast '2.30') {
    Set-Alias gpfwl 'git push --force-with-lease --force-if-includes'
} else {
    Set-Alias gpfwl 'git push --force-with-lease'
}

# -----------------------------
# Cleanup
# -----------------------------
Remove-Variable GitVersion -ErrorAction SilentlyContinue
