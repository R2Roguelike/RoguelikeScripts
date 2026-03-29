globalize_all_functions

void function RunStats_DamageDealt( int amount, bool isTitan, int loadout = -1 )
{
    table data = Roguelike_GetRunData()
    if (isTitan)
    {
        data.damageDealtTitan += amount
        if (loadout == 0)
            data.damageDealtTitan0 += amount
        if (loadout == 1)
            data.damageDealtTitan1 += amount
    }
    else
        data.damageDealtPilot += amount
}
void function RunStats_EnemyKilled( bool isTitan )
{
    table data = Roguelike_GetRunData()
    if (isTitan)
        data.titansKilled += 1
    else
        data.gruntsKilled += 1
}
void function RunStats_ItemObtained()
{
    table data = Roguelike_GetRunData()
    data.itemsObtained += 1
}
void function RunStats_ChestOpened()
{
    table data = Roguelike_GetRunData()
    data.chestsOpened += 1
}
void function RunStats_CashEarned( int amount )
{
    table data = Roguelike_GetRunData()
    data.cashEarned += amount
}
void function RunStats_ModsUnlocked( int amount )
{
    table data = Roguelike_GetRunData()
    data.modsUnlocked += amount
}
