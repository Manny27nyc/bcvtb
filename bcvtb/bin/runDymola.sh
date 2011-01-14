#!/bin/bash
##############################################################
# Script to run Dymola.
# This script is called by the BCVTB to run Dymola on Linux.
#
# If dsin.txt and dymosim exists, then 
# dymosim is started.
# Otherwise, Dymola is started and the passed file executed.
# 
# mwetter@lbl.gov                                   2010-01-20
##############################################################
DYMPAT=/opt/dymola
##############################################################
# Checking for Dymola
if ! test "`which dymola 2> /dev/null`"; then
    echo "Error: Did not find executable 'dymola'."
    echo "       Make sure dymola is on your PATH."
    echo "       Exit with error."
    exit 1
fi
##############################################################
# Checking for BCVTB dll's to be installed Dymola

if [ ! -f ${DYMPAT}/bin/lib/libbcvtb_modelica.so ]; then
    echo "Error: Expected file ${DYMPAT}/bin/lib/libbcvtb_modelica.so"
    echo "       You may need to copy"
    echo "       $BCVTB_HOME/lib/modelica/libbcvtb_modelica.so"
    echo "       to ${DYMPAT}/bin/lib"
    echo "       Exit with error."
    exit 1
fi
if [ ! -f ${DYMPAT}/bin/lib/libbcvtb.so ]; then
    echo "Error: Expected file ${DYMPAT}/bin/lib/libbcvtb.so"
    echo "       You may need to copy"
    echo "       $BCVTB_HOME/lib/util/libbcvtb.so"
    echo "       to ${DYMPAT}/bin/lib"
    echo "       Exit with error."
    exit 1
fi
##############################################################
# Getting file extension
mosfile=$1
echo 
ext=${mosfile#*.}
if [ "${ext}" != "mos" ]; then
    echo "Error: First argument of $0 must be mos file."
    echo "       Received $*"
    echo "       Exit with error."
    exit 1
fi

##############################################################
# Deleting temporary files generated by dymola
temFil="buildlog.txt dsfinal.txt dslog.txt request. dsmodel.c dsres.mat"
for ff in $temFil; do
    rm -f $ff;
done

##############################################################
# Checking if dymosim.exe and dsin.txt exist
if [[ -f "dymosim" && -f "dsin.txt" ]]; then
    export LD_LIBRARY_PATH=${DYMPAT}/bin/lib
    ./dymosim -s
    exiVal=$?
else
   # Copy files needed by Dymola
    ln -s -f "${BCVTB_HOME}/lib/modelica/bcvtb.h"
    dymola $*
    rm -f bcvtb.h
    exiVal=$?
fi
exit $exiVal
