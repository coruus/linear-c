#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include "print-impl.h"

#define printv(v) \
  printf( #v": %08x %08x %08x %08x\n", v[0], v[1], v[2], v[3]);

static const uint32_t test_k[4] = { 0x11223344, 0x10203040, 
                                    0x0a0b0c0d, 0xe0f01020};


typedef struct aes_key_st {
    uint32_t rd_key[4 *(14 + 1)];
    int rounds;
} AesKey;

extern void Rijndael_k32b16_expandkey(void*, const void*);
extern void exk1_lmix(void*);
extern void exk1(void*);
extern void exk2(void*);
extern void exiso1(void*);
extern void exiso2(void*);
#define AES_set_encrypt_key aesni_set_encrypt_key
extern void AES_set_encrypt_key(const void*, int, AesKey*);

int test_expansion(void) {
  uint32_t ks_ossl[60] = {0};
  uint32_t ks_this[60] = {0};
  AesKey aeskey;
  AES_set_encrypt_key((void*)test_k, 256, &aeskey);
  Rijndael_k32b16_expandkey(ks_this, test_k);

#ifdef APPLE_LIBCRYPTO_MADNESS
  for (int i = 0; i < 60; i++) {
    aeskey.rd_key[i] = __builtin_bswap32( aeskey.rd_key[i] );
  }
#endif

  printbuf(ks_this, 60*4);
  printbuf(aeskey.rd_key, 60*4);

  if (memcmp(ks_this, aeskey.rd_key, 60*4) == 0) {
    printf("\nOKAY\n\n");
  return 0;
  } else {
    printbuf(ks_this, 60*4);
    printbuf(aeskey.rd_key, 60*4);
    printf("\nFAIL\n\n");
    return -1;
  }
}

typedef uint64_t T;
#define N (1 << 18)
#define cpc(COUNTER) (((double)(COUNTER)) / (double)(N))
#define pcp(COUNTER) printf("%10s=%5.1f\n", #COUNTER, cpc(COUNTER))

#define cycles __builtin_readcyclecounter

#define REP(COUNTER, STMT) \
do {T COUNTER = cycles(); \
  for (uint64_t i = 0; i < N; i++) { \
    STMT; \
  } \
  COUNTER = cycles() - COUNTER; \
  pcp(COUNTER); } while(0)

int time_expansion(void) {
  uint32_t ks_ossl[60] = {0};
  uint32_t ks_this[60] = {0};
  AesKey aeskey;
  REP(ossl, AES_set_encrypt_key((void*)test_k, 256, &aeskey));
  REP(local, Rijndael_k32b16_expandkey(ks_this, test_k));
  printf("\n\n");
  REP(ossl, AES_set_encrypt_key(&aeskey, 256, &aeskey));
  REP(ossl, AES_set_encrypt_key(&aeskey, 256, &aeskey));
  REP(local, Rijndael_k32b16_expandkey(ks_this, ks_this+60-16));
  REP(local, Rijndael_k32b16_expandkey(ks_this, ks_this+60-16));
  
  return 0;
}



int main(void) {
  test_expansion();
  time_expansion();
  //return 0;
  uint8_t bb[16]; // = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16};
  for (int i = 0; i < 16; i++) {
    bb[i] = i * 17;
  }
  uint32_t a[4];// = {0x00, 0x01, 0x02, 0x03};
  uint32_t b[4];
  memcpy(a, bb, 4*4);
  memcpy(b, bb, 4*4);

  exiso2(a);
  printv(a);
  exk2(b);
  printv(b);
return 0;
  uint32_t c[4] = {0x00, 0x01, 0x02, 0x03};
  exk1_lmix(c);
  printv(c);

  uint8_t o[128] = {0};
  uint8_t k[32] = {0};
  for (uint8_t i = 0; i < 32; i++) {
    k[i] = i;
  }
  //aesinline(o, o, k);
  printbuf(o, 32);
  return 0;
}
