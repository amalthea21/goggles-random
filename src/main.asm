%include "constants.inc"

section .bss
    random resq 1       ; reserve 8 bytes for random number

section .text
    global _start
    extern get_systime  ; declare external function

_start:
    call get_systime
    mov [random], rax   ; store nanoseconds since epoch in random

    ; exit with random
    mov rax, SYS_EXIT   ; sys_exit
    xor rdi, [random]   ; exit code = random number (modulo 256)
    syscall