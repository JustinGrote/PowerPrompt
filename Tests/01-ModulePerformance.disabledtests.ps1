
Describe 'Module Performance Test' {
    It -Pending 'Loads in under 1 second of CPU time' {


        $benchmark = '
        sleep 0.5
        #($t = [diagnostics.stopwatch]::new()).start();
        $cpu = (Get-Process -id $pid).totalprocessortime.totalmilliseconds
        Import-Module {0} -force
        $cpuafter = (Get-Process -id $pid).totalprocessortime.totalmilliseconds
        $cpuafter - $cpu
        #write-host -fore cyan ($t.elapsed.totalmilliseconds)' -f (Get-Item "$PSScriptRoot\..\BuildOutput\Powerprompt\*\*.psd1").fullname

        $benchmarkResult = pwsh.exe -noninteractive -noprofile -command $benchmark
        Write-Host -fore magenta "        Module Import CPU time: ${benchmarkResult}ms"
        [int]$benchmarkResult | Should -BeLessThan 1000
    }
}
