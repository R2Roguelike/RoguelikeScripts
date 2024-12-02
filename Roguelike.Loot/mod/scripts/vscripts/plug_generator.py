# GENERATES ALL PLUGS OF N SLOTS WITH TOTAL K
def multichoose(n,k):
    if k < 0 or n < 0: return "Error"
    if not k: return [[0]*n]
    if not n: return []
    if n == 1: return [[k]]

    return ( [[0]+val for val in multichoose(n-1,k)] + # gemerates all plugs of n-1 slots, with total k, making a [0,...] plug
        [[val[0]+1]+val[1:] for val in multichoose(n,k-1)] ) # generates all plugs of k-1 total, making an [1+X, X, X] plug

print(multichoose(3,6))