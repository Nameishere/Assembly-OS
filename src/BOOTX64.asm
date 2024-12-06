[bits 64]

%include "src/boottypes.asm"
%include "src/Functions.asm"

section .text
global _start

_start:

    mov rbx, imageHandle
    mov [rbx], rcx

    call Table_setup

    ;Clear Screen
    mov rax, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.ClearScreen
    mov rbx, [rax]
    mov rax, EFI_SYSTEM_TABLE.ConOut
    mov rcx, [rax] 
    call rbx 

    mov rax, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.SetAttribute
    mov rbx, [rax]
    mov rax, EFI_SYSTEM_TABLE.ConOut
    mov rcx, [rax]
    mov rdx, 0x02
    call rbx 

    mov rax, 0
    call Change_Mode

    mov rax, SystemTableRevision
    call print_String

    mov rbx, EFI_SYSTEM_TABLE.Revision
    mov rax, 0
    mov eax, [rbx]
    mov r12, rax 
    shr rax, 16
    mov rcx, 0
    call print_Number

    call print_dot

    and r12, 0x0000000000FFFF
    mov rax, r12
    mov rcx, 10
    div rcx 
    mov r12, rdx
    mov rcx, 0 
    call print_Number

    call print_dot

    mov rax, r12
    mov rcx, 0 
    call print_Number

    call next_line

    mov rax, FirmwareVendor
    call print_String

    mov rdx, EFI_SYSTEM_TABLE.FirmwareVendor
    mov rax, [rdx]
    call print_unicode 

    call next_line

    mov rax, FirmwareRevision
    call print_String

    mov rbx, EFI_SYSTEM_TABLE.FirmwareRevision
    mov rax, [rbx]
    mov r12, rax 
    shr rax, 16
    mov rcx, 0
    call print_Number

    call print_dot

    and r12, 0x0000000000FFFF
    mov rax, r12
    mov rcx, 0 
    call print_Number

    call next_line

    mov rax, BootServicesRevision
    call print_String

    mov rbx, EFI_SYSTEM_TABLE.Revision
    mov rax, 0
    mov eax, [rbx]
    mov r12, rax 
    shr rax, 16
    mov rcx, 0
    call print_Number

    call print_dot

    and r12, 0x0000000000FFFF
    mov rax, r12
    mov rcx, 10
    div rcx 
    mov r12, rdx
    mov rcx, 0 
    call print_Number

    call print_dot

    mov rax, r12
    mov rcx, 0 
    call print_Number

    call next_line

    mov rax, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.EnableCursor
    mov rbx, [rax]
    mov rax, EFI_SYSTEM_TABLE.ConOut
    mov rcx, [rax] 
    mov rdx, 1
    call rbx 

    ;Reset Input Device 
    mov rax, EFI_SIMPLE_TEXT_INPUT_PROTOCOL.Reset
    mov rbx, [rax]
    mov rax, EFI_SYSTEM_TABLE.ConIn
    mov rcx, [rax] 
    mov rdx, 0
    call rbx 

    .GetInput:

    ;Reset Input Device 
    mov rax, EFI_SIMPLE_TEXT_INPUT_PROTOCOL.ReadKeyStroke
    mov rbx, [rax]
    mov rax, EFI_SYSTEM_TABLE.ConIn
    mov rcx, [rax] 
    mov rdx, read_character
    call rbx 

    cmp rax, EFI_SUCCESS
    jne .GetInput

    mov rax, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.OutputString
    mov rbx, [rax]
    mov rax, EFI_SYSTEM_TABLE.ConOut
    mov rcx, [rax] 
    mov rdx, read_character

    mov ax, [rdx]
    cmp ax, 0x17
    je .exit

    add rdx, 2
    je .exit
    call rbx 

    jmp .GetInput


    .exit:

    mov rax, EFI_RUNTIME_SERVICES.ResetSystem
    mov rbx, [rax]
    mov rcx, EFI_RESET_TYPE.EfiResetShutdown
    mov rdx, 0
    mov r8, 0

    call rbx

exception:
    mov rcx, 0
    div rcx


Table_setup:
    ; rdx is the system table pointer 
    mov rbx, EFI_SYSTEM_TABLE
    mov rcx, EFI_SYSTEM_TABLE.size
    Call mov_data

    mov rbx, EFI_SYSTEM_TABLE.ConOut
    mov rdx, [rbx]
    mov rbx, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL
    mov rcx, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.size
    Call mov_data

    mov rbx, EFI_SYSTEM_TABLE.ConIn
    mov rdx, [rbx]
    mov rbx, EFI_SIMPLE_TEXT_INPUT_PROTOCOL
    mov rcx, EFI_SIMPLE_TEXT_INPUT_PROTOCOL.size
    Call mov_data

    mov rbx, EFI_SYSTEM_TABLE.BootServices
    mov rdx, [rbx]
    mov rbx, EFI_BOOT_SERVICES
    mov rcx, EFI_BOOT_SERVICES.size
    Call mov_data

    mov rbx, EFI_SYSTEM_TABLE.RuntimeServices
    mov rdx, [rbx]
    mov rbx, EFI_RUNTIME_SERVICES
    mov rcx, EFI_RUNTIME_SERVICES.size
    Call mov_data

    ret


section .data

read_character: dw 0, 0, 0

FirmwareVendor: db "System Firmware Vendor: ",0

FirmwareRevision: db "System Firmware Revision: ", 0

SystemTableRevision: db "System Table Revision: ", 0

BootServicesRevision: db "Boot Services Table Revision: ", 0



section .bss

imageHandle: resq 1
