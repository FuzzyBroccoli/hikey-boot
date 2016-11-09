cd l-loader
ln -s ${EDK2_DIR}/Build/HiKey/RELEASE_GCC49/FV/bl1.bin
ln -s ${EDK2_DIR}/Build/HiKey/RELEASE_GCC49/FV/fip.bin
make # requires sudo for creating the partition tables
