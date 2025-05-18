untyped
global function Inventory_Init
global function Roguelike_GenerateLoot
global function Roguelike_StartNewRun
global function Roguelike_GetInventory
global function Roguelike_IsRunActive
global function Roguelike_GetRunData
global function Roguelike_GetMoney
global function Roguelike_AddMoney
global function Roguelike_TakeMoney
global function Roguelike_ApplyRunDataToConVars
global function RunEnded
global function __SetPower
global function Roguelike_GiveSmartPistolSkyway
global function Roguelike_GetSaveData
global function Roguelike_WriteSaveToDisk
global function Roguelike_IsSaveLoaded

const array<string> SAVE_CONVARS = [
    "meta_helmets_0",
    "meta_helmets_1",
    "meta_helmets_2",
    "meta_helmets_3",
    "meta_helmets_4",
    "meta_helmets_5",
    "meta_helmets_6",
    "meta_helmets_7",
    "meta_helmets_8",
    "meta_helmets_9",
    "meta_helmets_10",
    "meta_helmets_11",
    "meta_helmets_12",
    "meta_helmets_13",
    "meta_helmets_14",
    "roguelike_titan_loadout"
]

struct {
    table saveData
    table runData
    bool isSaveLoaded = false
    bool isRunActive = false
} file

void function Inventory_Init()
{
    thread LoadSaveData()

}

void function LoadSaveData()
{
    while (!IsFullyConnected() && uiGlobal.menuStack.len() <= 0)
        wait 0.001
    if (NSDoesFileExist("save.json"))
        NSLoadJSONFile(
            "save.json",
            void function( table t ) : ()
            {
                file.saveData = t

                foreach (string convar in SAVE_CONVARS)
                {
                    if (convar in file.saveData)
                        SetConVarString(convar, expect string(file.saveData[convar]))
                }
                printt("Save loaded successfully")
                file.isSaveLoaded = true
            },
            void function() : ()
            {
                while (uiGlobal.menuStack.len() == 0)
                    wait 0.001
                DialogData dialogData
                dialogData.header = "SAVE LOAD FAILED"
                dialogData.image = $"ui/menu/common/dialog_error"
                dialogData.forceChoice = true
                dialogData.message = "Loading save data failed. Would you like to try again or give up?"

                AddDialogButton( dialogData, "Retry", LoadSaveData )
                AddDialogButton( dialogData, "Quit", QuitGame )

                AddDialogFooter( dialogData, "#A_BUTTON_SELECT" )

                delaythread( 0.1 ) OpenDialog( dialogData )
            }
        )
    else
        file.isSaveLoaded = true
    
    if (NSDoesFileExist("run_backup.json"))
        NSLoadJSONFile( "run_backup.json", void function( table t ) : ()
        {
            DialogData dialogData
            dialogData.header = "RUN CHECKPOINT AVAILABLE"
            dialogData.forceChoice = true
            dialogData.message = "You quit or crashed mid-run, although a backup was saved. Would you like to continue from the last chapter?"

            AddDialogFooter( dialogData, "#A_BUTTON_SELECT" )

            file.runData = t
            file.isRunActive = true
            UpdateSPButtons()
        }
    )
}

void function RunEnded()
{
    // reset run
    NSDeleteFile( "run_backup.json" )
    file.isRunActive = false
    file.runData = {}
    ClientCommand("disconnect")
}

