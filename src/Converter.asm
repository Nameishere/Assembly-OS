[bits 64]

section .text
global _start          ;must be declared for linker (ld)


fixed_vars:

    ;Time 
    nz_time equ 12
    day_light_savings equ 1

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
    call open_efi_file

    mov rax, path
    mov rbx, path_size
    call add_path_to_esp
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
    mov rcx, 0 
    mov cl, [Vbr.BPB_NumFATs]
    mul rcx
    mov rcx, fat32_fats_lba
    add rax, rcx 
    mov r10, rax
    
    mov [fat32_data_lba], r10  
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
    push r10
    mov rcx, lba_size
    mul rcx
    mov rbx, rax

    call file_seek

    check3 equ FAT32_Dir_Entry_Short_size

    mov rax, FAT32_Dir_Entry_Short
    times check3 call write_to_file

    ;seek to (fat32_data_lba+1) * lba_size
    pop r10 
    mov rax, r10 
    push r10
    inc rax
    mov rcx, lba_size
    mul rcx
    call file_seek

    
    
    mov r10, FAT32_Dir_Entry_Short.DIR_Name
    mov r9, write_esp.in1
    times 10 call mov_to_var
    mov rax, FAT32_Dir_Entry_Short
    times check3 call write_to_file

    
    mov r10, FAT32_Dir_Entry_Short.DIR_Name
    mov r9, write_esp.in2
    times 10 call mov_to_var
    mov word [FAT32_Dir_Entry_Short.DIR_FstClusLO], 0
    mov rax, FAT32_Dir_Entry_Short
    times check3 call write_to_file

    
    mov r10, FAT32_Dir_Entry_Short.DIR_Name
    mov r9, write_esp.in3
    times 10 call mov_to_var
    mov word [FAT32_Dir_Entry_Short.DIR_FstClusLO], 4
    mov rax, FAT32_Dir_Entry_Short
    times check3 call write_to_file


    pop r10 
    mov rax, r10 
    inc rax
    inc rax
    mov rcx, lba_size
    mul rcx
    call file_seek

    mov r10, FAT32_Dir_Entry_Short.DIR_Name
    mov r9, write_esp.in1
    times 10 call mov_to_var
    mov word [FAT32_Dir_Entry_Short.DIR_FstClusLO], 4
    mov rax, FAT32_Dir_Entry_Short
    times check3 call write_to_file

    mov r10, FAT32_Dir_Entry_Short.DIR_Name
    mov r9, write_esp.in2
    times 10 call mov_to_var
    mov word [FAT32_Dir_Entry_Short.DIR_FstClusLO], 3
    mov rax, FAT32_Dir_Entry_Short
    times check3 call write_to_file
    ret 

    .in1: db ".          "
    .in2: db "..         "
    .in3: db "BOOT       "

open_efi_file:
    mov rdi, Boot64_name
    mov rsi, O_RDONLY     ;O_CREAT, man open
    mov rdx, 0     
    mov rax, LINUX_SYSCALL.open
    syscall


    call check_Error

    .end:
    mov [Boot64], rax
    ret


add_path_to_esp:
    ; rax is a pointer to the path  
    ; rbx is the length of the path 
    ; mov rcx, 0 
    mov cx, '/'

    cmp [rax], cl
    je .jumped

    mov rax, -1
    call check_Error

    .jumped:
    call String_to_Upper

    mov rdx, TYPE_DIR ;rdx is type 
    inc rax ;Skip slash '/'
    mov r10, rax ; r10 is end 
    push rax 
    mov rax, 2
    mov [dir_cluster], rax
    pop rax

    
    .loop1_start:
        cmp rdx, TYPE_DIR
        jne .loop1_end
        .loop2_start:
            mov cl, '/'
            cmp [r10], cl
            je .loop2_end
            mov cl, 0
            cmp [r10], cl 
            je .loop2_end

            inc r10 

            jmp .loop2_start
        .loop2_end:
        mov cl, '/'
        cmp [r10], cl
        je .if
        jmp .else
        .if: 
            mov rdx, TYPE_DIR
            jmp .end
        .else:
            mov rdx, TYPE_FILE
            ; call print_test
            jmp .end
        .end:

        mov byte [r10], 0
        
        mov r9, 0
        mov r9b, '.'
        call strchr


        cmp rdx, TYPE_DIR
        jne .criteria2
        .criteria1:

        push rax
        call strlen
        cmp rax, 11
        pop rax
        jg .true
        .criteria2:

        push rax
        call strlen
        cmp rax, 12
        pop rax
        jg .true

        .critera3:

        cmp r9, 0
        je .end2

        push r9
        sub r9, rax ; r9 = r9 - rax


        cmp r9, 8
        pop r9
        jg .true
        jmp .end2
        .true:
        mov rax, -1000            
        call check_Error
        .end2:

        
        push rax 
        push rbx 
        push rcx 
        mov rax, short_name
        mov rbx, short_name_length
        call zeroarray

        push rdx
        mov rax, short_name
        mov rbx, 11
        mov rcx, 0 
        mov cl, ' '
        call memset

        
        pop rdx 
        pop rcx 
        pop rbx 
        pop rax 


        cmp rdx, TYPE_DIR
        je .if2
        cmp r9, 0
        je .if2
        jmp .else2
        .if2:
            
            push rax
            push rbx
            push rcx
            push rdx
            mov rbx, rax ;start into rbx
            call strlen
            mov rcx, rax
            mov rax, short_name
            call memcopy
            pop rdx
            pop rcx
            pop rbx
            pop rax

            ; push r10
            ; mov r10, short_name
            ; times 11 call print_string
            ; pop r10
            jmp .end3
        .else2:
            ; call print_test
            push rax
            push rbx
            push rcx
            push rdx

            mov rbx, rax ;start into rbx
            mov rax, short_name
            mov rdx, rbx
            mov rcx, r9
            sub rcx, rbx

            call memcopy

            pop rdx
            pop rcx
            pop rbx
            pop rax

            push rax
            push rbx
            push rcx
            push rdx

            mov rax, short_name
            add rax, 8
            inc r9
            mov rbx, r9
            mov rcx, 3
            call strncpy


            pop rdx
            pop rcx
            pop rbx
            pop rax



        .end3:

        push rax
        push rbx
        mov rax, FAT32_Dir_Entry_Short
        mov rbx, FAT32_Dir_Entry_Short_size
        call zeroarray
        pop rbx
        pop rax

        mov byte [found], 0



        push rax
        push rcx
        push rdx
        mov rax, [fat32_data_lba]
        mov rcx, 0
        mov cl, [dir_cluster]
        add rax, rcx

        sub rax, 2
        mov rcx, lba_size
        mul rcx ; rdx:rax = rax*rcx, 
        
        Call file_seek
        pop rdx
        pop rcx
        pop rax



        .loop:

        push rax
        push rbx
        push rcx
        mov rax, [image]
        mov rbx, FAT32_Dir_Entry_Short
        mov rcx, FAT32_Dir_Entry_Short_size 
        call fread

        mov rax, short_name
        mov rbx, FAT32_Dir_Entry_Short.DIR_Name
        mov rcx, 11
        call memcmp


        cmp rax, 0
        jne .check

        jmp .check2
        .check:
        mov byte [found], 1
        
        mov rax, 0
        mov ax, [FAT32_Dir_Entry_Short.DIR_FstClusHI]
        shl eax, 16

        or eax, [FAT32_Dir_Entry_Short.DIR_FstClusLO]

        mov [dir_cluster], eax




        pop rcx
        pop rbx
        pop rax


        jmp .loop_end


        .check2:


        pop rcx
        pop rbx
        pop rax



        
        mov al, [FAT32_Dir_Entry_Short.DIR_Name]
        cmp al, 0
        jne .loop
        .loop_end:


        cmp byte [found], 0

        je .check3


        jmp .check4
        .check3:

        push rax 

        mov rax, rdx
        call add_file_to_esp

        pop rax


        .check4:




        inc r10
        mov rax, r10

        jmp .loop1_start
        
    .loop1_end:
    
    
    ret 



