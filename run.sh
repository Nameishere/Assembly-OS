./convert.sh
qemu-system-x86_64 \
    -drive format=raw,file=test.hdd \
    -bios OVMF-pure-efi.fd \
    -m 256M \
    -vga std \
    -display gtk,gl=on,zoom-to-fit=off,window-close=on \
    -name TESTOS \
    -machine q35 \
    -usb \
    -device usb-mouse \
    -rtc base=localtime \
    -net none
# qemu-system-x86_64 -bios bios64.bin -machine q35 -net none -drive file=../Reference/test.hdd,format=raw
