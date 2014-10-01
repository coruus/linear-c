clang -E expand.s | llvm-mc > expanded.s && clang -DRijndael_k32b16_expandkey=Rijndael_k8w4_expandkey -std=c11 -Wextra mini.c expanded.s libcrypto.a -o mini.out && sleep 1 && ./mini.out
