%include "constants.inc"

section .text
    global get_random
    global init_random_engine
    extern current_seed
    extern mix_seed

init_random_engine:
    ; initialize the random engine with entropy
    push rbp
    mov rbp, rsp

    ; call init_seed from seed.asm
    extern init_seed
    call init_seed

    ; additional entropy mixing
    rdtsc                    ; read timestamp counter (cpu cycle counter)
    shl rdx, 32
    or rax, rdx
    mov rdi, rax
    extern update_seed
    call update_seed

    ; mix with memory address
    lea rdi, [rel init_random_engine]
    call mix_seed

    pop rbp
    ret

xorshift64star:
    ; xorshift64* random number generator
    ; input: rax = current seed
    ; output: rax = new random number, seed updated

    mov rax, [current_seed]

    ; xor-shift algorithm
    mov rdx, rax
    shl rdx, 12
    xor rax, rdx

    mov rdx, rax
    shr rdx, 25
    xor rax, rdx

    mov rdx, rax
    shl rdx, 27
    xor rax, rdx

    ; store new seed
    mov [current_seed], rax

    ; apply multiplication for better distribution
    ; use the full 64 bit constant
    mov rdx, 0x2545F4914F6CDD1D
    mul rdx

    ret

pcg_random:
    ; pcg random number generator
    ; input: rax = current state
    ; output: rax = random number

    mov rax, [current_seed]

    ; update state: state = state * 6364136223846793005 + 1442695040888963407
    ; use two 32 bit loads for the 64 bit constant
    mov rdx, 6364136223846793005 & 0xFFFFFFFF
    or rdx, (6364136223846793005 >> 32) << 32
    mul rdx
    ; Add the constant 1442695040888963407
    mov rdx, 1442695040888963407 & 0xFFFFFFFF
    or rdx, (1442695040888963407 >> 32) << 32
    add rax, rdx
    mov [current_seed], rax

    ; generate output: xorshift and rotation
    mov rdx, rax
    shr rdx, 18
    xor rax, rdx
    shr rax, 27
    mov rcx, rax
    and rcx, 31
    ror rax, cl

    ret

get_random:
    ; generate random number in range [min, max] using rejection sampling
    ; input: rdi = min, rsi = max
    ; output: rax = random number in [min, max]

    push rbx
    push r12
    push r13
    push r14
    push r15

    mov r12, rdi            ; r12 = min
    mov r13, rsi            ; r13 = max

    ; calculate range size: (max - min + 1)
    mov rax, r13
    sub rax, r12
    inc rax                 ; rax = range_size
    mov r14, rax            ; r14 = range_size

    ; calculate rejection threshold to eliminate modulo bias
    ; threshold = (2^64 / range_size) * range_size
    ; this is the largest multiple of range_size that fits in 64 bits

    ; first calculate 2^64 / range_size (using 2^64 - 1 as approximation)
    mov rax, -1             ; rax = 0xFFFFFFFFFFFFFFFF (2^64 - 1)
    xor rdx, rdx            ; clear rdx for division
    div r14                 ; rax = floor((2^64 - 1) / range_size), rdx = remainder

    ; multiply back to get the threshold
    mul r14                 ; rax = (floor((2^64 - 1) / range_size)) * range_size
    mov r15, rax            ; r15 = rejection threshold

.retry:
    ; generate random number using xorshift64*
    call xorshift64star     ; rax = random 64-bit number

    ; rejection sampling: if random >= threshold, retry
    cmp rax, r15
    jae .retry              ; if rax >= threshold, get new random number

    ; now we have unbiased random number, take modulo
    xor rdx, rdx            ; clear rdx for division
    div r14                 ; rdx = rax % range_size (unbiased)

    ; add min to get final value in [min, max]
    mov rax, rdx
    add rax, r12

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

get_random_with_mix:
    ; alternative: get random number with additional entropy mixing
    ; input: rdi = min, rsi = max, rdx = additional entropy
    ; output: rax = random number

    push rbx

    ; mix in additional entropy
    mov rax, rdx
    mov rbx, rdx
    call mix_seed

    ; get random number
    mov rdi, rbx
    mov rsi, rdx
    call get_random

    pop rbx
    ret