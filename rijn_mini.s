[cpu intelnop]
[bits 64]

section .data
align 32

__isorate:
db 4, 5, 6, 7
db 5, 6, 7, 4
db 12, 13, 14, 15
db 13, 14, 15, 12

__isorate1:
db 4, 5, 6, 7
db 5, 6, 7, 4
db 12, 13, 14, 15
db 13, 14, 15, 12


__shuf_k1:
db 12, 13, 14, 15
db 12, 13, 14, 15
db 12, 13, 14, 15
db 12, 13, 14, 15

__shuf_k2:
db 9, 6, 3, 12
db 9, 6, 3, 12
db 9, 6, 3, 12
db 9, 6, 3, 12

__xor:
db 0, 0, 0, 0
db 1, 0, 0, 0
db 0, 0, 0, 0
db 1, 0, 0, 0

__xor4:
db 1, 0, 0, 0
db 1, 0, 0, 0
db 1, 0, 0, 0
db 1, 0, 0, 0

__rcstart:
db 1, 0, 0, 0
db 1, 0, 0, 0
db 1, 0, 0, 0
db 1, 0, 0, 0


__shuffle_mask:
  db 0xff, 0xff, 0xff, 0xff  
  db 0x0, 0x1, 0x2, 0x3     
  db 0x4, 0x5, 0x6, 0x7
  db 0x8, 0x9, 0xa, 0xb
%define shuffle_mask [rel __shuffle_mask]
%define ZERO xmm15

section .text
align 32

global _exiso
_exiso:

  vmovdqu xmm1, [rdi]
  vpxor xmm0, xmm0, xmm0
  vaesenclast xmm1, xmm1, xmm0
  vpshufb xmm1, xmm1, [rel __isorate]
  vpxor xmm1, xmm1, [rel __xor]
  vmovdqu [rdi], xmm1
  ret

global _ex
_ex:

  vmovdqu xmm1, [rdi]
  vaeskeygenassist xmm1, xmm1, 0x1
  ;vpshufd xmm1, xmm1, 011111111b
  vmovdqu [rdi], xmm1

  ret

global _exk1
_exk1:

  vmovdqu xmm1, [rdi]
  vaeskeygenassist xmm1, xmm1, 0x0
  vpshufd xmm1, xmm1, 010101010b
  vmovdqu [rdi], xmm1

  ret

global _exiso1
_exiso1:

  vmovdqu xmm1, [rdi]
  vpxor xmm0, xmm0, xmm0
  vpshufb xmm1, xmm1, [rel __shuf_k1]
  vaesenclast xmm1, xmm1, xmm0
  vmovdqu [rdi], xmm1
  ret


global _exiso2
_exiso2:

%define rc [rel __xor4]
  vmovdqu xmm1, [rdi]
  vpxor xmm0, xmm0, xmm0
  %define ZERO xmm0
  vaesenclast xmm1, xmm1, ZERO
  vpshufb xmm1, xmm1, [rel __shuf_k2]
  vpxor xmm1, xmm1, rc
  vmovdqu [rdi], xmm1
  ret

global _exk2
_exk2:

  vmovdqu xmm1, [rdi]
  vaeskeygenassist xmm1, xmm1, 0x01
  vpshufd xmm1, xmm1, 011111111b
  vmovdqu [rdi], xmm1

  ret


%macro l_k2 2
  vaeskeygenassist %1, %1, %2
  vpshufd xmm1, xmm1, 011111111b
%endmacro

%macro l_k1 1
  vaeskeygenassist %1, %1, 0x0
  vpshufd %1, %1, 010101010b
%endmacro

%macro lmix 3
  %define key %1 ; key
  %define t1 %2  ; xmm4
  %define t2 %3  ; xmm2

  vpshufb t1, key, shuffle_mask
  vpxor   key, key, t1          
  vpshufb t1, t1, shuffle_mask  
  vpxor   key, key, t1          
  vpshufb t1, t1, shuffle_mask  
  vpxor   key, key, t1          
  vpxor   key, key, t2          
%endmacro


%macro ex1 2
  vpshufb %1, %2, [rel __shuf_k1]
  vaesenclast %1, %1, ZERO
%endmacro

%macro ex2 2
  vaesenclast %1, %2, ZERO
  vpshufb %1, %1, [rel __shuf_k2]
  vpxor %1, %1, rc
  vpslld rc, rc, 1
%endmacro

%define key1 xmm5
%define key2 xmm6

%define ks rdi
%define rc xmm12

%macro k32_expand 1
  ;vaeskeygenassist xmm2, key2, %1
  ;vpshufd xmm2, xmm2, 011111111b

  vaesenclast xmm2, key2, ZERO
  vpshufb xmm2, xmm2, [rel __shuf_k2]
  vpxor xmm2, xmm2, rc
  vpslld rc, rc, 1
  
  lmix key1, xmm4, xmm2

  vmovdqu [ks+0 ], key1 
  
;  vaeskeygenassist xmm4, key1, 0
  vpxor ZERO, ZERO, ZERO
  ex1 xmm2, key1
;  vmovdqu xmm2, xmm4
  lmix key2, xmm4, xmm2

  vmovdqu [ks+16], key2

  add ks, 32
%endmacro

%macro loadk32 0
  vmovdqu key1, [rsi+0 ]
  vmovdqu key2, [rsi+16]
%endmacro

align 32
global _Rijndael_k32b16_expandkey 
_Rijndael_k32b16_expandkey:
  vzeroupper

  loadk32

  ; Load the shuffle mask used by key_expansion
;  vmovdqa shuffle_mask, [_Rijndael_k32_shuffle_mask wrt rip]
  vmovdqu rc, [__xor4 wrt rip]
  vmovdqu [ks+0 ], key1
  vmovdqu [ks+16], key2
  add ks, 32

  k32_expand 0x01
  k32_expand 0x02
  k32_expand 0x04
  k32_expand 0x08
  k32_expand 0x10
  k32_expand 0x20

  vaeskeygenassist xmm2, key2, 0x40
  vpshufd xmm2, xmm2, 011111111b
  lmix key1, xmm4, xmm2

  vmovdqu [ks], key1

  vzeroall
  ret
