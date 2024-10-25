[bits 64]

section .text
global _start          ;must be declared for linker (ld)

fixed_vars:

    ;constant enums 
    GPT_TABLE_SIZE equ 16384
    ALIGNMENT equ 1048576
    FALLOC_FL_ZERO_RANGE equ 0x10
    ATTR_DIRECTORY equ 0x10
    
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
    times 16 call mov_to_var

    mov rax, Mbr_init
    times 512 call write_to_file
    ret 

write_gpt:

    call new_guid
    mov rax, primary_gpt.disk_guid
    mov r9, guid
    mov r10, primary_gpt.disk_guid
    times 16 call mov_to_var

    mov rax, primary_gpt
    times 512 call write_to_file

    call write_table

    mov rax, (image_size_lbas - 1 - gpt_table_lbas) * lba_size
    call file_seek

    call write_table

    mov rax, secondary_gpt
    times 512 call write_to_file

    ret



write_table:
    mov rax, gpt_EFI_table
    times 128 call write_to_file

    mov rax, gpt_data_table
    times 128 call write_to_file

    times 128 - 2 call write_to_file_gpt_empty_table

    ret

write_to_file_gpt_empty_table:
    mov rax, gpt_empty_table
    times 128 call write_to_file    

write_esp:
    mov rax, esp_lba*lba_size
    call file_seek

    mov rax, Vbr
    check equ Vbr_size
    times check call write_to_file

    mov rax, FSInfo
    check2 equ FSInfo_size
    times check2 call write_to_file

    fat32_fats_lba equ esp_lba + Vbr.BPB_RsvdSecCnt
    fat32_data_lba equ fat32_fats_lba + (2* ((align_lba - reserved_sectors)/2));(Vbr.BPB_NumFATs * Vbr.BPB_FATSz32)

    mov rax, 0
    .loop:
        mov r10, rax 
        mov rcx, (align_lba - reserved_sectors)/2
        imul rax, rcx 
        mov rbx, fat32_fats_lba
        add rax, rbx
        mov rbx, lba_size
        imul rax, rbx
        call file_seek

        mov eax, 0xFFFFFFFB
        mov [cluster], eax ;0xFFFFFF00 | Vbr.BPB_Media
        times 4 call write_to_file

        mov eax, 0xFFFFFFFF
        mov [cluster], eax
        times 4 call write_to_file

        mov eax, 0xFFFFFFFF
        mov [cluster], eax
        times 4 call write_to_file

        mov eax, 0xFFFFFFFF
        mov [cluster], eax
        times 4 call write_to_file

        mov r10, rax
        inc rax
        cmp rax, 2 ;Vbr.BPB_NumFATs
        jl .loop

    mov rax, fat32_data_lba * lba_size
    call file_seek

    ;need to set time and date for FAT32_Dir_Entry_Short
    ;
    ;
    ;

    check3 equ FAT32_Dir_Entry_Short_size
    mov rax, FAT32_Dir_Entry_Short
    times check3 call write_to_file


    mov rax, (fat32_data_lba + 1) * lba_size
    call file_seek

    ;
    ;adjust dir name 

    mov rax, FAT32_Dir_Entry_Short
    times check3 call write_to_file

    ;
    ;adjust dir name 

    mov rax, FAT32_Dir_Entry_Short
    times check3 call write_to_file

    ;
    ;adjust dir name 

    mov rax, FAT32_Dir_Entry_Short
    times check3 call write_to_file


    mov rax, (fat32_data_lba + 2) * lba_size
    call file_seek

    ;
    ;adjust dir name 

    mov rax, FAT32_Dir_Entry_Short
    times check3 call write_to_file

    ;
    ;adjust dir name 

    mov rax, FAT32_Dir_Entry_Short
    times check3 call write_to_file


    ret 
        

