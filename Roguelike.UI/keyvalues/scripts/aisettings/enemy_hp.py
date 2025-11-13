import os
from functools import lru_cache

enemydefperlevel = 150
enemydef = 0
for i in range(0, 30):
    enemydef += enemydefperlevel
    print(str(enemydef) + " def (" + str((enemydef + 500) / 5) + "%) for " + str(i))
    enemydefperlevel += 25

enemydefperlevel = 150
enemydef = 0
for i in range(0, 30):
    enemydef += enemydefperlevel
    print(str(enemydef) + " def (" + str((enemydef + 500) / 5) + "%) for " + str(i))