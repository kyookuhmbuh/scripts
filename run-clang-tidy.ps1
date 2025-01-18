
[CmdletBinding(PositionalBinding=$false)]
param (
  [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
  $Path = ".",

  [Parameter()]
  $Filter = ("*.cpp","*.hpp","*.c","*.h"),

  [Parameter(ValueFromRemainingArguments=$true)]
  $Arguments
)

$ClangToolItem = Get-Item -Path $Path
$ClangToolFilter=($Filter)
$ClangToolWorkingDir = Get-Location
$ClangToolWorkingDir = "$ClangToolWorkingDir"
$ClangToolArgs = ($Arguments)

$ClangToolDataBasePath = `
    "$PSScriptRoot\.clang-tidy-database\" +
    "$($ClangToolItem.Parent)_$($ClangToolItem.Name)" +
    "_$($ClangToolItem.CreationTime.ToShortDateString())" +
    "_$($ClangToolItem.LastWriteTime.ToShortDateString())" 

echo "-- ClangToolItem=$ClangToolItem" 
echo "-- ClangToolArgs=$ClangToolArgs" 
echo "-- ClangToolFilter=$ClangToolFilter" 
echo "-- ClangToolWorkingDir=$ClangToolWorkingDir" 
echo "-- ClangToolDataBasePath=$ClangToolDataBasePath" 

# Run Visual Studio Developer Environment
function Run-VsDevShell() 
{
    $CurrentWorkingDir = Get-Location
    $VsInstallerPath = join-path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer';
    $VsWhere = join-path $VsInstallerPath vswhere.exe
    cd $VsInstallerPath
    $VsToolsPath = . $VsWhere -prerelease -latest -property installationPath
    . $VsToolsPath\'Common7\Tools\Launch-VsDevShell.ps1'
    cd $CurrentWorkingDir
}

Run-VsDevShell;

if([System.IO.File]::Exists($ClangToolItem)) 
{
    $ClangToolProcessFiles = ($ClangToolItem.FullName); 
}
else 
{
    $ClangToolProcessFiles = `
        Get-ChildItem -Path $ClangToolItem.FullName -File -Recurse -Include $ClangToolFilter `
        | %{ $_.FullName } ;

    cmake -S $ClangToolItem.FullName -B $ClangToolDataBasePath -G Ninja -D CMAKE_EXPORT_COMPILE_COMMANDS=1 -Wno-dev
    #cmake --build $ClangToolDataBasePath 
}

echo "-- ClangToolCommand=clang-tidy -p=$ClangToolDataBasePath $ClangToolArgs <Files...($(($ClangToolProcessFiles).Count))>" 

if ($($ClangToolProcessFiles).Count -ne 0) 
{
    clang-tidy "-p=$ClangToolDataBasePath" $ClangToolArgs $ClangToolProcessFiles
}
