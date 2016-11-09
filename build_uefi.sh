if [ ! -d ${EDK2_DIR} ]
then
	echo Environment variable EDK2_DIR[${EDK2_DIR}] not assigned or dir missing, quitting..
	exit -1
fi
if [ ! -d ${UEFI_TOOLS_DIR} ]
then
	echo Environment variable UEFI_TOOLS_DIR[${UEFI_TOOLS_DIR}] not assigned or dir missing, quitting..
	exit -1
fi
if [ ! -d ${ATF_DIR} ]
then
	echo Environment variable ATF_DIR[${ATF_DIR}] not assigned or dir missing, quitting..
	exit -1
fi
if [ ! -d ${OPTEE_DIR} ]
then
	echo Environment variable OPTEE_DIR[${OPTEE_DIR}] not assigned or dir missing, quitting..
	exit -1
fi
if [ ! -d OpenPlatformPkg ]
then
	echo OpenPlatformPkg -dir missing
	exit -1
fi


cd ${EDK2_DIR}
rmdir OpenPlatformPkg; ln -s ../OpenPlatformPkg
${UEFI_TOOLS_DIR}/uefi-build.sh -b RELEASE -a ${ATF_DIR} -s ${OPTEE_DIR} hikey
