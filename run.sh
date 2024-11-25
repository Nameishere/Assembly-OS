./convert.sh
qemu-system-x86_64 \
    -bios bios64.bin \
    -machine q35 \
    -net none\
    -drive file=test.hdd,format=raw\
    -m 256M \
    -vga std \
    -display gtk,gl=on,zoom-to-fit=off,window-close=on \
    -usb \
    -device usb-mouse \
    -rtc base=localtime \
# qemu-system-x86_64 -bios bios64.bin -machine q35 -net none -drive file=../Reference/test.hdd,format=raw