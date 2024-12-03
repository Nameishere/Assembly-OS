[bits 64]

%include "src/boottypes.asm"

section .text
global _start

EFI_BLACK equ  0x00
EFI_BLUE equ   0x01
EFI_GREEN equ  0x02
EFI_CYAN equ   0x03
EFI_RED equ    0x04
EFI_YELLOW equ 0x0E
EFI_WHITE equ  0x0F


uint64 equ 8
pointer equ 8
uint32 equ 4

EFI_SUCCESS equ 0
EFI_LOAD_ERROR equ 1 ; The image failed to load.
EFI_INVALID_PARAMETER equ 2 ; A parameter was incorrect.
EFI_UNSUPPORTED equ 3 ; The operation is not supported.
EFI_BAD_BUFFER_SIZE equ 4 ; The buffer was not the proper size for the request.
EFI_BUFFER_TOO_SMALL equ 5 ; The buffer is not large enough to hold the requested data. The required buffer size is returned in the appropriate parameter when this error occurs.
EFI_NOT_READY equ 6 ; There is no data pending upon return.
EFI_DEVICE_ERROR equ 7 ; The physical device reported an error while attempting the operation.
EFI_WRITE_PROTECTED equ 8 ; The device cannot be written to.
EFI_OUT_OF_RESOURCES equ 9 ; A resource has run out.
EFI_VOLUME_CORRUPTED equ 10 ;An inconstancy was detected on the file system causing the operating to fail.
EFI_VOLUME_FULL equ 11 ;There is no more space on the file system.
EFI_NO_MEDIA equ 12 ;The device does not contain any medium to perform the operation.
EFI_MEDIA_CHANGED equ 13 ;The medium in the device has changed since the last access.
EFI_NOT_FOUND equ 14 ;The item was not found.
EFI_ACCESS_DENIED equ 15 ;Access was denied.
EFI_NO_RESPONSE equ 16 ;The server was not found or did not respond to the request.
EFI_NO_MAPPING equ 17 ;A mapping to a device does not exist.
EFI_TIMEOUT equ 18 ;The timeout time expired.
EFI_NOT_STARTED equ 19 ;The protocol has not been started.
EFI_ALREADY_STARTED equ 20 ;The protocol has already been started.
EFI_ABORTED equ 21 ;The operation was aborted.
EFI_ICMP_ERROR equ 22 ;An ICMP error occurred during the network operation.
EFI_TFTP_ERROR equ 23 ;A TFTP error occurred during the network operation.
EFI_PROTOCOL_ERROR equ 24 ;A protocol error occurred during the network operation.
EFI_INCOMPATIBLE_VERSION equ 25 ;The function encountered an internal version that was incompatible with a version requested by the caller.
EFI_SECURITY_VIOLATION equ 26 ;The function was not performed due to a security violation.
EFI_CRC_ERROR equ 27 ;A CRC error was detected.
EFI_END_OF_MEDIA equ 28 ;Beginning or end of media was reached
EFI_END_OF_FILE equ 31 ;The end of the file was reached.
EFI_INVALID_LANGUAGE equ 32 ;The language specified was invalid.
EFI_COMPROMISED_DATA equ 33 ;The security status of the data is unknown or compromised and the data must be updated or replaced to restore a valid security status.
EFI_IP_ADDRESS_CONFLICT equ 34 ;There is an address conflict address allocation
EFI_HTTP_ERROR equ 35 ;A HTTP error occurred during the network operation.



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
    Call mov_table

    mov rbx, EFI_SYSTEM_TABLE.ConOut
    mov rdx, [rbx]
    mov rbx, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL
    mov rcx, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.size
    Call mov_table

    mov rbx, EFI_SYSTEM_TABLE.ConIn
    mov rdx, [rbx]
    mov rbx, EFI_SIMPLE_TEXT_INPUT_PROTOCOL
    mov rcx, EFI_SIMPLE_TEXT_INPUT_PROTOCOL.size
    Call mov_table

    mov rbx, EFI_SYSTEM_TABLE.BootServices
    mov rdx, [rbx]
    mov rbx, EFI_BOOT_SERVICES
    mov rcx, EFI_BOOT_SERVICES.size
    Call mov_table

    mov rbx, EFI_SYSTEM_TABLE.RuntimeServices
    mov rdx, [rbx]
    mov rbx, EFI_RUNTIME_SERVICES
    mov rcx, EFI_RUNTIME_SERVICES.size
    Call mov_table

    ret




