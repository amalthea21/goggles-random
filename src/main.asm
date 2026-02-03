%include "constants.inc"

section .bss
    random resq 1       ; reserve 8 bytes for random number

section .text
    global _start
    extern get_systime  ; declare external function
    extern parse_range  ; ^
    extern get_random   ; ^
    extern saved_rsp    ; declare external variable


_start:
    ; save original stack pointer for get_args
    mov [saved_rsp], rsp

    ; get min and max from command line arguments
    call parse_range
    ; rdi = min, rsi = max
    mov r12, rdi            ; save min
    mov r13, rsi            ; save max

    ; get system time
    call get_systime
    ; rax = systime in nanoseconds

    ; generate random number in range [min, max]
    mov rdi, r12            ; min
    mov rsi, r13            ; max
    mov rdx, rax            ; systime
    call get_random
    ; rax = random number

    mov [random], rax       ; store random number

    ; exit with random number (modulo 256 for exit code)
    mov rax, SYS_EXIT
    mov rdi, [random]
    and rdi, 0xFF           ; ensure exit code is 0-255
    syscall