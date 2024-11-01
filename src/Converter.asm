[bits 64]

section .text
global _start          ;must be declared for linker (ld)

fixed_vars:

    ;constant enums 
    GPT_TABLE_SIZE equ 16384
    ALIGNMENT equ 1048576
    FALLOC_FL_ZERO_RANGE equ 0x10
    
    ;Sizes 
    lba_size equ 512
    esp_size equ 1024*1024*33
    data_size equ 1024*1024*1
    gpt_table_lbas equ GPT_TABLE_SIZE / lba_size
    padding equ (ALIGNMENT*2 + (lba_size * ((gpt_table_lbas*2) + 1 + 2)))
    image_size equ esp_size + data_size + padding
    ;image_size equ esp_size + data_size + 1024*1024
    image_size_lbas equ (image_size + (lba_size -1))/lba_size ;bytes to lbas
    mbr_image_lbas equ image_size_lbas - 1
    align_lba equ ALIGNMENT/lba_size ;and also esp_lba
    esp_lba equ align_lba
    esp_size_lbas equ (esp_size + (lba_size -1))/lba_size ;bytes to lbas
    data_size_lbas equ (data_size + (lba_size -1))/lba_size ;bytes to lbas
    data_lba equ (esp_lba + esp_size_lbas) - ((esp_lba + esp_size_lbas) % align_lba) + align_lba



; Args: rdi   rsi   rdx   r10   r8    r9
_start:                ;tell linker entry point
    call open_file
    call write_mbr
    call write_gpt
    call write_esp
    jmp done



write_mbr:
    mov r9, Mbr_Partiiton1_init
    mov r10, Mbr_init.mbr_partition
    times 15 call mov_to_var

    mov rax, Mbr_init
    times 512 call write_to_file
    ret 



write_gpt:

    call new_guid
    mov r9, guid
    mov r10, primary_gpt.disk_guid
    times 15 call mov_to_var

    mov r9, guid
    mov r10, secondary_gpt.disk_guid
    times 15 call mov_to_var

    call new_guid
    mov r9, guid
    mov r10, gpt_data_table.unique_guid
    times 15 call mov_to_var

    call new_guid
    mov r9, guid
    mov r10, gpt_EFI_table.unique_guid
    times 15 call mov_to_var

    mov r9, data_guid
    mov r10, gpt_data_table.partition_type_guid  
    times 15 call mov_to_var

    mov r9, esp_guid
    mov r10, gpt_EFI_table.partition_type_guid
    times 15 call mov_to_var

    call write_table

    mov rax, 128*128
    mov rbx, gpt_table
    call calculate_crc32
    mov [primary_gpt.partition_table_crc32], eax

    mov rax, 92
    mov rbx, primary_gpt
    call calculate_crc32
    mov [primary_gpt.header_crc32], eax
    

    mov rax, primary_gpt
    times 512 call write_to_file

    mov rax, gpt_table
    times 128*128 call write_to_file

    mov rax, (image_size_lbas - 1 - gpt_table_lbas) * lba_size 

    call file_seek

    mov rax, gpt_table
    times 128*128 call write_to_file

    mov rax, 128*128
    mov rbx, gpt_table
    call calculate_crc32
    mov [secondary_gpt.partition_table_crc32], eax

    mov rax, 92
    mov rbx, secondary_gpt
    call calculate_crc32
    mov [secondary_gpt.header_crc32], eax

    mov rax, secondary_gpt
    times 512 call write_to_file

    ret



write_table:
    mov r9, gpt_EFI_table
    mov r10, gpt_table
    times 127 call mov_to_var

    mov r9, gpt_data_table
    mov r10, gpt_table + 128
    times 127 call mov_to_var

    ret


