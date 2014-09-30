[cpu intelnop]
[bits 64]

section .data
align 32


__shuf_k1:
  db 12, 13, 14, 15
  db 12, 13, 14, 15
  db 12, 13, 14, 15
  db 12, 13, 14, 15

__shuf_k1a:
  db 13, 14, 15, 12
  db 13, 14, 15, 12
  db 13, 14, 15, 12
  db 13, 14, 15, 12

__shuffle_mask:
  db 0xff, 0xff, 0xff, 0xff  
  db 0x0, 0x1, 0x2, 0x3     
  db 0x4, 0x5, 0x6, 0x7
  db 0x8, 0x9, 0xa, 0xb

%define shuffle_mask [rel __shuffle_mask]
%define ZERO xmm15

section .text
align 32

%macro l_k2 2
  vaeskeygenassist %1, %1, %2
  vpshufd xmm1, xmm1, 011111111b
%endmacro

%macro l_k1 1
  vaeskeygenassist %1, %1, 0x0
  vpshufd %1, %1, 010101010b
%endmacro

%macro lmix 3
  %define key %1 
  %define t1 %2  
  %define t2 %3  

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

%define key1 xmm5
%define key2 xmm6
%define rc xmm7

%define ks rdi

%macro k32_expand 1
  vaeskeygenassist xmm2, key2, %1
  vpshufd xmm2, xmm2,   11111111b
  lmix key1, xmm4, xmm2

  vmovdqu [ks+0 ], key1 
  
  ex1 xmm4, key1
  vpshufd xmm2, xmm4, 010101010b
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

;  vpxor ZERO, ZERO, ZERO
  loadk32

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
