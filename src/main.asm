section .bss
    random resq 1   ; reserve 8 bytes for random

section .text
    global _start

_start:
    call get_systime    ; call get_systime
    mov [random], rax   ; store result in random



    ; exit with random
    mov rax, 60         ; sys_exit
    xor rdi, [random]   ; exit with random number
    syscall

get_systime:
    ; get systime in nanoseconds since epoch
    mov rax, 228            ; sys_clock_gettime (system call number)
    mov rdi, 0              ; CLOCK_REALTIME
    mov rsi, time_buffer    ; buffer to store time
    syscall

    ; calculate: seconds * 1.000.000.000 + nanoseconds
    mov rax, [time_buffer]      ; seconds
    mov rdx, 1000000000         ; 1 billion (nanoseconds per second)
    mul rdx                     ; rax = seconds * 1.000.000.000
    add rax, [time_buffer + 8]  ; add nanoseconds
    ret

section .bss
    time_buffer resq 2  ; buffer for time structure (seconds and nanoseconds)