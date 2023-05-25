# Check if the execution policy is restricted
$executionPolicy = Get-ExecutionPolicy
if ($executionPolicy -eq "Restricted") {
    Write-Host "Changing execution policy..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
}

# Install Python if not already installed
$pythonInstalled = (Get-Command python -ErrorAction SilentlyContinue) -ne $null

if (-not $pythonInstalled) {
    $pythonInstallerUrl = "https://www.python.org/ftp/python/3.9.7/python-3.9.7-amd64.exe"
    $pythonInstallerPath = "$PSScriptRoot\python-installer.exe"

    # Download Python installer
    Invoke-WebRequest -Uri $pythonInstallerUrl -OutFile $pythonInstallerPath

    # Install Python and set PATH variable
    $installArguments = "/quiet", "PrependPath=1"
    Start-Process -Wait -FilePath $pythonInstallerPath -ArgumentList $installArguments

    # Remove Python installer
    Remove-Item -Path $pythonInstallerPath
}

# Set PATH variable if Python is installed but not in PATH
if (-not ($pythonInstalled -or (Get-Command python -ErrorAction SilentlyContinue) -ne $null)) {
    $pythonPath = (Get-Command python).Source
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::Machine)
    $newPath = "$pythonPath;$currentPath"
    [Environment]::SetEnvironmentVariable("PATH", $newPath, [EnvironmentVariableTarget]::Machine)
    Write-Host "Python added to PATH."
}

# Install NumPy
python -m pip install numpy

# Create and execute the Python script
$pythonScript = @"
import numpy as np

# Define the size of the array to be created
array_size = 10_000_000

# Create a large array
large_array = np.zeros(array_size, dtype=np.uint8)

# Keep the script running to hold the memory
while True:
    pass
"@

$pythonScriptPath = "$PSScriptRoot\memory_consumption.py"

$pythonScript | Out-File -FilePath $pythonScriptPath -Encoding ASCII

python $pythonScriptPath
