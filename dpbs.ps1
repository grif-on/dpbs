New-Item -Path "temp" -ItemType Directory -ErrorAction Ignore

Remove-Item -Path ".\Delirium.zip" -Force -ErrorAction Ignore
Remove-Item -Path ".\temp\output" -Recurse -Force -ErrorAction Ignore

Set-Location "./temp"
try {
	& "C:\ProgramData\GameMakerStudio2\Cache\runtimes\runtime-2023.11.1.160\bin\igor\windows\x64\Igor.exe" --project="V:\git\Delirium\Delirium.yyp" --rp="C:\ProgramData\GameMakerStudio2\Cache\runtimes\runtime-2023.11.1.160" --lf="..\licence.plist" Windows PackageZip
	# & "C:\ProgramData\GameMakerStudio2\Cache\runtimes\runtime-2023.11.1.160\bin\igor\windows\x64\Igor.exe" --project="V:\git\Delirium\Delirium.yyp" --rp="C:\ProgramData\GameMakerStudio2\Cache\runtimes\runtime-2023.11.1.160" --lf="..\licence.plist" --runtime=YYC Windows PackageZip
	Write-Host "`nPlease , don't mind the `"Empty file name is not legal`" error ."
	Write-Host "As far as i can tell , this is the only way to make gamemaker skip zipping of files :)`n"
} finally {
	Set-Location ".."
}

Copy-Item -Path "V:\git\Mapping" -Destination ".\temp\output\Delirium\Mapping" -Recurse -Force
Copy-Item -Path "D:\Dropbox\Moosor" -Destination ".\temp\output\Delirium\Moosor" -Recurse -Force
Copy-Item -Path "D:\Dropbox\Characters" -Destination ".\temp\output\Delirium\Characters" -Recurse -Force

& "D:\Programs\7-Zip\7z.exe" a ".\Delirium.zip" ".\temp\output\Delirium"

Remove-Item -Path ".\temp" -Recurse -Force