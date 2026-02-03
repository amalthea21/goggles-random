%include "constants.inc"

section .text
    global get_systime  ; make function available to other files

get_systime:
    ; get system time in nanoseconds since epoch
    mov rax, SYS_CLOCK_GETTIME
    mov rdi, CLOCK_REALTIME
    mov rsi, time_buffer            ; pointer to timespec buffer
    syscall

    ; calculate: seconds * 1,000,000,000 + nanoseconds
    mov rax, [time_buffer]          ; load seconds
    mov rdx, NANOSECONDS_PER_SECOND ; 1 billion
    mul rdx                         ; rax = seconds * 1,000,000,000
    add rax, [time_buffer + 8]      ; add nanoseconds
    ret

section .bss
    time_buffer resq 2  ; reserve 16 bytes for timespec (seconds + nanoseconds)