#/bin/bash
set -e	#stop and exit on error
if [ ! -d ${EDK2_DIR} ]
then
	echo Environment variable EDK2_DIR[${EDK2_DIR}] not assigned, quitting..
	exit -1
fi
if [ ! -e ${EDK2_DIR}/Build/HiKey/RELEASE_GCC49/AARCH64/AndroidFastbootApp.efi ]
then
	echo AndroidFastbootApp.efi missing, quitting..
	exit -1
fi

if [ ! -e grubaa64.efi ]
then
	#This path it the one in instructions
	#wget https://builds.96boards.org/snapshots/reference-platform/components/grub/latest/grubaa64.efi
	#This one below might not be the right file, though it's only one that's available
	wget http://builds.96boards.org/releases/reference-platform/openembedded/hikey/latest/rpb/grubaa64.efi
fi
if [ ! -e grubaa64.efi ]
then
	echo No grubaa64.efi, quitting..
	exit -1
fi

mkdir boot-fat
dd if=/dev/zero of=boot-fat.uefi.img bs=512 count=131072
sudo mkfs.fat -n "boot" boot-fat.uefi.img
sudo mount -o loop,rw,sync boot-fat.uefi.img boot-fat
sudo mkdir -p boot-fat/EFI/BOOT
sudo cp -vP ${EDK2_DIR}/Build/HiKey/RELEASE_GCC49/AARCH64/AndroidFastbootApp.efi boot-fat/EFI/BOOT/fastboot.efi
sudo cp -vP grubaa64.efi boot-fat/EFI/BOOT/grubaa64.efi
sudo umount boot-fat
sudo mv boot-fat.uefi.img hikey-boot-linux-VERSION.uefi.img
rm -rf boot-fat
echo Done: hikey-boot-linux-VERSION.uefi.img
