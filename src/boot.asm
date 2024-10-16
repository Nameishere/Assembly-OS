;Protective MBR File (Logical block size of 512)


;Boot code (Byte Offset: 0, Byte Length: 440)
;Unsued by UEFI systems 
times 440 db 0x00

;Unique MBR Disk Signature (Byte Offset: 440, Byte Length 4)
;Unsued Set to zero 
times 4 db 0x00

;Unknown (Byte Offset: 444, Byte Length: 2)
;Unused Set to Zero
times 2 db 0x00

;Partition Record (Byte Offset: 446, Byte Length: 16*4)
    ;Partition 1 for GPT disk layout:
        ;BootIndicator (Byte Offset: 0, Byte Lenght: 1):
        ;Set to 0x00 to indicate a non-bootable partition. If set to any
        ;value other than 0x00 the behavior of this flag on non-UEFI
        ;systems is undefined. Must be ignored by UEFI 
        ;implementations.
        db 0x00 

        ;StartingCHS (Byte Offset: 1, Byte Length: 3)
        ;Set to 0x000200, corresponding to the Starting LBA field.
        db 0x00
        db 0x02
        db 0x00 

        ;OSType (Byte Offset: 4 ,Byte Length: 1)
        ;Set to 0xEE (i.e., GPT Protective)
        db 0xEE 

        ;EndingCHS (Byte Offset: 5, Byte Length: 3)
        ; Set to the CHS address of the last logical block on the disk.
        ;Set to 0xFFFFFF if it is not possible to represent the value
        ;in this field.
        db 0xFF  
        db 0xFF
        db 0xFF

        ;StartingLBA (Byte Offset: 8, Byte Length: 4)
        ;Set to 0x00000001 (i.e., the LBA of the GPT Partition 
        ;Header)
        db 0x00 
        db 0x00 
        db 0x00 
        db 0x01 

        ;SizeInLBA (Byte Offset: 12, Byte Length: 4)
        ;Set to the size of the disk minus one. Set to 0xFFFFFFFF
        ;if the size of the disk is too large to be represented in this
        ;feld.
        db 0xFF 
        db 0xFF 
        db 0xFF 
        db 0xFF 
    ;Partition 2 - 4
        ;Remaining Partition Records shall be set to zero
        times 48 db 0x00

;Signature (Byte Offset: 510, Byte Length: 2)
;Set to 0xAA55 (i.e., byte 510 contains 0x55 and byte 511
;contains 0xAA)
dw 0xAA55

;Reserved (Byte Offset: 512, Byte Length: Logical Block Size-512)
;The rest of the logical block, if any, is reserved. Set to zero.
times 512 -($-$$) db 0x00
