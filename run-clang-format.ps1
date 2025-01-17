
param (
 $Path   
)

$ClangToolItem = Get-Item -Path $Path
$ClangToolWorkingDir = $PSScriptRoot # or Get-Location
$ClangToolWorkingDir = "$ClangToolWorkingDir"

$ClangToolArgs = ($MyInvocation.UnboundArguments)

echo "-- ClangToolItem=$ClangToolItem" 
echo "-- ClangToolArgs=$ClangToolArgs" 
echo "-- ClangToolWorkingDir=$ClangToolWorkingDir" 
echo "-- ClangToolDataBasePath=$ClangToolDataBasePath" 

# Visual Studio Developer Environment
. $env:VS140COMNTOOLS\'Launch-VsDevShell.ps1'
cd $ClangToolWorkingDir

if([System.IO.File]::Exists($ClangToolItem)) 
{
    $ClangToolProcessFiles = ($ClangToolItem.FullName); 
}
else 
{
    $ClangToolProcessFiles = `
        Get-ChildItem -Path $ClangToolItem.FullName -File -Recurse -Include "*.cpp","*.hpp","*.c","*.h" `
        | %{ $_.FullName } ;
}

echo "-- ClangToolCommand=clang-format $ClangToolArgs <Files...($(($ClangToolProcessFiles).Count))>" 
clang-format $ClangToolArgs $ClangToolProcessFiles
