import numpy as np

Fcpu = 16E6
clkopts = np.array([1, 8, 64, 256, 1024])

topts = clkopts / Fcpu;

maxT = topts * 2**16

print("CPU Frequency", Fcpu, "\n\n")

print("Tick Period Options", topts, "\n\n")

print("Max Period: ", maxT, "\n\n")

tStep = [maxT[n] / topts[n+1] for n in range(4)]

print("tStep: ", tStep, "\n\n")




