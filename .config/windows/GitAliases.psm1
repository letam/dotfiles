# Git Aliases PowerShell Module
# Converted from oh-my-zsh git plugin

# Git version checking
$script:GitVersion = $null
try {
    $gitVersionOutput = git version 2>$null
    if ($gitVersionOutput -match 'git version (\d+\.\d+\.\d+)') {
        $script:GitVersion = [version]$matches[1]
    }
} catch {
    $script:GitVersion = [version]"0.0.0"
}

#
# Helper Functions
#

function Get-GitCurrentBranch {
    $branch = git symbolic-ref --quiet --short HEAD 2>$null
    if ($branch) {
        return $branch
    }
    return $null
}

function Get-GitDevelopBranch {
    if (!(git rev-parse --git-dir 2>$null)) { return }

    $branches = @('dev', 'devel', 'develop', 'development')
    foreach ($branch in $branches) {
        if (git show-ref --quiet --verify "refs/heads/$branch" 2>$null) {
            return $branch
        }
    }

    return 'develop'
}

function Get-GitMainBranch {
    if (!(git rev-parse --git-dir 2>$null)) { return }

    $refs = @(
        'refs/heads/main', 'refs/heads/trunk', 'refs/heads/mainline',
        'refs/heads/default', 'refs/heads/stable', 'refs/heads/master',
        'refs/remotes/origin/main', 'refs/remotes/origin/trunk', 'refs/remotes/origin/mainline',
        'refs/remotes/origin/default', 'refs/remotes/origin/stable', 'refs/remotes/origin/master',
        'refs/remotes/upstream/main', 'refs/remotes/upstream/trunk', 'refs/remotes/upstream/mainline',
        'refs/remotes/upstream/default', 'refs/remotes/upstream/stable', 'refs/remotes/upstream/master'
    )

    foreach ($ref in $refs) {
        if (git show-ref --quiet --verify $ref 2>$null) {
            return Split-Path -Leaf $ref
        }
    }

    # Fallback: try to get the default branch from remote HEAD
    foreach ($remote in @('origin', 'upstream')) {
        $headRef = git rev-parse --abbrev-ref "$remote/HEAD" 2>$null
        if ($headRef -and $headRef -match "^$remote/(.+)$") {
            return $matches[1]
        }
    }

    return 'master'
}

function Rename-GitBranch {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$OldBranch,

        [Parameter(Mandatory=$true, Position=1)]
        [string]$NewBranch
    )

    # Rename branch locally
    git branch -m $OldBranch $NewBranch

    # Rename branch in origin remote
    if (git push origin ":$OldBranch" 2>$null) {
        git push --set-upstream origin $NewBranch
    }
}

#
# WIP Functions
#

function Invoke-GitUnwipAll {
    $commit = git log --grep='--wip--' --invert-grep --max-count=1 --format=format:%H 2>$null

    if ($commit) {
        $head = git rev-parse HEAD 2>$null
        if ($commit -ne $head) {
            git reset $commit
        }
    }
}

function Get-GitWorkInProgress {
    $logOutput = git -c log.showSignature=false log -n 1 2>$null
    if ($logOutput -match '--wip--') {
        Write-Host "WIP!!" -ForegroundColor Yellow
    }
}

#
# Complex Functions
#

function Invoke-GitPullAndPush {
    param([string[]]$Arguments)

    if ($Arguments.Count -eq 0) {
        Invoke-Expression "ggl"
        if ($LASTEXITCODE -eq 0) {
            Invoke-Expression "ggp"
        }
    } else {
        $argString = $Arguments -join ' '
        Invoke-Expression "ggl $argString"
        if ($LASTEXITCODE -eq 0) {
            Invoke-Expression "ggp $argString"
        }
    }
}

function Remove-GitBranchesDeletedAtOrigin {
    $defaultBranch = Get-GitMainBranch
    if (!$defaultBranch) {
        $defaultBranch = Get-GitDevelopBranch
    }

    git branch --no-color --merged |
        Where-Object { $_ -notmatch '^\*' -and $_ -notmatch "^\s*($defaultBranch|$(Get-GitDevelopBranch))\s*$" } |
        ForEach-Object { $_.Trim() } |
        ForEach-Object { git branch --delete $_ 2>$null }
}

function Remove-GitBranchesSquashMerged {
    $defaultBranch = Get-GitMainBranch
    if (!$defaultBranch) {
        $defaultBranch = Get-GitDevelopBranch
    }

    git for-each-ref refs/heads/ --format='%(refname:short)' | ForEach-Object {
        $branch = $_
        $mergeBase = git merge-base $defaultBranch $branch 2>$null
        if ($mergeBase) {
            $tree = git rev-parse "$branch^{tree}" 2>$null
            if ($tree) {
                $danglingCommit = git commit-tree $tree -p $mergeBase -m "_" 2>$null
                if ($danglingCommit) {
                    $cherry = git cherry $defaultBranch $danglingCommit 2>$null
                    if ($cherry -match '^-') {
                        git branch -D $branch
                    }
                }
            }
        }
    }
}

