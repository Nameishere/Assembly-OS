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


EFI_TABLE_HEADER:
    .Signature: equ 0
    .Revision: equ  .Signature + uint64   
    .HeaderSize: equ .Revision + uint32 
    .CRC32: equ .HeaderSize + uint32
    .Reserved: equ .CRC32 + uint32
    .size: equ .Reserved + uint32

EFI_SYSTEM_TABLE: 
    .EFI_TABLE_HEADER: equ 0 
    .FirmwareVendor: equ .EFI_TABLE_HEADER + EFI_TABLE_HEADER.size 
    .FirmwareRevision: equ .FirmwareVendor + pointer 
    .ConsoleInHandle: equ .FirmwareRevision + pointer  
    .ConIn: equ .ConsoleInHandle + pointer 
    .ConsoleOutHandle: equ .ConIn + pointer    
    .ConOut: equ .ConsoleOutHandle + pointer 
    .StandardErrorHandle: equ .ConOut + pointer 
    .StdErr: equ .StandardErrorHandle + pointer 
    .RuntimeServices: equ .StdErr + pointer 
    .BootServices: equ .RuntimeServices + pointer 
    .NumberOfTableEntries: equ .BootServices + pointer 
    .ConfigurationTable: equ .NumberOfTableEntries + pointer  
    .size: equ .ConfigurationTable + pointer 


EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL:
    .Reset: equ 0;
    .OutputString: equ .Reset + pointer ;
    .TestString: equ .OutputString + pointer ;
    .QueryMode: equ .TestString + pointer ;
    .SetMode: equ .QueryMode + pointer ;
    .SetAttribute: equ .SetMode + pointer ;
    .ClearScreen: equ .SetAttribute + pointer ;
    .SetCursorPosition: equ .ClearScreen + pointer ;
    .EnableCursor: equ .SetCursorPosition + pointer ;
    .Mode: equ .EnableCursor + pointer
    .Size: equ .Mode + pointer 


EFI_SIMPLE_TEXT_INPUT_PROTOCOL:
    .Reset: equ 0
    .ReadKeyStroke: equ .Reset + pointer  
    .WaitForKey: equ .ReadKeyStroke + pointer
    .size: equ .WaitForKey + pointer

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

    ;Set System Table pointer 
    mov rbx, System_table
    mov [rbx], rdx 

    ;Get ConOut pointer 
    add rdx, EFI_SYSTEM_TABLE.ConOut
    mov rax, [rdx]

    ;Get Set Clear Screen pointer
    add rax, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.ClearScreen
    mov rbx, [rax]

    ;Call Clear Screen 
    mov rcx, [rdx] 
    call rbx 

    ;Get System Table pointer 
    mov rbx, System_table
    mov rdx, [rbx] 

    ;Get ConOut pointer 
    add rdx, EFI_SYSTEM_TABLE.ConOut
    mov rax, [rdx]

    ;Get Set Output String pointer
    add rax, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.OutputString
    mov rbx, [rax]

    ;Call Output String 
    mov rcx, [rdx] 
    mov rdx, .Text1
    call rbx 

    

    ;Get System Table pointer 
    mov rbx, System_table
    mov rdx, [rbx] 

    ;Get ConIn pointer 
    add rdx, EFI_SYSTEM_TABLE.ConIn
    mov rax, [rdx]

    ;Get Read Key Stroke pointer
    add rax, EFI_SIMPLE_TEXT_INPUT_PROTOCOL.Reset
    mov rbx, [rax]

    ;Call Read Key Stroke 
    mov rcx, [rdx] 
    mov rdx, 0
    mov rax, 0
    call rbx 

    .GetInput:

    ;Get System Table pointer 
    mov rbx, System_table
    mov rdx, [rbx] 

    ;Get ConIn pointer 
    add rdx, EFI_SYSTEM_TABLE.ConIn
    mov rax, [rdx]

    ;Get Read Key Stroke pointer
    add rax, EFI_SIMPLE_TEXT_INPUT_PROTOCOL.ReadKeyStroke 
    mov rbx, [rax]

    ;Call Read Key Stroke 
    mov rcx, [rdx] 
    mov rdx, 0x01
    mov rax, 0
    call rbx 


    cmp rax, EFI_SUCCESS
    ; inc r14
    jne .GetInput

    ;Get System Table pointer 
    mov rbx, System_table
    mov rdx, [rbx] 

    ;Get ConOut pointer 
    add rdx, EFI_SYSTEM_TABLE.ConOut
    mov rax, [rdx]

    ;Get Set Output String pointer
    add rax, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.OutputString
    mov rbx, [rax]

    ;Call Output String 
    mov rcx, [rdx] 
    mov r14, read_character
    add r14, 2
    mov rdx, r14
    call rbx 

    jmp .GetInput


    .Text1: dw H,E,L,L,O,0x0020,W,O,R,L,D,0



exception:
    mov rcx, 0
    div rcx


section .data

read_character: dw 0, 0, 0




section .bss
    

System_table resq 1 


A equ 0x0041
B equ 0x0042
C equ 0x0043
D equ 0x0044
E equ 0x0045
F equ 0x0046
G equ 0x0047
H equ 0x0048
I equ 0x0049
J equ 0x004A
K equ 0x004B
L equ 0x004C
M equ 0x004D
N equ 0x004E
O equ 0x004F
P equ 0x0050
Q equ 0x0051
R equ 0x0052
S equ 0x0053
T equ 0x0054
U equ 0x0055
V equ 0x0056
W equ 0x0057
X equ 0x0058
Y equ 0x0059
Z equ 0x005A