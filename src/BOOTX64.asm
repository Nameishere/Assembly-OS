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


_start:
    mov r9, [rdx]
    add rdx, 64 ;void_pointer_size*4 + EFI_TABLE_HEADER_size + uint32_size 
    mov rax, [rdx] 
    mov r12, rax
    add rax, 8*6
    mov rbx, [rax]
    ; mov r9, [r9]
    mov rcx, r12 
    call rbx 

    mov rax, r12 
    add rax, 8
    mov rbx, [rax]

    mov rdx, .Text1
    mov rcx, r12 
    call rbx 
    

    ; mov rax, 2
    ; mov rbx, .things2
    ; mov [rbx], rax
    .begin:
    jmp .begin

    .Text1: dw H,E,L,L,O,0x20,W,O,R,L,D,0




section .data
thing: dq 




section .bss

EFI_TABLE_HEADER:
    .Signature: resq 1;
    .Revision: resd 1;
    .HeaderSize: resd 1;
    .CRC32: resd 1;
    .Reserved: resd 1;
    

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