add_file_to_esp:
    ;rax is type of being added to esp
    push rax
    push rbx
    push rcx
    push rdx

    push rax
    mov rax, Vbr
    mov rbx, Vbr_size
    call zeroarray
    
    mov rax, esp_lba
    mov rcx, lba_size
    mul rcx
    call file_seek


    mov rax, [image]
    mov rbx, Vbr
    mov rcx, Vbr_size
    call fread

    mov rax, FSInfo
    mov rbx, FSInfo_size
    call zeroarray

    mov rax, esp_lba
    mov rbx, 1
    add rax, rbx
    mov rcx, lba_size
    mul rcx
    call file_seek

    
    mov rax, [image]
    mov rbx, FSInfo
    mov rcx, FSInfo_size
    call fread

    mov rax, 0
    mov [file_size_bytes], rax ; file_size_bytes
    mov [file_size_lbas], rax ; file_size_lbas

    pop rax 
    cmp rax, TYPE_FILE
    push rax
    jne .endif1

    mov rax, [Boot64]
    mov rbx, 0
    mov rcx, SEEK_END
    call fseek
    mov [file_size_bytes], rax

    call bytes_to_lbas

    mov [file_size_lbas], rax

    mov rax, [Boot64]
    mov rbx, 0
    mov rcx, SEEK_SET
    call fseek

    .endif1:

    mov rax, 0
    mov eax, [FSInfo.FSI_Nxt_Free] 
    mov [next_free_cluster], eax

    mov eax, [next_free_cluster] 
    mov [starting_cluster], eax


    mov r10, 0
    .startloop1:
        cmp r10b, [Vbr.BPB_NumFATs]
        jge .endloop1


        mov rcx, 0
        mov ecx, [Vbr.BPB_FATSz32]
        mov rax, 0
        mov al, r10b
        mul rcx
        add rax, fat32_fats_lba
        mov rcx, lba_size
        mul rcx 
        mov rbx, rax
        mov rax, [image]
        mov rcx, SEEK_SET
        call fseek


        mov rcx, 0
        mov ecx, [next_free_cluster]
        mov rax, 4
        mul rcx
        mov rbx, rax
        mov rax, [image]
        mov rcx, SEEK_CUR
        call fseek

        ; mov rbx, 25
        ; call print_number
        ; call print_test

        mov eax, [FSInfo.FSI_Nxt_Free]
        mov [cluster], eax
        mov [next_free_cluster], eax

        pop rax 
        push rax
        cmp rax, TYPE_FILE
        jne .endloop2

        mov r9, 0 
        .startloop2:
            mov rax, [file_size_lbas]
            dec rax 
            cmp r9, rax
            jge .endloop2
            mov rax, 0
            mov eax, [cluster]
            inc eax
            mov [cluster], eax
            mov rax, 0
            mov eax, [next_free_cluster]
            inc eax
            mov [next_free_cluster], eax

            mov rax, [image]
            mov rbx, cluster
            mov rcx, 4
            
            call fwrite
            inc r9

            jmp .startloop2
        .endloop2:

        mov eax, 0xFFFFFFFF
        mov  [cluster], eax

        mov rax, 0
        mov eax, [next_free_cluster]
        inc eax
        mov [next_free_cluster], eax

        mov rax, [image]
        mov rbx, cluster
        mov rcx, 4
        call fwrite
        
        inc r10b
        jmp .startloop1
    .endloop1:

    mov eax, [next_free_cluster]
    mov [FSInfo.FSI_Nxt_Free], eax

    mov rax, esp_lba
    inc rax
    mov rcx, lba_size
    mul rcx

    mov rbx, rax
    mov rax, [image]
    mov rcx, SEEK_SET
    call fseek

    mov rbx, FSInfo
    mov rax, [image]
    mov rcx, FSInfo_size
    call fwrite

    mov rax, 0 
    mov rcx, 0
    mov eax, [dir_cluster]
    mov ecx, [fat32_data_lba]
    add eax, ecx
    dec rax
    dec rax
    mov rcx, lba_size
    mul rcx

    mov rbx, rax
    mov rax, [image]
    mov rcx, SEEK_SET
    call fseek


    mov rax, FAT32_Dir_Entry_Short
    mov rbx, FAT32_Dir_Entry_Short_size
    call zeroarray

    

    .startloop3:
    mov rax, [image]
    mov rbx, FAT32_Dir_Entry_Short
    mov rcx, FAT32_Dir_Entry_Short_size
    call fread

    mov al, [FAT32_Dir_Entry_Short.DIR_Name]
    cmp al, 0 
    je .endloop3

    mov rbx, -32
    mov rax, [image]
    mov rcx, SEEK_CUR
    call fseek


    mov rax, FAT32_Dir_Entry_Short.DIR_Name
    mov rbx, short_name
    mov rcx, 11
    call memcopy

    
    
    pop rax
    push rax
    cmp rax, TYPE_DIR
    jne .endif2
    mov byte [FAT32_Dir_Entry_Short.DIR_Attr], ATTR_DIRECTORY
    .endif2:

    
    call get_fat_dir_entry_time_date

    mov [FAT32_Dir_Entry_Short.DIR_CrtTime], bx
    mov [FAT32_Dir_Entry_Short.DIR_CrtDate], ax
    mov [FAT32_Dir_Entry_Short.DIR_WrtTime], bx
    mov [FAT32_Dir_Entry_Short.DIR_WrtDate], ax

    mov rax, 0
    mov eax, [starting_cluster]
    shr eax, 16
    and eax, 0xFFFF
    mov [FAT32_Dir_Entry_Short.DIR_FstClusHI], ax 

    mov rax, 0
    mov eax, [starting_cluster]
    and eax, 0xFFFF
    mov [FAT32_Dir_Entry_Short.DIR_FstClusLO], ax 

    
    pop rax
    push rax

    cmp rax, TYPE_FILE
    jne .endif3

    mov rax, [file_size_lbas]
    mov [FAT32_Dir_Entry_Short.DIR_FileSize], rax
    
    .endif3:

    mov rax, [image]
    mov rbx, FAT32_Dir_Entry_Short
    mov rcx, FAT32_Dir_Entry_Short_size
    call fwrite

    mov rax, [fat32_data_lba]
    mov rbx, 0
    mov ebx, [starting_cluster]
    add rax, rbx 
    sub rax, 2
    mov rcx, lba_size
    mul rcx
    mov rbx, rax 
    mov rax, [image]
    mov rcx, SEEK_SET
    call fseek 

    pop rax 
    push rax

    cmp rax, TYPE_DIR
    jne .elseif4

    mov rax, .String1
    mov rbx, FAT32_Dir_Entry_Short.DIR_Name
    mov rcx, 11
    call memcopy

    mov rax, [image]
    mov rbx, FAT32_Dir_Entry_Short
    mov rcx, FAT32_Dir_Entry_Short_size
    call fwrite

    mov rax, .String2
    mov rbx, FAT32_Dir_Entry_Short.DIR_Name
    mov rcx, 11
    call memcopy

    mov rax, 0
    mov eax, [dir_cluster]
    shr rax, 16 
    and rax, 0xFFFF
    mov [FAT32_Dir_Entry_Short.DIR_FstClusHI], ax
    mov rax, 0
    mov eax, [dir_cluster]
    and rax, 0xFFFF
    mov [FAT32_Dir_Entry_Short.DIR_FstClusLO], ax
    
    mov rax, [image]
    mov rbx, FAT32_Dir_Entry_Short
    mov rcx, FAT32_Dir_Entry_Short_size
    call fwrite

    jmp .endif4
    .elseif4:





    .endif4:




    ; call done
    call print_test
    jmp .startloop3
    .endloop3:

    
    pop rax
    pop rdx
    pop rcx
    pop rbx
    pop rcx
    ret

    .String1: db ".          "
    .String2: db "..         "

