untyped
global function Inventory_Init
global function Roguelike_GenerateLoot
global function Roguelike_AddToInventory
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
global function __SecondLoadout
global function Roguelike_GiveSmartPistolSkyway
global function Roguelike_GetSaveData
global function Roguelike_WriteSaveToDisk
global function Roguelike_IsSaveLoaded
global function Roguelike_GenerateItem

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
    "roguelike_titan_loadout",
    "roguelike_loadouts_unlocked",
    "roguelike_run_modifiers"
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
            void function(var err) : ()
            {
                while (uiGlobal.menuStack.len() == 0)
                    wait 0.001
                DialogData dialogData
                dialogData.header = "SAVE LOAD FAILED"
                dialogData.image = $"ui/menu/common/dialog_error"
                dialogData.forceChoice = true
                dialogData.message = "Loading save data failed! (" + err + ")"
                printt("DIALOG")

                AddDialogButton( dialogData, "Retry", LoadSaveData )
                AddDialogButton( dialogData, "Delete save file (PERMANENT DATA LOSS!)" )
                AddDialogButton( dialogData, "Quit Game", QuitGame )

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

            if ("version" in t && expect int(t.version) == RUNDATA_VERSION)
            {
                file.runData = t
                if (!("chipSlotIndex" in file.runData))
                    file.runData.chipSlotIndex <- 0 // why does this happen???
                file.isRunActive = true
            }
            UpdateSPButtons()
        }
    )
}

void function RunEnded()
{
    // reset run
    NSDeleteFile( "run_backup.json" )
    
    RunEnd_SetRunData( file.runData )
    file.isRunActive = false
    file.runData = {}
    AdvanceMenu(GetMenu("RunEndMenu"))
    //ClientCommand("disconnect")
}

void function Roguelike_StartNewRun(int seed = -1)
{
    if (seed == -1)
    {
        seed = RandomInt(2147483647)
    }
    PRandom rand = NewPRandom(seed)
    table runData = {
        inventory = [],
        length = "short",
        unlockedMods = [],
        newMods = []
    }

    file.runData = runData
    file.isRunActive = true

    // run stats
    runData.damageDealtPilot <- 0.0
    runData.damageDealtTitan <- 0.0
    runData.titansKilled <- 0
    runData.gruntsKilled <- 0
    runData.itemsObtained <- 0
    runData.modsUnlocked <- 0
    runData.titanHp <- 12500
    runData.titanSettings <- ""
    runData.titanMaxHp <- 12500

    // these arrays are to prevent the player from getting
    // 3+ of the same armor chip slot in a row, and to
    // gurantee the player gets a preferred chip slot
    // eventually.
    SetConVarInt("roguelike_run_seed", seed)
    runData.seed <- seed
    runData.chipSlotOrder <- [1,2,3,4,5,6,7,8]
    runData.chipSlotOrder.randomize()
    runData.chipSlotIndex <- 0
    runData.difficulty <- GetConVarInt("sp_difficulty")

    runData.balanced <- false

    runData.enemyBonusHP <- 0
    runData.enemyDEF <- 0
    runData.levelsCompleted <- 0

    runData.money <- 0
    runData.map <- "sp_crashsite"
    runData.startPointIndex <- 7
    if (Roguelike_GetTitanLoadouts().len() > 1)
        SetConVarString( "roguelike_titan_loadout", Roguelike_GetTitanLoadouts()[0])
    runData.loadouts <- GetConVarString("roguelike_titan_loadout")
    runData.runModifiers <- GetConVarString("roguelike_run_modifiers")
    SetConVarInt("memory_titan_hp", -1)
    SetConVarString("memory_titan_settings", "")
    runData.runHeat <- GetConVarInt("roguelike_run_heat")

    runData.shopRerolls <- {}
    //runData.lockedPilotMods <- GetAllLockedPilotMods()
    runData.lockedTitanMods <- GetAllLockedTitanMods()
    Roguelike_UnlockMods( 4 ) // have the player start with some amount of mods

    for (int i = 1; i <= 4; i++)
    {
        for (int j = 0; j < MOD_SLOTS; j++)
        {
            runData["AC" + i + "_PilotMod" + j] <- GetModByName("empty").index
            runData["AC" + i + "_TitanMod" + j] <- GetModByName("empty").index
        }
    }

    runData.ACPilot1 <- ArmorChip_ForceSlot( rand, 1, false )
    runData.ACPilot2 <- ArmorChip_ForceSlot( rand, 2, false )
    runData.ACPilot3 <- ArmorChip_ForceSlot( rand, 3, false )
    runData.ACPilot4 <- ArmorChip_ForceSlot( rand, 4, false )

    runData.ACTitan1 <- ArmorChip_ForceSlot( rand, 1, true )
    runData.ACTitan2 <- ArmorChip_ForceSlot( rand, 2, true )
    runData.ACTitan3 <- ArmorChip_ForceSlot( rand, 3, true )
    runData.ACTitan4 <- ArmorChip_ForceSlot( rand, 4, true )
    
    runData.loadout1Damage <- 0
    runData.loadout2Damage <- 0

    runData.Datacore <- RoguelikeDatacore_CreateDatacore( rand, RARITY_COMMON )
    runData.WeaponPrimary <- RoguelikeWeapon_CreateWeapon( rand, "mp_weapon_vinson", RARITY_COMMON, "primary" )
    runData.WeaponSecondary <- RoguelikeWeapon_CreateWeapon( rand, "mp_weapon_epg", RARITY_COMMON, "special" )
    runData.Grenade <- RoguelikeGrenade_CreateWeapon( rand, "mp_weapon_frag_grenade", RARITY_COMMON )

    Roguelike_ForceRefreshInventory()

    NSSaveJSONFile( "run_backup.json", runData )
    if (file.isSaveLoaded)
        Roguelike_WriteSaveToDisk()
}

void function Roguelike_ApplyRunDataToConVars()
{
    table runData = Roguelike_GetRunData()

    SetConVarInt("roguelike_levels_completed", expect int(runData.levelsCompleted))
    SetConVarInt("roguelike_levels_completed", expect int(runData.levelsCompleted))
    SetConVarInt("power_enemy_hp", expect int(runData.enemyBonusHP))
    SetConVarInt("power_enemy_def", expect int(runData.enemyDEF))
    SetConVarString("roguelike_titan_loadout", expect string(runData.loadouts))
    SetConVarString("roguelike_run_modifiers", expect string(runData.runModifiers))
    SetConVarInt("roguelike_run_heat", expect int(runData.runHeat))
    //SetConVarBool("roguelike_stat_balance", expect bool(runData.balanced))
    SetConVarInt("sp_difficulty", expect int(runData.difficulty))
    SetConVarInt("roguelike_run_seed", expect int(runData.seed))
    if ("titanHp" in runData)
        SetConVarInt("memory_titan_hp", expect int(runData.titanHp))
    if ("titanSettings" in runData)
        SetConVarString("memory_titan_settings", expect string(runData.titanSettings))
    if ("titanMaxHp" in runData)
        SetConVarInt("memory_titan_max_hp", expect int(runData.titanMaxHp))

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
            var pilotChip = runData["ACPilot" + i]
            if (pilotChip.mods.len() > j && pilotChip.mods[j] != 0)
                modIndexList.append(string(pilotChip.mods[j]))
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
        array mods = expect array(slot.mods)
        int level = expect int(slot.level)
        int rarity = expect int(slot.rarity)

        perks.append("level_" + level)

        switch (rarity)
        {
            case RARITY_COMMON:
                break
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
            default:
                perks.append("legendary")
                break
        }

        if (slot.bonusStat != "")
            perks.append(slot.bonusStat)
        if (slot.perk1 != "")
            perks.append(slot.perk1)
        if (slot.perkInherited != "")
            perks.append(slot.perkInherited)

        weaponPerks.append(JoinDynamicArray(perks, ","))
        weaponMods.append(JoinDynamicArray(mods, ","))

        weapons.append(expect string(slot.weapon))
    }
    SetConVarString( "player_weapon_perks", JoinStringArray( weaponPerks, " " ) )
    SetConVarString( "player_weapon_mods", JoinStringArray( weaponMods, " " ) )
    SetConVarString( "player_weapons", JoinStringArray( weapons, " " ) )

    var ordnanceSlot = runData["Grenade"]
    array<string> ordnancePerks = ["level_" + expect int(ordnanceSlot.level)]
    ordnancePerks.append(expect string(ordnanceSlot.perk1))
    switch (ordnanceSlot.rarity)
    {
        case RARITY_COMMON:
            break
        case RARITY_UNCOMMON:
            ordnancePerks.append("uncommon")
            break
        case RARITY_RARE:
            ordnancePerks.append("rare")
            break
        case RARITY_EPIC:
            ordnancePerks.append("epic")
            break
        case RARITY_LEGENDARY:
            ordnancePerks.append("legendary")
            break
        default:
            ordnancePerks.append("legendary")
            break
    }

    table datacore = expect table(runData["Datacore"])

    RoguelikeDatacorePerk datacorePerk = GetDatacorePerkDataByName( expect string(datacore.perk1) )
    float datacoreValue = datacorePerk.baseValue + datacorePerk.valuePerLevel * expect int(datacore.rarity)

    SetConVarString( "player_datacore", format("%i %s %f", datacore.dashes, datacore.perk1, datacoreValue))
    SetConVarString( "player_ordnance_perks", JoinStringArray( ordnancePerks, "," ))
    SetConVarString( "player_ordnance", expect string(ordnanceSlot.weapon))
}

