
from os import system
cls = lambda: system("clear")


#
segs = {0:"abcdef", 1:"bc", 2:"abdeg", 3:"abcdg", 4:"bcfg", 5:"acdfg", 6:"acdefg", 7:"abc", 8:"abcdefg", 9:"abcdfg"}

pinOrder = "edcbafg"

# so = ["0"+"".join(["1" if p in segs[n] else "0" for p in pinOrder]) for n in range(len(segs))]

# pbs = ["0x0" + F"{int(s[:4],2):X}" for s in so]

# pds = ["0x" + F"{int(s[4:]+'0000',2):X}"  for s in so]


def mapSevSeg(pinorder, spl=0):
    segs = {0:"abcdef", 1:"bc", 2:"abdeg", 3:"abcdg", 4:"bcfg",\
        5:"acdfg", 6:"acdefg", 7:"abc", 8:"abcdefg", 9:"abcdfg"}
    so = ["0"+"".join(["1" if p in segs[n] else "0" for p in pinOrder]) for n in range(len(segs))]
    # pbs = ["0x" + F"{int(s[:spl+1],2):X}".zfill(2) for s in so]
    # pds = ["0x" + F"{int(s[spl+1:] + ('0'*(8-spl-1)),2):X}"  for s in so]
    # pds = ["0x" + F"{int(s[spl+1:]+'0000',2):X}"  for s in so]
    # return [pbs, pds]
    return so

# pds = ["0x" + F"{int(s[spl+1:]+'0'*(8-spl-1),2):X}"  for s in so]

def mapSeg(pinOrder):
    segs = {0:"abcdef", 1:"bc", 2:"abdeg", 3:"abcdg", 4:"bcfg",\
        5:"acdfg", 6:"acdefg", 7:"abc", 8:"abcdefg", 9:"abcdfg"}
    so = []
    for s in range(len(segs)):
        po = "0"
        for p in pinOrder:
            po = po + ("1" if p in segs[s] else "0")
        so.append(po)
    sh = ["0x"+F"{int(B,2):X}".zfill(2) for B in so]
    return {'b':so, 'h':sh, 'j':" ".join(sh)}


# split list of binary strings into two lists of binary strings divided at n.=
# [[bn[:n] for bn in so['b']],[bn[n:] for bn in so['b']]]
sp = lambda byt, n: [[bn[:n] for bn in byt],[bn[n:] for bn in byt]]

# Convert list of binary values to hex.
b2h = lambda B: ["0x"+F"{int(b, 2):X}".zfill(2) for b in B]








