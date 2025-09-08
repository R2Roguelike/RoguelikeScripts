import math
def basicPowerScalar(player, enemy):
    powerDiff = player - enemy
    if (powerDiff > 0):
        return (100 + powerDiff) / 100
    return (100) / (100 - powerDiff)

levels = 15

EnemyHP = 0
for i in range(levels):
    EnemyHP += 10

playerPower = levels * 6

print("Player to Enemy scalar: " + str(basicPowerScalar(playerPower, EnemyHP)))
print("Enemy to Player scalar: " +  str((basicPowerScalar(EnemyHP, playerPower))))

print("Enemy: " + str(EnemyHP))
print("Player: " + str(playerPower))