[bits 64]

section .text
global _start          ;must be declared for linker (ld)

options:
    image_name db 'test.hdd', 0
    lba_size equ 0x00000200
    esp_size equ 1024*1024*33
    data_size equ 1024*1024
    esp_file_paths db 'path', 0
    num_esp_file_paths equ 0x00000001
    esp_files db 'e.bin', 0
    data_files db 'data.bin'
    num_data_files equ 0x00000001
    ALIGNMENT equ 1048576
    ;help db 0x00
    ;error db 0x00


; Args: rdi   rsi   rdx   r10   r8    r9
_start:                ;tell linker entry point
   call check_esp  
   call calc_values
   call open_file
   mov [image], rax
   call display_data
   call write_mbr
   call write_gpts



    jmp done

check_esp:
    .check1: ;lba_size = 512
        mov eax, lba_size
        mov ebx, 0x00000200 ;512
        cmp eax, ebx
        je .check5

    .check2: ;lba_size = 1024
        mov eax, lba_size
        mov ebx, 0x00000400 ;1024
        cmp eax, ebx
        je .check6

    .check3: ;lba_size = 2048
        mov eax, lba_size
        mov ebx, 0x00000800 ;2048
        cmp eax, ebx
        je .check7

    .check4: ;lba_size = 4096
        mov eax, lba_size
        mov ebx, 0x00000400 ;4096
        cmp eax, ebx
        je .check8
        jmp error
    
    .check5: ;esp_size < 33
        mov eax, esp_size
        mov ebx, 0x00000021 * ALIGNMENT;33
        cmp eax, ebx
        jl error
        ret

    .check6: ;esp_size < 65
        mov eax, esp_size
        mov ebx, 0x00000041 * ALIGNMENT;65
        cmp eax, ebx
        jl error
        ret

    .check7: ;esp_size < 129
        mov eax, esp_size
        mov ebx, 0x00000081 * ALIGNMENT;129
        cmp eax, ebx
        jl error
        ret

    .check8: ;esp_size < 257
        mov eax, esp_size
        mov ebx, 0x00000101 * ALIGNMENT;257
        cmp eax, ebx
        jl error
        ret
    
calc_values:
    mov edx, 0
    mov eax, GPT_TABLE_SIZE ; GPT_TABLE_SIZE/lba_size
    mov ecx, lba_size
    div ecx
    mov [gpt_table_lbas], eax

    ;(ALIGNMENT*2 + (lba_size * ((gpt_table_lbas*2) + 1 + 2))); 
    mov rax, [gpt_table_lbas] 
    mov rcx, 2
    mul rcx
    add rax, 3
    mov rdx, lba_size
    mul rdx
    add rax, ALIGNMENT*2
    mov [padding], rax

    mov rax, esp_size ; image_size = esp_size + data_size + padding
    mov rbx, data_size
    mov rcx, [padding]
    add rax, rbx
    add rax, rcx
    mov [image_size], rax


    mov rax, [image_size]
    call bytes_to_lbas
    mov [image_size_lbas], rax

    mov rdx, 0
    mov rax, ALIGNMENT
    mov rcx, lba_size
    div rcx

    mov [align_lba], rax

    mov [esp_lba], rax

    mov rax, esp_size
    call bytes_to_lbas
    mov [esp_size_lbas], rax


    mov rax, data_size
    call bytes_to_lbas
    mov [data_size_lbas], rax


    mov rax, [esp_lba]
    add rax, [esp_size_lbas]
    call next_aligned_lba
    mov [data_lba], rax

    ret

bytes_to_lbas: ; rax is the input and output
    mov rbx, rax
    mov rax, lba_size
    sub rax, 1
    add rax, rbx
    mov rdx, 0
    mov rcx, lba_size
    div rcx

    ret

next_aligned_lba:
    mov rbx, rax
    mov rdx, 0
    mov rcx, [align_lba]
    div rcx
    sub rax, rdx
    add rax, [align_lba]
    ret

open_file:
    mov rdi, image_name
    mov rsi, 0102o     ;O_CREAT, man open
    mov rdx, 0666o     ;umode_t
    mov rax, 2
    syscall
    mov [image], rax
    ret


display_data:
    mov rax, 1
    mov rdi, 1
    mov rsi, imgsn
    mov rdx, 13
    syscall

    mov rax, 1 ;image name output 
    mov rdi, 1
    mov rsi, image_name
    mov rdx, 9
    syscall
    mov rax, 1
    mov rdi, 1
    mov rsi, line_break
    mov rdx, 1
    syscall

    mov rax, 1 
    mov rdi, 1
    mov rsi, lbas
    mov rdx, 10
    syscall

    mov rdi, lba_size
    call print_uint

    mov rax, 1 
    mov rdi, 1
    mov rsi, esps
    mov rdx, 10
    syscall

    mov rdx, 0
    mov rax, esp_size
    mov rcx, ALIGNMENT
    div rcx
    mov rdi, rax
    call print_uint

    mov rax, 1 
    mov rdi, 1
    mov rsi, datas
    mov rdx, 11
    syscall

    mov rdx, 0
    mov rax, data_size
    mov rcx, ALIGNMENT
    div rcx
    mov rdi, rax
    call print_uint


    mov rax, 1 
    mov rdi, 1
    mov rsi, pads
    mov rdx, 9
    syscall

    mov rdx, 0
    mov rax, [padding]
    mov rcx, ALIGNMENT
    div rcx
    mov rdi, rax
    call print_uint

    mov rax, 1 
    mov rdi, 1
    mov rsi, imgs
    mov rdx, 12
    syscall

    mov rdx, 0
    mov rax, [image_size]
    mov rcx, ALIGNMENT
    div rcx
    mov rdi, rax
    call print_uint

    ret

