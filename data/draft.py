from fixedpoint import FixedPoint as fp
import numpy as np

a = fp("0b1011", signed=True, m=4, n=0, str_base=2)
b = fp("0b1010", signed=True, m=4, n=0, str_base=2)
a1 = fp("0b11111011", signed=True, m=8, n=0, str_base=2)
b1 = fp("0b1111111111111010", signed=True, m=16, n=0, str_base=2)

print((a*b).m, (a*b).n)
print(a*b)
print(a1*b1)
