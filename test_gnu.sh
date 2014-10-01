clang -E expand.s | llvm-mc > expanded.s && 
  clang -DRijndael_k32b16_expandkey=Rijndael_k8w4_expandkey -std=c11 -Wextra mini.c expanded.s ossl_expansion.s -o mini.out && 
 sleep 0.5 && 
  ./mini.out && 
  ./mini.out | tail -6
