# Copyright - 2015 - Jan Christoph Uhde <Jan@UhdeJC.com>

# INSTRUCTIONS
#
# Run the command below as administrator to enable the execution of powershell scripts:
# set-executionpolicy remotesigned
#
# Copy this file in a directory of your %PATH%. If you have added cmake.exe to the path
# this script must be contained in a folder appearing earlier in the %PATH% than the
# cmake installation folder.
#
# Change Variables in the next section so that the content matches you system's
# installation.
#

# cmake binary
$cmake     = "C:\Program Files (x86)\CMake\bin\cmake.exe"
$cmake_gui = "C:\Program Files (x86)\CMake\bin\cmake-gui.exe"

# prefix locations - cmake will look for libraries in these paths
$cm_prefix_in=@(
  "C:\local\boost_1_58_0",
  "C:\local\eigen",
  "C:\local\qt5"
)

# extra options - will be passed as `-Dkey="value"` to cmake
$cm_d_options=@{
  "DESTDIR" = "C:\local\";
  "BOOST_ROOT" = "C:\local\boost_1_58_0";
  "CMAKE_BUILD_TYPE" = "Debug"
}


### Do not touch code below!

# build value for %CMAKE_PREFIX_PATH%
$cm_prefix_out=$cm_prefix_in[0]
foreach ($prefix in $cm_prefix_in[1..($cm_prefix_in.length-1)]){
  $cm_prefix_out+=";$prefix"
}

# build extra arguments form hash
$cm_call_args = [System.Collections.ArrayList]@()
foreach ($item in $cm_d_options.GetEnumerator()){
  $rv = $cm_call_args.Add([string]::Format("-D{0:C}='{1:C}'", $item.Name, $item.Value))
}

# append args passed to the script
foreach ($arg in $args){
  $cm_call_args += $arg
}

# show vars
Echo "PREFIX:   $cm_prefix_out"
Echo "CALLARGS: $cm_call_args"

# set %CMAKE_PREFIX_PATH% environment variable
$env:CMAKE_PREFIX_PATH = $cm_prefix_out

# run command
Start-Process -FilePath "$cmake" -ArgumentList $cm_call_args -NoNewWindow -Wait