function Invoke-GitCloneAndChangeDir {
    param([string[]]$Arguments)

    # Clone repository
    git clone --recurse-submodules $Arguments

    if ($LASTEXITCODE -eq 0) {
        # Get the last argument or parse repo name
        $lastArg = $Arguments[-1]

        if (Test-Path $lastArg -PathType Container) {
            Set-Location $lastArg
        } else {
            # Parse repo name from URL
            $repoName = Split-Path -Leaf $lastArg
            $repoName = $repoName -replace '\.git$', ''
            if (Test-Path $repoName -PathType Container) {
                Set-Location $repoName
            }
        }
    }
}

function Get-GitDiffView {
    param([string[]]$Arguments)
    git diff -w $Arguments
}

function Get-GitDiffNoLock {
    param([string[]]$Arguments)
    $excludes = @(':(exclude)package-lock.json', ':(exclude)*.lock')
    git diff $Arguments $excludes
}

function Show-GitLogPrettily {
    param([string]$Format)
    if ($Format) {
        git log --pretty=$Format
    }
}

function Invoke-GitPullRebaseOrigin {
    param([string]$Branch)

    if (!$Branch) {
        $Branch = Get-GitCurrentBranch
    }

    if ($Branch) {
        git pull --rebase origin $Branch
    }
}

function Invoke-GitPullOrigin {
    param([string[]]$Arguments)

    if ($Arguments.Count -eq 0) {
        $branch = Get-GitCurrentBranch
        if ($branch) {
            git pull origin $branch
        }
    } elseif ($Arguments.Count -eq 1) {
        git pull origin $Arguments[0]
    } else {
        git pull origin $Arguments
    }
}

function Invoke-GitPushForceOrigin {
    param([string]$Branch)

    if (!$Branch) {
        $Branch = Get-GitCurrentBranch
    }

    if ($Branch) {
        git push --force origin $Branch
    }
}

function Invoke-GitPushForceLease {
    param([string]$Branch)

    if (!$Branch) {
        $Branch = Get-GitCurrentBranch
    }

    if ($Branch) {
        git push --force-with-lease origin $Branch
    }
}

function Invoke-GitPushOrigin {
    param([string[]]$Arguments)

    if ($Arguments.Count -eq 0) {
        $branch = Get-GitCurrentBranch
        if ($branch) {
            git push origin $branch
        }
    } elseif ($Arguments.Count -eq 1) {
        git push origin $Arguments[0]
    } else {
        git push origin $Arguments
    }
}

#
# Aliases
#

# Navigation
Set-Alias -Name grt -Value Set-LocationToGitRoot -Scope Global
function Set-LocationToGitRoot {
    $root = git rev-parse --show-toplevel 2>$null
    if ($root) {
        Set-Location $root
    }
}

# Basic Git Commands
Set-Alias -Name g -Value git -Scope Global

# Git Add
Set-Alias -Name ga -Value git-add -Scope Global
function git-add { git add $args }

Set-Alias -Name gaa -Value git-add-all -Scope Global
function git-add-all { git add --all }

Set-Alias -Name gapa -Value git-add-patch -Scope Global
function git-add-patch { git add --patch $args }

Set-Alias -Name gau -Value git-add-update -Scope Global
function git-add-update { git add --update }

Set-Alias -Name gav -Value git-add-verbose -Scope Global
function git-add-verbose { git add --verbose $args }

Set-Alias -Name gwip -Value git-wip -Scope Global
function git-wip {
    git add -A
    git ls-files --deleted | ForEach-Object { git rm $_ 2>$null }
    git commit --no-verify --no-gpg-sign --message "--wip-- [skip ci]"
}

# Git AM
Set-Alias -Name gam -Value git-am -Scope Global
function git-am { git am $args }

Set-Alias -Name gama -Value git-am-abort -Scope Global
function git-am-abort { git am --abort }

Set-Alias -Name gamc -Value git-am-continue -Scope Global
function git-am-continue { git am --continue }

Set-Alias -Name gamscp -Value git-am-show-current-patch -Scope Global
function git-am-show-current-patch { git am --show-current-patch }

Set-Alias -Name gams -Value git-am-skip -Scope Global
function git-am-skip { git am --skip }

# Git Apply
Set-Alias -Name gap -Value git-apply -Scope Global
function git-apply { git apply $args }

Set-Alias -Name gapt -Value git-apply-3way -Scope Global
function git-apply-3way { git apply --3way $args }

# Git Bisect
Set-Alias -Name gbs -Value git-bisect -Scope Global
function git-bisect { git bisect $args }

