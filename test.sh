yasm rijn_mini.s -f macho64 && clang -std=c11 -Wextra mini.c rijn_mini.o libcrypto.a -o mini.out && sleep 1 && ./mini.out