get_fat_dir_entry_time_date:
    ; rax output as date 
    ; rbx output as time  
    push rcx
    push rdx

    mov rax, 0
    call timef
    call localtime
    ; call print_localtime
    mov     rax,    0
    mov     eax,    [tm.year] 
    sub     rax,    80
    shl     rax,    9
    mov     rbx,    0
    mov     bl,     [tm.mon]
    add     rbx,    1 
    shl     rbx,    5
    or      rax,    rbx 
    mov     rbx,    0
    mov     bl,     [tm.mday]
    or      ax,     bx
    ;ax is now date 

    push    rax 
    mov     rax,    0
    mov     al,     [tm.hour]
    shl     rax,    11
    mov     rbx,    0
    mov     bl,     [tm.min]
    shl     rbx,    5
    or      rbx,    rax
    mov     rax,    0
    mov     al,     [tm.sec]
    mov     rcx,    2
    div     rcx
    or      rbx,    rax
    pop rax 
    ;bx is now time 

    pop rdx
    pop rcx
    ret


localtime:
    ;divide to get the number of minutes since epoch in rax and currenty seconds in rdx 
    push rcx
    push rax 
    push rdx 
    push rbx
    push r10

    mov rdx, 0
    mov rcx, 60 
    div rcx

    ; rdx is the current seconds time  
    mov [tm.sec], dl

    ;divide to get the number of hours since epoch in rax and current minutes in rdx 
    mov rdx, 0
    mov rcx, 60 
    div rcx

    ; rdx is the current minutes 
    mov [tm.min], dl

    ; convert to time zone and daylight savings
    add rax, nz_time
    add rax, day_light_savings

    ;divide by 24 to get the number of days since epoch in rax and current hours in rdx
    mov rdx, 0
    mov rcx, 24 
    div rcx

    ; rdx is the current hours 
    mov [tm.hour], dl

    ;At this point rax is the number of days 
    ;need: number of years, day of year, months, day of month and day of week


    ;Calculate the day of the week 
    push rax 
    add rax, 3 ;account for not starting on monday 
    mov rdx, 0
    mov rcx, 7
    div rcx
    mov [tm.wday], dl
    pop rax


    ;calculate year 
    add rax, 365*2 + 1  ;account for leap year timings 
    
    mov rdx, 0
    mov rcx, 4
    mul rcx
    mov rdx, 0
    mov rcx, 1461 ;365*4 + 1
    div rcx
    sub rax, 2


    ;Year 
    push rax 
    push rdx 
    mov rcx, 70
    add rax, rcx
    mov [tm.year], eax
    pop rdx
    pop rax 

    ;caluculate day of year 
    push rax 
    mov rax, rdx
    
    mov rdx, 0
    mov rcx, 4
    div rcx

    mov [tm.yday], ax

    mov rdx, rax
    pop rax



    push rdx
    mov rdx,0 
    mov rcx, 4
    div rcx
    mov rax, rdx
    sub rax, 2
    pop rdx
    
    ;at this point rdx is the day of the year and rax is remainder of year /4 (0 when leap)
    ;need day of month and month
    mov rcx, 0 ; month
    mov r10, .month_lengths
    .startloop1:
    cmp rax, 0
    jne .ifend1 
    
    cmp rcx, 1
    je .ifend2
    
    .ifend1:
    cmp dx, [r10]
    jl .endloop1
    sub dx, [r10]
    jmp .else1
    .ifend2:
    
    cmp dx, 29
    jl .endloop1
    sub dx, 29
    .else1:


    
    inc r10
    inc r10
    inc rcx
    jmp .startloop1 
    .endloop1:


    mov [tm.mon], cl

    mov [tm.mday], dl

    mov byte [tm.isdst], day_light_savings

    pop r10
    pop rbx
    pop rdx
    pop rax
    pop rcx

    ret 
    .month_lengths: dw 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31


