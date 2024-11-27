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

uint64 equ 8
pointer equ 8
uint32 equ 4


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

    ;Call Clear Screen 
    mov rcx, [rdx] 
    mov rdx, .Text1
    call rbx 
    
    
    .begin:
    jmp .begin

    .Text1: dw H,E,L,L,O,0x0020,W,O,R,L,D,0



section .data





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