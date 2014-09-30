.data

__shufmask:
  .byte 0xff, 0xff, 0xff, 0xff  
  .byte 0x0, 0x1, 0x2, 0x3     
  .byte 0x4, 0x5, 0x6, 0x7
  .byte 0x8, 0x9, 0xa, 0xb
  .byte 0xff, 0xff, 0xff, 0xff  
  .byte 0x0, 0x1, 0x2, 0x3     
  .byte 0x4, 0x5, 0x6, 0x7
  .byte 0x8, 0x9, 0xa, 0xb

.text

.macro START
  rdtsc          
  shlq $0x20, %rdx  
  addq %rdx, %rax 
  mov %rax, %r14
.endmacro

.macro END
  rdtsc          
  shlq $0x20, %rdx  
  addq %rdx, %rax 
  subq %r14, %rax
.endmacro


.globl _k8b4_akg
_k8b4_akg:
  vzeroupper
  START
//  vmovdqu (%rdi), %%xmm0
  movq $0x100000, %rcx
  .align 4
  Lstart:
    aeskeygenassist $0x01, %xmm0, %xmm0
    aeskeygenassist $0, %xmm0, %xmm0
    aeskeygenassist $0x02, %xmm0, %xmm0
    aeskeygenassist $0, %xmm0, %xmm0
    aeskeygenassist $0x04, %xmm0, %xmm0
    aeskeygenassist $0, %xmm0, %xmm0
    aeskeygenassist $0x06, %xmm0, %xmm0
    aeskeygenassist $0, %xmm0, %xmm0
    aeskeygenassist $0x08, %xmm0, %xmm0
    aeskeygenassist $0, %xmm0, %xmm0
    aeskeygenassist $0x10, %xmm0, %xmm0
    aeskeygenassist $0, %xmm0, %xmm0
    aeskeygenassist $0x20, %xmm0, %xmm0
    aeskeygenassist $0, %xmm0, %xmm0
    aeskeygenassist $0x40, %xmm0, %xmm0
  dec %rcx
  jnz Lstart

//  vmovdqu (%%xmm0), (%rdi)
  END
  ret

.globl _k8b4_ael
_k8b4_ael:
  vzeroupper  
  START
  movq $0x100000, %rcx
  .align 4
  Lstart_ael:
    aeskeygenassist $0x01, %xmm0, %xmm0
    aeskeygenassist $0, %xmm0, %xmm0
    aeskeygenassist $0x02, %xmm0, %xmm0
    aeskeygenassist $0, %xmm0, %xmm0
    aeskeygenassist $0x04, %xmm0, %xmm0
    aeskeygenassist $0, %xmm0, %xmm0
    aeskeygenassist $0x06, %xmm0, %xmm0
    aeskeygenassist $0, %xmm0, %xmm0
    aeskeygenassist $0x08, %xmm0, %xmm0
    aeskeygenassist $0, %xmm0, %xmm0
    aeskeygenassist $0x10, %xmm0, %xmm0
    aeskeygenassist $0, %xmm0, %xmm0
    aeskeygenassist $0x20, %xmm0, %xmm0
    aeskeygenassist $0, %xmm0, %xmm0
    aeskeygenassist $0x40, %xmm0, %xmm0
  dec %rcx
  jnz Lstart_ael

  END
  ret


.globl _lmix1
_lmix1:
  vzeroupper
  START
  .align 4
  movq $0x100000, %rcx
  Lstart_lmix:
    vpxor %ymm0, %ymm5, %ymm6 #needed?
    vpshufd $0b00000101, %ymm6, %ymm1
    vpshufd $0b00000010, %ymm6, %ymm2
    vpshufd $0b00000000, %ymm3, %ymm3
    vpxor %ymm1, %ymm2, %ymm1
    vpxor %ymm0, %ymm3, %ymm0
    vpxor %ymm0, %ymm1, %ymm0
  dec %rcx
  jnz Lstart_lmix

  END
  ret


.globl _lmix2
_lmix2:
  vzeroupper
  START
  .align 4
  movq $0x100000, %rcx
  Lstart_lmix2:
    vpslldq $32, %ymm0, %ymm1
    vpxor   %ymm0, %ymm1, %ymm0
    vpslldq $32, %ymm0, %ymm1
    vpxor   %ymm0, %ymm1, %ymm0
    vpslldq $32, %ymm0, %ymm1
    vpxor   %ymm0, %ymm1, %ymm0
  dec %rcx
  jnz Lstart_lmix2

  END
  ret

.globl _lmix3
_lmix3:
  vzeroupper
  vmovdqu __shufmask(%rip), %ymm0
  START
  .align 4
  movq $0x100000, %rcx
  Lstart_lmix3:
    vpshufb %ymm0, %ymm1, %ymm2
    vpxor   %ymm1, %ymm2, %ymm1
    vpshufb %ymm0, %ymm1, %ymm2
    vpxor   %ymm1, %ymm2, %ymm1
    vpshufb %ymm0, %ymm1, %ymm2
    vpxor   %ymm1, %ymm2, %ymm1
  dec %rcx
  jnz Lstart_lmix3

  END
  ret
