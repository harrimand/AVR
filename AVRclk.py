
import pandas as pd
from os import system
from math import log10
clc = lambda: system("clear")

MCUclk = [1E6, 8E6, 16E6, 20E6]
CKsel = [0, 1, 8, 64, 256, 1024]

T1top = 2**16

# maxT = 1 / MCUclk[1] * CKsel[5]
maxT = [[1/fcpu * ck * 2**16 for ck in CKsel] for fcpu in MCUclk]
maxT8 = [[1/fcpu * ck * 2**8 for ck in CKsel] for fcpu in MCUclk]

fixe = lambda n: log10(n)//3 * 3 if n != 0 else 0
feng = lambda n: F"{n / 10**fixe(n):.3f} E{int(fixe(n))}"

Tmax = {f:maxT[i] for i, f in enumerate(MCUclk)}
Tmaxeng = [[feng(t) for t in T] for T in Tmax.values()]

Tmax8 = {f:maxT8[i] for i, f in enumerate(MCUclk)}
Tmaxeng8 = [[feng(t) for t in T] for T in Tmax8.values()]

FCPU = [feng(f) for f in MCUclk]

# T1 = pd.DataFrame(maxT, index=FCPU, columns=CKsel, dtype=float)
T1 = pd.DataFrame(Tmaxeng, index=FCPU, columns=CKsel, dtype=float)
T0 = pd.DataFrame(Tmaxeng8, index=FCPU, columns=CKsel, dtype=float)

print(T1)
print()
print(T0)



