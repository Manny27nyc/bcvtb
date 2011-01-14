#!/bin/bash
##############################################################
# This file sets environment variables for the BCVTB.
# 
# To run it, change to top level directory of the BCVTB and
# type
#  source bin/setenv.sh
# To force reseting variables, use
#  source bin/setenv.sh -f
#
# MWetter@lbl.gov                                   2008-07-15
##############################################################

##############################################################
# Don't run script twice, unless forced to do so
if [ "$1" != "-f" ]; then
    if test ${BCVTBEnvSet}; then
	echo "BCVTB environment already set. Doing nothing."
	echo "To set again, use 'source bin/setenv.sh -f'"
	return 1
    fi
else
    echo "Forcing reset of environment variables."
fi

##############################################################
# Ensure that we are in the top level directory of the BCVTB
# This is needed since we use the pwd command
if test ! "`ls bin/setenv.sh 2> /dev/null`"; then
	echo "Error: Script bcvbt.sh must be run from root directory"
        echo "       of the BCVTB and not from `pwd`"
        echo "       Exit with error."
	return 1
fi


# Set EnergyPlus version
BCVTB_EP_VERSION=4.0

PROPERTYFILE=build.properties
BCVTBUSEMS=true # Set to true to use Microsoft compiler, set to false to use cygwin

##############################################################
# Test if software is present, and set environment variables
if test "x" != "x$PTII"; then
    # PTII is set. Make sure that it contains the bcvtb configuration
    if [ ! -f "${PTII}/ptolemy/configs/bcvtb/configuration.xml" ]; then 
	echo "Error: PTII is set to $PTII"
        echo "       But this Ptolemy version does not contain the BCVTB configuration."
        echo "       You need to update to Ptolemy 8.1 or later."
        echo "       If you set PTII manually, you may want to unset it in order to use"
        echo "       the Ptolemy version that is distributed with the BCVTB."
        echo "       Exit with error."
	return 1
    fi
fi

# Check for vergil
##if test "x" == "x`which vergil`"; then
##    echo "Error: Did not find vergil which is needed to run Ptolemy."  
##    echo "       Did you install Ptolemy correctly?"
##    echo "       Exit with error."
##    return 1
##fi

# Check for ifort
if test ! "`which ifort 2> /dev/null`"; then
    echo "Fortran compiler not found: ifort."
    echo "  If Fortran is installed, make sure 'ifort' is on path."
fi

# Check for matlab
if test ! "`which matlab 2> /dev/null`"; then
    echo "Matlab not found."
    echo "  If Matlab is installed, make sure 'matlab' is on path."
fi

##############################################################
# Set directories

# top level directory of the BCVTB
BCVTB_HOME=`pwd`
# PTII directory for BCVTB
if test "x" == "x$PTII"; then
    export PTII=${BCVTB_HOME}/lib/ptII
fi



# MATLAB/Simulink libraries path
# This works for Mac OS X and Linux, but MATLABPATH leads
# to an error on Windows.
MATLABPATH=$MATLABPATH:$BCVTB_HOME/lib/matlab

# Java CLASSPATH
CLASSPATH=$BCVTB_HOME/lib:${PTII}:$CLASSPATH:$BCVTB_HOME/lib/cpptasks.jar
# Additions to classpath to compile Launcher
##CLASSPATH=${CLASSPATH}:${PTII}:${PTII}/lbnl/demo/demo.jar:${PTII}/ptolemy/domains/ct/ct.jar:${PTII}/doc/docConfig.jar:${PTII}/doc/codeDoc.jar:${PTII}/lib/diva.jar:${PTII}/ptolemy/ptsupport.jar:${PTII}/ptolemy/vergil/vergil.jar:${PTII}/ptolemy/domains/sdf/sdf.jar:${PTII}/ptolemy/domains/modal/modal.jar:${PTII}/ptolemy/domains/fsm/fsm.jar

# EnergyPlus directory
ENERGYPLUS_DIR=$BCVTB_HOME/clients/ep-${BCVTB_EP_VERSION}

# Ptolemy binary directory
# If ${PTII}/bin exist, we put it the path to allow users to switch to the
# official Ptolemy version.
if [ -d "${PTII}/bin" ]; then 
    PATH=${PTII}/bin:${BCVTB_HOME}/bin:${PATH}
else
    PATH=${BCVTB_HOME}/bin:${PATH}
fi

##############################################################
# System dependent environment variables
case `uname` in
    Linux)
	export LD_LIBRARY_PATH=$BCVTB_HOME/lib/util:$LD_LIBRARY_PATH
	PATH=$ENERGYPLUS_DIR/bin-linux:$PATH
	BCVTB_OS=linux
    ;;
    Darwin)
	export DYLD_LIBRARY_PATH=$BCVTB_HOME/lib/util:$DYLD_LIBRARY_PATH
	PATH=$ENERGYPLUS_DIR/bin-mac:$PATH
	BCVTB_OS=mac
    ;;*)
    	echo "setenv.sh: Unknown operating system: `uname`"
esac

##############################################################
# Set properties for ant build file
echo "// This file was autogenerated by $user on `date`" > $PROPERTYFILE
echo "// Changes to this file will be lost whenever" >> $PROPERTYFILE
echo "// bin/setenv.sh is executed."  >> $PROPERTYFILE
if test "`which ifort 2> /dev/null`"; then
    echo haveIfort=true >> $PROPERTYFILE
fi
if test "`which matlab 2> /dev/null`"; then
    echo haveMatlab=true >> $PROPERTYFILE
fi
if [ -d "${ENERGYPLUS_DIR}" ]; then
    echo haveEnergyPlus=true >> $PROPERTYFILE
fi
if test "`which doxygen 2> /dev/null`"; then
    echo haveDoxygen=true >> $PROPERTYFILE
fi
if test "`which dymola 2> /dev/null`"; then
    echo haveDymola=true >> $PROPERTYFILE
fi

##############################################################
# Export variables
export BCVTBEnvSet="true"
export CLASSPATH
export ENERGYPLUS_DIR
export PATH
export BCVTB_HOME
export MATLABPATH
# BCVTB_OS is needed by matlab to deterine the library names on Linux
export BCVTB_OS 
export BCVTB_PTIISrc=~/proj/bcvtb/code/ptII-devel