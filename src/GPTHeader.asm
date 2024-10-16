;GPT Header

;Signature (Byte Offset: 0, Byte Length: 8)
;Identifies EFI-compatible partition table header. This value must contain
;the ASCII string “EFI PART”, encoded as the 64-bit constant 0x5452415020494645.
dq 0x5452415020494645

;Revision (Byte Offset: 8, Byte Length: 4)
;The revision number for this header. This revision value is not related to the
;UEFI Specification version. This header is version 1.0, so the correct value
;is 0x00010000.
dd 0x00010000

;HeaderSize (Byte Offset: 12, Byte Length: 4)
;Size in bytes of the GPT Header. The HeaderSize must be greater than or
;equal to 92 and must be less than or equal to the logical block size.
dd 0x00000200

;HeaderCRC32 (Byte Offset: 16, Byte Length: 4)
;CRC32 checksum for the GPT Header structure. This value is computed by
;setting this field to 0, and computing the 32-bit CRC for HeaderSize bytes.
dd 0x00000000

;Reserved (Byte Offset: 20, Byte Length: 4)
; Must be zero
dd 0x00000000

;MyLBA (Byte Offset: 24, Byte Length: 8)
;The LBA that contains this data structure.
dq 0x0000000000000001

;AlternateLBA (Byte Offset: 32, Byte Length: 8)
;LBA address of the alternate GPT Header
dq 0x00000000000003E8

;FirstUsableLBA (Byte Offset: 40, Byte Length: 8)
;The first usable logical block that may be used by a partition described by a
;GUID Partition Entry.
dq 0x0000000000000022

;LastUsableLBA (Byte Offset: 48, Byte Length: 8)
;The last usable logical block that may be used by a partition described by a
;GUID Partition Entry
dq 0x00000000000003C5

;DiskGUID (Byte Offset: 56, Byte Length: 16)
;GUID that can be used to uniquely identify the disk
dq 0x0000000000000000
dq 0x0000000000000001

;PartitionEntryLBA ( Byte Offset: 72, Byte Length: 8)
;The starting LBA of the GUID Partition Entry array.
dq 0x0000000000000002

;NumberOfPartitionEntries (Byte Offset: 80, Byte Length: 4)
;The number of Partition Entries in the GUID Partition Entry array.
dd 0x00000001

;SizeOf PartitionEntry (Byte Offset: 84, Byte Length: 4)
;The size, in bytes, of each the GUID Partition Entry structures in the GUID
;Partition Entry array. This field shall be set to a value of 128 x 2 n where n
;is an integer greater than or equal to zero (e.g., 128, 256, 512, etc.). NOTE:
;Previous versions of this specification allowed any multiple of 8..
dd 0x00000200

;PartitionEntryArrayCRC32 (Byte Offset: 88, Byte Length: 4)
;The CRC32 of the GUID Partition Entry array. Starts at PartitionEntryLBA
;and is computed over a byte length of NumberOfPartitionEntries * 
;SizeOfPartitionEntry
dd 0x00000200

;Reserved (Byte Offset: 92, Byte Length: Block Size - 92)
; The rest of the block is reserved by UEFI and must be zero.
times 512 - ($-$$) db 0x00






