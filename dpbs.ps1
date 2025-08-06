#region Arguments

param (
	[switch]$CompileVM, # Can be combined wiht -CompileYYC in a single script call
	[switch]$CompileYYC, # Can be combined wiht -CompileVM in a single script call
	[switch]$CleanUp, # Clean up cahce , logs and previously compiled files
	[string]$ConfigFilePath # By default the script will use config.json near the script file , but you can supply path to different config file
)

if (!($CompileVM -or $CompileYYC -or $CleanUp)) {
	Write-Host "To use this script provide at least one of these arguments :"
	Write-Host "-CompileVM"
	Write-Host "-CompileYYC"
	Write-Host "-CleanUp"
	Write-Host ""
	Write-Host "Note that you can combine -CompileVM and -CompileYYC in to one script call"
	
	exit
	
}

# Ignore compile arguments if already got clean up argument
if ($CleanUp -and ($CompileVM -or $CompileYYC)) {
	Write-Host "Note - you can't use -CleanUp and compile project at the same time !`n"
	$CompileVM = $false
	$CompileYYC = $false
}

if ($ConfigFilePath -eq "") {
	$ConfigFilePath = "./config.json"
}

#endregion Arguments


#region Functions

function addAdditionalContent([string] $destination, [hashtable] $content_paths) {
	foreach ($source_path in $content_paths.Keys) {
		$destination_subpath = $content_paths[$source_path]
		Copy-Item -Path $source_path -Destination "$($destination)/$($destination_subpath)" -Recurse -Force
	}
}

function printCurrentTime() {
	$date = Get-Date 
	Write-Host "$($date.Hour):$($date.Minute):$($date.Second)"	
}

function resolvePathForPairInHashtable([hashtable] $hashtable, [string] $pair_name, [switch] $in_value, [switch] $in_name) {
	if ($in_value) {
		$hashtable[$pair_name] = Resolve-Path -Path $hashtable[$pair_name]
	}
	if ($in_name) {
		$new_pair_name = Resolve-Path -Path $pair_name
		$hashtable[$new_pair_name] = $hashtable[$pair_name]
		$hashtable.Remove($pair_name)
	}
}

#endregion Functions


#region Main script part

if (!$CleanUp) {
	if (!(Test-Path -Path $ConfigFilePath)) {
		Write-Host "Can't find config file !"
		Write-Host "Make sure that `"$ConfigFilePath`" exists .`n"
		
		exit
	}
	
	$raw_config = ConvertFrom-Json -InputObject (Get-Content -Path $ConfigFilePath -Raw)

	$config = @{}
	foreach ($pair in $raw_config.PSObject.Properties) {
		if ($pair.Value -is [string] -or $pair.Value -is [bool]) {
			$config[$pair.Name] = $pair.Value
		}
		elseif ($pair.Value -is [PSCustomObject]) {
			$inner_hashtable = @{}
			foreach ($inner_pair in $pair.Value.PSObject.Properties) {
				$inner_hashtable[$inner_pair.Name] = $inner_pair.Value
			}
			$config[$pair.Name] = $inner_hashtable
		}
		else {
			
			Write-Error "Wrong data type in one of the config fields"
			exit
			
		}
	}
	
	$compiler_path_parts = $config.gamemaker_compiler.Replace("\", "/").Split("/")
	$runtime_path_parts = $compiler_path_parts[0..($compiler_path_parts.Length - 5 - 1)]
	$config.gamemaker_runtime = ($runtime_path_parts -join "/")
	
	$initial_location = Get-Location
	try {
		$config_file_directory = Split-Path -Parent (Resolve-Path -Path $ConfigFilePath)
		Set-Location $config_file_directory
		
		# We need to .Clone() Keys since we don't want to (and will not be allowed) itterate over new/chaged/deleted fields of hashtable
		foreach ($setting_name in $config.Keys.Clone()) {
			$setting_value = $config[$setting_name]
			if ($setting_value -is [bool]) {
				# not a path
			}
			elseif ($setting_value -is [string]) {
				resolvePathForPairInHashtable -hashtable $config -pair_name $setting_name -in_value
			}
			elseif ($setting_value -is [hashtable]) {
				foreach ($subsetting_name in $setting_value.Keys.Clone()) {
					resolvePathForPairInHashtable -hashtable $setting_value -pair_name $subsetting_name -in_name
				}
			}
			else {
				
				Write-Error "Wrong data type in one of the config's hastable fields"
				exit
				
			}
		}
	}
	finally {
		Set-Location $initial_location
	}
}

if ($config.use_assets_cache -and !$CleanUp) {
	if (Get-Item -Path "./temp/cache" -ErrorAction Ignore) { # todo - rewrite with Test-Path
		Write-Host "Old cache : found`n"
	} else {
		Write-Host "Old cache : no`n"
	}
} else {
	Write-Host "Cleaning up assets cache ..."
	Remove-Item -Path "./temp" -Recurse -Force -ErrorAction Ignore
	Write-Host "DONE`n"
}

Write-Host "Cleaning up old builds ..."
Remove-Item -Path "./temp/output" -Recurse -Force -ErrorAction Ignore
Remove-Item -Path "./output_vm" -Recurse -Force -ErrorAction Ignore
Remove-Item -Path "./output_yyc" -Recurse -Force -ErrorAction Ignore
Write-Host "DONE`n"

if ($CleanUp) {
	exit
}

# Creation of temp directory should be unconditional , in case user delete it manually
New-Item -Path "temp" -ItemType Directory -ErrorAction Ignore > $null

$note_about_intentional_error = "`nPlease , don't mind the `"Empty file name is not legal`" error .`nAs far as i can tell , this is the only way to make gamemaker skip zipping of files :)"

