globalize_all_functions

void function RunStats_DamageDealt( int amount, bool isTitan )
{
    table data = Roguelike_GetRunData()
    if (isTitan)
        data.damageDealtTitan += amount
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
