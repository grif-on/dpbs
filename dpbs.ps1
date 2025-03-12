Remove-Item -Path ".\Delirium.zip" -Force

New-Item -Path "temp" -ItemType Directory

Set-Location "./temp"
& "C:\ProgramData\GameMakerStudio2\Cache\runtimes\runtime-2023.11.1.160\bin\igor\windows\x64\Igor.exe" --project="V:\git\Delirium\Delirium.yyp" --rp="C:\ProgramData\GameMakerStudio2\Cache\runtimes\runtime-2023.11.1.160" --lf=".\licence.plist" Windows PackageZip
# & "C:\ProgramData\GameMakerStudio2\Cache\runtimes\runtime-2023.11.1.160\bin\igor\windows\x64\Igor.exe" --project="V:\git\Delirium\Delirium.yyp" --rp="C:\ProgramData\GameMakerStudio2\Cache\runtimes\runtime-2023.11.1.160" --lf=".\licence.plist" --runtime=YYC Windows PackageZip
Set-Location ".."

Copy-Item -Path "V:\git\Mapping" -Destination ".\temp\output\Delirium\Mapping" -Recurse -Force
Copy-Item -Path "D:\Dropbox\Moosor" -Destination ".\temp\output\Delirium\Moosor" -Recurse -Force
Copy-Item -Path "D:\Dropbox\Characters" -Destination ".\temp\output\Delirium\Characters" -Recurse -Force

& "D:\Programs\7-Zip\7z.exe" a ".\Delirium.zip" ".\temp\output\Delirium"

Remove-Item -Path ".\temp" -Recurse -Force