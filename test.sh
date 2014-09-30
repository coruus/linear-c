yasm rijn_mini.s -f macho64 && clang -std=c11 -Wextra mini.c rijn_mini.o /Users/dlg/repos/googlesource.com/boringssl/build/crypto/libcrypto.a -o mini.out && ./mini.out
