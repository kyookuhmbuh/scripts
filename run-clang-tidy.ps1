
param (
 $Path   
)

$ClangToolItem = Get-Item -Path $Path
$ClangToolWorkingDir = $PSScriptRoot # or Get-Location
$ClangToolWorkingDir = "$ClangToolWorkingDir"

$ClangToolDataBasePath = `
    "$ClangToolWorkingDir\.clang-tidy-database\" +
    "$($ClangToolItem.Parent)_$($ClangToolItem.Name)" +
    "_$($ClangToolItem.CreationTime.ToShortDateString())" +
    "_$($ClangToolItem.LastWriteTime.ToShortDateString())" 

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

    cmake -S $ClangToolItem.FullName -B $ClangToolDataBasePath -G Ninja -D CMAKE_EXPORT_COMPILE_COMMANDS=1 -Wno-dev
    #cmake --build $ClangToolDataBasePath 
}

echo "-- ClangToolCommand=clang-tidy -p=$ClangToolDataBasePath $ClangToolArgs <Files...($(($ClangToolProcessFiles).Count))>" 
clang-tidy "-p=$ClangToolDataBasePath" $ClangToolArgs $ClangToolProcessFiles