void function Roguelike_Reset()
{
    file.runData.clear()
    file.isRunActive = false
}

void function Roguelike_AddToInventory( table item )
{
    file.runData.inventory.append(item)

    Roguelike_ForceRefreshInventory()

    if (IsFullyConnected())
        RunClientScript( "Roguelike_ItemGained" )
}

void function Roguelike_GenerateLoot(int seed = 0)
{
    if (seed == 0)
        seed = RandomInt(2000000000)
    PRandom rand = NewPRandom(seed)

    table item = Roguelike_GenerateItem(rand, false)
    foreach (string k, var v in item)
        printt(k,v)
    file.runData.inventory.append(item)
    RunStats_ItemObtained()

    Roguelike_ForceRefreshInventory()

    if (IsFullyConnected())
        RunClientScript( "Roguelike_ItemGained" )
}

table function Roguelike_GenerateItem(PRandom rand, bool isShop)
{
    switch (PRandomInt(rand, 10))
    {
        case 0:
        case 1: // 22.2% weapon
            return RoguelikeWeapon_Generate(rand)
            break
        case 2: // 11.1% grenade
            return RoguelikeGrenade_Generate(rand)
            break
        case 3: // 22.2% datacore
        case 4:
            return RoguelikeDatacore_Generate(rand)
            break
        case 5:
        case 6:
        case 7:
        case 8:
        case 9:
        default:
            return ArmorChip_Generate(rand, isShop)
            break
    }
    unreachable
}

void function Roguelike_GiveSmartPistolSkyway()
{
    printt("skyway smart pistol")
    PRandom rand = NewPRandom(Roguelike_GetRunSeed())
    table item = RoguelikeWeapon_GenerateSmartPistol(rand)

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
    runData.enemyDEF <- enemyDEFGained * levelsCompleted + GetDEFFromIncreasePerLevel(levelsCompleted)
    runData.levelsCompleted = levelsCompleted

    Roguelike_ApplyRunDataToConVars()
}

int function GetDEFFromIncreasePerLevel( int levelsCompleted )
{
    int result = 0
    for (int i = 1; i <= levelsCompleted; i++)
    {
        result += 25 * levelsCompleted
    }
    return result
}
void function __SecondLoadout()
{
    AdvanceMenu(GetMenu("LimitedLoadoutChoice"))
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
    RunClientScript( "RoguelikeTimer_SetMoney", file.runData.money )
}

void function Roguelike_TakeMoney( int amt )
{
    if (!file.isRunActive)
        return

    file.runData.money -= amt
    RunClientScript( "RoguelikeTimer_SetMoney", file.runData.money )
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