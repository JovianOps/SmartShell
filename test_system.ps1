function Run-SystemInfo {
    try {
        $nv = cmd /c nvidia-smi --query-gpu=utilization.gpu,temperature.gpu --format=csv,noheader 2>$null | Out-String
        $nv = $nv.Trim()
        Write-Host "NV value: '$nv'"
        if ($nv) {
            Write-Host "GPU FOUND: $nv"
        } else {
            Write-Host "GPU EMPTY"
        }
    } catch {
        Write-Host "CAUGHT: $_"
    }
}
Run-SystemInfo
