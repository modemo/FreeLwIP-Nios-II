#!/bin/sh

# FreeRTOS LwIP install script
#
#    This file is part of the FreeRTOS distribution.
#
#    FreeRTOS is free software; you can redistribute it and/or modify it under
#    the terms of the GNU General Public License (version 2) as published by the
#    Free Software Foundation AND MODIFIED BY the FreeRTOS exception.
#    >>>NOTE<<< The modification to the GPL is included to allow you to
#    distribute a combined work that includes FreeRTOS without being obliged to
#    provide the source code for proprietary components outside of the FreeRTOS
#    kernel.  FreeRTOS is distributed in the hope that it will be useful, but
#    WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
#    or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
#    more details. You should have received a copy of the GNU General Public
#    License and the FreeRTOS license exception along with FreeRTOS; if not it
#    can be viewed here: http://www.freertos.org/a00114.html and also obtained
#    by writing to Richard Barry, contact details for whom are available on the
#    FreeRTOS WEB site.
#
# Created by Engineering Spirit (c) 2012-2013 http://engineering-spirit.nl/
#

# header
cat << EOF
/***************************************************************************\ 
| Welcome to the FreeRTOS v7.2.0 with LwIP 1.4.1 installer!                 |
| This installer will will create an FreeRTOS BSP and LwIP software package |
| into your Nios II IDE. We'll also create a Demo application which you can |
| chose in your IDE to see how to work with this type of BSP / TCP/IP stack |
|                                                                           |
| This is free software; you can redistribute it and/or modify it under the |
| terms of the GNU General Public License (version 2) as published by the   |
| Free Software Foundation AND MODIFIED BY the FreeRTOS exception.          |
| >>>NOTE<<< The modification to the GPL is included to allow you to        |
| distribute a combined work that includes FreeRTOS without being obliged   |
| to provide the source code for proprietary components outside of the      |
| FreeRTOS kernel.  FreeRTOS is distributed in the hope that it will be     |
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of    |
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             |
| GNU General Public License for more details. You should have received a   |
| copy of the GNU General Public License and the FreeRTOS license exception |
| along with FreeRTOS; if not it can be viewed here:                        |
| http://www.freertos.org/a00114.html and also obtained by writing to       |
| Richard Barry, contact details for whom are available on the              |
| FreeRTOS WEB site.                                                        |
|                                                                           |
| Installer provided by:                                                    |
|         Engineering Spirit (c) 2012 http://engineering-spirit.nl/         |
\***************************************************************************/

EOF

