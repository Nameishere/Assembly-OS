[bits 64]

%include "src/boottypes.asm"

extern _start

_start:

    .begin:

    jmp .begin 
    .end:

