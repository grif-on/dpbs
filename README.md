# Delirious Production Build Script

#### A simple powershell script for compiling a GameMaker project in a terminal / console .

It only covers compilation of VM and YYC for windows .
But you should be fine in case you need to tailor it for your other target platforms .

Installation of runtimes and obtaining a license token is intended to be done via GameMaker IDE (but you can do this via Igor.exe directly if you ***really*** need to) .

### IMPORTANT :
If you are using the [steamworks GameMaker extension](https://github.com/YoYoGames/GMEXT-Steamworks) - you need to either :
 - Ensure that you have steamworks extension version 2.1.3 or higher (it contains an important bugfix) .
 - Alternatively , if you need to use version 2.1.2 or lower - backport [this bugfix](https://github.com/YoYoGames/GMEXT-Steamworks/commit/962c208c794935c1dd262df2d2c5840a198b8272) that prevents modern powershell from going nuts (detailed info about the bug are [here](https://github.com/YoYoGames/GMEXT-Steamworks/issues/120)) . In other words , just add the line from the bugfix to your extension file .

### To get started :
- Install the runtime via GameMaker IDE , and then run your game project in the IDE at least once to ensure that it is compilable .
- Make a copy of `config.json.template` and name it `config.json` .
- Edit values of the required fields in `config.json` :
	- For `gamemaker_compiler` (Igor.exe) check the runtimes path located in the runtimes tab of the IDE preferences . Note that the runtime will be selected to match compiler version .
	- For `licence_file` check `%AppData%\GameMakerStudio2\` .
	- `project_file` is a path to your project .yyp file .
	- And if you need YYC , then you also need to fill in the `visual_studio_tools` , which can be found somewhere around the place where "Windows Start"'s "native tools command prompt for VS" link is points to .
		- **Again - the VM compilation does NOT need visual studio and this field .**
- Run `dpbs.ps1 -CompileVM` or `dpbs.ps1 -CompileYYC` or `dpbs.ps1 -CompileVM -CompileYYC` in the default windows powershell ("powershell 7" is also supported) .

### Optional settings and features :
- All paths in config file , except right side (values) of additional_directories_to_include , can work with both - absolute paths and paths relative to config file directory .
- `additional_directories_to_include` - these directories will be copied to output folders at the end of the script work . Here is the structure and an example of how to fill it :
	
		{
			"source path (absolute or relative to config file directory)": "destination relative to output folder",
			"D:/git/Mapping/": "./< project name >/Mapping/",
			"D:/Dropbox/Moosor/": "./< project name >/Moosor/"
		}
	
- Setting of `use_assets_cache` to `true` will speed up second and subsequent builds . However , be aware that gamemaker can mess up cached assets (for various reasons) , so it is advised to keep this setting on `false` for production builds .