print_localtime:
    ;Run the Local time function then call this function to print all Tm Values 
    mov rbx, 5
    mov rax, 0
    mov al, [tm.sec]
    call print_number
    call print_newline
    mov rax, 0 
    mov al, [tm.min] 
    call print_number
    call print_newline
    mov rax, 0
    mov al, [tm.hour] 
    call print_number
    call print_newline
    mov rax, 0
    mov al, [tm.mday] 
    call print_number
    call print_newline
    mov rax, 0
    mov al, [tm.mon] 
    call print_number
    call print_newline
    mov rax, 0
    mov eax, [tm.year] 
    call print_number
    call print_newline
    mov rax, 0
    mov al, [tm.wday] 
    call print_number
    call print_newline
    mov rax, 0
    mov ax, [tm.yday] 
    call print_number
    call print_newline
    mov rax, 0
    mov al, [tm.isdst] 
    call print_number
    call print_newline
    ret

timef:
    ;rax is a pointer to the output if not null 

    push rdx
    push rsi
    push rdi
    mov rdx, 0       ;message length
    mov rsi, 0        ;message to write
    mov rdi, rax        ;file descriptor
    mov rax, LINUX_SYSCALL.time  
    syscall            ;call kernel   

    call check_Error
    pop rdi
    pop rsi
    pop rdx
    

    ret

fwrite:
    ;rax is a pointer to the file 
    ;rbx is a pointer to the input 
    ;rcx is the size to input 

    push rax
    push rdx
    push rsi
    push rdi
    mov rdx, rcx       ;message length
    mov rsi, rbx        ;message to write
    mov rdi, rax        ;file descriptor
    mov rax, LINUX_SYSCALL.write  
    syscall            ;call kernel    
    pop rdi
    pop rsi
    pop rdx
    pop rax

    ret

bytes_to_lbas:
    push rbx
    mov rbx, lba_size
    dec rbx
    add rax, rbx
    mov rcx, lba_size
    div rcx
    pop rbx

    ret





memcmp:
    ;rax is the input of the first memory pointer , and the true or false output
    ;rbx is the input of the second memory
    ;rcx is the length of the comparison 
    ;internal registers: rdx, r10
    push rdx
    push rbx
    push rcx
    push r10
    mov rdx, 0 
    .loop:
    ; call print_test

    mov r10b, [rbx]
    cmp [rax], r10b
    jne .fail
    inc rax
    inc rbx
    inc rdx

    cmp rdx, rcx
    jl .loop

    mov rax, 1
    jmp .end

    .fail:
    mov rax, 0

    .end:

    pop r10
    pop rcx
    pop rbx
    pop rdx
    ret



fread:
    ;rax is the file pointer 
    ;rbx is the location the output read from file 
    ;rcx is the count of bytes taken from the file 
    push rdx
    push rdi 
    push rsi
    mov rdi, rax
    mov rsi, rbx
    mov rdx, rcx     
    mov rax, LINUX_SYSCALL.read_SYSCALL
    syscall


    call check_Error
    pop rsi
    pop rdi
    pop rdx
    ret



strncpy:; registers used: rax, rbx, rcx, rdx
    ;rax is the string to be set 
    ;rbx is pointer to value to copy
    ;rcx is the length of the string 
    ;only inside: rdx
    push rax
    push rbx
    push rcx
    push rdx
    mov rdx, 0 
    .loop1_start:
    cmp rdx, rcx
    je .loop1_end

    cmp byte [rbx], 0
    je .loop1_end
    push rcx
    mov rcx, [rbx]
    mov [rax], rcx
    pop rcx
    inc rax 
    inc rbx 
    jmp .loop1_start
    .loop1_end:

    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret 


strlen:; registers used: rax
    ;rax is the string to be set and the number returned
    push rbx
    mov rbx, 0
    .loop1_start:

    cmp byte [rax], 0
    je .loop1_end

    inc rbx
    inc rax 
    ; push rax
    ; mov rax, rbx
    ; call print_number
    ; pop rax
    jmp .loop1_start
    .loop1_end:
    mov rax, rbx
    pop rbx

    ret 


memcopy:; registers used: rax, rbx, rcx, rdx
    ;rax is the string to be set 
    ;rbx is pointer to value to copy
    ;rcx is the length of the string 
    ;only inside: rdx
    push rax
    push rbx
    push rdx
    mov rdx, 0

    .loop1_start:

    cmp rdx, rcx
    je .loop1_end

    ; call print_test
    push rcx
    mov rcx, 0
    mov cl, [rbx]
    mov [rax], cl
    pop rcx

    inc rax 
    inc rbx 
    inc rdx
    jmp .loop1_start
    .loop1_end:

    pop rdx
    pop rbx
    pop rax

    ret 


zeroarray: ;registers used: rax, rbx, rcx 
    ;rax is the string 
    ;rbx is the length 
    ;only inside: rcx
   push rax
   push rbx
   push rcx
    mov rcx, 0
    .loop1_start:
        cmp rbx, rcx 
        je .loop1_end
        mov byte [rax], 0
        inc rcx
        
        jmp .loop1_start
    .loop1_end:

    pop rcx
    pop rbx
    pop rax
    ret 



memset: ;registers used: rax, rbx, rcx, rdx 
    ;rax is a pointer to the start of the sting 
    ;rbx is the length of the string to be set to rax 
    ;rcx is the character to set the values to 
    ;only inside: rdx 
    push rax
    push rbx
    push rcx
    push rdx

    mov rdx, 0
    .loop1_start:
        cmp rbx, rdx 
        je .loop1_end
        mov [rax], cl
        inc rdx
        inc rax
        
        
        jmp .loop1_start
    .loop1_end:

    pop rdx
    pop rcx
    pop rbx
    pop rax

    ret 


strchr:
    ;rax is pointer to start of string is kept the same 
    ;r9 is character to compare and will be position if true (r9l)
    
    push rax 

    .loop1_start:
        cmp [rax], r9b
        je .loop1_end2
        inc rax


        cmp byte [rax], 0
        je .loop1_end1
        
        jmp .loop1_start
    .loop1_end1:
    mov rax, 0 
    .loop1_end2:
    mov r9, rax 
    pop rax 
    ret