mov_table:
    ;rdx is source
    ;rbx is the destination  
    ;rcx is the source
    push rdx 
    mov rax, 0
    .loop1_start:
    cmp rax, rcx
    jg .loop1_end

    mov r10b, [rdx]
    mov [rbx], r10b 
    
    inc rax 
    inc rdx
    inc rbx 
    jmp .loop1_start
    .loop1_end:

    pop rdx 
    ret 

print_unicode:
    ;rax is pointer to string 

    call test_string

    mov rdx, rax
    mov rax, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.OutputString
    mov rbx, [rax]
    mov rax, EFI_SYSTEM_TABLE.ConOut
    mov rcx, [rax] 
    call rbx 
    ret 


test_string:
    ;rax is pointer to string 
    push rax

    mov rdx, rax
    mov rax, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.TestString
    mov rbx, [rax]
    mov rax, EFI_SYSTEM_TABLE.ConOut
    mov rcx, [rax] 
    call rbx 


    pop rax 
    ret



print_String: 
    ;This function prints a asci string as a unicode string (format of firmwae input)
    ;rax is input string  
    push rax
    push rbx
    push rcx
    push rdx

    mov r10, 1 ;loop Count initiliased 
    .loop1_start:
        mov bl, [rax]
        cmp bl, 0
        je .loop1_end

        inc rax 
        inc r10
        jmp .loop1_start
    .loop1_end:

    mov r12, r10 
    mov rbx, 0 
    .loop2_start:
        cmp r10, 0
        je .loop2_end

        dec rsp 
        mov bl, 0 
        mov [rsp], bl

        dec rsp 
        mov bl, [rax]
        mov [rsp], bl

        dec r10 
        dec rax 
        jmp .loop2_start
    .loop2_end:

    ;Print 
    mov rax, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.OutputString
    mov rbx, [rax]
    mov rax, EFI_SYSTEM_TABLE.ConOut
    mov rcx, [rax] 
    mov rdx, rsp
    call rbx 

    mov rax, 2
    mul r12
    mov r12, rax 
    add rsp, r12


    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret


print_Number: 
    ;This function prints a asci string as a unicode string (format of firmwae input)
    ;rax is input number
    ;rcx is optional digits input ie if 0 doesn't use 


    ; call exception ;FEA6808
    push rbx 
    push r12

    dec rsp
    dec rsp 

    mov rdx, 0 
    mov [rsp], dx

    ; mov rcx, 10
    mov r12, 0 ;loop Count initiliased 
    .loop2_start:
        cmp rcx, 0 
        je .if1_end
        
        cmp rcx, r12
        jl .if2_end

        jmp .if3_end
        .if1_end:

        cmp rax, 0
        jne .if3_end
        
        
        cmp r12, 0 
        jne .if2_end
        ; call exception

        inc r12
        dec rsp
        dec rsp 

        mov rdx, 0x0030 
        mov [rsp], dx

        ; call print_dot
        .if2_end:

        jmp .loop2_end
        .if3_end:


        dec rsp 
        mov bl, 0 
        mov [rsp], bl

        

        ; call print_test

        push rcx 
        mov rdx, 0 
        mov rcx, 10
        div rcx
        pop rcx 

        dec rsp 
        add rdx, 0x30
        mov bl, dl
        mov [rsp], bl




        inc r12 
        jmp .loop2_start
    .loop2_end:

    ;Print 
    mov rax, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.OutputString
    mov rbx, [rax]
    mov rax, EFI_SYSTEM_TABLE.ConOut
    mov rcx, [rax] 
    mov rdx, rsp
    call rbx 

    mov rax, 2
    mul r12
    mov r12, rax 
    add rsp, r12
    add rsp, 2

    pop r12
    pop rbx 
    ; call exception
    ret ;FEA686E ;FEA6800 ;FEA67F8