write_esp:

    fat32_fats_lba equ esp_lba + 32

    mov rax, [Vbr.BPB_FATSz32]
    mov rcx, [Vbr.BPB_NumFATs]
    mul rcx
    mov rcx, fat32_fats_lba
    add rax, rcx 
    mov r10, rax
    
    push r10

    mov rax, esp_lba*lba_size
    call file_seek

    mov rax, Vbr
    times 512 call write_to_file

    mov rax, FSInfo
    times 512 call write_to_file


    mov rax, 0
    .loop:
        mov r10, rax 
        mov rcx, [Vbr.BPB_FATSz32]
        mul rcx 
        mov rbx, fat32_fats_lba
        add rax, rbx
        mov rbx, lba_size
        mul rbx

        call file_seek

        mov eax, 0xFFFFFFFB
        mov [cluster], eax ;0xFFFFFF00 | Vbr.BPB_Media
        mov rax, cluster
        times 4 call write_to_file

        mov eax, 0xFFFFFFFF
        mov [cluster], eax
        mov rax, cluster
        times 4 call write_to_file

        mov eax, 0xFFFFFFFF
        mov [cluster], eax
        mov rax, cluster
        times 4 call write_to_file

        mov eax, 0xFFFFFFFF
        mov [cluster], eax
        mov rax, cluster
        times 4 call write_to_file

        mov rax, r10
        inc rax
        cmp rax, 2 ;Vbr.BPB_NumFATs
        jl .loop

    pop r10 
    mov rax, r10 
    ; push r10
    mov rcx, lba_size
    mul rcx
    mov rbx, rax
    push rax 
    ;call print_number
    pop rax
    
    inc rax 
    inc rax 
    inc rax 
    inc rax 
    inc rax 
    inc rax 
    inc rax 
    inc rax 
    inc rax 
    inc rax 
    inc rax 


    call file_seek

    check3 equ FAT32_Dir_Entry_Short_size

    mov rax, FAT32_Dir_Entry_Short
    times check3 call write_to_file

    ; ;seek to (fat32_data_lba+1) * lba_size
    ; pop r10 
    ; mov rax, r10 
    ; push r10
    ; inc rax
    ; mov rcx, lba_size
    ; mul rcx
    ; call file_seek

    ; ; mov [FAT32_Dir_Entry_Short.DIR_Name] ,".          "
    ; mov rax, FAT32_Dir_Entry_Short
    ; times check3 call write_to_file

    ; ;mov [FAT32_Dir_Entry_Short.DIR_Name] ,"..         "
    ; mov word [FAT32_Dir_Entry_Short.DIR_FstClusLO], 0
    ; mov rax, FAT32_Dir_Entry_Short
    ; times check3 call write_to_file

    ; ;mov [FAT32_Dir_Entry_Short.DIR_Name] ,"BOOT       "
    ; mov word [FAT32_Dir_Entry_Short.DIR_FstClusLO], 4
    ; mov rax, FAT32_Dir_Entry_Short
    ; times check3 call write_to_file


    ; pop r10 
    ; mov rax, r10 
    ; inc rax
    ; inc rax
    ; mov rcx, lba_size
    ; mul rcx
    ; call file_seek

    ; ;mov [FAT32_Dir_Entry_Short.DIR_Name] ,".          "
    ; mov word [FAT32_Dir_Entry_Short.DIR_FstClusLO], 4
    ; mov rax, FAT32_Dir_Entry_Short
    ; times check3 call write_to_file

    ; ;mov [FAT32_Dir_Entry_Short.DIR_Name] ,"..         "
    ; mov word [FAT32_Dir_Entry_Short.DIR_FstClusLO], 3
    ; mov rax, FAT32_Dir_Entry_Short
    ; times check3 call write_to_file


    ret 
        
mov_word:



