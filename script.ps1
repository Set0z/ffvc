function Video_chose{
    Clear-History
    Write-Host "Select video file to compress"

    Add-Type -AssemblyName System.Windows.Forms
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = "VIdo (*.mp4)|*.mp4"
    $openFileDialog.Title = "Select video file"
    if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $inputFile = $openFileDialog.FileName
    } else {
        Write-Host "No file selected. Exit..."
        pause
        exit
    }
    

    Clear-History
    Clear-Host
    Write-Host "Select a save location"

    Add-Type -AssemblyName System.Windows.Forms

    $saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
    $saveFileDialog.Filter = "Video (*.mp4)|*.mp4"
    $saveFileDialog.Title = "Select a location to save the file"
    $DesktopPath = $env:USERPROFILE + "\Desktop"
    $saveFileDialog.InitialDirectory = $DesktopPath

    if ($saveFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $outputFile = $saveFileDialog.FileName
        Write-Host "Selected path to save the file: $outputFile"
    } else {
        Write-Host "No file selected. Exit..."
        pause
        exit
    }
    return @{inputFile = $inputFile; outputFile = $outputFile}
}

if($PSScriptRoot -eq ""){Invoke-WebRequest https://raw.githubusercontent.com/Set0z/ffvc/refs/heads/main/config.json -OutFile "$($env:TEMP)\config.json" ; $configFile = "$($env:TEMP)\config.json"}else{$configFile = $PSScriptRoot + "\config.json"}



try {
    ffmpeg -h > $null 2>&1
}
catch {
    Write-Host "The path to ffmpeg is not set!"
    Write-Host "Select the path to ffmpeg.exe"


    Add-Type -AssemblyName System.Windows.Forms
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = "ffmpeg (*.exe)|ffmpeg.exe"
    $openFileDialog.Title = "Select file ffmpeg.exe"
    if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $ffmpegDir = [System.IO.Path]::GetDirectoryName($openFileDialog.FileName)
    } else {
        Write-Host "No file selected. Exit..."
        pause
        exit
    }

    $PATH = [Environment]::GetEnvironmentVariable("PATH")
    [Environment]::SetEnvironmentVariable("PATH", "$PATH;$ffmpegDir", "Machine")
    $ffmpegDir = $ffmpegDir + "\ffmpeg.exe"


    $configFile = $PSScriptRoot + "\config.json"
    $config = Get-Content -Path $configFile | ConvertFrom-Json


    $result = Video_chose
    $inputFile = $result.inputFile
    $outputFile = $result.outputFile

    & $ffmpegDir -i "$inputFile" -c:v $($config.videoCodec) -preset $($config.preset) -b:v $($config.bitrateVideo) -c:a $($config.audioCodec) -b:a $($config.bitrateAudio) -movflags $($config.movflags) "$outputFile"

    Write-Host "`n`n`n`nDone!"
    pause
    exit

}


# Чтение конфигурации из файла
$config = Get-Content -Path $configFile | ConvertFrom-Json


$result = Video_chose
$inputFile = $result.inputFile
$outputFile = $result.outputFile

& ffmpeg -i "$inputFile" -c:v $($config.videoCodec) -preset $($config.preset) -b:v $($config.bitrateVideo) -c:a $($config.audioCodec) -b:a $($config.bitrateAudio) -movflags $($config.movflags) "$outputFile"
Write-Host "`n`n`n`nDone!"