Set-Alias -Name gbsb -Value git-bisect-bad -Scope Global
function git-bisect-bad { git bisect bad }

Set-Alias -Name gbsg -Value git-bisect-good -Scope Global
function git-bisect-good { git bisect good }

Set-Alias -Name gbsn -Value git-bisect-new -Scope Global
function git-bisect-new { git bisect new }

Set-Alias -Name gbso -Value git-bisect-old -Scope Global
function git-bisect-old { git bisect old }

Set-Alias -Name gbsr -Value git-bisect-reset -Scope Global
function git-bisect-reset { git bisect reset }

Set-Alias -Name gbss -Value git-bisect-start -Scope Global
function git-bisect-start { git bisect start $args }

# Git Blame
Set-Alias -Name gbl -Value git-blame -Scope Global
function git-blame { git blame -w $args }

# Git Branch
Set-Alias -Name gb -Value git-branch -Scope Global
function git-branch { git branch $args }

Set-Alias -Name gba -Value git-branch-all -Scope Global
function git-branch-all { git branch --all }

Set-Alias -Name gbd -Value git-branch-delete -Scope Global
function git-branch-delete { git branch --delete $args }

Set-Alias -Name gbD -Value git-branch-delete-force -Scope Global
function git-branch-delete-force { git branch --delete --force $args }

Set-Alias -Name gbda -Value Remove-GitBranchesDeletedAtOrigin -Scope Global
Set-Alias -Name gbds -Value Remove-GitBranchesSquashMerged -Scope Global

Set-Alias -Name gbgd -Value git-branch-gone-delete -Scope Global
function git-branch-gone-delete {
    git branch --no-color -vv |
        Select-String ': gone\]' |
        ForEach-Object { ($_ -replace '^\s+', '') -split '\s+' | Select-Object -First 1 } |
        ForEach-Object { git branch -d $_ }
}

Set-Alias -Name gbgD -Value git-branch-gone-delete-force -Scope Global
function git-branch-gone-delete-force {
    git branch --no-color -vv |
        Select-String ': gone\]' |
        ForEach-Object { ($_ -replace '^\s+', '') -split '\s+' | Select-Object -First 1 } |
        ForEach-Object { git branch -D $_ }
}

Set-Alias -Name gbm -Value git-branch-move -Scope Global
function git-branch-move { git branch --move $args }

Set-Alias -Name gbnm -Value git-branch-no-merged -Scope Global
function git-branch-no-merged { git branch --no-merged }

Set-Alias -Name gbr -Value git-branch-remote -Scope Global
function git-branch-remote { git branch --remote }

Set-Alias -Name ggsup -Value git-branch-set-upstream -Scope Global
function git-branch-set-upstream {
    $branch = Get-GitCurrentBranch
    if ($branch) {
        git branch --set-upstream-to=origin/$branch
    }
}

Set-Alias -Name gbg -Value git-branch-gone -Scope Global
function git-branch-gone {
    git branch -vv | Select-String ': gone\]'
}

# Git Checkout
Set-Alias -Name gco -Value git-checkout -Scope Global
function git-checkout { git checkout $args }

Set-Alias -Name gcor -Value git-checkout-recurse -Scope Global
function git-checkout-recurse { git checkout --recurse-submodules $args }

Set-Alias -Name gcb -Value git-checkout-branch -Scope Global
function git-checkout-branch { git checkout -b $args }

Set-Alias -Name gcB -Value git-checkout-branch-force -Scope Global
function git-checkout-branch-force { git checkout -B $args }

Set-Alias -Name gcd -Value git-checkout-develop -Scope Global
function git-checkout-develop {
    $branch = Get-GitDevelopBranch
    if ($branch) { git checkout $branch }
}

Set-Alias -Name gcm -Value git-checkout-main -Scope Global
function git-checkout-main {
    $branch = Get-GitMainBranch
    if ($branch) { git checkout $branch }
}

# Git Cherry-pick
Set-Alias -Name gcp -Value git-cherry-pick -Scope Global
function git-cherry-pick { git cherry-pick $args }

Set-Alias -Name gcpa -Value git-cherry-pick-abort -Scope Global
function git-cherry-pick-abort { git cherry-pick --abort }

Set-Alias -Name gcpc -Value git-cherry-pick-continue -Scope Global
function git-cherry-pick-continue { git cherry-pick --continue }

# Git Clean
Set-Alias -Name gclean -Value git-clean -Scope Global
function git-clean { git clean --interactive -d }

# Git Clone
Set-Alias -Name gcl -Value git-clone -Scope Global
function git-clone { git clone --recurse-submodules $args }

Set-Alias -Name gclf -Value git-clone-filter -Scope Global
function git-clone-filter { git clone --recursive --shallow-submodules --filter=blob:none --also-filter-submodules $args }