new_guid:
    ;note this may not work as not seeded the random generation 
    ; with time ( havn't reaserched how it is meant to work)
    call rand

    mov r10, guid
    mov r9, rand_arr
    times 15 call mov_to_var
    mov bx, 0b0100111111111111
    mov ax, [guid.time_hi_and_ver]
    and ax, bx
    mov bx, 0b0100000000000000
    or ax, bx
    mov [guid.time_hi_and_ver], ax

    mov bl, 0b11000000
    mov al, [guid.clock_seq_hi_and_res]
    or al, bl
    mov bl, 0b11011111
    and al, bl
    mov [guid.clock_seq_hi_and_res], al
    ret

create_crc32_table:

    ;set ntemp and ctmp to 0
    mov eax, 0x00000000
    mov [ctemp], eax
    mov [ntemp], eax ;variable in for loop

    .loop1_start:

    ;set ctemp to ntemp
    mov eax, [ntemp]
    mov [ctemp], eax

    ;set ktemp to 0 (for loop initialise)
    mov eax, 0x00000000
    mov [ktemp], eax

    .loop2_start:
        mov eax, [ctemp]
        and eax, 0x00000001
        cmp eax, 0x00000001

        
        jne .check2

    .check1:
        ; call test1
        mov eax, [ctemp]
        shr eax, 1
        mov ebx, eax
        mov eax, 0xedb88320
        xor eax, ebx
        mov [ctemp], eax
        jmp .check_end

    .check2:
        ; call test2
        mov eax, [ctemp]
        shr eax, 1
        mov [ctemp], eax
    
    .check_end:


    mov eax, [ktemp]
    inc eax
    mov [ktemp],eax
    cmp eax, 8

    jl .loop2_start
    ; call break
    
    mov rbx, crc_table
    mov eax, [ntemp]
    mov ecx, 4
    mul ecx ;convert to 32 byte indexes 
    add rax, rbx

    mov ebx, [ctemp]


    mov [rax], ebx

    ; mov ebx, [ctemp]
    ; call print_number

    ;I if n is less than 256 after increment go to start of loop 
    mov eax, [ntemp]
    inc eax
    mov [ntemp], eax
    cmp eax, 256
    jl .loop1_start

    ret

calculate_crc32: ; rax is len, rbx is pointer ;eax is return

    mov r10, rax ;r10 is len 
    mov r9, rbx ; r9 is pointer
    push r10
    push r9
    call create_crc32_table
    pop r9
    pop r10

    mov eax, 0xFFFFFFFF
    mov [ctemp], eax ; ctemp is 0xFFFFFFFFL

    mov eax, 0
    mov [ntemp], eax 

    .loop1_start:

    ;calc start
    mov eax, [ntemp] ;offset from pointer 
    mov rbx, r9 ;pointer
    add rax, rbx ;position in table 
    mov ebx, [rax] ;value at position in table 
    mov eax, [ctemp] 
    xor eax, ebx
    and eax, 0xFF 
    mov ecx, 4
    mul ecx ; eax is offset from pointer in table (32 bit)
    mov rbx, crc_table ;pointer to table 
    add rax, rbx ;position in table
    mov ecx, [rax] ;value at position in table 

    mov eax, [ctemp]
    shr eax, 8 ;(c >> 8)
    mov ebx, eax
    mov eax, ecx
    xor eax, ebx 
    mov [ctemp], eax ;update c

    ;end of loop 
    mov eax, [ntemp]
    inc eax 
    mov [ntemp], eax 
    mov rcx, r10
    cmp eax, ecx ; n < len
    jl .loop1_start

    ;invert bits for return in eax 
    mov ebx,  0xFFFFFFFF 
    mov eax, [ctemp]
    xor eax, ebx

    ret



rand:
    mov rdi, rand_arr
    mov rsi, 16
    mov rdx, 0     
    mov rax, 318
    syscall
    ret

mov_to_var:
    mov ax, [r9]
    mov [r10], ax

    inc r10
    inc r9
    ret 


file_seek:

    mov rdi, [image]
    mov rsi, rax
    mov rdx, 0     
    mov rax, 8
    syscall
    ret

open_file:
    mov rdi, image_name
    mov rsi, 0102o     ;O_CREAT, man open
    mov rdx, 0666o     ;umode_t
    mov rax, 2
    syscall
    mov [image], rax

    .fallocate:
        mov rax, 285
        mov rdi, [image]
        mov rsi, FALLOC_FL_ZERO_RANGE
        mov rdx, 0
        mov r10, (image_size_lbas) * lba_size
        syscall

    ret   

write_to_file: ;rax is pointer to start of stuff to write to file 
    push rax
    mov rdx, 1       ;message length
    mov rsi, rax       ;message to write
    mov rdi, [image]      ;file descriptor
    mov rax, 1         ;system call number (sys_write)
    syscall            ;call kernel    
    pop rax
    inc rax
    ret



write_zero_to_file: ;rax is pointer to start of stuff to write to file 
    mov rdx, 1       ;message length
    mov rsi, .zero       ;message to write
    mov rdi, [image]      ;file descriptor
    mov rax, 1         ;system call number (sys_write)
    syscall            ;call kernel    
    ret
    .zero: db 0x00


print_number: ;Code is Done ebx is input

    mov r10, rsp
    mov r9, rbx
    mov r8, 0

    mov eax, ebx

    push 0x0A

    .loop:
    mov edx, 0
    mov ecx, 10
    div ecx
    add edx, 0x30
    push rdx 

    inc r8
    cmp r8, 12

    jl .loop

    mov rax, 1
    mov rdi, 1
    mov rsi, rsp
    mov rdx, 8*13
    syscall

    mov rsp, r10

    ret



done: ;Code is Done

    mov rax, 1
    mov rdi, 1
    mov rsi, .message
    mov rdx, 13
    syscall

    mov eax, 60
    xor rdi, rdi
    syscall

    .message: ;Error Message
        dd "Code is done", 10

section .data

    ;File image
    image dq 0
    image_name db 'test.hdd', 0

    ;Vars 
    cluster dd 0

    ;rand_arr
    rand_arr times 16 db 0x00


; Master boot record 
Mbr_Partiiton1_init:
    .boot_indicator: db 0
    .starting_chs: db 0x00, 0x02, 0x00
    .os_type: db 0xEE
    .ending_chs: db 0xFF, 0xFF,0xFF
    .starting_lba: dd 0x00000001
    .size_lba: dd mbr_image_lbas

    mbr_partition_size equ $-Mbr_Partiiton1_init

; MBR partition 
Mbr_init:
    .boot_code: times 440 db 0x00
    .mbr_signature: dd 0x00 
    .unknown: dw 0x00
    .mbr_partition: times mbr_partition_size*4 db 0x00 ;set to partition later
    .boot_signature: dw 0xAA55


    mbr_size equ $-Mbr_init

guid:
    .time_lo: dd 0x00
    .time_mid: dw 0
    .time_hi_and_ver: dw 0
    .clock_seq_hi_and_res: db 0
    .clock_seq_lo: db 0
    .node: times 6 db 0

guid_size equ $-guid


data_guid:
    .time_lo: dd 0xEBD0A0A2
    .time_mid: dw 0xB9E5
    .time_hi_and_ver: dw 0x4433
    .clock_seq_hi_and_res: db 0x87
    .clock_seq_lo: db 0xC0
    .node: db 0x68, 0xB6, 0xB7, 0x26, 0x99, 0xC7

esp_guid:
    .time_lo: dd 0xC12A7328
    .time_mid: dw 0xF81F
    .time_hi_and_ver: dw 0x11D2
    .clock_seq_hi_and_res: db 0xBA
    .clock_seq_lo: db 0x4B
    .node: db 0x00, 0xA0, 0xC9, 0x3E, 0xC9, 0x3B




primary_gpt:
    .signature: db "EFI PART"
    .revision: dd 0x00010000
    .header_size: dd 92
    .header_crc32: dd 0 ;calculate later 
    ; .header_crc32: db 0x83, 0x2B, 0x5A, 0x1C
    .reserved_1: dd 0
    .my_lba: dq 1
    .alternate_lba: dq image_size_lbas - 1
    .first_usable_lba: dq 1 + 1 + gpt_table_lbas
    .last_usable_lba: dq image_size_lbas - 2 - gpt_table_lbas
    ; .disk_guid: times guid_size db 0x00 ; set later 
    .disk_guid: db 0xB4,0x85,0x77,0xAC,0x30,0xFE,0x8A,0x4C,0xD0,0xBC,0x6E,0x2C,0xDE,0x50,0x61,0xDA 
    .partition_table_lba: dq 2
    .number_of_entries: dd 128
    .size_of_entry: dd 128
    .partition_table_crc32: dd 0
    ; .partition_table_crc32: db 0x44,0x1D,0x11,0x87 
    .reserved_2: times 512-92 db 0x00


secondary_gpt:
    .signature: db "EFI PART"
    .revision: dd 0x00010000
    .header_size: dd 92
    .header_crc32: dd 0
    ; .header_crc32: db 0xCC, 0x4A, 0x1F, 0x45
    .reserved_1: dd 0
    .my_lba: dq image_size_lbas - 1
    .alternate_lba: dq 1
    .first_usable_lba: dq 1 + 1 + gpt_table_lbas
    .last_usable_lba: dq image_size_lbas - 2 - gpt_table_lbas
    ; .disk_guid: times guid_size db 0x00
    .disk_guid: db 0xB4,0x85,0x77,0xAC,0x30,0xFE,0x8A,0x4C,0xD0,0xBC,0x6E,0x2C,0xDE,0x50,0x61,0xDA
    .partition_table_lba: dq image_size_lbas - 1 - gpt_table_lbas
    .number_of_entries: dd 128
    .size_of_entry: dd 128
    .partition_table_crc32: dd 0
    ; .partition_table_crc32: db 0x44,0x1D,0x11,0x87 
    .reserved_2: times 512-92 db 0x00


gpt_EFI_table:
    .partition_type_guid: times guid_size db 0x00
    ; .unique_guid: times guid_size db 0x00
    .unique_guid: db 0xEB,0x5E,0xAD,0x70,0x15,0xD5,0xBA,0x49,0xCD,0xA8,0x9C,0xDF,0x8E,0x53,0x5E,0x42
    .starting_lba: dq esp_lba
    .ending_lba: dq esp_lba + esp_size_lbas
    .attributes: dq 0
    .name: dw "E","F","I"," ","S","Y","S","T","E","M"
    .name_end: times 72 - ($ - .name) dw 0


gpt_data_table:
    .partition_type_guid: times guid_size db 0x00
    ; .unique_guid: times guid_size db 0x00
    .unique_guid: db 0xD8,0xD6,0xEE,0x08,0xD4,0x79,0xE5,0x44,0xD5,0x53,0x91,0x13,0xA4,0xF2,0xEE,0x8F
    .starting_lba: dq data_lba
    .ending_lba: dq data_lba + data_size_lbas
    .attributes: dq 0
    .name: dw "B","A","S","I","C"," ","D","A","T","A"
    .name_end: times 72 - ($ - .name) dw 0

gptTable_size equ $ - gpt_data_table

gpt_table times gptTable_size*128 db 0x00


reserved_sectors equ 32
Vbr:
    .BS_jmpBoot: db 0xEB, 0x00, 0x90
    .BS_OEMName: db "GPCCOOLS"
    .BPB_BytesPerSec: dw lba_size
    .BPB_SecPerClus: db 1
    .BPB_RsvdSecCnt: dw reserved_sectors
    .BPB_NumFATs: db 2
    .BPB_RootEntCnt: dw 0
    .BPB_TotSec16: dw 0
    .BPB_Media: db 0xF8
    .BPB_FATSz16: dw 0
    .BPB_SecPerTrk: dw 0
    .BPB_NumHeads: dw 0
    .BPB_HiddSec: dd (esp_lba - 1)
    .BPB_TotSec32: dd esp_size_lbas
    .BPB_FATSz32: dd (align_lba - reserved_sectors)/2
    .BPB_ExtFlags: dw 0
    .BPB_FSVer: dw 0
    .BPB_RootClus: dd 2
    .BPB_FSInfo: dw 1
    .BPB_BkBootSec: dw 6
    .BPB_Reserved: times 12 db 0
    .BS_DrvNum: db 0x80
    .BS_Reserved1: db 0
    .BS_BootSig: db 0x29
    .BS_VolID: times 4 db 0
    .BS_VolLab: db "NO NAME    "
    .BS_FilSysType: db "FAT32   "
    .boot_code: times 510-90 db 0
    .bootsect_sig: dw 0xAA55

Vbr_size equ $ - Vbr

FSInfo:
    .FSI_LeadSig: dd 0x41615252
    .FSI_Reserved1: times 480 db 0
    .FSI_StrucSig: dd 0x61417272
    .FSI_Free_Count: dd 0xFFFFFFFF
    .FSI_Nxt_Free: dd 5 
    .FSI_Reserved2: times 12 db 0
    .FSI_TrailSig: dd 0xAA550000

FSInfo_size equ $ - FSInfo

FAT32_Dir_Entry_Short:
        .DIR_Name: db "EFI        "
        .DIR_Attr: db ATTR_DIRECTORY
        .DIR_NTRes: db 0
        .DIR_CrtTimeTenth: db 0 
        .DIR_CrtTime: dw 0
        .DIR_CrtDate: dw 0
        .DIR_LstAccDate: dw 0
        .DIR_FstClusHI: dw 0
        .DIR_WrtTime: dw 0
        .DIR_WrtDate: dw 0
        .DIR_FstClusLO: dw 3
        .DIR_FileSize: dd 0

FAT32_Dir_Entry_Short_size equ $ - FAT32_Dir_Entry_Short

FAT32_Dir_Attr:
    ATTR_READ_ONLY equ 0x01
    ATTR_HIDDEN    equ 0x02
    ATTR_SYSTEM    equ 0x04
    ATTR_VOLUME_ID equ 0x08
    ATTR_DIRECTORY equ 0x10
    ATTR_ARCHIVE   equ 0x20
    ATTR_LONG_NAME equ ATTR_READ_ONLY | ATTR_HIDDEN | ATTR_SYSTEM | ATTR_VOLUME_ID



section .bss

;crc table
crc_table resd 256 
ctemp resd 1
ntemp resd 1
ktemp resd 1