write_mbr:
    mov rax, [image_size_lbas]
    mov [mbr_image_lbas], rax

    mov rax, mbr_image_lbas
    mov rbx, 0xFFFFFFFF
    cmp rax, rbx
    jg .check1
    jmp .check2

    .check1:
        mov rax, 0x100000000
        mov [mbr_image_lbas], rax

    .check2:
        mov rax, 0
        times 440 call write_to_file

        mov rax, 0
        times 4 call write_to_file

        mov rax, 0
        times 2 call write_to_file

        mov rax, 0
        call write_to_file

        mov rax, 0
        call write_to_file
        mov rax, 0x02
        call write_to_file
        mov rax, 0
        call write_to_file

        mov rax, 0xEE
        call write_to_file

        mov rax, 0xFF
        times 3 call write_to_file

        mov rax, 0x00
        times 3 call write_to_file
        mov rax, 0x01
        call write_to_file



        mov rax, [mbr_image_lbas]
        mov rbx, 1
        sub rax, rbx
        mov rbx, rax
        mov rdx, 4
        call write_to_file_4byte

        mov rax, 0 
        times 48 call write_to_file  
      
        mov rax, 0xAA
        call write_to_file
        mov rax, 0x55
        call write_to_file

        call write_full_lba_size

        ret 


write_full_lba_size:
    mov rax, 0x00
    times 512*(lba_size-512) call write_to_file

    ret

write_to_file:
    push rax
    mov rdx, 1       ;message length
    mov rsi, rsp       ;message to write
    mov rdi, [image]      ;file descriptor
    mov rax, 1         ;system call number (sys_write)
    syscall            ;call kernel    
    pop rax

    ret

write_to_file_4byte: ; rax input num , rdx is input length
    mov rdx, 4
    .repeat: 
        rol eax, 8

        push rdx
        call write_to_file
        pop rdx
        dec rdx

        test rdx, rdx
        jnz .repeat

        ret


write_to_file_8byte: ; rax input num , rdx is input length
    mov rdx, 8
    .repeat: 
        rol rax, 8

        push rdx
        call write_to_file
        pop rdx
        dec rdx

        test rdx, rdx
        jnz .repeat

        ret
    
write_gpts:
    mov rax, 1
    mov rdi, [image]
    mov rsi, signature
    mov rdx, 8
    syscall

    mov rax, 0x00010000
    call write_to_file_4byte

    mov rax, 92
    call write_to_file_4byte


    ;
    ; need to put header_crc32 herw
    ;


    mov rax, 0x00
    times 4 call write_to_file

    mov rax, 1
    call write_to_file_8byte

    mov rax, [image_size_lbas]
    mov rbx, 1
    sub rax, rbx
    call write_to_file_8byte

    mov rax, [gpt_table_lbas]
    mov rbx, 1
    sub rax, rbx
    call write_to_file_8byte

    mov rax, [image_size_lbas]
    mov rbx, 1
    sub rax, rbx
    mov rbx, [gpt_table_lbas]
    sub rax, rbx
    call write_to_file_8byte

    ;
    ; disk guid will be here 
    ;

    mov rax, 2
    call write_to_file_8byte

    mov rax, 128
    call write_to_file_4byte

    mov rax, 128
    call write_to_file_4byte


    ;
    ;partition table crc32 will be here 
    ;

    mov rax, 0x00
    times 512-92 call write_to_file


    call write_full_lba_size

    ret


calculate_crc32:


filestuff:

    mov rdx, len       ;message length
    mov rsi, msg2       ;message to write
    mov rdi, [image]      ;file descriptor
    mov rax, 1         ;system call number (sys_write)
    syscall            ;call kernel

    mov rdi, [image]
    mov rax, 3         ;sys_close
    syscall

    ret


print_uint: ; rdi is the number input 
    mov r10, rsp ;record stack pointer 
    mov    rax, rdi              

    mov    rcx, 0xa       ; new line        
    push   rcx            ; new line at end of int        
    mov    rsi, rsp       ;set input of syscalls to be stack 

    .toascii_digit:                
        xor    rdx, rdx
        div    rcx                   
        add    rdx, '0'
        dec    rsi                 
        mov    [rsi], dl

        test   rax, rax             
        jnz  .toascii_digit

        mov rax, 1               
        mov rdi, 1 
        mov r9, r10          
        sub r10, rsi   
        mov rdx, r10 ; length of message
        syscall 

        mov rsp, r9 ;reset stack pointer 
        ret
    

error: ;Prints Error message to Terminal then Exits 

    mov rax, 1
    mov rdi, 1
    mov rsi, .message
    mov rdx, 12
    syscall

    mov eax, 60
    xor rdi, rdi
    syscall

    .message: ;Error Message
        dd "Error", 10


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

definitions: 
    ;
    ; sizes in bytes 
    ;
    uint_8 equ 1
    uint_16 equ 2
    uint_32 equ 4
    uint_64 equ 8
    char16_t equ 2

Mbr: 


section .data
    msg db 0xF1
    msg2 db 0x56
    len equ $ - msg
    line_break db 0xa
    image dq 0
    GPT_TABLE_SIZE equ 16384
    gpt_table_lbas dq 0
    image_size dq 0
    image_size_lbas dq 0
    align_lba dq 0
    esp_lba dq 0
    esp_size_lbas dq 0
    data_size_lbas dq 0
    data_lba dq 0

    imgsn db "IMAGE NAME: "
    lbas db "LBA SIZE: "
    esps db "ESP Size: "
    datas db "DATA SIZE: "
    pads db "PADDING: "
    imgs db "IMAGE SIZE: "
    signature dq "EFI PART"


section .bss
    padding resq 1
    mbr_image_lbas resq 1


    


    






