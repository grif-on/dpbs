# Delirious Production Build Script

#### Simple powershell script for compilation of GameMaker project in terminal / console .

It covers only compilation of VM and YYC for windows .
But you should be fine in case you need to tailor it for your other target platforms .

Runtimes instalation and getting of licence token is intended to be done via GameMaker IDE (but you can do this via Igor.exe directly if you ***really*** need to) .

### IMPORTANT :
If you are using [steamworks GameMaker extension](https://github.com/YoYoGames/GMEXT-Steamworks) - you need to either :
 - Ensure that you have steamworks extension version 2.1.3 or highter (it already have important bugfix) .
 - Alternatively , if you need to use version 2.1.2 or lower - backport [this bugfix](https://github.com/YoYoGames/GMEXT-Steamworks/commit/962c208c794935c1dd262df2d2c5840a198b8272) that prevents modern powershell from going nuts (detailed info about bug are [here](https://github.com/YoYoGames/GMEXT-Steamworks/issues/120)) . I.e. just add line from bugfix into your extension file .

### To get started :
- Install runtime via GameMaker IDE and run your game project in IDE at least once to ensure that it is compilable .
- Rename `config.json.template` into `config.json` .
- Edit values of these required fields in `config.json` :
	- For `gamemaker_compiler` (Igor.exe) check runtimes path located in runtimes tab of the IDE preferences . Note that runtime will be selected to match compiler version .
	- For `licence_file` check `%AppData%\GameMakerStudio2\` .
	- `project_file` is a path to your project .yyp file .
	- And if you need YYC then you also need to fill `visual_studio_tools` which can be found somewhere around the place where "Windows Start"'s "native tools command prompt for VS" link points to .
		- **Again - VM does NOT need visual studio and this field .**
- Run `dpbs.ps1 -CompileVM` or `dpbs.ps1 -CompileYYC` or `dpbs.ps1 -CompileVM -CompileYYC` in default windows powershell ("powershell 7" is also supported) .

#### Optional settings :
- `additional_directories_to_include` - these directories will be copied to output folders at the end of the script work . Here is structure and example how to fill it :
	
		{
			"source": "destination relative to output folder",
			"D:/git/Mapping/": "./< project name >/Mapping/",
			"D:/Dropbox/Moosor/": "./< project name >/Moosor/"
		}
	
- Seting of `use_assets_cache` to `true` will speed up second and subsequent builds . But be aware that gamemaker can mess up cached assets (for various resons) , it is advised to keep this setting on `false` for production builds .
