$win_steam =${env:ProgramFiles(x86)}+"\Steam\steamapps\common\Ninja Kiwi Archive\resources"
$win_standalone1=${env:LocalAppData}+"\Programs\Ninja Kiwi Archive\resources"
$win_standalone2=${env:ProgramFiles}+"\Ninja Kiwi\Ninja Kiwi Archive\resources"
$mac_steam=$HOME +"/Library/Application Support/Steam/steamapps/common/Ninja Kiwi Archive/resources"
$mac_standalone="/Applications/Ninja Kiwi Archive.app/Contents/Resources"
$URL_STEAM="https://github.com/GlennnM/NKMultiArchive/releases/download/v1.0/app_steam.zip"
$URL_STANDALONE="https://github.com/GlennnM/NKMultiArchive/releases/download/v1.0/app_standalone.zip"
$SIZE_STEAM = 49746313
$SIZE_STANDALONE = 49746102
$filename="app.asar"
function DownloadThenExtract([string]$cache,[string]$zippath,[string]$downloadpath,[int]$FULL_SIZE){
[int]$FULL_MB = $FULL_SIZE / 0.1MB
$FULL_MB_FLOAT = $FULL_MB / 10
        $N = (New-Object Net.WebClient)
try {
		Set-Location $cache
		Write-Host -NoNewline "Downloading $filename ... "
		$E = $N.DownloadFileTaskAsync($zippath,$downloadpath)
		while (!($E.IsCompleted)) {
			Start-Sleep -Seconds 1
				$size = (Get-Item -Path $downloadpath).Length
				if ($size -eq 0) {
					continue
				}
				[int]$percent = ($size / $FULL_SIZE * 1000)
				[int]$mb = $size / 0.1MB
				$percent_float = $percent / 10
				$mb_float = $mb / 10
				#Write-Progress -Activity "Downloading app.asar:" -Status "$percent_float% complete.." -PercentComplete $percent_float
				Write-Host -NoNewline "`rDownloading $filename ... $percent_float% ($mb_float MB/$FULL_MB_FLOAT MB)    "
			
		}
		if ($size -lt $FULL_SIZE) {
			"`n"
			throw
		}
		Write-Host -NoNewline "`rDownloading $filename complete!                        "
        if(Test-Path -Path $cache'/app.asar'){
		    Remove-Item $cache'/app.asar'
        }
		"`nExtracting..."
		try {
			"Attempting unzip method 1(powershell 5+)..."
			Expand-Archive -Path "$cache/install.zip" -DestinationPath "$cache/"

		} catch {
			try {
				"Attempting unzip method 2(.NET)..."
				Add-Type -AssemblyName System.IO.Compression.FileSystem
				function Unzip
				{
					param([string]$zipfile,[string]$outpath)

					[System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile,$outpath)
				}

				Unzip "$cache/install.zip" "$cache/"
			} catch {
				try {
					"Attempting unzip method 3(tar -xvf)"
					Start-Process tar -Wait -NoNewWindow -ArgumentList -WorkingDirectory "$cache" @("-xvf","install.zip")

				} catch {
					if ($IsWindows -or $ENV:OS) {
						"Attempting unzip method 4(7zip)"
						Start-Process -Wait -FilePath "C:\Program Files\7-Zip\7z.exe" -NoNewWindow -WorkingDirectory "$cache" -ArgumentList @("e","install.zip")
					} else {
						"Attempting unzip method 4(unzip)"
						Start-Process Unzip -Wait -NoNewWindow -WorkingDirectory "$cache" -ArgumentList @("install.zip")
					}
				}

			}
		}
		Remove-Item "$cache/install.zip"

		if (Test-Path -Path $cache'/app.asar') {

			"Mod installation for NK Archive at "+$cache+" probably succeeded!!"
		} else {
			"Mod installation failed."
		}
	} catch {
		$Q = Read-Host "One or more files failed to download, exiting."
	} finally {
		try {
			$N.CancelAsync();
		} catch {

		}
		$N.Dispose();
	}
}
"NK MultiArchive Installer by glenn m"
	"The following mods will be installed:"
	"Ninja Kiwi Multi-Instance Archive"
	"Approx data size: 47.4 MB"
	"==============================="

	$X = Read-Host "Please ensure all Ninja Kiwi Archive windows(INCLUDING THE LAUNCHER!!!) are closed, then press ENTER to begin installation..."
	
if ($IsWindows -or $ENV:OS) {
    if (Test-Path -Path $win_steam) {
        "Located windows/steam installation(probably)"
        DownloadThenExtract -cache $win_steam -zippath $URL_STEAM -downloadpath $win_steam'/install.zip' -FULL_SIZE $SIZE_STEAM
    }
    if (Test-Path -Path $win_standalone1) {
        "Located windows/standalone installation(probably)"
        DownloadThenExtract -cache $win_standalone1 -zippath $URL_STANDALONE -downloadpath $win_standalone1'/install.zip' -FULL_SIZE $SIZE_STANDALONE
    }
    if (Test-Path -Path $win_standalone2) {
        "Located windows/standalone(All Users) installation(probably)"
        DownloadThenExtract -cache $win_standalone2 -zippath $URL_STANDALONE -downloadpath $win_standalone2'/install.zip' -FULL_SIZE $SIZE_STANDALONE
    }
}else{
    if(Test-Path -Path $mac_steam){
        "Located mac/steam installation(probably)"
        
        DownloadThenExtract -cache $mac_steam -zippath $URL_STEAM -downloadpath $mac_steam'/install.zip' -FULL_SIZE $SIZE_STEAM

    }if(Test-Path -Path $mac_standalone){
        "Located mac/standalone installation(probably)"
        DownloadThenExtract -cache $mac_standalone -zippath $URL_STANDALONE -downloadpath $mac_standalone'/install.zip' -FULL_SIZE $SIZE_STANDALONE

    }
}
$X = Read-Host "Press enter to exit..."