print_dot:
    push rax 
    push rbx 
    push rcx 
    push rdx 
    push r10 
    push r8
    push r9
    push r11
    mov rax, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.OutputString
    mov rbx, [rax]
    mov rax, EFI_SYSTEM_TABLE.ConOut
    mov rcx, [rax] 
    mov rdx, .dot
    call rbx 

    pop r11
    pop r9
    pop r8
    pop r10 
    pop rdx 
    pop rcx 
    pop rbx 
    pop rax 
    ret 
    .dot: dw ".",0

Change_Mode: 
    ;rax is the mode to change to 

    mov rdx, rax 
    push rdx 
    mov rax, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.QueryMode
    mov rbx, [rax]
    mov rax, EFI_SYSTEM_TABLE.ConOut
    mov rcx, [rax]
    call rbx 
    pop rdx

    ; call exception
    cmp rax, EFI_SUCCESS
    jne .if1

    mov rdx ,rax 

    mov rax, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.SetMode
    mov rbx, [rax]
    mov rax, EFI_SYSTEM_TABLE.ConOut
    mov rcx, [rax]
    call rbx 

    jmp .if1_end
    .if1:
    call next_line


    mov rax, .Message
    call print_String

    call next_line

    .if1_end:


    ret 



    .Message: db "Mode Does not Exist", 0



next_line:
    mov rcx, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.Mode
    mov rdx, [rcx]
    add rdx, 16
    mov r8d, [rdx]
    add r8, 1
    ; call exception
    mov rax, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.SetCursorPosition
    mov rbx, [rax]
    mov rax, EFI_SYSTEM_TABLE.ConOut
    mov rcx, [rax]
    mov rdx, 0
    call rbx 
    ret 

section .data

read_character: dw 0, 0, 0

FirmwareVendor: db "System Firmware Vendor: ",0

FirmwareRevision: db "System Firmware Revision: ", 0

SystemTableRevision: db "System Table Revision: ", 0

BootServicesRevision: db "Boot Services Table Revision: ", 0



section .bss

imageHandle: resq 1

EFI_RESET_TYPE:
    .EfiResetCold: equ 0
    .EfiResetWarm: equ 1
    .EfiResetShutdown: equ 2
    .EfiResetPlatformSpecific: equ 3


EFI_SYSTEM_TABLE:
    ;EFI Table Header 
    .Signature: resb uint64
    .Revision: resb uint32
    .HeaderSize: resb uint32 
    .CRC32: resb uint32
    .Reserved: resb uint32
    ;End of EFI Table Header
    .FirmwareVendor: resb 8 
    .FirmwareRevision: resb 8  
    .ConsoleInHandle: resb 8   
    .ConIn: resb 8  
    .ConsoleOutHandle: resb 8     
    .ConOut: resb 8  
    .StandardErrorHandle: resb 8  
    .StdErr: resb 8  
    .RuntimeServices: resb 8  
    .BootServices: resb 8  
    .NumberOfTableEntries: resb 8  
    .ConfigurationTable: resb 8   
    .size: equ $ - EFI_SYSTEM_TABLE

EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL:
    .Reset: resb pointer
    .OutputString: resb pointer ;
    .TestString: resb pointer ;
    .QueryMode: resb pointer ;
    .SetMode: resb pointer ;
    .SetAttribute: resb pointer ;
    .ClearScreen: resb pointer ;
    .SetCursorPosition: resb pointer ;
    .EnableCursor: resb pointer ;
    .Mode: resb pointer
    .size: equ $ - EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL 


EFI_SIMPLE_TEXT_INPUT_PROTOCOL:
    .Reset: resb pointer 
    .ReadKeyStroke: resb pointer   
    .WaitForKey: resb pointer 
    .size: equ $ - EFI_SIMPLE_TEXT_INPUT_PROTOCOL


