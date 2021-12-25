#!/bin/bash

# check that the provided examples (which do not have a reference case) compile and run for a few loops

rep_example_list="HD/KHI HD/RWI-cavity HD/VSI MHD/AmbipolarShearingBox MHD/AmbipolarWind MHD/FieldLoop MHD/HallDisk MHD/HallWhistler MHD/disk MHD/diskSpherical"

# refer to the parent dir of this file, wherever this is called from
# a python equivalent is e.g.
#
# import pathlib
# TEST_DIR = pathlib.Path(__file__).parent
TEST_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"


function resolve_path {
    # resolve relative paths
    # work around the fact that `realpath` is not bundled with every UNIX distro
    echo "`cd "$1";pwd`"
}

target_dir=$(resolve_path $TEST_DIR/..)

if [ -z ${var+IDEFIX_DIR} ] & [ -d "$IDEFIX_DIR" ] ; then
    global_dir=$(resolve_path $IDEFIX_DIR)
    if [ $target_dir != $global_dir ] ; then
        echo \
        "Warning: IDEFIX_DIR is set globally to $global_dir" \
        ", but is redefined to $target_dir"
    fi
fi

export IDEFIX_DIR=$target_dir
echo $IDEFIX_DIR

set -e
options=$@

# HD tests
for rep in $rep_example_list; do
    cd $TEST_DIR/$rep
    echo "***********************************************"
    echo "Configuring  $rep"
    echo "***********************************************"
    rm -f CMakeCache.txt

    cmake $IDEFIX_DIR || { echo "!!!! Example $rep failed during configuration"; exit 1; }
    echo "***********************************************"
    echo "Making  $rep"
    echo "***********************************************"
    make clean; make -j 4 || { echo "!!!! Example $rep failed during compilation"; exit 1; }


    echo "***********************************************"
    echo "Running  $rep"
    echo "***********************************************"
    ./idefix -maxcycles 10 || { echo "!!!! Example $rep failed running"; exit 1; }

    make clean
    rm -f *.vtk *.dbl

done