void function Roguelike_StartNewRun()
{
    table runData = {
        inventory = [],
        length = "short",
        unlockedMods = [],
        newMods = []
    }

    file.runData = runData
    file.isRunActive = true


    // these arrays are to prevent the player from getting
    // 3+ of the same armor chip slot in a row, and to
    // gurantee the player gets a preferred chip slot
    // eventually.
    runData.chipSlotOrder <- [1,2,3,4,5,6,7,8]
    runData.chipSlotOrder.randomize()
    runData.chipSlotIndex <- 0

    runData.balanced <- false

    runData.powerPlayer <- 0
    runData.enemyBonusHP <- 0
    runData.enemyDEF <- 0
    runData.levelsCompleted <- 0

    runData.money <- 0
    runData.map <- "sp_crashsite"
    runData.startPointIndex <- 7
    if (Roguelike_GetTitanLoadouts().len() < 2)
        SetConVarString( "roguelike_titan_loadout", "mp_titanweapon_leadwall mp_titanweapon_meteor")
    runData.loadouts <- GetConVarString("roguelike_titan_loadout")
    runData.runModifiers <- GetConVarString("roguelike_run_modifiers")
    runData.memoryHP <- "-1"
    runData.memorySettings <- ""
    SetConVarInt("memory_titan_hp", -1)
    SetConVarString("memory_titan_settings", "")
    runData.runHeat <- GetConVarInt("roguelike_run_heat")

    runData.lockedPilotMods <- GetAllLockedPilotMods()
    runData.lockedTitanMods <- GetAllLockedTitanMods()
    Roguelike_UnlockMods( 10 ) // have the player start with some amount of mods

    for (int i = 1; i <= 4; i++)
    {
        for (int j = 0; j < MOD_SLOTS; j++)
        {
            runData["AC" + i + "_PilotMod" + j] <- GetModByName("empty").index
            runData["AC" + i + "_TitanMod" + j] <- GetModByName("empty").index
        }
    }

    runData.ACPilot1 <- ArmorChip_ForceSlot( 1, false )
    runData.ACPilot2 <- ArmorChip_ForceSlot( 2, false )
    runData.ACPilot3 <- ArmorChip_ForceSlot( 3, false )
    runData.ACPilot4 <- ArmorChip_ForceSlot( 4, false )

    runData.ACTitan1 <- ArmorChip_ForceSlot( 1, true )
    runData.ACTitan2 <- ArmorChip_ForceSlot( 2, true )
    runData.ACTitan3 <- ArmorChip_ForceSlot( 3, true )
    runData.ACTitan4 <- ArmorChip_ForceSlot( 4, true )

    runData.WeaponPrimary <- RoguelikeWeapon_CreateWeapon( "mp_weapon_vinson", RARITY_COMMON, "primary" )
    runData.WeaponSecondary <- RoguelikeWeapon_CreateWeapon( "mp_weapon_epg", RARITY_COMMON, "special" )

    Roguelike_ForceRefreshInventory()

    NSSaveJSONFile( "run_backup.json", runData )
    if (file.isSaveLoaded)
        Roguelike_WriteSaveToDisk()
}

void function Roguelike_ApplyRunDataToConVars()
{
    table runData = Roguelike_GetRunData()

    SetConVarInt("roguelike_levels_completed", expect int(runData.levelsCompleted))
    SetConVarInt("power_enemy_hp", expect int(runData.enemyBonusHP))
    SetConVarInt("power_enemy_def", expect int(runData.enemyDEF))
    SetConVarString("roguelike_titan_loadout", expect string(runData.loadouts))
    SetConVarString("roguelike_run_modifiers", expect string(runData.runModifiers))
    SetConVarString("memory_titan_hp", expect string(runData.memoryHP))
    SetConVarString("memory_titan_settings", expect string(runData.memorySettings))
    SetConVarInt("roguelike_run_heat", expect int(runData.runHeat))
    SetConVarBool("roguelike_stat_balance", expect bool(runData.balanced))

    // server doesnt care about mod order since it only uses this
    // userinfo convar to check which mods to apply
    // technically this makes mods and stats client authoritative
    // but since this is singleplayer and co-op will never happen
    // (that co-op mod will never get finished ;-;) then we kinda
    // ... dont care.
    if (!("AC1_PilotMod0" in runData))
    {
        return
    }
    array<string> modIndexList
    for (int i = 1; i < 5; i++)
    {
        for (int j = 0; j < MOD_SLOTS; j++)
        {
            if (runData["AC" + i + "_PilotMod" + j] != 0)
                modIndexList.append(string(runData["AC" + i + "_PilotMod" + j]))
            if (runData["AC" + i + "_TitanMod" + j] != 0)
                modIndexList.append(string(runData["AC" + i + "_TitanMod" + j]))
        }
    }
    SetConVarString( "player_mods", JoinStringArray( modIndexList, " " ) )

    array<string> weapons = []
    array<string> weaponPerks = []
    array<string> weaponMods = []
    for (int i = 0; i < 2; i++)
    {
        string slotName = i == 1 ? "WeaponSecondary" : "WeaponPrimary"
        string otherSlotName = i == 0 ? "WeaponSecondary" : "WeaponPrimary"
        table slot = expect table(runData[slotName])
        array perks = []
        perks.extend(expect array(slot.perks))
        array mods = expect array(slot.mods)
        int level = expect int(slot.level)
        int rarity = expect int(slot.rarity)
        perks.append("level_" + level)
        switch (rarity)
        {
            case RARITY_UNCOMMON:
                perks.append("uncommon")
                break
            case RARITY_RARE:
                perks.append("rare")
                break
            case RARITY_EPIC:
                perks.append("epic")
                break
            case RARITY_LEGENDARY:
                perks.append("legendary")
                break
        }

        weaponPerks.append(JoinDynamicArray(perks, ","))
        weaponMods.append(JoinDynamicArray(mods, ","))

        weapons.append(expect string(slot.weapon))
    }
    SetConVarString( "player_weapon_perks", JoinStringArray( weaponPerks, " " ) )
    SetConVarString( "player_weapon_mods", JoinStringArray( weaponMods, " " ) )
    SetConVarString( "player_weapons", JoinStringArray( weapons, " " ) )
}

