#region Functions

function printCurrentTime() {
	Write-Output "$((Get-Date).Hour):$((Get-Date).Minute):$((Get-Date).Second)"	
}

#endregion Functions


#region Main script part

$clear_assets_cache = $true

if ($clear_assets_cache) {
	Remove-Item -Path ".\temp" -Recurse -Force -ErrorAction Ignore
}

# Creation of temp directory should be unconditional , in case user delete it manually
New-Item -Path "temp" -ItemType Directory -ErrorAction Ignore > $null

Remove-Item -Path ".\temp\output" -Recurse -Force -ErrorAction Ignore
Remove-Item -Path ".\output_vm" -Recurse -Force -ErrorAction Ignore
Remove-Item -Path ".\output_yyc" -Recurse -Force -ErrorAction Ignore

$note_about_intentional_error = "`nPlease , don't mind the `"Empty file name is not legal`" error .`nAs far as i can tell , this is the only way to make gamemaker skip zipping of files :)"

# Igor.exe is hardcoded to read location of VsDevCmd.bat from this file
Set-Content -NoNewline -Path "./temp/local_settings.json" -Value ("{ `"machine.Platform Settings.Windows.visual_studio_path`": `"" + "C:/Program Files/Microsoft Visual Studio/2022/Community/Common7/Tools/VsDevCmd.bat" + "`" }")

try {
	Set-Location "./temp"
	
	# Gamemaker macro-expanse (sets) GM_build_date somewhere on the start of compilation .
	# And since VM compiles faster than YYC , compiling VM first and then YYC will make their GM_build_date more closer to each others .
	# In other words - difference of GM_build_date inside VM and YYC data.win files is a roughly a time spent on compiling first thing .
	
	printCurrentTime
	Write-Output "Compiling VM ..."
	& "C:\ProgramData\GameMakerStudio2\Cache\runtimes\runtime-2023.11.1.160\bin\igor\windows\x64\Igor.exe" --project="D:\git\Delirium\Delirium.yyp" --rp="C:\ProgramData\GameMakerStudio2\Cache\runtimes\runtime-2023.11.1.160" --lf="..\licence.plist" Windows PackageZip > compile_log_vm.txt
	# New-Item -Path "output/" -ItemType Directory > $null
	Write-Output $note_about_intentional_error >> compile_log_vm.txt
	printCurrentTime
	
	Move-Item -Path "./output/" -Destination "../output_vm"
	Write-Output "done`n"
	
	printCurrentTime
	Write-Output "Compiling YYC ..."
	& "C:\ProgramData\GameMakerStudio2\Cache\runtimes\runtime-2023.11.1.160\bin\igor\windows\x64\Igor.exe" --project="D:\git\Delirium\Delirium.yyp" --rp="C:\ProgramData\GameMakerStudio2\Cache\runtimes\runtime-2023.11.1.160" --lf="..\licence.plist" --runtime=YYC Windows PackageZip > compile_log_yyc.txt
	# New-Item -Path "output/" -ItemType Directory > $null
	Write-Output $note_about_intentional_error >> compile_log_yyc.txt
	printCurrentTime
	
	Move-Item -Path "./output/" -Destination "../output_yyc"
	Write-Output "done`n"
} finally {
	Set-Location ".."
}

Copy-Item -Path "D:\git\Mapping" -Destination ".\temp\output\Delirium\Mapping" -Recurse -Force
Copy-Item -Path "D:\Dropbox\Moosor" -Destination ".\temp\output\Delirium\Moosor" -Recurse -Force

#endregion Main script part