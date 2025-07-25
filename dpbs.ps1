#region Functions


#endregion Functions


#region Main script part

$clear_assets_cache = $true

if ($clear_assets_cache) {
	Remove-Item -Path ".\temp" -Recurse -Force -ErrorAction Ignore
}

# Creation of temp directory should be unconditional , in case user delete it manually
New-Item -Path "temp" -ItemType Directory -ErrorAction Ignore > $null

Remove-Item -Path ".\temp\output" -Recurse -Force -ErrorAction Ignore
Remove-Item -Path ".\output" -Recurse -Force -ErrorAction Ignore

# Igor.exe is hardcoded to read location of VsDevCmd.bat from this file
Set-Content -NoNewline -Path "./temp/local_settings.json" -Value ("{ `"machine.Platform Settings.Windows.visual_studio_path`": `"" + "C:/Program Files/Microsoft Visual Studio/2022/Community/Common7/Tools/VsDevCmd.bat" + "`" }")

try {
	Set-Location "./temp"
	
	# "C:\ProgramData\GameMakerStudio2\Cache\runtimes\runtime-2023.11.1.160\bin\igor\windows\x64\Igor.exe" --project="D:\git\Delirium\Delirium.yyp" --rp="C:\ProgramData\GameMakerStudio2\Cache\runtimes\runtime-2023.11.1.160" --lf="..\licence.plist" --runtime=YYC Windows PackageZip > compile_log_yyc.txt
	
	& "C:\ProgramData\GameMakerStudio2\Cache\runtimes\runtime-2023.11.1.160\bin\igor\windows\x64\Igor.exe" --project="D:\git\Delirium\Delirium.yyp" --rp="C:\ProgramData\GameMakerStudio2\Cache\runtimes\runtime-2023.11.1.160" --lf="..\licence.plist" Windows PackageZip > compile_log_vm.txt
	
	Write-Host "`nPlease , don't mind the `"Empty file name is not legal`" error ."
	Write-Host "As far as i can tell , this is the only way to make gamemaker skip zipping of files :)`n"
} finally {
	Set-Location ".."
}

Copy-Item -Path "D:\git\Mapping" -Destination ".\temp\output\Delirium\Mapping" -Recurse -Force
Copy-Item -Path "D:\Dropbox\Moosor" -Destination ".\temp\output\Delirium\Moosor" -Recurse -Force

Move-Item -Path "./temp/output" -Destination "./output" -Recurse -Force

#endregion Main script part