void function Roguelike_Reset()
{
    file.runData.clear()
    file.isRunActive = false
}

void function Roguelike_GenerateLoot()
{
    print("GENERATING LOOT")
    int r = RandomInt(3)

    table item = {}
    switch (r)
    {
        case 0:
            item = RoguelikeWeapon_Generate()
            break
        case 1:
        case 2:
            item = ArmorChip_Generate()
            break
    }
    file.runData.inventory.append(item)

    Roguelike_ForceRefreshInventory()

    Roguelike_AddMoney( RandomIntRange(25, 50) )

    if (IsFullyConnected())
        RunClientScript( "Roguelike_ItemGained" )
}

void function Roguelike_GiveSmartPistolSkyway()
{
    printt("skyway smart pistol")
    table item = RoguelikeWeapon_GenerateSmartPistol()

    table oldWeapon = expect table(file.runData["WeaponPrimary"])

    file.runData["WeaponPrimary"] = item
    file.runData.inventory.append(oldWeapon)

    Roguelike_ForceRefreshInventory()
}

void function __SetPower( int levelsCompleted )
{
    table runData = Roguelike_GetRunData()
    int enemyDEFGained = ENEMY_DEF_PER_LEVEL
    int enemyHPGained = ENEMY_HP_PER_LEVEL

    switch (GetConVarInt("sp_difficulty"))
    {
        case 0:
            enemyDEFGained = ENEMY_DEF_PER_LEVEL_EASY
            break
        case 2:
            enemyHPGained = ENEMY_HP_PER_LEVEL_HARD
            enemyDEFGained = ENEMY_DEF_PER_LEVEL_HARD
            break
        case 3:
            enemyHPGained = ENEMY_HP_PER_LEVEL_MASTER
            enemyDEFGained = ENEMY_DEF_PER_LEVEL_MASTER
            break
    }
    runData.enemyBonusHP <- enemyHPGained * levelsCompleted
    runData.enemyDEF <- enemyDEFGained * levelsCompleted
    runData.levelsCompleted = levelsCompleted

    Roguelike_ApplyRunDataToConVars()
}

array function Roguelike_GetInventory()
{
    if (!file.isRunActive)
        return []
    return expect array(file.runData.inventory)
}

int function Roguelike_GetMoney()
{
    if (!file.isRunActive)
        return 0

    return expect int(file.runData.money)
}

void function Roguelike_AddMoney( int amt )
{
    if (!file.isRunActive)
        return

    file.runData.money += amt
}

void function Roguelike_TakeMoney( int amt )
{
    if (!file.isRunActive)
        return

    file.runData.money -= amt
}

table function Roguelike_GetRunData()
{
    if (!file.isRunActive)
        return {}
    return file.runData
}

bool function Roguelike_IsRunActive()
{
    return file.isRunActive
}

table function Roguelike_GetSaveData()
{
    return file.saveData
}

void function Roguelike_WriteSaveToDisk()
{
    if (!file.isSaveLoaded)
        throw "Cannot save whilst save data not loaded!"
    foreach (string convar in SAVE_CONVARS)
    {
        file.saveData[convar] <- GetConVarString(convar)
    }
    printt("SAVING FILE")
    NSSaveJSONFile( "save.json", file.saveData )
}

bool function Roguelike_IsSaveLoaded()
{
    return file.isSaveLoaded
}