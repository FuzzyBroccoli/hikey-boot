default: all

.PHONY: all
all: clone tools uefi l-loader/ptable.img boot.img
	echo Original instructions were found in https://github.com/Linaro/documentation/blob/master/Reference-Platform/RPOfficial/ConsumerEdition/HiKey/BuildSourceBL.md
	echo All done.


.PHONY: clone
clone: edk2 OpenPlatformPkg arm-trusted-firmware l-loader uefi-tools optee_os
	echo Clone done.


edk2:   
	git clone -b hikey-aosp https://github.com/96boards-hikey/edk2.git

OpenPlatformPkg:
	git clone -b hikey-aosp https://github.com/96boards-hikey/OpenPlatformPkg.git

arm-trusted-firmware:
	git clone -b hikey      https://github.com/96boards-hikey/arm-trusted-firmware.git

l-loader:
	git clone               https://github.com/96boards-hikey/l-loader.git

uefi-tools:
	git clone -b hikey-aosp https://github.com/96boards-hikey/uefi-tools.git

optee_os:
	git clone https://github.com/OP-TEE/optee_os.git

export_paths.sh:
	echo export AARCH64_TOOLCHAIN=GCC49              > export_paths.sh
	echo export EDK2_DIR=${PWD}/edk2                >> export_paths.sh
	echo export OPTEE_DIR=${PWD}/optee_os           >> export_paths.sh
	echo export ATF_DIR=${PWD}/arm-trusted-firmware >> export_paths.sh
	echo export UEFI_TOOLS_DIR=${PWD}/uefi-tools    >> export_paths.sh


.PHONY: tools
tools: arm-tc53 arm64-tc53 53_path.sh
	set -e; \
	. ./53_path.sh; \
	echo On call: ${PATH};\
	echo On run:  $$PATH ;\
	echo Path is valid only for one command;\
	arm-linux-gnueabihf-gcc --version ;\
	echo Tools done.

gcc-linaro-5.3-2016.02-x86_64_arm-linux-gnueabihf.tar.xz:
	wget http://releases.linaro.org/components/toolchain/binaries/5.3-2016.02/arm-linux-gnueabihf/gcc-linaro-5.3-2016.02-x86_64_arm-linux-gnueabihf.tar.xz

gcc-linaro-5.3-2016.02-x86_64_aarch64-linux-gnu.tar.xz:
	wget http://releases.linaro.org/components/toolchain/binaries/5.3-2016.02/aarch64-linux-gnu/gcc-linaro-5.3-2016.02-x86_64_aarch64-linux-gnu.tar.xz

arm-tc53: gcc-linaro-5.3-2016.02-x86_64_arm-linux-gnueabihf.tar.xz
	mkdir arm-tc53
	tar --strip-components=1 -C ${PWD}/arm-tc53 -xf gcc-linaro-5.3-2016.02-x86_64_arm-linux-gnueabihf.tar.xz
           
arm64-tc53: gcc-linaro-5.3-2016.02-x86_64_aarch64-linux-gnu.tar.xz
	mkdir arm64-tc53
	tar --strip-components=1 -C ${PWD}/arm64-tc53 -xf gcc-linaro-5.3-2016.02-x86_64_aarch64-linux-gnu.tar.xz

53_path.sh:
	echo PATH="${PWD}/arm-tc53/bin:${PWD}/arm64-tc53/bin:${PATH}" > 53_path.sh


uefi: clone tools build_uefi.sh export_paths.sh
	set -e; \
	. ./53_path.sh; \
	. ./export_paths.sh; \
	echo building BL1,2,3 ;\
	./build_uefi.sh

#Package of BL2, BL3-0, BL3-1, BL3-2 and BL3-3
arm-trusted-firmware/build/hikey/release/fip.bin: uefi
	echo ./arm-trusted-firmware/build/hikey/release/fip.bin build done.
.PHONY: fib.bin
fib.bin: arm-trusted-firmware/build/hikey/release/fip.bin


l-loader/ptable.img: l-loader tools build_ptable.sh export_paths.sh
	set -e; \
	. ./53_path.sh; \
	. ./export_paths.sh; \
	echo building ptable.img and l-loader.bin ;\
	./build_ptable.sh 

l-loader/l-loader.bin: l-loader/ptable.img
.PHONY: ptable.img
ptable.img: l-loader/ptable.img
.PHONY: l-loader.bin
l-loader.bin: l-loader/ptable.img

boot.img: edk2/Build/HiKey/RELEASE_GCC49/AARCH64/AndroidFastbootApp.efi 53_path.sh export_paths.sh
	set -e; \
	. ./53_path.sh; \
	. ./export_paths.sh; \
	echo building boot.img ;\
	./build_boot_img.sh 


.PHONY: help
help:
	echo wand.image:
	echo   sudo apt-get install libmagickwand-dev imagemagick python-pip
	echo   sudo pip install Wand

