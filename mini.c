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

// Skip the dispatch; this isn't in the headers.
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
    printf("\nOKAY\n");
    return 0;
  } else {
    printf("\nFAIL\n");
    return -1;
  }
}


#define N (1 << 18)
#define cpc(COUNTER) (((double)(COUNTER)) / (double)(N))
#define pcp(COUNTER) printf("%10s=%5.1f\n", #COUNTER, cpc(COUNTER))

#define cycles __builtin_readcyclecounter

#define REP(COUNTER, STMT)             \
  do {                                 \
    uint64_t COUNTER = cycles();       \
    for (uint64_t i = 0; i < N; i++) { \
      STMT;                            \
    }                                  \
    COUNTER = cycles() - COUNTER;      \
    pcp(COUNTER);                      \
  } while (0)

int time_expansion(void) {
  uint32_t ks_ossl[60] = {0};
  uint32_t ks_this[60] = {0};
  AesKey aeskey;

  printf("\nBenchmark:\n");
  REP(ossl, AES_set_encrypt_key((void*)test_k, 256, &aeskey));
  REP(local, Rijndael_k32b16_expandkey(ks_this, test_k));

  printf("\nDependency-chained:\n");
  REP(ossl, AES_set_encrypt_key(&aeskey, 256, &aeskey));
  REP(ossl, AES_set_encrypt_key(&aeskey, 256, &aeskey));
  REP(local, Rijndael_k32b16_expandkey(&aeskey, &aeskey));
  REP(local, Rijndael_k32b16_expandkey(&aeskey, &aeskey));
  REP(ossl, AES_set_encrypt_key(&aeskey, 256, &aeskey)); 
  REP(local, Rijndael_k32b16_expandkey(&aeskey, &aeskey));

  return 0;
}

int main(void) {
  test_expansion();
  time_expansion();
  return 0;
}