EFI_BOOT_SERVICES:
    ;EFI Table Header 
    .Signature: resb uint64
    .Revision: resb uint32
    .HeaderSize: resb uint32 
    .CRC32: resb uint32
    .Reserved: resb uint32
    ;End of EFI Table Header
    ;
    ; Task Priority Services
    ;
    .RaiseTPL: resq 1; EFI 1.0+
    .RestoreTPL: resq 1; EFI 1.0+
    ;
    ; Memory Services
    ;
    .AllocatePages: resq 1; EFI 1.0+
    .FreePages: resq 1; EFI 1.0+
    .GetMemoryMap: resq 1; EFI 1.0+
    .AllocatePool: resq 1; EFI 1.0+
    .FreePool: resq 1; EFI 1.0+
    ;
    ; Event & Timer Services
    ;
    .CreateEvent: resq 1; EFI 1.0+
    .SetTimer: resq 1; EFI 1.0+
    .WaitForEvent: resq 1; EFI 1.0+
    .SignalEvent: resq 1; EFI 1.0+
    .CloseEvent: resq 1; EFI 1.0+
    .CheckEvent: resq 1; EFI 1.0+
    ;
    ; Protocol Handler Services
    ;
    .InstallProtocolInterface: resq 1; EFI 1.0+
    .ReinstallProtocolInterface: resq 1; EFI 1.0+
    .UninstallProtocolInterface: resq 1; EFI 1.0+
    .HandleProtocol: resq 1; EFI 1.0+
    .Reserved2: resq 1; EFI 1.0+
    .RegisterProtocolNotify: resq 1; EFI 1.0+
    .LocateHandle: resq 1; EFI 1.0+
    .LocateDevicePath: resq 1; EFI 1.0+
    .InstallConfigurationTable: resq 1; EFI 1.0+
    ;
    ; Image Services
    ;
    .LoadImage: resq 1; EFI 1.0+
    .StartImage: resq 1; EFI 1.0+
    .Exit: resq 1; EFI 1.0+
    .UnloadImage: resq 1; EFI 1.0+
    .ExitBootServices: resq 1; EFI 1.0+
    ;
    ; Miscellaneous Services
    ;
    .GetNextMonotonicCount: resq 1; EFI 1.0+
    .Stall: resq 1; EFI 1.0+
    .SetWatchdogTimer: resq 1; EFI 1.0+
    ;
    ; DriverSupport Services
    ;
    .ConnectController: resq 1; EFI 1.1
    .DisconnectController: resq 1; EFI 1.1+
    ;
    ; Open and Close Protocol Services
    ;
    .OpenProtocol: resq 1; EFI 1.1+
    .CloseProtocol: resq 1; EFI 1.1+
    .OpenProtocolInformation: resq 1; EFI 1.1+
    ;
    ; Library Services
    ;
    .ProtocolsPerHandle: resq 1; EFI 1.1+
    .LocateHandleBuffer: resq 1; EFI 1.1+
    .LocateProtocol: resq 1; EFI 1.1+
    .InstallMultipleProtocolInterfaces: resq 1; ;EFI 1.1+
    .UninstallMultipleProtocolInterfaces: resq 1; EFI 1.1+*
    ;
    ; 32-bit CRC Services
    ;
    .CalculateCrc32: resq 1; ; EFI 1.1+
    ;
    ; Miscellaneous Services
    ;
    .CopyMem: resq 1; EFI 1.1+
    .SetMem: resq 1; EFI 1.1+
    .CreateEventEx: resq 1; UEFI 2.0+
    .size: equ $ - EFI_BOOT_SERVICES


EFI_RUNTIME_SERVICES:
    .Signature: resb uint64
    .Revision: resb uint32
    .HeaderSize: resb uint32 
    .CRC32: resb uint32
    .Reserved: resb uint32
    ;
    ; Time Services
    ;
    .GetTime: resq 1
    .SetTime: resq 1
    .GetWakeupTime: resq 1
    .SetWakeupTime: resq 1
    ;
    ; Virtual Memory Services
    ;
    .SetVirtualAddressMap: resq 1
    .ConvertPointer: resq 1
    ;
    ; Variable Services
    ;
    .GetVariable: resq 1
    .GetNextVariableName: resq 1
    .SetVariable: resq 1
    ;
    ; Miscellaneous Services
    ;
    .GetNextHighMonotonicCount: resq 1
    .ResetSystem: resq 1
    ;
    ; UEFI 2.0 Capsule Services
    ;
    .UpdateCapsule: resq 1
    .QueryCapsuleCapabilities: resq 1
    ;
    ; Miscellaneous UEFI 2.0 Service
    ;
    .QueryVariableInfo: resq 1
    .size: equ $ - EFI_RUNTIME_SERVICES