Set-Alias -Name gccd -Value Invoke-GitCloneAndChangeDir -Scope Global

# Git Commit
Set-Alias -Name gcam -Value git-commit-all-message -Scope Global
function git-commit-all-message { git commit --all --message $args }

Set-Alias -Name gcas -Value git-commit-all-signoff -Scope Global
function git-commit-all-signoff { git commit --all --signoff }

Set-Alias -Name gcasm -Value git-commit-all-signoff-message -Scope Global
function git-commit-all-signoff-message { git commit --all --signoff --message $args }

Set-Alias -Name gcs -Value git-commit-gpg-sign -Scope Global
function git-commit-gpg-sign { git commit --gpg-sign $args }

Set-Alias -Name gcss -Value git-commit-gpg-sign-signoff -Scope Global
function git-commit-gpg-sign-signoff { git commit --gpg-sign --signoff $args }

Set-Alias -Name gcssm -Value git-commit-gpg-sign-signoff-message -Scope Global
function git-commit-gpg-sign-signoff-message { git commit --gpg-sign --signoff --message $args }

Set-Alias -Name gcmsg -Value git-commit-message -Scope Global
function git-commit-message { git commit --message $args }

Set-Alias -Name gcsm -Value git-commit-signoff-message -Scope Global
function git-commit-signoff-message { git commit --signoff --message $args }

Set-Alias -Name gc -Value git-commit-verbose -Scope Global
function git-commit-verbose { git commit --verbose $args }

Set-Alias -Name gca -Value git-commit-verbose-all -Scope Global
function git-commit-verbose-all { git commit --verbose --all }

function git-commit-verbose-all-amend { git commit --verbose --all --amend }
Set-Alias -Name 'gca!' -Value git-commit-verbose-all-amend -Scope Global

function git-commit-verbose-all-no-edit-amend { git commit --verbose --all --no-edit --amend }
Set-Alias -Name 'gcan!' -Value git-commit-verbose-all-no-edit-amend -Scope Global

function git-commit-verbose-all-signoff-no-edit-amend { git commit --verbose --all --signoff --no-edit --amend }
Set-Alias -Name 'gcans!' -Value git-commit-verbose-all-signoff-no-edit-amend -Scope Global

function git-commit-verbose-all-date-now-no-edit-amend { git commit --verbose --all --date=now --no-edit --amend }
Set-Alias -Name 'gcann!' -Value git-commit-verbose-all-date-now-no-edit-amend -Scope Global

function git-commit-verbose-amend { git commit --verbose --amend }
Set-Alias -Name 'gc!' -Value git-commit-verbose-amend -Scope Global

Set-Alias -Name gcn -Value git-commit-verbose-no-edit -Scope Global
function git-commit-verbose-no-edit { git commit --verbose --no-edit $args }

function git-commit-verbose-no-edit-amend { git commit --verbose --no-edit --amend }
Set-Alias -Name 'gcn!' -Value git-commit-verbose-no-edit-amend -Scope Global

# Git Config
Set-Alias -Name gcf -Value git-config-list -Scope Global
function git-config-list { git config --list }

Set-Alias -Name gcfu -Value git-commit-fixup -Scope Global
function git-commit-fixup { git commit --fixup $args }

# Git Describe
Set-Alias -Name gdct -Value git-describe-tags -Scope Global
function git-describe-tags {
    $tag = git rev-list --tags --max-count=1 2>$null
    if ($tag) {
        git describe --tags $tag
    }
}

# Git Diff
Set-Alias -Name gd -Value git-diff -Scope Global
function git-diff { git diff $args }

Set-Alias -Name gdca -Value git-diff-cached -Scope Global
function git-diff-cached { git diff --cached $args }

Set-Alias -Name gdcw -Value git-diff-cached-word -Scope Global
function git-diff-cached-word { git diff --cached --word-diff $args }

Set-Alias -Name gds -Value git-diff-staged -Scope Global
function git-diff-staged { git diff --staged $args }

Set-Alias -Name gdw -Value git-diff-word -Scope Global
function git-diff-word { git diff --word-diff $args }

Set-Alias -Name gdv -Value Get-GitDiffView -Scope Global

Set-Alias -Name gdup -Value git-diff-upstream -Scope Global
function git-diff-upstream { git diff '@{upstream}' $args }

Set-Alias -Name gdnolock -Value Get-GitDiffNoLock -Scope Global

Set-Alias -Name gdt -Value git-diff-tree -Scope Global
function git-diff-tree { git diff-tree --no-commit-id --name-only -r $args }

# Git Fetch
Set-Alias -Name gf -Value git-fetch -Scope Global
function git-fetch { git fetch $args }

