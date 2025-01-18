
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

echo "-- ClangToolItem=$ClangToolItem" 
echo "-- ClangToolFilter=$ClangToolFilter" 
echo "-- ClangToolArgs=$ClangToolArgs" 
echo "-- ClangToolWorkingDir=$ClangToolWorkingDir" 

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
}

echo "-- ClangToolCommand=clang-format $ClangToolArgs <Files...($(($ClangToolProcessFiles).Count))>" 

if ($($ClangToolProcessFiles).Count -ne 0) 
{
    clang-format $ClangToolArgs $ClangToolProcessFiles
}
