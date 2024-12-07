[bits 64]

%include "src/boottypes.asm"
%include "src/Functions.asm"

section .text
global _start

_start:

    mov rbx, imageHandle
    mov [rbx], rcx

    call Table_setup

    

    mov rax, 0x02
    call SetTextColor

    mov rax, 0
    call Change_Mode

    call DisplayFirmwareInfo

    mov rax, 1
    call EnableCursor

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
    mov r12, 0
    div r12

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


DisplayFirmwareInfo: 
    call Clear_Screen

    ;Display Page Title: 
    mov rax, .PageTitle
    call print_String
    call next_line
    call next_line

    ;Firmware Section Title
    mov rax, .FirmwareInfo
    call print_String
    call next_line

    ;Display Firmware Vendor
    mov rax, .FirmwareVendor
    call print_String
    mov rdx, EFI_SYSTEM_TABLE.FirmwareVendor
    mov rax, [rdx]
    call print_unicode 
    call next_line

    ;Display Firmware Revision
    mov rax, .FirmwareRevision
    call print_String
    mov rbx, EFI_SYSTEM_TABLE.FirmwareRevision
    call DisplayFirmwareRevision
    call next_line

    call next_line

    ;Table Section Title
    mov rax, .TableInfo
    call print_String
    call next_line

    ;Display System Table Revision
    mov rax, .SystemTableRevision
    call print_String
    mov rbx, EFI_SYSTEM_TABLE.Revision ;pointer to number 
    call DisplayRevision
    call next_line

    ;Display Boot Services Table Revision
    mov rax, .BootServicesRevision
    call print_String
    mov rbx, EFI_BOOT_SERVICES.Revision
    call DisplayRevision
    call next_line

    ;Display RunTime Services Table Revision
    mov rax, .RunTimeServicesRevision
    call print_String
    mov rbx, EFI_RUNTIME_SERVICES.Revision
    call DisplayRevision
    call next_line


    call DisplayTime

    call DisplayEsc

    ret

    .PageTitle: db "        General Info Page", 0
    .FirmwareInfo: db "Firmware Info:", 0
    .TableInfo: db "Table Revisions:", 0
    .FirmwareVendor: db "System Firmware Vendor: ",0
    .FirmwareRevision: db "System Firmware Revision: ", 0
    .SystemTableRevision: db "System Table Revision: ", 0
    .BootServicesRevision: db "Boot Services Table Revision: ", 0
    .RunTimeServicesRevision: db "RunTime Services Table Revision: ", 0


DisplayEsc:
    mov rax, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.Mode
    mov rbx, [rax]

    add rbx, 12
    mov rax, 0
    mov eax, [rbx]
    push rax
    add rbx, 4
    mov rax, 0
    mov eax, [rbx]
    push rax 

    mov rdx, SelectedMode
    mov rax, [rdx]
    call QueryMode

    mov r8, rdx
    dec r8

    mov rdx, 0
    call SetCursorPosition

    mov rax, .Message
    call print_String


    pop rax
    mov r8, rax
    pop rax
    mov rdx, rax
    call SetCursorPosition

    ret
    .Message: db "[Press Esc to Exit]", 0

DisplayTime:

    mov rax, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.Mode
    mov rbx, [rax]

    add rbx, 12
    mov rax, 0
    mov eax, [rbx]
    push rax
    add rbx, 4
    mov rax, 0
    mov eax, [rbx]
    push rax 

    mov rdx, SelectedMode
    mov rax, [rdx]
    call QueryMode
    
    
    mov r8, rdx
    dec r8

    mov rdx, rcx
    sub rdx, 20


    call SetCursorPosition

    call GetTime

    call Print_Time

    ;return to old position 
    pop rax
    mov r8, rax
    pop rax
    mov rdx, rax
    call SetCursorPosition
    
    ret

Print_Time:
    mov rax, 0
    mov rbx, EFI_TIME.Year
    mov ax, [rbx]
    mov rcx, 4
    call print_Number

    mov rax, .Slash
    call print_String

    mov rax, 0
    mov rbx, EFI_TIME.Month
    mov al, [rbx]
    mov rcx, 2
    call print_Number

    mov rax, .Slash
    call print_String

    mov rax, 0
    mov rbx, EFI_TIME.Day
    mov al, [rbx]
    mov rcx, 2
    call print_Number

    mov rax, .Colon
    call print_String

    mov rax, 0
    mov rbx, EFI_TIME.Hour
    mov al, [rbx]
    mov rcx, 2
    call print_Number

    mov rax, .Colon
    call print_String

    mov rax, 0
    mov rbx, EFI_TIME.Minute
    mov al, [rbx]
    mov rcx, 2
    call print_Number

    mov rax, .Colon
    call print_String
    
    mov rax, 0
    mov rbx, EFI_TIME.Second
    mov al, [rbx]
    mov rcx, 2
    call print_Number

    ret 
    .Colon: db ":",0
    .Slash: db "/",0

DisplayRevision:
    ;rbx is number input
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

    ret

DisplayFirmwareRevision:
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

    ret


section .data

read_character: dw 0, 0, 0
SelectedMode: dq 0

section .bss

imageHandle: resq 1


