#Lightweight GitStatus Function
function Get-GitStatus ([Switch]$AsPrompt) {

    function GetPathIfFileExist($Path, $File) {
        if (-not $Path) {
            return
        } elseif (Test-Path (Join-Path $Path $File)) {
            $Path
        } else {
            GetPathIfFileExist (Split-Path $Path) $File
        }
    }

    $isGitRepo = $null -ne (GetPathIfFileExist $pwd '.git')
    if (-not $isGitRepo) {return}

    #PS6.1 and up can use MemoryCache with a HostFileChangeMonitor. For now we're rolling our own cache with a global hashtable and a filesystemwatcher
    if ($PSEdition -eq 'Core') {
        $cache = [Runtime.Caching.MemoryCache]::Default
    } else {
        $SCRIPT:cache = @{}
    }

    $cacheKey = "PowerPrompt_GitStatus_$pwd"

    if ($cache[$cacheKey]) { $GitBranchSummary = $cache[$cacheKey]}
    function Add-CachePathItem ([String]$Key, $InputObject, [Collections.Generic.List[string]]$Path = $pwd, $Cache = [Runtime.Caching.MemoryCache]::Default) {
    <#
    .SYNOPSIS
    Set a cache entry based on one or more file paths. If anything in that file path or paths change, the cache will be invalidated
    #>
        $cacheItemPolicy = [Runtime.Caching.CacheItemPolicy]::new()
        $cacheItemPolicy.ChangeMonitors.Add(
            [Runtime.Caching.HostFileChangeMonitor]::new($Path)
        )
        $cache.Add(
            $Key, #Key
            $InputObject, #Name
            $cacheItemPolicy
        )
    }

    $gitResult = & git status --porcelain=2 --branch *>&1

    if ($gitresult -match '^fatal: not a git repository') {
        Write-Debug "$pwd is not a git repository."
        return
    }
    if ($LASTEXITCODE -ne 0 -and $gitresult -match '^fatal: (.+)') {
        Write-Warning $matches[1]
        return
    }
    if (-not $gitBranchSummary) {
        $gitBranchSummary = [ordered]@{ }
        $gitResult.foreach{
            if ($PSItem -match '(?m)^# branch\.(?<property>\w+) (?<value>.+)$') {
                $gitBranchSummary.($matches.property) = $matches.value
            }
        }

        if ($gitBranchSummary.ab -match '^\+(?<ahead>\d+) -(?<behind>\d+)$') {
            $gitBranchSummary.ahead = $matches.ahead
            $gitBranchSummary.behind = $matches.behind
        }
        #File Path Monitor Doesn't work on Linux as of 6.1 but doesn't matter because git status caches pretty well anyways there
        if ($isWindows) {
            $null = Add-CachePathItem $cacheKey $gitBranchSummary
        }
    }

    if ($AsPrompt -and $gitBranchSummary) {
        [String]$gitPrompt = [char]0xe0a0 + $gitBranchSummary.head
        if ($gitBranchSummary.ahead -or $gitBranchSummary.behind) {
            $gitPrompt += " " + $gitBranchSummary.behind + [char]0x2193 + " " + $gitBranchSummary.Ahead + [char]0x2191
        }
        $gitPrompt
    } else {
        return $gitBranchSummary
    }
}