String_to_Upper:
    ;rax is the pointer to the string for input and output
    ;rbx is the length of the string for input and output
    push rax
    push rbx 
    
    mov r10, rbx 
    mov r9, 0
    .loop_start:
        cmp byte [rax], 122
        jg .else

        cmp byte [rax], 97
        jl  .else

    .if:
        mov rbx, [rax]
        mov rcx, 32
        Sub rbx, rcx
        mov [rax], rbx

    .else:
        inc rax 
        inc r9
        cmp r9, r10

        jl .loop_start


    pop rbx
    pop rax 
    ret



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
    push rax 
    push rdx
    push rdi 
    push rsi
    mov rdi, [image]
    mov rsi, rax
    mov rdx, 0     
    mov rax, 8
    syscall
    pop rsi
    pop rdi
    pop rdx
    pop rax
    ret

fseek:
    ;uses lseek linux function
    ;rax is file
    ;rbx is destination in file 
    ;rcx is type of Search  

    push rdx
    push rdi 
    push rsi


    mov rdi, rax
    mov rsi, rbx
    mov rdx, rcx     
    mov rax, LINUX_SYSCALL.lseek
    syscall

    call check_Error

    pop rsi
    pop rdi
    pop rdx
    ret




open_file:
    mov rdi, image_name
    mov rsi, O_CREAT | O_RDWR     ;0102o O_CREAT, man open
    mov rdx, S_IRUSR | S_IWUSR | S_IROTH | S_IWOTH ; 0666o umode_t
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


print_number: 
    ;rax is input number 
    ;rbx is digits printed 
    ;internal registers: rcx, rdx, rdi, rsi, r10
    push rax
    push rbx
    push rcx
    push rdx
    push rdi 
    push rsi 
    push r10

    mov r10, 0 ;loop Count initiliased 
    push 0x0A ; add new line to stack

    .loop:
    mov rdx, 0 ;zero rdx
    mov rcx, 10 ;base ten 

    div rcx ; rax = rax / rcx, rdx = remainder 

    add rdx, 0x30 ;convert to ASCI

    push rdx ; add to stack 

    ; call print_test
    inc r10
    
    cmp r10, rbx ;check if loop is done 
     
    jl .loop

    mov rax, 8
    mul rbx ; rax = rbx * rax
    mov rdx, rax
    mov rax, LINUX_SYSCALL.write  
    mov rdi, write_console
    mov rsi, rsp ;print stack
    syscall

    inc r10 
    mov rax, 8
    mul r10
    add rsp, rax 


    pop r10
    pop rsi 
    pop rdi 
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret



check_Error: ;Code is Done
    cmp rax, 0
    jl .Error
    ret 

    .Error:
    mov rcx, -1
    mul rcx

    mov rbx, LINUX_ERRORS.EBADF
    cmp rax, EBADF
    je .print

    mov rbx, LINUX_ERRORS.ENOENT
    cmp rax, ENOENT
    je .print
    
    mov rbx, .unknown
    .print:

    mov rax, .Error_Message
    call print_string

    mov rax, rbx
    call print_string
    
    .end_program:
    mov eax, 60
    xor rdi, rdi
    syscall

    .unknown: db "Unknown Error", 0 
    .Error_Message: db "Error: " , 0



print_string: ;rax is pointer to string

    push rax
    push rcx
    push rax
    push rdx
    push rdi
    push rsi

    mov rsi, rax
    call strlen
    mov rdx, rax
    mov rax, LINUX_SYSCALL.write
    mov rdi, write_console
    syscall

    
    pop rsi
    pop rdi
    pop rdx
    pop rax
    pop rcx
    pop rax
    ret


print_test: 

    push rax
    push rdi
    push rsi 
    push rdx

    mov rax, 1
    mov rdi, 1
    mov rsi, .message
    mov rdx, 5
    syscall

    pop rdx
    pop rsi 
    pop rdi
    pop rax
    ret 

    .message: db "Test" , 0x0A



    print_newline: 

    push rax
    push rdi
    push rsi 
    push rdx

    mov rax, 1
    mov rdi, 1
    mov rsi, .message
    mov rdx, 1
    syscall

    pop rdx
    pop rsi 
    pop rdi
    pop rax
    ret 

    .message: db 0x0A


done: ;Code is Done

    mov rax, 1
    mov rdi, 1
    mov rsi, .message
    mov rdx, 13
    syscall

    mov eax, 60
    xor rdi, rdi
    syscall

    .message: 
        dd "Code is done", 10
;========================================================
;Data
;========================================================
section .data

    ;File image
    image dq 0
    image_name db 'test.hdd', 0

    ;Boot64.efi
    Boot64 dq 0
    Boot64_name db 'src/BOOTX64.asm', 0

    ;Vars 
    cluster dd 0
    path db "/EFI/BOOT/DSKIMG.INF", 0
    path_size equ $-path

    ;rand_arr
    rand_arr times 16 db 0x00

    found db 0 
    dir_cluster dd 0

    file_size_bytes dq 0 
    next_free_cluster dd 0
    starting_cluster dd 0
    file_size_lbas dq 0
    

File_type:
    TYPE_DIR equ 0
    TYPE_FILE equ 1


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

tm:
    .sec:   db 0 ;seconds,  range 0 to 59
    .min:   db 0 ;minutes, range 0 to 59
    .hour:  db 0 ;hours, range 0 to 23
    .mday:  db 0 ;day of the month, range 1 to 31
    .mon:   db 0 ;month, range 0 to 11
    .year:  dd 0 ;The number of years since 1900
    .wday:  db 0 ;day of the week, range 0 to 6
    .yday:  dw 0 ;day in the year, range 0 to 36
    .isdst: db 0 ;daylight saving time

FAT32_Dir_Attr:
    ATTR_READ_ONLY equ 0x01
    ATTR_HIDDEN    equ 0x02
    ATTR_SYSTEM    equ 0x04
    ATTR_VOLUME_ID equ 0x08
    ATTR_DIRECTORY equ 0x10
    ATTR_ARCHIVE   equ 0x20
    ATTR_LONG_NAME equ ATTR_READ_ONLY | ATTR_HIDDEN | ATTR_SYSTEM | ATTR_VOLUME_ID