if ($CompileYYC) {
	# Igor.exe is hardcoded to read location of VsDevCmd.bat from this file
	Set-Content -NoNewline -Path "./temp/local_settings.json" -Value ("{ `"machine.Platform Settings.Windows.visual_studio_path`": `"" + $config.visual_studio_tools + "`" }")
}

try {
	Set-Location "./temp"
	
	# Gamemaker macro-expanse (sets) GM_build_date somewhere on the start of compilation .
	# And since VM compiles faster than YYC , compiling VM first and then YYC will make their GM_build_date more closer to each others .
	# In other words - difference of GM_build_date inside VM and YYC data.win files is a roughly a time spent on compiling first thing .
	
	if ($CompileVM) {
		printCurrentTime
		Write-Host "Compiling VM ..."
		& $config.gamemaker_compiler --project="$($config.project_file)" --rp="$($config.gamemaker_runtime)" --lf="$($config.licence_file)" Windows PackageZip > "compile_log_vm.txt"
		# New-Item -Path "output/" -ItemType Directory > $null
		Write-Output $note_about_intentional_error >> "compile_log_vm.txt"
		printCurrentTime
		
		Move-Item -Path "./output/" -Destination "../output_vm"
		Write-Host "DONE`n"
	}
	
	if ($CompileYYC) {
		printCurrentTime
		Write-Host "Compiling YYC ..."
		& $config.gamemaker_compiler --project="$($config.project_file)" --rp="$($config.gamemaker_runtime)" --lf="$($config.licence_file)" --runtime=YYC Windows PackageZip > "compile_log_yyc.txt"
		# New-Item -Path "output/" -ItemType Directory > $null
		Write-Output $note_about_intentional_error >> "compile_log_yyc.txt"
		printCurrentTime
		
		Move-Item -Path "./output/" -Destination "../output_yyc"
		Write-Host "DONE`n"
	}
} finally {
	Set-Location ".."
}

Write-Host "Adding additional content ..."
if ($CompileVM) {
	addAdditionalContent -destination "./output_vm/" -content_paths $config.additional_directories_to_include
}
if ($CompileYYC) {
	addAdditionalContent -destination "./output_yyc/" -content_paths $config.additional_directories_to_include
}
Write-Host "DONE`n"

#endregion Main script part