new_guid:
    ;note this may not work as not seeded the random generation 
    ; with time ( havn't reaserched how it is meant to work)
    call rand

    mov r10, guid
    mov r9, rand_arr
    times 16 call mov_to_var
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
    mov eax, 0
    mov [ntemp], eax
    .loop1_start:
    mov eax, [ntemp]
    mov [ctemp], eax
    mov eax, 0x00000000
    mov [ktemp], eax
    .loop2_start:

    .check1:
        mov eax, [ctemp]
        shr eax, 1
        mov ebx, eax
        mov eax, 0x3db88320
        call exponent32
        mov [ctemp], eax


    .check2:
        mov eax, [ctemp]
        shr eax, 1
        mov [ctemp], eax

    mov eax, [ktemp]
    inc eax
    mov eax,[ktemp]
    cmp eax, 8

    jne .loop2_start

    mov rbx, crc_table
    mov eax, [ntemp]
    mov ecx, 4
    mul ecx ;convert to 32 byte indexes 
    add rax, rbx

    mov rbx, [ctemp]
    mov [rax], rbx

    mov eax, [ntemp]
    inc eax
    mov [ntemp], eax
    cmp eax, 256
    jne .loop1_start

    ret

calculate_crc32: ; rax is len, rbx is pointer ;eax is return

    push rax 
    push rbx 
    call create_crc32_table

    mov eax, 0xFFFFFFFF
    mov [ctemp], eax

    mov eax, 0
    mov [ntemp], eax 

    pop rbx
    pop rax 
    mov ecx, eax
    .loop1_start:
    push ecx

    mov eax, [ntemp]
    add rax, rbx
    push ebx
    mov ebx, eax
    mov eax, [ctemp]
    call exponent32
    and eax, 0xFF
    
    mov rbx, crc_table
    mov ecx, 4
    mul ecx ;convert to 32 byte indexes 
    add rax, rbx
    mov ebx, [ctemp]
    shr ebx
    mov eax, [rax]
    call exponent32
    mov [ctemp], eax



    mov [ctemp], eax

    mov eax, [ntemp]
    inc eax
    mov [ntemp], eax
    pop ebx
    pop ecx
    cmp eax, ecx
    jne .loop1_start

    mov ebx,  0xFFFFFFFF
    mov eax, [ctemp]
    call exponent32 

    ret



exponent32: ;a^n, eax is a, ebx is n returns in eax
    mov ecx, 0
    mov edx, eax
    mov eax, 1

    .start:
    inc ecx
    cmp ecx, ebx
    je .done

    .multiply:
    mul edx
    
    jmp .start
    .done:
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
        mov r10, (image_size_lbas + 5) * lba_size
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
    .time_lo: dd 0x47
    .time_mid: dw 0
    .time_hi_and_ver: dw 0
    .clock_seq_hi_and_res: db 0
    .clock_seq_lo: db 0
    .node: times 6 db 0


guid_size equ $-guid

primary_gpt:
    .signature: db "EFI PART"
    .revision: dd 0x00010000
    .header_size: dd 92
    .header_crc32: dd 0 ;calculate later 
    .reserved_1: dd 0
    .my_lba: dq 1
    .alternate_lba: dq image_size_lbas - 1
    .first_usable_lba: dq 1 + 1 + gpt_table_lbas
    .last_usable_lba: dq image_size_lbas - 1 - gpt_table_lbas
    .disk_guid: times guid_size db 0x00 ; set later 
    .partition_table_lba: dq 2
    .number_of_entries: dd 128
    .size_of_entry: dd 128
    .partition_table_crc32: dd 0 ; calculate later 
    .reserved_2: times 512-92 dd 0x00


secondary_gpt:
    .signature: db "EFI PART"
    .revision: dd 0x00010000
    .header_size: dd 92
    .header_crc32: dd 0
    .reserved_1: dd 0
    .my_lba: dq image_size_lbas - 1
    .alternate_lba: dq 1
    .first_usable_lba: dq 1 + 1 + gpt_table_lbas
    .last_usable_lba: dq image_size_lbas - 1 - gpt_table_lbas
    .disk_guid: times guid_size db 0x00
    .partition_table_lba: dq image_size_lbas - 1 - gpt_table_lbas
    .number_of_entries: dd 128
    .size_of_entry: dd 128
    .partition_table_crc32: dd 0
    .reserved_2: times 512-92 dd 0x00


gpt_EFI_table:
    .partition_type_guid: times guid_size db 0x00
    .unique_guid: times guid_size db 0x00
    .starting_lba: dq esp_lba
    .ending_lba: dq esp_lba + esp_size_lbas
    .attributes: dq 0
    .name: dw "E","F","I"," ","S","Y","S","T","E","M"
    .name_end: times 36 - ($ - .name) db 0


gpt_data_table:
    .partition_type_guid: times guid_size db 0x00
    .unique_guid: times guid_size db 0x00
    .starting_lba: dq data_lba
    .ending_lba: dq data_lba + data_size_lbas
    .attributes: dq 0
    .name: dw "B","A","S","I","C"," ","D","A","T","A"
    .name_end: times 36 - ($ - .name) db 0

gpt_empty_table:
    .partition_type_guid: times guid_size db 0x00
    .unique_guid: times guid_size db 0x00
    .starting_lba: dq 0
    .ending_lba: dq 0
    .attributes: dq 0
    .name: times 36 dw 0

reserved_sectors equ 32
Vbr:
    .BS_jmpBoot: db 0xEB, 0x00, 0x90
    .BS_OEMName: db "THISDISK"
    .BPB_BytesPerSec: dw lba_size
    .BPB_SecPerClus: db 1
    .BPB_RsvdSecCnt: dw reserved_sectors
    .BPB_NumFATs: db 2
    .BPB_RootEntCnt: dw 0
    .BPB_TotSec16: dw 0
    .BPB_Media: db 0xFB
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
    .BPB_BkBootSec: dw 0
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


section .bss

;crc table
crc_table resd 256 
ctemp resd 1
ntemp resd 1
ktemp resd 1



