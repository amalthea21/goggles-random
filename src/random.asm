%include "constants.inc"

section .text
    global get_random   ; make function available to other files

get_random:
    ; generate random number in range [min, max]
    ; input: rdi = min, rsi = max, rdx = systime (nanoseconds)
    ; output: rax = random number in [min, max]

    ; save parameters
    mov r12, rdi            ; r12 = min
    mov r13, rsi            ; r13 = max
    mov r14, rdx            ; r14 = systime

    ; calculate range size: (max - min + 1)
    mov rax, r13
    sub rax, r12
    inc rax                 ; rax = range_size
    mov r15, rax            ; r15 = range_size

    ; use systime as seed for random
    mov rax, r14            ; systime

    ; simple LCG (Linear Congruential Generator)
    ; formula: (a * seed + c) mod m
    mov rcx, 1103515245     ; a (multiplier)
    mul rcx                 ; rax = systime * a
    add rax, 12345          ; rax = (systime * a) + c

    ; get modulo range_size
    xor rdx, rdx            ; clear rdx for division
    div r15                 ; rdx = rax % range_size

    ; add min to get final value in [min, max]
    mov rax, rdx
    add rax, r12

    ret