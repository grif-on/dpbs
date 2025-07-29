#region Arguments

param (
	[switch]$CompileVM,
	[switch]$CompileYYC
)


if (!($CompileVM -or $CompileYYC)) {
	Write-Host "To use this script provide at least one of these arguments :"
	Write-Host "-CompileVM"
	Write-Host "-CompileYYC"
	Write-Host ""
	Write-Host "Note that you can combine -CompileVM and -CompileYYC in to one script call"
	
	exit
	
}

#endregion Arguments


#region Functions

function addAdditionalContent([string] $destination, $content_paths) {
	foreach ($path in $content_paths.PSObject.Properties) {
		Copy-Item -Path $path.Name -Destination "$($destination)/$($path.Value)" -Recurse -Force
	}
}

function printCurrentTime() {
	Write-Output "$((Get-Date).Hour):$((Get-Date).Minute):$((Get-Date).Second)"	
}

#endregion Functions


#region Main script part

$config = ConvertFrom-Json -InputObject (Get-Content -Path "config.json" -Raw)

$compiler_path_parts = $config.gamemaker_compiler.Replace("\", "/").Split("/")
$runtime_path_parts = $compiler_path_parts[0..($compiler_path_parts.Length - 5 - 1)]
Add-Member -InputObject $config -MemberType NoteProperty -Name gamemaker_runtime -Value $($runtime_path_parts -join "/")

if ($config.use_assets_cache) {
	if (Get-Item -Path "./temp/cache" -ErrorAction Ignore) {
		Write-Output "Old cache : found`n"
	} else {
		Write-Output "Old cache : no`n"
	}
} else {
	Write-Output "Cleaning up assets cache ..."
	Remove-Item -Path "./temp" -Recurse -Force -ErrorAction Ignore
	Write-Output "done`n"
}

# Creation of temp directory should be unconditional , in case user delete it manually
New-Item -Path "temp" -ItemType Directory -ErrorAction Ignore > $null

Write-Output "Cleaning up old builds ..."
Remove-Item -Path "./temp/output" -Recurse -Force -ErrorAction Ignore
Remove-Item -Path "./output_vm" -Recurse -Force -ErrorAction Ignore
Remove-Item -Path "./output_yyc" -Recurse -Force -ErrorAction Ignore
Write-Output "done`n"

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
		Write-Output "Compiling VM ..."
		& $config.gamemaker_compiler --project="$($config.project_file)" --rp="$($config.gamemaker_runtime)" --lf="$($config.licence_file)" Windows PackageZip > "compile_log_vm.txt"
		# New-Item -Path "output/" -ItemType Directory > $null
		Write-Output $note_about_intentional_error >> "compile_log_vm.txt"
		printCurrentTime
		
		Move-Item -Path "./output/" -Destination "../output_vm"
		Write-Output "done`n"
	}
	
	if ($CompileYYC) {
		printCurrentTime
		Write-Output "Compiling YYC ..."
		& $config.gamemaker_compiler --project="$($config.project_file)" --rp="$($config.gamemaker_runtime)" --lf="$($config.licence_file)" --runtime=YYC Windows PackageZip > "compile_log_yyc.txt"
		# New-Item -Path "output/" -ItemType Directory > $null
		Write-Output $note_about_intentional_error >> "compile_log_yyc.txt"
		printCurrentTime
		
		Move-Item -Path "./output/" -Destination "../output_yyc"
		Write-Output "done`n"
	}
} finally {
	Set-Location ".."
}

Write-Output "Adding additional content ..."
if ($CompileVM) {
	addAdditionalContent -destination "./output_vm/" -content_paths $config.additional_directories_to_include
}
if ($CompileYYC) {
	addAdditionalContent -destination "./output_yyc/" -content_paths $config.additional_directories_to_include
}
Write-Output "done`n"

#endregion Main script part