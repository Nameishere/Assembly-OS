[bits 64]

%include "src/boottypes.asm"
%include "src/Functions.asm"
%include "src/DisplayPage.asm"
%include "src/MenuPage.asm"

section .text
global _start

_start:

    
    mov rbx, imageHandle
    mov [rbx], rcx

    call Table_setup

    mov rax, 0x02
    call SetTextColor

    sub rsp, 32
    mov rcx, EVT_TIMER | EVT_NOTIFY_SIGNAL
    mov rdx, TPL_CALLBACK
    mov r8, DisplayTime
    mov r9, 0
    mov rax, EFI_EVENT
    mov [rsp + 0x20], rax
    mov rax, EFI_BOOT_SERVICES.CreateEvent
    mov rbx, [rax]
    call rbx 
    add rsp, 32

    cmp rax, EFI_SUCCESS
    jne exception


    mov rax, EFI_EVENT
    mov rcx, [rax]

    mov rdx, TimerPeriodic
    mov r8, 10000000
    call SetTimer
    cmp rax, EFI_SUCCESS
    jne exception

    ; call exception

    call DisplayFirmwareInfo

    .GetInput:
    jmp .GetInput

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
    push rbx
    push rbp 
    push rdi 
    push rsi
    push r12
    push r13
    push r14
    push r15

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

    pop r15
    pop r14
    pop r13
    pop r12
    pop rsi
    pop rdi 
    pop rbp 
    pop rbx


    mov rcx, 0 
    mov rdx, 0
    mov r8, 0
    mov r9, 0
    mov r10, 0
    mov r11, 0 
    mov rax, 0
    
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

section .data

read_character: dw 0, 0, 0
SelectedMode: dq 0
TimeEvent: dq 0

section .bss

imageHandle: resq 1