if ($script:GitVersion -ge [version]"2.8") {
    Set-Alias -Name gfa -Value git-fetch-all-prune-jobs -Scope Global
    function git-fetch-all-prune-jobs { git fetch --all --tags --prune --jobs=10 }
} else {
    Set-Alias -Name gfa -Value git-fetch-all-prune -Scope Global
    function git-fetch-all-prune { git fetch --all --tags --prune }
}

Set-Alias -Name gfo -Value git-fetch-origin -Scope Global
function git-fetch-origin { git fetch origin }

# Git GUI
Set-Alias -Name gg -Value git-gui -Scope Global
function git-gui { git gui citool }

Set-Alias -Name gga -Value git-gui-amend -Scope Global
function git-gui-amend { git gui citool --amend }

# Git Help
Set-Alias -Name ghh -Value git-help -Scope Global
function git-help { git help $args }

# Git Log
Set-Alias -Name glgg -Value git-log-graph -Scope Global
function git-log-graph { git log --graph }

Set-Alias -Name glgga -Value git-log-graph-all -Scope Global
function git-log-graph-all { git log --graph --decorate --all }

Set-Alias -Name glgm -Value git-log-graph-max -Scope Global
function git-log-graph-max { git log --graph --max-count=10 }

Set-Alias -Name glods -Value git-log-oneline-decorate-short -Scope Global
function git-log-oneline-decorate-short { git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset" --date=short }

Set-Alias -Name glod -Value git-log-oneline-decorate -Scope Global
function git-log-oneline-decorate { git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset" }

Set-Alias -Name glola -Value git-log-oneline-all -Scope Global
function git-log-oneline-all { git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" --all }

Set-Alias -Name glols -Value git-log-oneline-stat -Scope Global
function git-log-oneline-stat { git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" --stat }

Set-Alias -Name glol -Value git-log-oneline -Scope Global
function git-log-oneline { git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" }

Set-Alias -Name glo -Value git-log-oneline-short -Scope Global
function git-log-oneline-short { git log --oneline --decorate }

Set-Alias -Name glog -Value git-log-graph-short -Scope Global
function git-log-graph-short { git log --oneline --decorate --graph }

Set-Alias -Name gloga -Value git-log-graph-all-short -Scope Global
function git-log-graph-all-short { git log --oneline --decorate --graph --all }

Set-Alias -Name glp -Value Show-GitLogPrettily -Scope Global

Set-Alias -Name glg -Value git-log-stat -Scope Global
function git-log-stat { git log --stat }

Set-Alias -Name glgp -Value git-log-stat-patch -Scope Global
function git-log-stat-patch { git log --stat --patch }

# Git Ls-files
Set-Alias -Name gignored -Value git-ls-ignored -Scope Global
function git-ls-ignored { git ls-files -v | Select-String '^[[:lower:]]' }

Set-Alias -Name gfg -Value git-ls-grep -Scope Global
function git-ls-grep { git ls-files | Select-String $args }

# Git Merge
Set-Alias -Name gm -Value git-merge -Scope Global
function git-merge { git merge $args }

Set-Alias -Name gma -Value git-merge-abort -Scope Global
function git-merge-abort { git merge --abort }

Set-Alias -Name gmc -Value git-merge-continue -Scope Global
function git-merge-continue { git merge --continue }

Set-Alias -Name gms -Value git-merge-squash -Scope Global
function git-merge-squash { git merge --squash $args }

Set-Alias -Name gmff -Value git-merge-ff-only -Scope Global
function git-merge-ff-only { git merge --ff-only $args }

Set-Alias -Name gmom -Value git-merge-origin-main -Scope Global
function git-merge-origin-main {
    $branch = Get-GitMainBranch
    if ($branch) { git merge origin/$branch }
}

Set-Alias -Name gmum -Value git-merge-upstream-main -Scope Global
function git-merge-upstream-main {
    $branch = Get-GitMainBranch
    if ($branch) { git merge upstream/$branch }
}

Set-Alias -Name gmtl -Value git-mergetool -Scope Global
function git-mergetool { git mergetool --no-prompt }

Set-Alias -Name gmtlvim -Value git-mergetool-vimdiff -Scope Global
function git-mergetool-vimdiff { git mergetool --no-prompt --tool=vimdiff }

# Git Pull
Set-Alias -Name gl -Value git-pull -Scope Global
function git-pull { git pull $args }

Set-Alias -Name gpr -Value git-pull-rebase -Scope Global
function git-pull-rebase { git pull --rebase }

Set-Alias -Name gprv -Value git-pull-rebase-verbose -Scope Global
function git-pull-rebase-verbose { git pull --rebase -v }

Set-Alias -Name gpra -Value git-pull-rebase-autostash -Scope Global
function git-pull-rebase-autostash { git pull --rebase --autostash }

Set-Alias -Name gprav -Value git-pull-rebase-autostash-verbose -Scope Global
function git-pull-rebase-autostash-verbose { git pull --rebase --autostash -v }

Set-Alias -Name ggu -Value Invoke-GitPullRebaseOrigin -Scope Global

Set-Alias -Name gprom -Value git-pull-rebase-origin-main -Scope Global
function git-pull-rebase-origin-main {
    $branch = Get-GitMainBranch
    if ($branch) { git pull --rebase origin $branch }
}

Set-Alias -Name gpromi -Value git-pull-rebase-interactive-origin-main -Scope Global
function git-pull-rebase-interactive-origin-main {
    $branch = Get-GitMainBranch
    if ($branch) { git pull --rebase=interactive origin $branch }
}

Set-Alias -Name gprum -Value git-pull-rebase-upstream-main -Scope Global
function git-pull-rebase-upstream-main {
    $branch = Get-GitMainBranch
    if ($branch) { git pull --rebase upstream $branch }
}

Set-Alias -Name gprumi -Value git-pull-rebase-interactive-upstream-main -Scope Global
function git-pull-rebase-interactive-upstream-main {
    $branch = Get-GitMainBranch
    if ($branch) { git pull --rebase=interactive upstream $branch }
}

Set-Alias -Name ggpull -Value git-pull-origin-current -Scope Global
function git-pull-origin-current {
    $branch = Get-GitCurrentBranch
    if ($branch) { git pull origin $branch }
}

Set-Alias -Name ggl -Value Invoke-GitPullOrigin -Scope Global

Set-Alias -Name gluc -Value git-pull-upstream-current -Scope Global
function git-pull-upstream-current {
    $branch = Get-GitCurrentBranch
    if ($branch) { git pull upstream $branch }
}

Set-Alias -Name glum -Value git-pull-upstream-main -Scope Global
function git-pull-upstream-main {
    $branch = Get-GitMainBranch
    if ($branch) { git pull upstream $branch }
}

# Git Push
Set-Alias -Name gp -Value git-push -Scope Global
function git-push { git push $args }

Set-Alias -Name gpd -Value git-push-dry-run -Scope Global
function git-push-dry-run { git push --dry-run }

Set-Alias -Name ggf -Value Invoke-GitPushForceOrigin -Scope Global

function git-push-force { git push --force }
Set-Alias -Name 'gpf!' -Value git-push-force -Scope Global

if ($script:GitVersion -ge [version]"2.30") {
    Set-Alias -Name gpf -Value git-push-force-lease-includes -Scope Global
    function git-push-force-lease-includes { git push --force-with-lease --force-if-includes }
} else {
    Set-Alias -Name gpf -Value git-push-force-lease -Scope Global
    function git-push-force-lease { git push --force-with-lease }
}

Set-Alias -Name ggfl -Value Invoke-GitPushForceLease -Scope Global

Set-Alias -Name gpsup -Value git-push-set-upstream -Scope Global
function git-push-set-upstream {
    $branch = Get-GitCurrentBranch
    if ($branch) { git push --set-upstream origin $branch }
}

if ($script:GitVersion -ge [version]"2.30") {
    Set-Alias -Name gpsupf -Value git-push-set-upstream-force-lease-includes -Scope Global
    function git-push-set-upstream-force-lease-includes {
        $branch = Get-GitCurrentBranch
        if ($branch) { git push --set-upstream origin $branch --force-with-lease --force-if-includes }
    }
} else {
    Set-Alias -Name gpsupf -Value git-push-set-upstream-force-lease -Scope Global
    function git-push-set-upstream-force-lease {
        $branch = Get-GitCurrentBranch
        if ($branch) { git push --set-upstream origin $branch --force-with-lease }
    }
}

Set-Alias -Name gpv -Value git-push-verbose -Scope Global
function git-push-verbose { git push --verbose }

Set-Alias -Name gpoat -Value git-push-origin-all-tags -Scope Global
function git-push-origin-all-tags {
    git push origin --all
    git push origin --tags
}

Set-Alias -Name gpod -Value git-push-origin-delete -Scope Global
function git-push-origin-delete { git push origin --delete $args }

Set-Alias -Name ggpush -Value git-push-origin-current -Scope Global
function git-push-origin-current {
    $branch = Get-GitCurrentBranch
    if ($branch) { git push origin $branch }
}

Set-Alias -Name ggp -Value Invoke-GitPushOrigin -Scope Global
Set-Alias -Name ggpnp -Value Invoke-GitPullAndPush -Scope Global

Set-Alias -Name gpu -Value git-push-upstream -Scope Global
function git-push-upstream { git push upstream $args }

# Git Rebase
Set-Alias -Name grb -Value git-rebase -Scope Global
function git-rebase { git rebase $args }

Set-Alias -Name grba -Value git-rebase-abort -Scope Global
function git-rebase-abort { git rebase --abort }

Set-Alias -Name grbc -Value git-rebase-continue -Scope Global
function git-rebase-continue { git rebase --continue }

Set-Alias -Name grbi -Value git-rebase-interactive -Scope Global
function git-rebase-interactive { git rebase --interactive $args }

Set-Alias -Name grbo -Value git-rebase-onto -Scope Global
function git-rebase-onto { git rebase --onto $args }

Set-Alias -Name grbs -Value git-rebase-skip -Scope Global
function git-rebase-skip { git rebase --skip }

Set-Alias -Name grbd -Value git-rebase-develop -Scope Global
function git-rebase-develop {
    $branch = Get-GitDevelopBranch
    if ($branch) { git rebase $branch }
}

Set-Alias -Name grbm -Value git-rebase-main -Scope Global
function git-rebase-main {
    $branch = Get-GitMainBranch
    if ($branch) { git rebase $branch }
}

Set-Alias -Name grbom -Value git-rebase-origin-main -Scope Global
function git-rebase-origin-main {
    $branch = Get-GitMainBranch
    if ($branch) { git rebase origin/$branch }
}

Set-Alias -Name grbum -Value git-rebase-upstream-main -Scope Global
function git-rebase-upstream-main {
    $branch = Get-GitMainBranch
    if ($branch) { git rebase upstream/$branch }
}

# Git Reflog
Set-Alias -Name grf -Value git-reflog -Scope Global
function git-reflog { git reflog }

# Git Remote
Set-Alias -Name gr -Value git-remote -Scope Global
function git-remote { git remote $args }

Set-Alias -Name grv -Value git-remote-verbose -Scope Global
function git-remote-verbose { git remote --verbose }

Set-Alias -Name gra -Value git-remote-add -Scope Global
function git-remote-add { git remote add $args }

Set-Alias -Name grrm -Value git-remote-remove -Scope Global
function git-remote-remove { git remote remove $args }

Set-Alias -Name grmv -Value git-remote-rename -Scope Global
function git-remote-rename { git remote rename $args }

Set-Alias -Name grset -Value git-remote-set-url -Scope Global
function git-remote-set-url { git remote set-url $args }

Set-Alias -Name grup -Value git-remote-update -Scope Global
function git-remote-update { git remote update }

# Git Reset
Set-Alias -Name grh -Value git-reset -Scope Global
function git-reset { git reset $args }

Set-Alias -Name gru -Value git-reset-files -Scope Global
function git-reset-files { git reset -- $args }

Set-Alias -Name grhh -Value git-reset-hard -Scope Global
function git-reset-hard { git reset --hard $args }

Set-Alias -Name grhk -Value git-reset-keep -Scope Global
function git-reset-keep { git reset --keep $args }

Set-Alias -Name grhs -Value git-reset-soft -Scope Global
function git-reset-soft { git reset --soft $args }

Set-Alias -Name gpristine -Value git-pristine -Scope Global
function git-pristine {
    git reset --hard
    git clean --force -dfx
}

Set-Alias -Name gwipe -Value git-wipe -Scope Global
function git-wipe {
    git reset --hard
    git clean --force -df
}

Set-Alias -Name groh -Value git-reset-origin-hard -Scope Global
function git-reset-origin-hard {
    $branch = Get-GitCurrentBranch
    if ($branch) { git reset origin/$branch --hard }
}

# Git Restore
Set-Alias -Name grs -Value git-restore -Scope Global
function git-restore { git restore $args }

Set-Alias -Name grss -Value git-restore-source -Scope Global
function git-restore-source { git restore --source $args }

Set-Alias -Name grst -Value git-restore-staged -Scope Global
function git-restore-staged { git restore --staged $args }

# Git Revert
Set-Alias -Name gunwip -Value git-unwip -Scope Global
function git-unwip {
    $lastCommit = git rev-list --max-count=1 --format='%s' HEAD 2>$null | Select-String '--wip--'
    if ($lastCommit) {
        git reset 'HEAD~1'
    }
}

Set-Alias -Name gunwipall -Value Invoke-GitUnwipAll -Scope Global

Set-Alias -Name grev -Value git-revert -Scope Global
function git-revert { git revert $args }

Set-Alias -Name greva -Value git-revert-abort -Scope Global
function git-revert-abort { git revert --abort }

Set-Alias -Name grevc -Value git-revert-continue -Scope Global
function git-revert-continue { git revert --continue }

# Git Rm
Set-Alias -Name grm -Value git-rm -Scope Global
function git-rm { git rm $args }

Set-Alias -Name grmc -Value git-rm-cached -Scope Global
function git-rm-cached { git rm --cached $args }

# Git Shortlog
Set-Alias -Name gcount -Value git-shortlog-summary -Scope Global
function git-shortlog-summary { git shortlog --summary --numbered }

# Git Show
Set-Alias -Name gsh -Value git-show -Scope Global
function git-show { git show $args }

Set-Alias -Name gsps -Value git-show-signature -Scope Global
function git-show-signature { git show --pretty=short --show-signature $args }

# Git Stash
Set-Alias -Name gstall -Value git-stash-all -Scope Global
function git-stash-all { git stash --all }

Set-Alias -Name gstaa -Value git-stash-apply -Scope Global
function git-stash-apply { git stash apply $args }

Set-Alias -Name gstc -Value git-stash-clear -Scope Global
function git-stash-clear { git stash clear }

Set-Alias -Name gstd -Value git-stash-drop -Scope Global
function git-stash-drop { git stash drop $args }

Set-Alias -Name gstl -Value git-stash-list -Scope Global
function git-stash-list { git stash list }

Set-Alias -Name gstp -Value git-stash-pop -Scope Global
function git-stash-pop { git stash pop $args }

if ($script:GitVersion -ge [version]"2.13") {
    Set-Alias -Name gsta -Value git-stash-push -Scope Global
    function git-stash-push { git stash push $args }
} else {
    Set-Alias -Name gsta -Value git-stash-save -Scope Global
    function git-stash-save { git stash save $args }
}

Set-Alias -Name gsts -Value git-stash-show -Scope Global
function git-stash-show { git stash show --patch $args }

Set-Alias -Name gstu -Value git-stash-include-untracked -Scope Global
function git-stash-include-untracked { git stash push --include-untracked }

# Git Status
Set-Alias -Name gst -Value git-status -Scope Global
function git-status { git status $args }

Set-Alias -Name gss -Value git-status-short -Scope Global
function git-status-short { git status --short }

Set-Alias -Name gsb -Value git-status-short-branch -Scope Global
function git-status-short-branch { git status --short --branch }

# Git Submodule
Set-Alias -Name gsi -Value git-submodule-init -Scope Global
function git-submodule-init { git submodule init }

Set-Alias -Name gsu -Value git-submodule-update -Scope Global
function git-submodule-update { git submodule update }

# Git SVN
Set-Alias -Name gsd -Value git-svn-dcommit -Scope Global
function git-svn-dcommit { git svn dcommit }

Set-Alias -Name gsr -Value git-svn-rebase -Scope Global
function git-svn-rebase { git svn rebase }

# Git Switch
Set-Alias -Name gsw -Value git-switch -Scope Global
function git-switch { git switch $args }

Set-Alias -Name gswc -Value git-switch-create -Scope Global
function git-switch-create { git switch --create $args }

Set-Alias -Name gswd -Value git-switch-develop -Scope Global
function git-switch-develop {
    $branch = Get-GitDevelopBranch
    if ($branch) { git switch $branch }
}

Set-Alias -Name gswm -Value git-switch-main -Scope Global
function git-switch-main {
    $branch = Get-GitMainBranch
    if ($branch) { git switch $branch }
}

# Git Tag
Set-Alias -Name gta -Value git-tag-annotate -Scope Global
function git-tag-annotate { git tag --annotate $args }

Set-Alias -Name gts -Value git-tag-sign -Scope Global
function git-tag-sign { git tag --sign $args }

Set-Alias -Name gtv -Value git-tag-sort -Scope Global
function git-tag-sort { git tag | Sort-Object { [version]($_ -replace '^v', '') } }

Set-Alias -Name gtl -Value git-tag-list -Scope Global
function git-tag-list {
    param([string]$Pattern = '*')
    git tag --sort=-v:refname -n --list "$Pattern*"
}

# Git Update-index
Set-Alias -Name gignore -Value git-update-index-assume-unchanged -Scope Global
function git-update-index-assume-unchanged { git update-index --assume-unchanged $args }

Set-Alias -Name gunignore -Value git-update-index-no-assume-unchanged -Scope Global
function git-update-index-no-assume-unchanged { git update-index --no-assume-unchanged $args }

# Git Whatchanged
Set-Alias -Name gwch -Value git-whatchanged -Scope Global
function git-whatchanged { git log --patch --abbrev-commit --pretty=medium --raw }

# Git Worktree
Set-Alias -Name gwt -Value git-worktree -Scope Global
function git-worktree { git worktree $args }

Set-Alias -Name gwta -Value git-worktree-add -Scope Global
function git-worktree-add { git worktree add $args }

Set-Alias -Name gwtls -Value git-worktree-list -Scope Global
function git-worktree-list { git worktree list }

Set-Alias -Name gwtmv -Value git-worktree-move -Scope Global
function git-worktree-move { git worktree move $args }

Set-Alias -Name gwtrm -Value git-worktree-remove -Scope Global
function git-worktree-remove { git worktree remove $args }

# Aliases for common shortcuts
Set-Alias -Name ggpur -Value ggu -Scope Global
Set-Alias -Name grename -Value Rename-GitBranch -Scope Global

# Export all functions and aliases
Export-ModuleMember -Function * -Alias *
