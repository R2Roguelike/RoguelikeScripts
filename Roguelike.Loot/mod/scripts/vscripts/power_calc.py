import math
def basicPowerScalar(player, enemy):
    powerDiff = player - enemy
    if (powerDiff > 0):
        return (100 + powerDiff) / 100
    return (100) / (100 - powerDiff)

levels = 15

enemyPower = 0
for i in range(levels):
    enemyPower += 10

playerPower = levels * 6

print("Player to Enemy scalar: " + str(basicPowerScalar(playerPower, enemyPower)))
print("Enemy to Player scalar: " +  str((basicPowerScalar(enemyPower, playerPower))))

print("Enemy: " + str(enemyPower))
print("Player: " + str(playerPower))