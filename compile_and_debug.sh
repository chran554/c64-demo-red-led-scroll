#!/bin/bash

assemblerFile="red_led_scroll.asm"
projectFileDir="."

utilities_path="~/projects/code/c64/c64-utilities"

# Get absolute path for supplied project path (no relative path)
cd $projectFileDir
projectFileDir=$(pwd)
cd -

"$utilities_path/compile_and_debug.sh" "$assemblerFile" . debug