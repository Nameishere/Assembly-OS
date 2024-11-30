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

    call Table_setup
    ;Clear Screen
    mov rax, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.ClearScreen
    mov rbx, [rax]
    mov rax, EFI_SYSTEM_TABLE.ConOut
    mov rcx, [rax] 
    call rbx 

    ;Print Hello World
    mov rax, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.OutputString
    mov rbx, [rax]
    mov rax, EFI_SYSTEM_TABLE.ConOut
    mov rcx, [rax] 
    mov rdx, .Text1
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


    ;Print Hello World
    mov rax, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.OutputString
    mov rbx, [rax]
    mov rax, EFI_SYSTEM_TABLE.ConOut
    mov rcx, [rax] 
    mov rdx, read_character
    add rdx, 2
    call rbx 

    jmp .GetInput


    .end:
    jmp .end
    
    .Text1: dw H,E,L,L,O,0x0020,W,O,R,L,D,0



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


section .data

read_character: dw 0, 0, 0



section .bss



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