# check argument count
if [ ! $# -eq 2 ]; then
	if [ ! -z "${OS}" ]; then
		echo "Don't call this script directly use alt-freertos-lwip-install.bat";
	else
		echo "Don't call this script directly use alt-freertos-lwip-install.sh";
	fi;
	
	exit 1;
fi;

# set path's needed for install
ALT_PATH="$1"
INST_PATH="$2"

# check if the arguments are not empty and valid
if [ "${ALT_PATH}" == "" ] || ! ls "${ALT_PATH}/nios2eds" &> /dev/null; then
	echo "Altera path could not found..." 1>&2;
	exit 1;
fi;

if [ "${INST_PATH}" == "" ] || ! ls "${INST_PATH}/freertos" &> /dev/null; then
	echo "Install path could not be found..." 1>&2;
	exit 1;
fi;

# are we agreeing?
read -p " Do you agree to the GNU GPL? [type y/yes] > " ANS

if [ "${ANS}" != "yes" ] && [ "${ANS}" != "y" ]; then
	exit 1;
fi;

# make directories just to be sure
mkdir -p FreeRTOS_src 2> /dev/null;
mkdir -p lwip 2> /dev/null;

# auto update for later
which 2> /dev/null;
if [ $? -eq 255 ]; then
	if which wget &> /dev/null && which curl &> /dev/null && which unzip &> /dev/null; then
		# check for FreeRTOS update
		NEW_VERSION=`curl "http://sourceforge.net/projects/freertos/files/FreeRTOS/" -s | grep -o "V[0-9].[0-9].[0-9]" | head -1`;
		CUR_VERSION=`cat FreeRTOS_src/.cur_version 2>&1`;
		
		if [ "${NEW_VERSION}" != "${CUR_VERSION}" ]; then
			echo -e "\nNew FreeRTOS version found: ${NEW_VERSION}\n Downloading please wait...";
			wget "http://downloads.sourceforge.net/project/freertos/FreeRTOS/${NEW_VERSION}/FreeRTOS${NEW_VERSION}.zip" -O FreeRTOS_src/FreeRTOS${NEW_VERSION}.zip;
			cd FreeRTOS_src;
			echo "Download done! Unpacking... please wait...";
			unzip -qq -o FreeRTOS${NEW_VERSION}.zip; # -qq
			echo "Updating files...";
			rm -r Demo License Source readme.txt 2> /dev/null;
			mv FreeRTOS${NEW_VERSION}/FreeRTOS/* .;
			rm -r FreeRTOS${NEW_VERSION} FreeRTOS${NEW_VERSION}.zip;
			cd ..;
			echo ${NEW_VERSION} > FreeRTOS_src/.cur_version;
		else
			echo -e "\nFreeRTOS up to date! Using: ${NEW_VERSION}\n";
		fi;
		
		# can't auto update LwIP because of a lot of changes to the default LwIP
		# source tree
	fi;
fi;

if [ ! -e "FreeRTOS_src" ] || [ ! -e "lwip" ]; then
	# dummy... will always be false now ;)
	echo "Can't find FreeRTOS / LwIP sources! Please download the latest sources and place them in the FreeRTOS_src!" 1>&2;
fi;

# set some other path
COMPONENTS="${ALT_PATH}/nios2eds/components";
EXAMPLES="${ALT_PATH}/nios2eds/examples/software";

# get the right file access rights for Windows 7 machines
echo " - Silently setting rw POSIX access on the distribution files to avoid access troubles..";
chmod -Rf u+rw FreeRTOS_src > /dev/null
chmod -Rf u+rw freertos_demo > /dev/null
chmod -Rf u+rw nios2_freertos_port > /dev/null
chmod -Rf u+rw altera_nios2 > /dev/null
chmod -Rf u+rw freertos > /dev/null
chmod -Rf u+rw lwip > /dev/null

echo -e "\n1. Preparing software Nios II Packages!";

# copy all source files we need
echo "    - Copy FreeRTOS sources";
cp FreeRTOS_src/Source/croutine.c "${INST_PATH}/freertos/FreeRTOS/src";
cp FreeRTOS_src/Source/portable/MemMang/heap_3.c "${INST_PATH}/freertos/FreeRTOS/src";
cp FreeRTOS_src/Source/list.c "${INST_PATH}/freertos/FreeRTOS/src";

cp nios2_freertos_port/port.c "${INST_PATH}/freertos/FreeRTOS/src/";
cp nios2_freertos_port/port_asm.S "${INST_PATH}/freertos/FreeRTOS/src/";

cp FreeRTOS_src/Source/queue.c "${INST_PATH}/freertos/FreeRTOS/src";
cp FreeRTOS_src/Source/tasks.c "${INST_PATH}/freertos/FreeRTOS/src";
cp FreeRTOS_src/Source/timers.c "${INST_PATH}/freertos/FreeRTOS/src";

# copy all header files we need
echo "    - Copy FreeRTOS headers";
cp FreeRTOS_src/Source/include/croutine.h "${INST_PATH}/freertos/FreeRTOS/inc";
cp FreeRTOS_src/Source/include/FreeRTOS.h "${INST_PATH}/freertos/FreeRTOS/inc";
cp FreeRTOS_src/Source/include/list.h "${INST_PATH}/freertos/FreeRTOS/inc";
cp FreeRTOS_src/Source/include/mpu_wrappers.h "${INST_PATH}/freertos/FreeRTOS/inc";
cp FreeRTOS_src/Source/include/portable.h "${INST_PATH}/freertos/FreeRTOS/inc";

cp nios2_freertos_port/portmacro.h "${INST_PATH}/freertos/FreeRTOS/inc";

cp FreeRTOS_src/Source/include/projdefs.h "${INST_PATH}/freertos/FreeRTOS/inc";
cp FreeRTOS_src/Source/include/queue.h "${INST_PATH}/freertos/FreeRTOS/inc";
cp FreeRTOS_src/Source/include/semphr.h "${INST_PATH}/freertos/FreeRTOS/inc";
cp FreeRTOS_src/Source/include/StackMacros.h "${INST_PATH}/freertos/FreeRTOS/inc";
cp FreeRTOS_src/Source/include/task.h "${INST_PATH}/freertos/FreeRTOS/inc";
cp FreeRTOS_src/Source/include/timers.h "${INST_PATH}/freertos/FreeRTOS/inc";

# copy demo files
echo "    - Copy FreeRTOS demo files";
mkdir -p "${INST_PATH}/freertos_demo/common";
mkdir -p "${INST_PATH}/freertos_demo/inc";
cp FreeRTOS_src/Demo/Common/minimal/BlockQ.c "${INST_PATH}/freertos_demo/common/";
cp FreeRTOS_src/Demo/Common/minimal/blocktim.c "${INST_PATH}/freertos_demo/common/";
cp FreeRTOS_src/Demo/Common/minimal/countsem.c "${INST_PATH}/freertos_demo/common/";
cp FreeRTOS_src/Demo/Common/minimal/death.c "${INST_PATH}/freertos_demo/common/";
cp FreeRTOS_src/Demo/Common/minimal/dynamic.c "${INST_PATH}/freertos_demo/common/";
cp FreeRTOS_src/Demo/Common/minimal/GenQTest.c "${INST_PATH}/freertos_demo/common/";
cp FreeRTOS_src/Demo/Common/minimal/integer.c "${INST_PATH}/freertos_demo/common/";
cp FreeRTOS_src/Demo/Common/minimal/PollQ.c "${INST_PATH}/freertos_demo/common/";
cp FreeRTOS_src/Demo/Common/minimal/QPeek.c "${INST_PATH}/freertos_demo/common/";
cp FreeRTOS_src/Demo/Common/minimal/recmutex.c "${INST_PATH}/freertos_demo/common/";
cp FreeRTOS_src/Demo/Common/minimal/semtest.c "${INST_PATH}/freertos_demo/common/";
cp FreeRTOS_src/Demo/Common/include/* "${INST_PATH}/freertos_demo/inc";

echo -e "\n2. Copying packages to Nios II IDE"

# now lets copy our stuff to the altera directory
echo -n "    - FreeRTOS..........: ";
if cp -rf "${INST_PATH}/freertos" "${COMPONENTS}"; then
	echo "Success";
else
	echo "Failed with error code: $?";
fi;

echo -n "    - FreeRTOS+ Trace...: ";
if cp -rf "${INST_PATH}/freertos_plus_trace" "${COMPONENTS}"; then
	echo "Success";
else
	echo "Failed with error code: $?";
fi;

echo -n "    - LwIP..............: ";
if cp -rf "${INST_PATH}/lwip" "${COMPONENTS}"; then
	echo "Success";
else
	echo "Failed with error code: $?";
fi;

echo -n "    - HAL...............: ";
if cp -rf "${INST_PATH}/altera_nios2" "${COMPONENTS}"; then
	echo "Success";
else
	echo "Failed with error code: $?";
fi;

#echo -n "    - Driver............: ";
#if cp -rf "${INST_PATH}/altera_triple_speed_ethernet" "${ALT_PATH}/ip/altera/triple_speed_ethernet/lib/sopc_builder"; then
#	echo "Success";
#else
#	echo "Failed with error code: $?";
#fi;

echo -n "    - Hello World.......: ";
if cp -rf "${INST_PATH}/hello_freertos" "${EXAMPLES}"; then
	echo "Success";
else
	echo "Failed with error code: $?";
fi;

echo -n "    - LwIP Demo.........: ";
if cp -rf "${INST_PATH}/freertos_demo" "${EXAMPLES}"; then
	echo "Success";
else
	echo "Failed with error code: $?";
fi;

# goto component the directory
echo -e "\n3. Updating TCL / packed generation scripts";
cd "${COMPONENTS}"

# Update all TCL scripts in the components directory so the IDE can use them
IFS_B=$IFS;
IFS=$'\n';

for f in `find . -iname "*.tcl" -print`; do
	if grep "# This driver supports HAL & UCOSII BSP (OS) types" "$f" > /dev/null; then
		# only update the files if FreeRTOS is not yet found in the files
		if ! grep "FreeRTOS" "$f" > /dev/null; then
			# replace header and insert the FreeRTOS BSP support
			sed -i "s/^# This driver supports HAL & UCOSII BSP (OS) types&/# This driver supports HAL, UCOSII & FreeRTOS BSP (OS) types/g" "$f";
			sed -i "s/^add_sw_property supported_bsp_type UCOSII$/add_sw_property supported_bsp_type UCOSII\r\nadd_sw_property supported_bsp_type FreeRTOS/g" "$f";
			
			echo "    Updated.......: ${f}";
		else
			echo "    Already Done..: ${f}";
		fi;
	else
		echo "    Skipped.......: ${f}";
	fi;
done;

IFS=$IFS_B;

# re-generate the components.ipx file for rockin and rollin
echo -e "\n4. Re-Generating compontents.ipx to enable the packages in the Nios II IDE\n This could take a while, please stand by...";
# All data belongs to us =)
OUTPUT=`ip-make-ipx.exe --source-directory=. --output=components.ipx 2>&1`;

if [ $? -eq 0 ]; then
	# Great succes!
	echo "    Including:";
	for f in `echo "${OUTPUT}" | grep -o "[a-zA-Z0-9_/]*.tcl"`; do
		echo "    - ${f}";
	done;
	echo -e "\n    Summary:";
	echo "    - "`echo "${OUTPUT}" | grep -o "Found [0-9]* components"`;

	# clean up all copied stuff
	rm "${INST_PATH}/freertos/FreeRTOS/src/croutine.c";
	rm "${INST_PATH}/freertos/FreeRTOS/src/heap_3.c";
	rm "${INST_PATH}/freertos/FreeRTOS/src/list.c";
	rm "${INST_PATH}/freertos/FreeRTOS/src/port.c";
	rm "${INST_PATH}/freertos/FreeRTOS/src/port_asm.S";
	rm "${INST_PATH}/freertos/FreeRTOS/src/queue.c";
	rm "${INST_PATH}/freertos/FreeRTOS/src/tasks.c";
	rm "${INST_PATH}/freertos/FreeRTOS/src/timers.c";

	rm "${INST_PATH}/freertos/FreeRTOS/inc/croutine.h";
	rm "${INST_PATH}/freertos/FreeRTOS/inc/FreeRTOS.h";
	rm "${INST_PATH}/freertos/FreeRTOS/inc/list.h";
	rm "${INST_PATH}/freertos/FreeRTOS/inc/mpu_wrappers.h";
	rm "${INST_PATH}/freertos/FreeRTOS/inc/portable.h";
	rm "${INST_PATH}/freertos/FreeRTOS/inc/portmacro.h";
	rm "${INST_PATH}/freertos/FreeRTOS/inc/projdefs.h";
	rm "${INST_PATH}/freertos/FreeRTOS/inc/queue.h";
	rm "${INST_PATH}/freertos/FreeRTOS/inc/semphr.h";
	rm "${INST_PATH}/freertos/FreeRTOS/inc/StackMacros.h";
	rm "${INST_PATH}/freertos/FreeRTOS/inc/task.h";
	rm "${INST_PATH}/freertos/FreeRTOS/inc/timers.h";

	rm -r "${INST_PATH}/freertos_demo/common/";
	rm -r "${INST_PATH}/freertos_demo/inc";
	
	# Inform the user we are done here...
	echo -e "\n5. Start your Nios II IDE and create a new BSP with FreeRTOS and include the LwIP software package, our create the new FreeRTOS + LwIP demo application";
else
	# Problem?
	echo " --- FAILURE --- FAILURE --- FAILURE --- FAILURE --- FAILURE ---";
	echo "${OUTPUT}";
	echo " --- FAILURE --- FAILURE --- FAILURE --- FAILURE --- FAILURE ---";
fi;

echo -e "\n Done!\nPress the any key to continue...";
read