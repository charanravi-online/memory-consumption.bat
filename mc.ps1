# Install Python if not already installed
$pythonInstalled = (Get-Command python -ErrorAction SilentlyContinue) -ne $null

if (-not $pythonInstalled) {
    $pythonInstallerUrl = "https://www.python.org/ftp/python/3.9.7/python-3.9.7-amd64.exe"
    $pythonInstallerPath = "$PSScriptRoot\python-installer.exe"

    # Download Python installer
    Invoke-WebRequest -Uri $pythonInstallerUrl -OutFile $pythonInstallerPath

    # Install Python
    Start-Process -Wait -FilePath $pythonInstallerPath -ArgumentList "/quiet", "PrependPath=1"

    # Remove Python installer
    Remove-Item -Path $pythonInstallerPath
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
