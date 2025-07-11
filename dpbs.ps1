#region Functions


#endregion Functions


#region Main script part

New-Item -Path "temp" -ItemType Directory -ErrorAction Ignore

Remove-Item -Path ".\output" -Recurse -Force -ErrorAction Ignore

# Igor.exe is hardcoded to read location of VsDevCmd.bat from this file
Set-Content -NoNewline -Path "./temp/local_settings.json" -Value ("{ `"machine.Platform Settings.Windows.visual_studio_path`": `"" + "V:/Programs/VS/2022/Community/Common7/Tools/VsDevCmd.bat" + "`" }")

Set-Location "./temp"
try {
	# & "C:\ProgramData\GameMakerStudio2\Cache\runtimes\runtime-2023.11.1.160\bin\igor\windows\x64\Igor.exe" --project="V:\git\Delirium\Delirium.yyp" --rp="C:\ProgramData\GameMakerStudio2\Cache\runtimes\runtime-2023.11.1.160" --lf="..\licence.plist" Windows PackageZip
	& "C:\ProgramData\GameMakerStudio2\Cache\runtimes\runtime-2023.11.1.160\bin\igor\windows\x64\Igor.exe" --project="V:\git\Delirium\Delirium.yyp" --rp="C:\ProgramData\GameMakerStudio2\Cache\runtimes\runtime-2023.11.1.160" --lf="..\licence.plist" --runtime=YYC Windows PackageZip
	Write-Host "`nPlease , don't mind the `"Empty file name is not legal`" error ."
	Write-Host "As far as i can tell , this is the only way to make gamemaker skip zipping of files :)`n"
} finally {
	Set-Location ".."
}

Copy-Item -Path "V:\git\Mapping" -Destination ".\temp\output\Delirium\Mapping" -Recurse -Force
Copy-Item -Path "D:\Dropbox\Moosor" -Destination ".\temp\output\Delirium\Moosor" -Recurse -Force
Copy-Item -Path "D:\Dropbox\Characters" -Destination ".\temp\output\Delirium\Characters" -Recurse -Force

Move-Item -Path "./temp/output" -Destination "./output" -Recurse -Force

Remove-Item -Path ".\temp" -Recurse -Force
Remove-Item -Path "./temp/local_settings.json" -Force

#endregion Main script part