LINUX_SYSCALL:
    .read_SYSCALL:  equ 0 
    .write: equ 1
        write_console   equ 1
    .open:  equ 2;int open(const char *pathname, int flags, /* mode_t mode */ );
        O_RDONLY        equ 0000o ;Read only 
        O_WRONLY        equ 0001o ;write only 
        O_RDWR          equ 0002o ;read and write
        O_CREAT         equ 0100o ;if file doesn't exist create it 

        ;modes for O_CREAT
        S_IRWXU         equ 00700o ; user (file owner) has read, write, and execute permission
        S_IRUSR         equ 00400o ; user has read permission
        S_IWUSR         equ 00200o ; user has write permission
        S_IXUSR         equ 00100o ; user has execute permission
        S_IRWXG         equ 00070o ; group has read, write, and execute permission
        S_IRGRP         equ 00040o ; group has read permission
        S_IWGRP         equ 00020o ; group has write permission
        S_IXGRP         equ 00010o ; group has execute permission
        S_IRWXO         equ 00007o ; others have read, write, and execute permission
        S_IROTH         equ 00004o ; others have read permission
        S_IWOTH         equ 00002o ; others have write permission
        S_IXOTH         equ 00001o ; others have execute permission

        S_ISUID         equ 00040o ;00 set-user-ID bit
        S_ISGID         equ 00020o ;00 set-group-ID bit (see inode(7)).
        S_ISVTX         equ 00010o ;00 sticky bit (see inode(7)).
    .close_SYSCALL: equ 3
    .stat_SYSCALL:  equ 4
    .fstat_SYSCALL: equ 5
    .lstat_SYSCALL: equ 6
    .poll:          equ 7
    .lseek:         equ 8
        SEEK_SET        equ 0
        SEEK_CUR        equ 1
        SEEK_END        equ 2
    .mmap_SYSCALL:  equ 9
        PROT_READ	    equ 0x1		/* page can be read */
        PROT_WRITE	    equ 0x2		/* page can be written */
        PROT_EXEC	    equ 0x4	    /* page can be executed */
        PROT_NONE	    equ 0x0	

        MAP_SHARED	    equ 0x01		/* Share changes */
        MAP_PRIVATE	    equ 0x02		/* Changes are private */
        MAP_SHARED_VALIDATE equ  0x03	/* share + validate extension flags */
        MAP_FIXED	    equ 0x100		/* Interpret addr exactly */
        MAP_ANONYMOUS	equ 0x10        /* don't use a file */
        MAP_FIXED_NOREPLACE	equ 0x200000/* MAP_FIXED which doesn't unmap underlying mapping */
        MAP_GROWSDOWN	equ 0x01000		/* stack-like segment */
        MAP_HUGETLB 	equ 0x100000	/* create a huge page mapping */
        MAP_LOCKED	    equ 0x08000		/* lock the mapping */
        MAP_NONBLOCK    equ 0x40000		/* do not block on IO */
        MAP_NORESERVE	equ 0x10000		/* don't check for reservations */
        MAP_POPULATE    equ 0x20000		/* populate (prefault) pagetables */
        MAP_STACK	    equ 0x80000		/* give out an address that is best suited for process/thread stacks */
        MAP_UNINITIALIZED equ  0x4000000	/* For anonymous mmap, memory could be uninitialized */
        MAP_SYNC		equ 0x080000 /* perform synchronous page faults for the mapping */
        MAP_32BIT	    equ 0x40	
        MAP_HUGE_2MB    equ 21 << MAP_HUGE_SHIFT
        MAP_HUGE_2MB    equ 30 << MAP_HUGE_SHIFT


    .mporotect:     equ 10
    .munmap:        equ 11
    .time:          equ 201



MAP_HUGE_SHIFT equ 26	

