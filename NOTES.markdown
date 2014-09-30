
All numbers with Turbo Boost disabled.

k8b4 expansion:

  150 AESENCLAST-depth(15)
  151 AESKEYGENASSIST-depth(15)

5-6 cycles per lmix

4 parallel SubBytes:
  37.75 cycles
  2 parallel lmixes = 3 cycles per lmix
  3 * 14? = 42 cycles

72.5 to 79.5 per k8b4 expansion

Linear phase:

  4 lmix

Linear phase:

       x0, x1, x2, x3
    TO
       x0, x0^x1, x0^x1^x2, x0^x1^x2^x3

    # in   = 0, x1, x2, x3
    vpshufd $0b00000101, \in, \t1
    # t1   = 0, 0, x1, x1
    vpshufd $0b00000010, \in, \t2
    # t2   = 0, 0, 0,  x2
    vpshufd $b000000000, \x0, \x0
    # x0   = x0, x0, x0, x0
    vpxor   \t1, \t2, \t1
    vpxor   \in, \x0, \in
    vpxor   \in, \x0, \t1