LINUX_ERRORS:
    EPERM equ           1  ;Operation not permitted
    ENOENT equ          2  ;No such file or directory
    ESRCH equ           3  ;No such process
    EINTR equ           4  ;Interrupted system call
    EIO equ             5  ;I/O error
    ENXIO equ           6  ;No such device or address
    E2BIG equ           7  ;Argument list too long
    ENOEXEC equ         8  ;Exec format error
    EBADF equ           9  ;Bad file number
    ECHILD equ          10 ;No child processes
    EAGAIN equ          11 ;Try again
    ENOMEM equ          12 ;Out of memory
    EACCES equ          13 ;Permission denied
    EFAULT equ          14 ;Bad address
    ENOTBLK equ         15 ;Block device required
    EBUSY equ           16 ;Device or resource busy
    EEXIST equ          17 ;File exists
    EXDEV equ           18 ;Cross-device link
    ENODEV equ          19 ;No such device
    ENOTDIR equ         20 ;Not a directory
    EISDIR equ          21 ;Is a directory
    EINVAL equ          22 ;Invalid argument
    ENFILE equ          23 ;File table overflow
    EMFILE equ          24 ;Too many open files
    ENOTTY equ          25 ;Not a typewriter
    ETXTBSY equ         26 ;Text file busy
    EFBIG equ           27 ;File too large
    ENOSPC equ          28 ;No space left on device
    ESPIPE equ          29 ;Illegal seek
    EROFS equ           30 ;Read-only file system
    EMLINK equ          31 ;Too many links
    EPIPE equ           32 ;Broken pipe
    EDOM equ            33 ;Math argument out of domain of func
    ERANGE equ          34 ;Math result not representable
    EDEADLK equ         35 ;Resource deadlock would occur
    ENAMETOOLONG equ    36 ;File name too long
    ENOLCK equ          37 ;No record locks available
    ENOSYS equ          38 ;Function not implemented
    ENOTEMPTY equ       39 ;Directory not empty
    ELOOP equ           40 ;Too many symbolic links encountered
    ENOMSG equ          42 ;No message of desired type
    EIDRM equ           43 ;Identifier removed
    ECHRNG equ          44 ;Channel number out of range
    EL2NSYNC equ        45 ;Level 2 not synchronized
    EL3HLT equ          46 ;Level 3 halted
    EL3RST equ          47 ;Level 3 reset
    ELNRNG equ          48 ;Link number out of range
    EUNATCH equ         49 ;Protocol driver not attached
    ENOCSI equ          50 ;No CSI structure available
    EL2HLT equ          51 ;Level 2 halted
    EBADE equ           52 ;Invalid exchange
    EBADR equ           53 ;Invalid request descriptor
    EXFULL equ          54 ;Exchange full
    ENOANO equ          55 ;No anode
    EBADRQC equ         56 ;Invalid request code
    EBADSLT equ         57 ;Invalid slot
    EBFONT equ          59 ;Bad font file format
    ENOSTR equ          60 ;Device not a stream
    ENODATA equ         61 ;No data available
    ETIME equ           62 ;Timer expired
    ENOSR equ           63 ;Out of streams resources
    ENONET equ          64 ;Machine is not on the network
    ENOPKG equ          65 ;Package not installed
    EREMOTE equ         66 ;Object is remote
    ENOLINK equ         67 ;Link has been severed
    EADV equ            68 ;Advertise error
    ESRMNT equ          69 ;Srmount error
    ECOMM equ           70 ;Communication error on send
    EPROTO equ          71 ;Protocol error
    EMULTIHOP equ       72 ;Multihop attempted
    EDOTDOT equ         73 ;RFS specific error
    EBADMSG equ         74 ;Not a data message
    EOVERFLOW equ       75 ;Value too large for defined data type
    ENOTUNIQ equ        76 ;Name not unique on network
    EBADFD equ          77 ;File descriptor in bad state
    EREMCHG equ         78 ;Remote address changed
    ELIBACC equ         79 ;Can not access a needed shared library
    ELIBBAD equ         80 ;Accessing a corrupted shared library
    ELIBSCN equ         81 ;.lib section in a.out corrupted
    ELIBMAX equ         82 ;Attempting to link in too many shared libraries
    ELIBEXEC equ        83 ;Cannot exec a shared library directly
    EILSEQ equ          84 ;Illegal byte sequence
    ERESTART equ        85 ;Interrupted system call should be restarted
    ESTRPIPE equ        86 ;Streams pipe error
    EUSERS equ          87 ;Too many users
    ENOTSOCK equ        88 ;Socket operation on non-socket
    EDESTADDRREQ equ    89 ;Destination address required
    EMSGSIZE equ        90 ;Message too long
    EPROTOTYPE equ      91 ;Protocol wrong type for socket
    ENOPROTOOPT equ     92 ;Protocol not available
    EPROTONOSUPPORT equ 93 ;Protocol not supported
    ESOCKTNOSUPPORT equ 94 ;Socket type not supported
    EOPNOTSUPP equ      95 ;Operation not supported on transport endpoint
    EPFNOSUPPORT equ    96 ;Protocol family not supported
    EAFNOSUPPORT equ    97 ;Address family not supported by protocol
    EADDRINUSE equ      98 ;Address already in use
    EADDRNOTAVAIL equ   99 ;Cannot assign requested address
    ENETDOWN equ        100;Network is down
    ENETUNREACH equ     101;Network is unreachable
    ENETRESET equ       102;Network dropped connection because of reset
    ECONNABORTED equ    103;Software caused connection abort
    ECONNRESET equ      104;Connection reset by peer
    ENOBUFS equ         105;No buffer space available
    EISCONN equ         106;Transport endpoint is already connected
    ENOTCONN equ        107;Transport endpoint is not connected
    ESHUTDOWN equ       108;Cannot send after transport endpoint shutdown
    ETOOMANYREFS equ    109;Too many references: cannot splice
    ETIMEDOUT equ       110;Connection timed out
    ECONNREFUSED equ    111;Connection refused
    EHOSTDOWN equ       112;Host is down
    EHOSTUNREACH equ    113;No route to host
    EALREADY equ        114;Operation already in progress
    EINPROGRESS equ     115;Operation now in progress
    ESTALE equ          116;Stale NFS file handle
    EUCLEAN equ         117;Structure needs cleaning
    ENOTNAM equ         118;Not a XENIX named type file
    ENAVAIL equ         119;No XENIX semaphores available
    EISNAM equ          120;Is a named type file
    EREMOTEIO equ       121;Remote I/O error
    EDQUOT equ          122;Quota exceeded
    ENOMEDIUM equ       123;No medium found
    EMEDIUMTYPE equ     124;Wrong medium type
    ECANCELED equ       125;Operation Canceled
    ENOKEY equ          126;Required key not available
    EKEYEXPIRED equ     127;Key has expired
    EKEYREVOKED equ     128;Key has been revoked
    EKEYREJECTED equ    129;Key was rejected by service
    EOWNERDEAD equ      130;Owner died
    ENOTRECOVERABLE equ 131;State not recoverable
    .EPERM:           db "Operation not permitted", 0x0A ,0
    .ENOENT:          db "No such file or directory", 0x0A ,0
    .ESRCH:           db "No such process", 0x0A ,0
    .EINTR:           db "Interrupted system call", 0x0A ,0
    .EIO:             db "I/O error", 0x0A ,0
    .ENXIO:           db "No such device or address", 0x0A ,0
    .E2BIG:           db "Argument list too long", 0x0A ,0
    .ENOEXEC:         db "Exec format error", 0x0A ,0
    .EBADF:           db "Bad file number", 0x0A ,0
    .ECHILD:          db "No child processes", 0x0A ,0
    .EAGAIN:          db "Try again", 0x0A ,0
    .ENOMEM:          db "Out of memory", 0x0A ,0
    .EACCES:          db "Permission denied", 0x0A ,0
    .EFAULT:          db "Bad address", 0x0A ,0
    .ENOTBLK:         db "Block device required", 0x0A ,0
    .EBUSY:           db "Device or resource busy", 0x0A ,0
    .EEXIST:          db "File exists", 0x0A ,0
    .EXDEV:           db "Cross-device link", 0x0A ,0
    .ENODEV:          db "No such device", 0x0A ,0
    .ENOTDIR:         db "Not a directory", 0x0A ,0
    .EISDIR:          db "Is a directory", 0x0A ,0
    .EINVAL:          db "Invalid argument", 0x0A ,0
    .ENFILE:          db "File table overflow", 0x0A ,0
    .EMFILE:          db "Too many open files", 0x0A ,0
    .ENOTTY:          db "Not a typewriter", 0x0A ,0
    .ETXTBSY:         db "Text file busy", 0x0A ,0
    .EFBIG:           db "File too large", 0x0A ,0
    .ENOSPC:          db "No space left on device", 0x0A ,0
    .ESPIPE:          db "Illegal seek", 0x0A ,0
    .EROFS:           db "Read-only file system", 0x0A ,0
    .EMLINK:          db "Too many links", 0x0A ,0
    .EPIPE:           db "Broken pipe", 0x0A ,0
    .EDOM:            db "Math argument out of domain of func", 0x0A ,0
    .ERANGE:          db "Math result not representable", 0x0A ,0
    .EDEADLK:         db "Resource deadlock would occur", 0x0A ,0
    .ENAMETOOLONG:    db "File name too long", 0x0A ,0
    .ENOLCK:          db "No record locks available", 0x0A ,0
    .ENOSYS:          db "Function not implemented", 0x0A ,0
    .ENOTEMPTY:       db "Directory not empty", 0x0A ,0
    .ELOOP:           db "Too many symbolic links encountered", 0x0A ,0
    .ENOMSG:          db "No message of desired type", 0x0A ,0
    .EIDRM:           db "Identifier removed", 0x0A ,0
    .ECHRNG:          db "Channel number out of range", 0x0A ,0
    .EL2NSYNC:        db "Level 2 not synchronized", 0x0A ,0
    .EL3HLT:          db "Level 3 halted", 0x0A ,0
    .EL3RST:          db "Level 3 reset", 0x0A ,0
    .ELNRNG:          db "Link number out of range", 0x0A ,0
    .EUNATCH:         db "Protocol driver not attached", 0x0A ,0
    .ENOCSI:          db "No CSI structure available", 0x0A ,0
    .EL2HLT:          db "Level 2 halted", 0x0A ,0
    .EBADE:           db "Invalid exchange", 0x0A ,0
    .EBADR:           db "Invalid request descriptor", 0x0A ,0
    .EXFULL:          db "Exchange full", 0x0A ,0
    .ENOANO:          db "No anode", 0x0A ,0
    .EBADRQC:         db "Invalid request code", 0x0A ,0
    .EBADSLT:         db "Invalid slot", 0x0A ,0
    .EBFONT:          db "Bad font file format", 0x0A ,0
    .ENOSTR:          db "Device not a stream", 0x0A ,0
    .ENODATA:         db "No data available", 0x0A ,0
    .ETIME:           db "Timer expired", 0x0A ,0
    .ENOSR:           db "Out of streams resources", 0x0A ,0
    .ENONET:          db "Machine is not on the network", 0x0A ,0
    .ENOPKG:          db "Package not installed", 0x0A ,0
    .EREMOTE:         db "Object is remote", 0x0A ,0
    .ENOLINK:         db "Link has been severed", 0x0A ,0
    .EADV:            db "Advertise error", 0x0A ,0
    .ESRMNT:          db "Srmount error", 0x0A ,0
    .ECOMM:           db "Communication error on send", 0x0A ,0
    .EPROTO:          db "Protocol error", 0x0A ,0
    .EMULTIHOP:       db "Multihop attempted", 0x0A ,0
    .EDOTDOT:         db "RFS specific error", 0x0A ,0
    .EBADMSG:         db "Not a data message", 0x0A ,0
    .EOVERFLOW:       db "Value too large for defined data type", 0x0A ,0
    .ENOTUNIQ:        db "Name not unique on network", 0x0A ,0
    .EBADFD:          db "File descriptor in bad state", 0x0A ,0
    .EREMCHG:         db "Remote address changed", 0x0A ,0
    .ELIBACC:         db "Can not access a needed shared library", 0x0A ,0
    .ELIBBAD:         db "Accessing a corrupted shared library", 0x0A ,0
    .ELIBSCN:         db ".lib section in a.out corrupted", 0x0A ,0
    .ELIBMAX:         db "Attempting to link in too many shared libraries", 0x0A ,0
    .ELIBEXEC:        db "Cannot exec a shared library directly", 0x0A ,0
    .EILSEQ:          db "Illegal byte sequence", 0x0A ,0
    .ERESTART:        db "Interrupted system call should be restarted", 0x0A ,0
    .ESTRPIPE:        db "Streams pipe error", 0x0A ,0
    .EUSERS:          db "Too many users", 0x0A ,0
    .ENOTSOCK:        db "Socket operation on non-socket", 0x0A ,0
    .EDESTADDRREQ:    db "Destination address required", 0x0A ,0
    .EMSGSIZE:        db "Message too long", 0x0A ,0
    .EPROTOTYPE:      db "Protocol wrong type for socket", 0x0A ,0
    .ENOPROTOOPT:     db "Protocol not available", 0x0A ,0
    .EPROTONOSUPPORT: db "Protocol not supported", 0x0A ,0
    .ESOCKTNOSUPPORT: db "Socket type not supported", 0x0A ,0
    .EOPNOTSUPP:      db "Operation not supported on transport endpoint", 0x0A ,0
    .EPFNOSUPPORT:    db "Protocol family not supported", 0x0A ,0
    .EAFNOSUPPORT:    db "Address family not supported by protocol", 0x0A ,0
    .EADDRINUSE:      db "Address already in use", 0x0A ,0
    .EADDRNOTAVAIL:   db "Cannot assign requested address", 0x0A ,0
    .ENETDOWN:        db "Network is down", 0x0A ,0
    .ENETUNREACH:     db "Network is unreachable", 0x0A ,0
    .ENETRESET:       db "Network dropped connection because of reset", 0x0A ,0
    .ECONNABORTED:    db "Software caused connection abort", 0x0A ,0
    .ECONNRESET:      db "Connection reset by peer", 0x0A ,0
    .ENOBUFS:         db "No buffer space available", 0x0A ,0
    .EISCONN:         db "Transport endpoint is already connected", 0x0A ,0
    .ENOTCONN:        db "Transport endpoint is not connected", 0x0A ,0
    .ESHUTDOWN:       db "Cannot send after transport endpoint shutdown", 0x0A ,0
    .ETOOMANYREFS:    db "Too many references: cannot splice", 0x0A ,0
    .ETIMEDOUT:       db "Connection timed out", 0x0A ,0
    .ECONNREFUSED:    db "Connection refused", 0x0A ,0
    .EHOSTDOWN:       db "Host is down", 0x0A ,0
    .EHOSTUNREACH:    db "No route to host", 0x0A ,0
    .EALREADY:        db "Operation already in progress", 0x0A ,0
    .EINPROGRESS:     db "Operation now in progress", 0x0A ,0
    .ESTALE:          db "Stale NFS file handle", 0x0A ,0
    .EUCLEAN:         db "Structure needs cleaning", 0x0A ,0
    .ENOTNAM:         db "Not a XENIX named type file", 0x0A ,0
    .ENAVAIL:         db "No XENIX semaphores available", 0x0A ,0
    .EISNAM:          db "Is a named type file", 0x0A ,0
    .EREMOTEIO:       db "Remote I/O error", 0x0A ,0
    .EDQUOT:          db "Quota exceeded", 0x0A ,0
    .ENOMEDIUM:       db "No medium found", 0x0A ,0
    .EMEDIUMTYPE:     db "Wrong medium type", 0x0A ,0
    .ECANCELED:       db "Operation Canceled", 0x0A ,0
    .ENOKEY:          db "Required key not available", 0x0A ,0
    .EKEYEXPIRED:     db "Key has expired", 0x0A ,0
    .EKEYREVOKED:     db "Key has been revoked", 0x0A ,0
    .EKEYREJECTED:    db "Key was rejected by service", 0x0A ,0
    .EOWNERDEAD:      db "Owner died", 0x0A ,0
    .ENOTRECOVERABLE: db "State not recoverable", 0x0A ,0





section .bss

;crc table
crc_table resd 256 
ctemp resd 1
ntemp resd 1
ktemp resd 1

;fat32datalba
fat32_data_lba resq 1


short_name times 12 resb 1
short_name_length equ $-short_name