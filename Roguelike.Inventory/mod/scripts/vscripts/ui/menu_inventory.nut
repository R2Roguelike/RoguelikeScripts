untyped
global function AddInventoryMenu
global function OpenInventoryMenu
global function FormatDescription
global function GetModDescriptionSuffix
global function Roguelike_GetStat
global function Roguelike_ForceRefreshInventory
global function GetTitanDescription

struct {
    var menu
    string nextMap = ""
    int startPointIndex = 0
    int kills = 69
    float time = 370
    GridMenuData gridData
    bool isOpen = true
    array<var> modSlots
    float startDismantleTime = -1.0
    float endDismantleTime = -1.0
    int totalPilot = 0
    int totalTitan = 0
} file

void function AddInventoryMenu()
{
    SetConVarInt("script_server_fps", 20)
    SetConVarInt("sv_maxvelocity", 36000)
	AddMenu( "InventoryMenu", $"resource/ui/menus/inventory.menu", InitInventoryMenu )
    delaythread(0.001) UpdateMenuState()
    delaythread(0.001) UpdateInventory()
}

void function InitInventoryMenu()
{
    file.menu = GetMenu( "InventoryMenu" )
    RegisterSignal( "StopDismantle" )

	AddMenuFooterOption( file.menu, BUTTON_A, "#A_BUTTON_SELECT" )
	AddMenuFooterOption( file.menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )

    AddMenuEventHandler( file.menu, eUIEvent.MENU_OPEN, OnOpen )
    AddMenuEventHandler( file.menu, eUIEvent.MENU_CLOSE, OnClose )

	file.gridData.columns = 7
	file.gridData.rows = 2
	file.gridData.numElements = 16
	file.gridData.pageType = eGridPageType.HORIZONTAL
	file.gridData.tileWidth = ContentScaledXAsInt( 80 )
	file.gridData.tileHeight = ContentScaledYAsInt( 80 )
	file.gridData.paddingVert = int( ContentScaledX( 8 ) )
	file.gridData.paddingHorz = int( ContentScaledX( 8 ) )
	file.gridData.initCallback = Slot_Init

    GridMenuInit( file.menu, file.gridData )
    Grid_InitPage( file.menu, file.gridData )

    // add hovers to armor chips
    AddHover( Hud_GetChild( file.menu, "ACPilot1" ), ArmorChip_Hover, HOVER_ARMOR_CHIP )
    AddHover( Hud_GetChild( file.menu, "ACPilot2" ), ArmorChip_Hover, HOVER_ARMOR_CHIP )
    AddHover( Hud_GetChild( file.menu, "ACPilot3" ), ArmorChip_Hover, HOVER_ARMOR_CHIP )
    AddHover( Hud_GetChild( file.menu, "ACPilot4" ), ArmorChip_Hover, HOVER_ARMOR_CHIP )
    AddHover( Hud_GetChild( file.menu, "ACTitan1" ), ArmorChip_Hover, HOVER_ARMOR_CHIP )
    AddHover( Hud_GetChild( file.menu, "ACTitan2" ), ArmorChip_Hover, HOVER_ARMOR_CHIP )
    AddHover( Hud_GetChild( file.menu, "ACTitan3" ), ArmorChip_Hover, HOVER_ARMOR_CHIP )
    AddHover( Hud_GetChild( file.menu, "ACTitan4" ), ArmorChip_Hover, HOVER_ARMOR_CHIP )

    AddHover( Hud_GetChild(file.menu, "WeaponPrimary"), Weapon_Hover, HOVER_WEAPON )
    AddHover( Hud_GetChild(file.menu, "WeaponSecondary"), Weapon_Hover, HOVER_WEAPON )
    AddHover( Hud_GetChild(file.menu, "Grenade"), Grenade_Hover, HOVER_WEAPON )

    AddHover( Hud_GetChild( file.menu, "BalanceSymbol" ), void function( var symbol, var panel ) : (){
        table runData = Roguelike_GetRunData()
        if (runData.balanced)
        {
            Hud_SetColor( Hud_GetChild(panel, "TitleStrip"), 255, 122, 244, 255 )
            Hud_SetColor( Hud_GetChild(panel, "BG"), 204, 98, 195, 255 )
            Hud_SetText( Hud_GetChild(panel, "Title"), FormatDescription("Augment of Balance"))
            Hud_SetText( Hud_GetChild(panel, "Description"), FormatDescription("Your mind is cleared, and you see through the fog.\n\n-20% DMG taken from enemies.") )
            return
        }
        else
        {
            Hud_SetText( Hud_GetChild(panel, "Title"), "???")
            bool tooMuchTitan = file.totalTitan > file.totalPilot
            Hud_SetText( Hud_GetChild(panel, "Description"), FormatDescription(format("You lack balance in your perspective...\n\n%i titan | %i pilot", file.totalTitan, file.totalPilot)) )
        }
    }, HOVER_SIMPLE )

    RegisterButtonPressedCallback( BUTTON_X, AttemptUpgrade )
    RegisterButtonPressedCallback( MOUSE_RIGHT, AttemptUpgrade )
    RegisterButtonPressedCallback( KEY_F, AttemptDismantle )
    RegisterButtonReleasedCallback( KEY_F, StopDismantle )
    RegisterButtonPressedCallback( BUTTON_Y, AttemptDismantle )
    RegisterButtonReleasedCallback( BUTTON_Y, StopDismantle )

    array<var> modButtons = GetElementsByClassname( file.menu, "ModSlot" )

    // HELP TEXT
    for (int i = 1; i < 5; i++)
    {
        AddHover( Hud_GetChild(file.menu, "AC" + i + "_PilotHelp"), ModHelp_Hover, HOVER_SIMPLE )
        AddHover( Hud_GetChild(file.menu, "AC" + i + "_TitanHelp"), ModHelp_Hover, HOVER_SIMPLE )
    }
    AddHover( Hud_GetChild(file.menu, "TitanPassive"), ModHelp_Hover, HOVER_SIMPLE )

    // STAT IMAGES
    for (int i = 0; i < 6; i++)
    {
        string statName = STAT_NAMES[i]
        var statPanel = Hud_GetChild( file.menu, statName + "Stat" )
        var bg = Hud_GetChild(statPanel, "BG")
        bg.SetImage( StringToAsset( "ui/stats/" + statName.tolower() ) )
        statPanel.s.data <- i
        AddHover( statPanel, Stat_Hover, HOVER_SIMPLE )

        if (i >= 3)
        {
            var label = Hud_GetChild(statPanel, "Value")

            bg.SetColor( [ 255, 176, 0, 255 ] )
            label.SetColor( [ 255, 176, 0, 255 ] )
        }
    }

    foreach (var modSlot in modButtons)
    {
        Hud_AddEventHandler( Hud_GetChild(modSlot, "Button"), UIE_CLICK, ModSlot_Click )

        string parentName = Hud_GetHudName( Hud_GetParent( modSlot ) )
        bool isTitan = parentName.find("Titan") != null
        int chipSlot = int( parentName.slice(2, 3) )
        modSlot.s.data <- format("AC%i_%sMod%i", chipSlot, isTitan ? "Titan" : "Pilot", int( Hud_GetScriptID( modSlot ) ))
    }

    file.modSlots.extend(modButtons)

    thread void function() : ()
    {
        while( 1)
        {
            wait 0
            for (int i = 0; i < 6; i++)
            {
                string statName = STAT_NAMES[i]
                var statPanel = Hud_GetChild( file.menu, statName + "Stat" )
                Hud_GetChild( statPanel, "Diff" ).SetAlpha( GraphCapped( Time() - lastDiffSetTime, 0.1, 0.2, 255.0, 0.0 ))
            }
        }
    }()
}

void function AttemptDismantle( var fuck )
{
    Signal( uiGlobal.signalDummy, "StopDismantle" )
    var slot = GetCurrentHoverTarget()
    if (slot == null)
        return
    if (!("elemNum" in slot.s))
        return
    thread void function():(slot)
    {
        EmitUISound( "UI_CTF_1P_FlagReturnMeter" )
        EndSignal( uiGlobal.signalDummy, "StopHover" )
        EndSignal( uiGlobal.signalDummy, "StopDismantle" )

        OnThreadEnd( void function() : () {
            file.startDismantleTime = -1.0
            file.endDismantleTime = -1.0
            StopUISound( "UI_CTF_1P_FlagReturnMeter" )
        })
        file.startDismantleTime = Time()
        file.endDismantleTime = Time() + 0.4
        wait 0.4

        // DISMANTLE
        int elemNum = Grid_GetElemNumForButton( slot )
        array inventory = Roguelike_GetInventory()
        table item = expect table(inventory[elemNum])

        SwapSequence(slot)
        if ("moneyInvested" in item)
            Roguelike_AddMoney( expect int(item.moneyInvested) / 2 ) // return 66% of money
        inventory.remove(elemNum)

        EmitUISound( "Menu_LoadOut_WeaponCamo_Select" )
        RefreshInventory()
    }()
}
void function StopDismantle( var fuck )
{
    Signal( uiGlobal.signalDummy, "StopDismantle" )
}

void function Stat_Hover( var statPanel, var panel )
{
    int statIndex = expect int(statPanel.s.data)
    string statName = STAT_NAMES[statIndex]
    int statValue = Roguelike_GetStat( statIndex )
    int statValueRaw = Roguelike_GetStatRaw( statIndex )

    string title = statName
    string description = "MISSING DESCRIPTION"
    switch (statIndex)
    {
        case STAT_ARMOR:
            description = format("Reduces Titan damage taken.\n\n"
                + "Titan damage reduced by <cyan>%.1f%%</>.",
                Roguelike_GetTitanDamageResist(statValue) * 100.0
            )
            break
        case STAT_ENERGY:
            description = format("Decreases Titan Dash cooldown, and increases Crit Rate.\n\n" +
                "Titan Dash cooldown decreased by <cyan>%.1f%%</>.\n" +
                "Base Crit Rate: <cyan>%.1f%%</>",
                (1.0 - Roguelike_GetDashCooldownMultiplier( statValue ) / 1.2) * 100.0,
                Roguelike_BaseCritRate( statValue ) * 100.0
            )
            break
        case STAT_POWER:
            description = format("Reduces Titan ability cooldowns, and increases Crit DMG.\n\n" +
                "Titan core gain increased by about <cyan>%.1f%%</>.\n" +
                "Base Crit DMG: <cyan>%.1f%%</>",
                (Roguelike_GetTitanCoreGain(statValue) / 0.5 - 1.0) * 100.0,
                Roguelike_BaseCritDMG( statValue ) * 100.0
            )
            break
        case STAT_TEMPER:
            description = format("Reduces Pilot ability cooldowns.\n\n" +
                "Pilot ability cooldowns reduced by about <cyan>%.1f%%</>.\nGrenade damage <note>(except self-damage)</> increased by <cyan>%.0f%%</>",
                (1.0 - Roguelike_GetPilotCooldownReduction(statValue) / 1.5) * 100.0,
                (Roguelike_GetGrenadeDamageBoost(statValue) - 1.0) * 100.0
            )
            break
        case STAT_SPEED:
            description = format("Increases Pilot movement speed.\n\n" +
                "Pilot movement speed increased by <cyan>%.1f%%</>.",
                Roguelike_GetPilotSpeedBonus(statValue) * 100.0
            )
            break
        case STAT_ENDURANCE:
            float multiplier = 1.0 + Roguelike_GetPilotHealthBonus(statValue)
            float selfDMGMult = Roguelike_GetPilotSelfDamageMult(statValue)
            description = format("Increases Pilot max health. Decreases Self Damage.\n\n" +
                "Max health increased to <cyan>%i</>.\nSelf Damage decreased by <cyan>%.1f%%</>",
                int(multiplier * 100.0),
                (1.0 - selfDMGMult) * 100.0
            )
            break
    }
    if (statValueRaw > STAT_CAP)
    {
        description += "\n\n<red>Increasing a stat above 100 has no effect.</>"
    }
    Hud_SetText( Hud_GetChild(panel, "Title"), title)
    Hud_SetText( Hud_GetChild(panel, "Description"), FormatDescription(description) )
}

string function GetModDescriptionSuffix( RoguelikeMod mod )
{
    string result = ""
    //if (mod.loadouts.len() > 1)
    //    return "\n\n<warn>Equipping this mod applies it to the ability GLOBALLY, regardless of loadout."

    return result
}

void function OnOpen()
{
    SetBlurEnabled( true )
    RefreshInventory()
}
void function OnClose()
{
    // TODO: save run data
}

void function RefreshInventory()
{
    table runData = Roguelike_GetRunData()

    Grid_InitPage( file.menu, file.gridData )

    Hud_SetText( Hud_GetChild(file.menu, "Money"), Roguelike_GetMoney() + "$" )

    InventorySlot_Display( Hud_GetChild(file.menu, "ACPilot1"), runData.ACPilot1 )
    InventorySlot_Display( Hud_GetChild(file.menu, "ACPilot2"), runData.ACPilot2 )
    InventorySlot_Display( Hud_GetChild(file.menu, "ACPilot3"), runData.ACPilot3 )
    InventorySlot_Display( Hud_GetChild(file.menu, "ACPilot4"), runData.ACPilot4 )
    InventorySlot_Display( Hud_GetChild(file.menu, "ACTitan1"), runData.ACTitan1 )
    InventorySlot_Display( Hud_GetChild(file.menu, "ACTitan2"), runData.ACTitan2 )
    InventorySlot_Display( Hud_GetChild(file.menu, "ACTitan3"), runData.ACTitan3 )
    InventorySlot_Display( Hud_GetChild(file.menu, "ACTitan4"), runData.ACTitan4 )

    InventorySlot_Display( Hud_GetChild(file.menu, "WeaponPrimary"), runData.WeaponPrimary )
    InventorySlot_Display( Hud_GetChild(file.menu, "WeaponSecondary"), runData.WeaponSecondary )
    InventorySlot_Display( Hud_GetChild(file.menu, "Grenade"), runData.Grenade )

    //Hud_SetText( Hud_GetChild(file.menu, "AC3_TitanHelp"), GetTitanNameFromWeapon(Roguelike_GetTitanLoadouts()[0]) )
    //Hud_SetText( Hud_GetChild(file.menu, "AC4_TitanHelp"), GetTitanNameFromWeapon(Roguelike_GetTitanLoadouts()[1]) )

    bool hasTitanLoadoutPassive = GetTitanLoadoutPassiveData()[0] != "No Passive"
    Hud_SetVisible( Hud_GetChild(file.menu, "TitanPassive"), hasTitanLoadoutPassive )

    for (int i = 1; i < 5; i++)
    {
        int totalEnergyUsed = GetTotalEnergyUsed( i, false )
        int energyAvailable = expect int(runData["ACPilot" + i].energy)
        for (int j = 0; j < MOD_SLOTS && totalEnergyUsed > energyAvailable; j++)
        {
            string modIndex = FormatModIndex(i, false, j)
            RoguelikeMod mod = GetModForIndex(runData[modIndex])

            if (mod.isSwappable)
            {
                printt("SETTING EMPTY")
                runData[modIndex] <- GetModByName("empty").index
            }

            totalEnergyUsed = GetTotalEnergyUsed( i, false )
        }
        totalEnergyUsed = GetTotalEnergyUsed( i, false )

        Hud_SetText(Hud_GetChild(file.menu, format("AC%i_PilotEnergy", i)), format("%i/%i", totalEnergyUsed, runData["ACPilot" + i].energy))

        totalEnergyUsed = GetTotalEnergyUsed( i, true )
        energyAvailable = expect int(runData["ACTitan" + i].energy)

        for (int j = 0; j < MOD_SLOTS && totalEnergyUsed > energyAvailable; j++)
        {
            string modIndex = FormatModIndex(i, true, j)
            RoguelikeMod mod = GetModForIndex(runData[modIndex])

            if (mod.isSwappable)
            {
                printt("SETTING EMPTY")
                runData[modIndex] <- GetModByName("empty").index
            }

            totalEnergyUsed = GetTotalEnergyUsed( i, true )
        }
        totalEnergyUsed = GetTotalEnergyUsed( i, true )

        Hud_SetText(Hud_GetChild(file.menu, format("AC%i_TitanEnergy", i)), format("%i/%i", totalEnergyUsed, runData["ACTitan" + i].energy))
    }

    array<var> modButtons = GetElementsByClassname( file.menu, "ModSlot" )
    foreach (var modSlot in modButtons)
    {
        RemoveHover(modSlot)
        string modIndex = expect string(modSlot.s.data)
        if (runData[modIndex] != "")
        {
            ModSlot_DisplayMod( modSlot, GetModForIndex(runData[modIndex]) )
            int chipIndex = int( modIndex.slice( 2, 3 ) )
            bool isTitanMod = modIndex.find("Titan") != null
            array<RoguelikeMod> slotMods = GetModsForChipSlot( chipIndex, isTitanMod )
            bool notification = false
            foreach (RoguelikeMod newMod in slotMods)
            {
                if (runData.newMods.contains(newMod.uniqueName))
                {
                    notification = true
                    break
                }
            }
            if (notification)
                Hud_SetColor( Hud_GetChild(modSlot, "BG"), 255,128,32, 135 )
            else
                Hud_SetColor( Hud_GetChild(modSlot, "BG"), 0,0,0, 135 )

            AddHover( modSlot, ModSlot_Hover, HOVER_SIMPLE )
        }
    }
    
    Roguelike_GetRunData().memoryHP = GetConVarString("memory_titan_hp")
    Roguelike_GetRunData().memorySettings = GetConVarString("memory_titan_settings")

    string statsConVar = ""

    file.totalPilot = 0
    file.totalTitan = 0
    array<int> stats = [0,0,0,0,0,0]

    for (int chip = 1; chip <= 4; chip++)
    {
        table pilotData = expect table(runData["ACPilot" + chip])
        table titanData = expect table(runData["ACTitan" + chip])

        foreach (table data in [pilotData, titanData])
        {
            AddStatsArrays( stats, ArmorChip_GetStats( data ))
        }
    }

    if (Roguelike_HasMod( "endurance_2" ))
    {
        stats[STAT_ENDURANCE] += 10
    }
    if (Roguelike_HasMod( "armor_2" ))
    {
        stats[STAT_ARMOR] += 10
    }


    for (int i = 0; i < 6; i++)
    {
        int total = stats[i]
        if (i < 3)
            file.totalTitan += total
        else
            file.totalPilot += total
        string statName = STAT_NAMES[i]
        var statPanel = Hud_GetChild( file.menu, statName + "Stat" )
        Hud_SetText( Hud_GetChild(statPanel, "Value"), string( total ) )
    }
    statsConVar = JoinIntArray( stats, " " )

    runData.balanced = file.totalPilot == file.totalTitan
    if (runData.balanced)
    {
        Hud_SetColor(Hud_GetChild( file.menu, "BalanceSymbol" ), 255,122, 244, 255 )
    }
    else
    {
        Hud_SetColor(Hud_GetChild( file.menu, "BalanceSymbol" ), 64, 64, 64, 255 )
    }
    Roguelike_ApplyRunDataToConVars()
    // HACK: should be moved to Roguelike_ApplyRunDataToConVars
    SetConVarString( "player_stats", strip( statsConVar ) )

    if (IsFullyConnected() && GetUIPlayer() && !uiGlobal.isLoading)
    {
        ClientCommand( "RefreshInventory" )
    }
}

bool function Slot_Init( var button, int elemNum )
{
    Hud_SetBarProgress( Hud_GetChild( button, "EnergyBar1" ), 1 )
    Hud_SetBarProgress( Hud_GetChild( button, "EnergyBar2" ), 1 )

    if (!("clickCallback" in button.s))
    {
        Hud_AddEventHandler( Hud_GetChild( button, "Button" ), UIE_CLICK, InventorySlot_Click )
        button.s.clickCallback <- true
    }

    RemoveHover( button )
    array inventory = Roguelike_GetInventory()
    if (elemNum < inventory.len())
    {
        InventorySlot_Display( button, inventory[elemNum] )
        switch (inventory[elemNum].type)
        {
            case "armor_chip":
                AddHover( button, ArmorChip_Hover, HOVER_ARMOR_CHIP )
                break
            case "weapon":
                AddHover( button, Weapon_Hover, HOVER_WEAPON )
                break
            case "grenade":
                AddHover( button, Grenade_Hover, HOVER_WEAPON )
                break
        }
    }
    else
    {
        InventorySlot_Display( button, null )
    }
    return true
}

void function Grenade_Hover( var slot, var panel )
{
    table data = {}
    bool isEquipped = Hud_GetHudName(slot) ==  "Grenade"
    if (isEquipped)
    {
        data = expect table( Roguelike_GetRunData()[Hud_GetHudName(slot)] )
    }
    else
    {
        int elemNum = Grid_GetElemNumForButton( slot )
        data = expect table(Roguelike_GetInventory()[elemNum])
    }

    Hud_EnableKeyBindingIcons( Hud_GetChild( panel, "FooterText") )
    int level = expect int(data.level)
    int price = Roguelike_GetUpgradePrice( data )
    array<string> options = []
    if (level < Roguelike_GetItemMaxLevel( data ))
    {
        options.append( "%[X_BUTTON|MOUSE2]%Upgrade (" + price + "$)" )
    }
    else
    {
        options.append("MAX LEVEL")
    }
    if (!isEquipped)
        options.append("%[X_BUTTON|F]%Dismantle")
    Hud_SetText( Hud_GetChild( panel, "LevelLabel"), format("Level %i/%i", level, Roguelike_GetItemMaxLevel( data )))
    Hud_SetText( Hud_GetChild( panel, "FooterText" ), JoinStringArray( options, " " ) )

    string weaponClassName = expect string(data.weapon)
    int rarity = expect int(data.rarity)

    string description = "Grenade"
    Hud_SetText( Hud_GetChild( panel, "SubTitle" ), FormatDescription( description ) )

    Hud_SetText( Hud_GetChild(panel, "Title"), GetWeaponInfoFileKeyField_GlobalString( weaponClassName, "shortprintname" ))
    string weaponDesc =  GetWeaponInfoFileKeyField_GlobalString( weaponClassName, "description" ) 

    switch (Roguelike_GetWeaponElement( weaponClassName ))
    {
        case RoguelikeElement.fire: 
            weaponDesc += FormatDescription( " Deals <burn>Fire</> damage." )
            break
        case RoguelikeElement.electric: 
            weaponDesc += FormatDescription(" Deals <cyan>Energy</> damage.")
            break
        case RoguelikeElement.physical: 
            weaponDesc += FormatDescription(" Deals <daze>Physical</> damage.")
            break
    }

    weaponDesc += "\n\n"
    string formatting = "+%i%% Damage\n"
    string levelFormatting = "Level %i: -%i%% Cooldown\n\n"
    table<int, string> rarityNames = {
        [ RARITY_COMMON ] = "Common",
        [ RARITY_UNCOMMON ] = "Uncommon",
        [ RARITY_RARE ] = "Rare",
        [ RARITY_EPIC ] = "Epic",
        [ RARITY_LEGENDARY ] = "Legendary"
    }
    table<int, int> values = {
        [ RARITY_UNCOMMON ] = 0,
        [ RARITY_RARE ] = 0,
        [ RARITY_EPIC ] = 15,
        [ RARITY_LEGENDARY ] = 25
    }
    if (rarity in values && values[rarity] != 0)
        weaponDesc += FormatDescription(format(rarityNames[rarity] + ": " + formatting, values[rarity]))
    
    if (level > 0)
        weaponDesc += FormatDescription(format(levelFormatting, level, level * 10))

    if (data.bonusStat != "")
    {
        RoguelikeWeaponPerk statPerk = GetWeaponPerkDataByName( data.bonusStat )
        weaponDesc += format(statPerk.description + "\n", (statPerk.baseValue + statPerk.valuePerLevel * level) * 100)
    }

    if (data.perk1 != "")
    {
        RoguelikeWeaponPerk perk1 = GetWeaponPerkDataByName( data.perk1 )
        weaponDesc += format("%s: %s\n", perk1.name, perk1.description)
    }

    if (file.startDismantleTime != -1.0)
    {
        Hud_SetBarProgress( Hud_GetChild( panel, "FooterBar" ), GraphCapped(Time(), file.startDismantleTime, file.endDismantleTime, 0, 1) )
    }
    else
    {
        Hud_SetBarProgress( Hud_GetChild( panel, "FooterBar" ), 0.0 )
    }

    Hud_SetText( Hud_GetChild(panel, "Description"), weaponDesc )
}

void function Weapon_Hover( var slot, var panel )
{
    table data = {}
    bool isEquipped = StartsWith( Hud_GetHudName(slot), "Weapon" )
    if (isEquipped)
    {
        data = expect table( Roguelike_GetRunData()[Hud_GetHudName(slot)] )
    }
    else
    {
        int elemNum = Grid_GetElemNumForButton( slot )
        data = expect table(Roguelike_GetInventory()[elemNum])
    }

    Hud_EnableKeyBindingIcons( Hud_GetChild( panel, "FooterText") )
    int level = expect int(data.level)
    int price = Roguelike_GetUpgradePrice( data )
    array<string> options = []
    if (level < Roguelike_GetItemMaxLevel( data ))
    {
        options.append( "%[X_BUTTON|MOUSE2]%Upgrade (" + price + "$)" )
    }
    else
    {
        options.append("MAX LEVEL")
    }
    if (!isEquipped)
        options.append("%[X_BUTTON|F]%Dismantle")
    Hud_SetText( Hud_GetChild( panel, "LevelLabel"), format("Level %i/%i", level, Roguelike_GetItemMaxLevel( data )))
    Hud_SetText( Hud_GetChild( panel, "FooterText" ), JoinStringArray( options, " " ) )

    string weaponClassName = expect string(data.weapon)

    string description = "Primary Weapon"
    string slot = RoguelikeWeapon_GetSlot( weaponClassName )
    switch (slot)
    {
        case "special":
            description = "<green>Movement Tool"
            break
        case "secondary":
            description = "Secondary Weapon"
            break
    }
    Hud_SetText( Hud_GetChild( panel, "SubTitle" ), FormatDescription( description ) )

    Hud_SetText( Hud_GetChild(panel, "Title"), GetWeaponInfoFileKeyField_GlobalString( weaponClassName, "shortprintname" ))
    string weaponDesc =  GetWeaponInfoFileKeyField_GlobalString( weaponClassName, "description" ) 

    switch (Roguelike_GetWeaponElement( weaponClassName ))
    {
        case RoguelikeElement.fire: 
            weaponDesc += FormatDescription( " Deals <burn>Fire</> damage." )
            break
        case RoguelikeElement.electric: 
            weaponDesc += FormatDescription(" Deals <cyan>Energy</> damage.")
            break
        case RoguelikeElement.physical: 
            weaponDesc += FormatDescription(" Deals <daze>Physical</> damage.")
            break
    }

    weaponDesc += "\n\n"


    string formatting = "+%i%% Non-Titan Damage\n"
    string levelFormatting = "Level %i: +%i%% Non-Titan Damage"

    table<int, int> values = {
        [ RARITY_UNCOMMON ] = 0,
        [ RARITY_RARE ] = 0,
        [ RARITY_EPIC ] = 15,
        [ RARITY_LEGENDARY ] = 25
    }
    int valuePerLevel = 15
    table<int, string> rarityNames = {
        [ RARITY_COMMON ] = "Common",
        [ RARITY_UNCOMMON ] = "Uncommon",
        [ RARITY_RARE ] = "Rare",
        [ RARITY_EPIC ] = "Epic",
        [ RARITY_LEGENDARY ] = "Legendary"
    }

    if (slot == "special")
    {
        formatting = "+%i%% Explosion Force\n"
        levelFormatting = "Level %i: +%i%% Explosion Force"
        values = {
            [ RARITY_UNCOMMON ] = 25,
            [ RARITY_RARE ] = 40,
            [ RARITY_EPIC ] = 55,
            [ RARITY_LEGENDARY ] = 70
        }
        valuePerLevel = 25

        int damage = GetWeaponInfoFileKeyField_GlobalInt( weaponClassName, "explosion_damage" )
        float selfDMGMult = Roguelike_GetPilotSelfDamageMult(Roguelike_GetStat( STAT_ENDURANCE ))
        weaponDesc += "Explosion Damage: " + damage
        if (weaponClassName == "mp_weapon_shotgun" || weaponClassName == "mp_weapon_mastiff")
            weaponDesc += "x8"

        weaponDesc += " (" + (damage * selfDMGMult) + " Self Damage)" + "\n\n"
    }

    if (data.bonusStat != "")
    {
        RoguelikeWeaponPerk statPerk = GetWeaponPerkDataByName( data.bonusStat )
        weaponDesc += format(statPerk.description + "\n\n", (statPerk.baseValue + statPerk.valuePerLevel * level) * 100)
    }

    if (data.perkInherited != "")
    {
        RoguelikeWeaponPerk perk1 = GetWeaponPerkDataByName( data.perkInherited )
        weaponDesc += FormatDescription( format("<daze>%s</>: %s\n\n", perk1.name, perk1.description) )
    }

    if (data.perk1 != "")
    {
        RoguelikeWeaponPerk perk1 = GetWeaponPerkDataByName( data.perk1 )
        weaponDesc += FormatDescription( format("<daze>%s</>: %s\n\n", perk1.name, perk1.description) )
    }

    int rarity = expect int(data.rarity)

    if (rarity in values && values[rarity] != 0)
        weaponDesc += FormatDescription(format(rarityNames[rarity] + ": " + formatting, values[rarity]))

    if (level > 0)
    {
        weaponDesc += FormatDescription(format(levelFormatting + "\n\n", level, valuePerLevel * level))
    }

    if (file.startDismantleTime != -1.0)
    {
        Hud_SetBarProgress( Hud_GetChild( panel, "FooterBar" ), GraphCapped(Time(), file.startDismantleTime, file.endDismantleTime, 0, 1) )
    }
    else
    {
        Hud_SetBarProgress( Hud_GetChild( panel, "FooterBar" ), 0.0 )
    }

    Hud_SetText( Hud_GetChild(panel, "Description"), weaponDesc )
}

void function InventorySlot_Click( var button )
{
    var slot = Hud_GetParent( button )
    table runData = Roguelike_GetRunData()
    array inventory = expect array(runData.inventory)
    int elemNum = Grid_GetElemNumForButton( slot )
    if (elemNum >= inventory.len())
        return
    table curSlot = expect table(inventory[elemNum])

    switch (curSlot.type)
    {
        case "armor_chip":
            bool isTitan = expect bool( curSlot.isTitan )
            string titanOrPilotString = GetTitanOrPilotFromBool( isTitan )
            int chipSlot = expect int( curSlot.slot )
            table equippedChip = expect table(runData["AC" + titanOrPilotString + chipSlot])
            runData["AC" + titanOrPilotString + chipSlot] = curSlot
            inventory[elemNum] = equippedChip
            EmitUISound( "menu_loadout_ordinance_select" )
            SwapSequence(slot)
            SwapSequenceAlt(Hud_GetChild(file.menu, "AC" + titanOrPilotString + chipSlot))

            var equippedChipPanel = Hud_GetChild(file.menu, "AC" + titanOrPilotString + chipSlot)

            RefreshInventory()
            break
        case "weapon":
            string weaponClassName = expect string(curSlot.weapon)
            string weaponSlot = RoguelikeWeapon_GetSlot( weaponClassName )
            switch (weaponSlot)
            {
                case "primary":
                    table equippedChip = expect table(runData["WeaponPrimary"])
                    runData["WeaponPrimary"] = curSlot
                    inventory[elemNum] = equippedChip
                    EmitUISound( "menu_loadout_ordinance_select" )
                    SwapSequence(slot)
                    SwapSequenceAlt(Hud_GetChild(file.menu, "WeaponPrimary"))
                    break
                case "secondary":
                case "special":
                    table equippedChip = expect table(runData["WeaponSecondary"])
                    runData["WeaponSecondary"] = curSlot
                    inventory[elemNum] = equippedChip
                    EmitUISound( "menu_loadout_ordinance_select" )
                    SwapSequence(slot)
                    SwapSequenceAlt(Hud_GetChild(file.menu, "WeaponSecondary"))
                    break
            }
            RefreshInventory()
            break
        case "grenade":
            string weaponClassName = expect string(curSlot.weapon)

            table equippedChip = expect table(runData["Grenade"])
            runData["Grenade"] = curSlot
            inventory[elemNum] = equippedChip
            EmitUISound( "menu_loadout_ordinance_select" )
            SwapSequence(slot)
            SwapSequenceAlt(Hud_GetChild(file.menu, "Grenade"))
            
            RefreshInventory()
            break

    }
}

void function SwapSequence( var slot )
{
    thread Sequence( 0.333, void function ( float t ) : (slot)
    {
        var swapEffect = Hud_GetChild(slot, "SwapEffect")
        var swapEffect2 = Hud_GetChild(slot, "SwapEffect2")

        Hud_SetVisible(swapEffect, true)
        Hud_SetVisible(swapEffect2, true)

        int scaled48 = ContentScaledYAsInt(40)
        if (t <= 0.5)
        {
            float width = GraphCapped( t, 0.0, 0.5, 0, scaled48)
            Hud_SetY( swapEffect, 0 )
            Hud_SetY( swapEffect2, ContentScaledYAsInt(80) - width )
            Hud_SetHeight( swapEffect, width )
            Hud_SetHeight( swapEffect2, width )
        }
        else
        {
            float width = GraphCapped( t, 0.5, 1.0, scaled48, 0)
            width = ceil(width)
            Hud_SetY( swapEffect, scaled48 - width )
            Hud_SetY( swapEffect2, scaled48 )
            Hud_SetHeight( swapEffect, width )
            Hud_SetHeight( swapEffect2, width )
        }

        if (t == 1.0)
        {
            Hud_SetVisible(swapEffect, false)
            Hud_SetVisible(swapEffect2, false)
        }
    })
}

void function SwapSequenceAlt( var slot )
{
    thread Sequence( 0.333, void function ( float t ) : (slot)
    {
        var swapEffect = Hud_GetChild(slot, "SwapEffect")
        var swapEffect2 = Hud_GetChild(slot, "SwapEffect2")

        Hud_SetVisible(swapEffect, true)
        Hud_SetVisible(swapEffect2, true)

        int scaled48 = ContentScaledYAsInt(40)
        if (t <= 0.5)
        {
            float width = GraphCapped( t, 0, 0.5, 0, scaled48)
            width = ceil(width)
            Hud_SetY( swapEffect, scaled48 - width )
            Hud_SetY( swapEffect2, scaled48 )
            Hud_SetHeight( swapEffect, width )
            Hud_SetHeight( swapEffect2, width )
        }
        else
        {
            float width = GraphCapped( t, 0.5, 1.0, scaled48, 0)
            Hud_SetY( swapEffect, 0 )
            Hud_SetY( swapEffect2, ContentScaledYAsInt(80) - width )
            Hud_SetHeight( swapEffect, width )
            Hud_SetHeight( swapEffect2, width )
        }
        if (t == 1.0)
        {
            Hud_SetVisible(swapEffect, false)
            Hud_SetVisible(swapEffect2, false)
        }
    })
}

string function GetTitanRole(string weapon)
{
    switch (weapon)
    {
        case "mp_titanweapon_xo16_shorty":
            return "SUPPORT / CD REDUCTION"

        case "mp_titanweapon_sticky_40mm":
            return "Tone"

        case "mp_titanweapon_meteor": // scorch
            return "SUPPORT / DAMAGE"

        case "mp_titanweapon_rocketeer_rocketstream":
            return "Brute"

        case "mp_titanweapon_particle_accelerator":
            return "BURST / SUSTAIN"

        case "mp_titanweapon_leadwall": // ronin
            return "BURST / CQB"

        case "mp_titanweapon_sniper":
            return "BURST / LONG RANGE"

        case "mp_titanweapon_predator_cannon":
            return "SUSTAIN / ANY RANGE"
    }
    return "INVALID"
}

string function GetTitanDescription(string weapon)
{
    switch (weapon)
    {
        case "mp_titanweapon_xo16_shorty":
            return "<note>Ol' Reliable... with a twist.</>\n \nExpedition's E-Smoke is replaced with <daze>Rearm</>." +
                "\n<daze>Rearm</> <cyan>resets all cooldowns<note> (except itself) <cyan>for both loadouts</>.\n \n" +
                "Expedition's status effect is <weak>Weak</>.\n" +
                "<weak>Weak</> is applied with <daze>Expedition's missiles</>.\n" +
                "<weak>Weak</> reduces outgoing damage by 25%, and increases <cyan>incoming weapon<note>*<cyan> damage</> by 35%.\n" +
                "<note>* Weapon = Primaries and Melee"

        case "mp_titanweapon_sticky_40mm":
            return "Tone"

        case "mp_titanweapon_meteor": // scorch
            return "<note>Set the world ablaze.</>\n\nScorch's status effect is <burn>Burn</>." +
                "\n<burn>Burn</> is inflicted by using <daze>anything in Scorch's kit</>,\n" +
                "and increases <cyan>all non-fire damage by up to 50%</>.\n\n"

        case "mp_titanweapon_rocketeer_rocketstream":
            return "Brute"

        case "mp_titanweapon_particle_accelerator":
            return "<note>We're all connected. Except me and the enemy team.</>\n\n" +
                   "Ion's status effect is <charge>Charge</>.\n" +
                   "Charge is inflicted by Ion's <daze>Pylons</> or <daze>primary</>.\n\n" +
                   "When <charge>Charge</> is at max, damage with <cyan>Laser Shot</>, <cyan>Pylons</>, or <cyan>Laser Core</> " +
                   "will trigger a <charge>Discharge</>, dealing massive damage.\n" +
                   "If <daze>the other loadout</> also inflicted it's status effect, <red>Disorder</> will be triggered instead, removing the effect and <cyan>increasing damage further</>."

        case "mp_titanweapon_leadwall": // ronin
            return "<note>No need for a shield if you've got a giant sword...</>\n \nRonin's status effect is <daze>Daze</>." +
                "\n\n<daze>Daze</> is inflicted with <cyan>Arc Wave</>.\n" +
                "<cyan>Sword hits</> consume <daze>Daze</> to grant <overload>Overload</> stacks.\n" +
                "\n<overload>Overload</> stacks are consumed when you <daze>fire your shotgun</> for a <red>high base damage increase</>."

        case "mp_titanweapon_sniper":
            return "<note>Yeah i got railgunned. Railgunned by ur mom!!!1!</>\n\n" +
                   "Northstar's Railgun does <red>not</> crit randomly, but instead <cyan>crits when hitting the enemy's weak spot</>.\n\n" +
                   "Northstar's status effect is <fulm>Fulminate</>.\n\n" +
                   "<fulm>Fulminate</> is dealt with any source of damage, and <cyan>increases the Crit DMG of your next Railgun crit by up to 45%</>."

        case "mp_titanweapon_predator_cannon":
            return "<note>The answer... is a gun. And if that don't work? Use more gun.</>\n \n" +
            "Legion's status effect is <punc>Puncture</>.\n\n" +
            "<punc>Puncture</> is inflicted with <daze>Power Shot</>.\n"+
            "While a target is <punc>Punctured</>, <cyan>Crit Rate</> against it is increased by 25%."
    }
    return "INVALID"
}

void function ModHelp_Hover( var label, var panel )
{
    string hudName = Hud_GetHudName(label)
    table runData = Roguelike_GetRunData()


    string title = "MISSING TITLE"
    string description = "MISSING DESCRIPTION"
    switch (hudName)
    {
        case "AC1_PilotHelp":
            title = "Survival Mods"
            description = "These mods focus on improving your survivability as a pilot."
            break
        case "AC2_PilotHelp":
            title = "Utility Mods"
            description = "These mods focus on improving your pilot overall."
            break
        case "AC3_PilotHelp":
            title = "Weapon Mods"
            description = "These mods focus on improving your weaponry."
            break
        case "AC4_PilotHelp":
            title = "Ability Mods"
            description = "These mods focus on improving your abilities."
            break
        case "AC1_TitanHelp":
            title = "Survival Mods"
            description = "These mods focus on improving your survivability as a titan."
            break
        case "AC2_TitanHelp":
            title = "Utility Mods"
            description = "These mods focus on improving your titan overall."
            break
        case "AC3_TitanHelp":
            title = "Core and Weapon Mods"
            description = "These mods focus on improving your core and weapon."
            break
        case "AC4_TitanHelp":
            title = "Ability Mods"
            description = "These mods focus on improving your abilities."
            break
        case "TitanPassive":
            array<string> passiveData = GetTitanLoadoutPassiveData()
            title = passiveData[0]
            description = passiveData[1]
    }

    Hud_SetText( Hud_GetChild(panel, "Title"), title)
    Hud_SetText( Hud_GetChild(panel, "Description"), FormatDescription(description) )
}

void function OpenInventoryMenu()
{
	AdvanceMenu( file.menu )
}

void function ModSlot_Hover( var slot, var panel )
{
    string modIndex = expect string(slot.s.data)
    table runData = Roguelike_GetRunData()

    RoguelikeMod mod = GetModForIndex(runData[modIndex])

    Hud_SetText( Hud_GetChild(panel, "Title"), mod.name)
    Hud_SetText( Hud_GetChild(panel, "Description"), format("Energy Cost: ^FF800000%i^FFFFFFFF\n\n%s", mod.cost, FormatDescription(mod.description)) )
}

// utility to allow using <color> tags instead of memorizing ^ABCDEF12 sequences
string function FormatDescription(string desc)
{
    string result = desc
    result = StringReplace( result, "</>",     "^FFFFFFFF", true )
    result = StringReplace( result, "<cyan>",  "^20D0FF00", true )
    result = StringReplace( result, "<charge>",  "^40FFFF00", true )
    result = StringReplace( result, "<daze>",  "^FFE16400", true )
    result = StringReplace( result, "<overload>",  "^0080FF00", true )
    result = StringReplace( result, "<warn>",  "^FFA00000", true )
    result = StringReplace( result, "<note>",  "^88888800", true )
    result = StringReplace( result, "<fulm>",  "^4060FF00", true )
    result = StringReplace( result, "<burn>",  "^FF891200", true )
    result = StringReplace( result, "<green>", "^60FF6000", true )
    result = StringReplace( result, "<red>",   "^FF404000", true )
    result = StringReplace( result, "<weak>",  "^B15EFF00", true )
    result = StringReplace( result, "<magic>", "^FF7AF400", true )
    result = StringReplace( result, "<punc>", "^FF404000", true )

    return result
}

void function ModSlot_Click( var button )
{
    var slot = Hud_GetParent( button )

    ModSelect_SetContext( expect string( slot.s.data ), Hud_GetAbsX( slot ), Hud_GetAbsY( slot ) )

    OpenSubmenu( GetMenu("ModSelect"), false )
}

void function AttemptUpgrade( var env )
{
    if (uiGlobal.activeMenu != file.menu)
        return

    var slot = GetCurrentHoverTarget()
    if (slot == null)
        return

    table data = {}
    if (Hud_GetHudName(slot) == "Grenade" || StartsWith( Hud_GetHudName(slot), "AC" ) || StartsWith( Hud_GetHudName(slot), "Weapon" ))
    {
        data = expect table( Roguelike_GetRunData()[Hud_GetHudName(slot)] )
    }
    else
    {
        try
        {

        int elemNum = Grid_GetElemNumForButton( slot )
        data = expect table(Roguelike_GetInventory()[elemNum])
        }
        catch (e)
        {
            return
        }
    }

    int price = Roguelike_GetUpgradePrice( data )
    if (data.level >= Roguelike_GetItemMaxLevel( data ) || (Roguelike_GetMoney() < price && !GetConVarBool("roguelike_unlock_all")))
    {
        EmitUISound( "HUD_MP_BountyHunt_BankBonusPts_Deposit_End_Unsuccessful_1P" )
        return
    }

    EmitUISound( "HUD_MP_BountyHunt_BankBonusPts_Deposit_End_Successful_1P" )
    Roguelike_TakeMoney( price )

    data.level += 1
    data.moneyInvested += price

    switch (data.type)
    {
        case "armor_chip":
            data.energy += 1
            if (data.subStats.len() > 0)
                data.boosts.append(RandomInt(data.subStats.len()))
            break
        case "weapon":
            break
    }

    RefreshInventory()
}

float lastDiffSetTime = -99.9
void function ArmorChip_Hover( var slot, var panel )
{
    table data = {}
    bool isEquipped = StartsWith( Hud_GetHudName(slot), "AC" )
    if (isEquipped)
    {
        data = expect table( Roguelike_GetRunData()[Hud_GetHudName(slot)] )
    }
    else
    {
        int elemNum = Grid_GetElemNumForButton( slot )
        data = expect table(Roguelike_GetInventory()[elemNum])
    }

    Hud_EnableKeyBindingIcons( Hud_GetChild( panel, "FooterText") )
    bool isTitan = expect bool(data.isTitan)
    int slot = expect int( data.slot )
    int level = expect int(data.level)
    int rarity = expect int(data.rarity)
    int price = Roguelike_GetUpgradePrice( data )

    table equippedChip = expect table( Roguelike_GetRunData()["AC" + GetTitanOrPilotFromBool(isTitan) + slot ] )

    array<string> options = []
    if (level < Roguelike_GetItemMaxLevel( data ))
    {
        options.append( "%[X_BUTTON|MOUSE2]%Upgrade (" + price + "$)" )
    }
    else
    {
        options.append("MAX LEVEL")
    }
    if (!isEquipped)
        options.append("%[X_BUTTON|F]%Dismantle")
    Hud_SetText( Hud_GetChild( panel, "FooterText" ), JoinStringArray( options, " " ) )

    Hud_SetText( Hud_GetChild( panel, "Title" ), isTitan ? "TITAN CHIP" : "PILOT CHIP")

    var titleStrip = Hud_GetChild(panel, "TitleStrip")
    var title = Hud_GetChild(panel, "Title")
    var bg = Hud_GetChild(panel, "BG")
    var levelBar = Hud_GetChild(panel, "EnergyBar1")
    var barBG = Hud_GetChild(panel, "EnergyBarBG")
    var energyLabel = Hud_GetChild(panel, "EnergyCount")

    Hud_SetColor( energyLabel, 25, 25, 25, 255 )
    Hud_SetText( energyLabel, format("Level %i/%i", data.level, Roguelike_GetItemMaxLevel( data )) )

    Hud_SetBarProgress( barBG, 1.0 )
    Hud_SetX( levelBar, 0 )


    int segmentCount = 8
    int length = Hud_GetWidth( levelBar )
    int gap = segmentCount - length % segmentCount
    if (segmentCount - length % segmentCount < 1)
        gap = (segmentCount - length % segmentCount) + segmentCount

    int segmentWidth = (length + gap) / segmentCount - gap

    Hud_SetBarSegmentInfo( levelBar, gap, segmentWidth )
    Hud_SetBarSegmentInfo( barBG, gap, segmentWidth )

    int totalEnergy = expect int(data.energy)
    Hud_SetBarProgress( levelBar, float(totalEnergy) / 8.0 - 0.0001 )
    Hud_SetColor( levelBar, 25, 25, 25, 255 )
    Hud_SetColor( title, 25, 25, 25, 255 )
    Hud_SetColor( titleStrip, 40, 40, 40, 255 )
    Hud_SetColor( bg, 25, 25, 25, 255 )


    Hud_SetColor( title, 25, 25, 25, 255 )

    int r = 0, g = 0, b = 0
    switch (slot)
    {
        case 1:
            r = 0
            g = 214
            b = 255
            break
        case 2:
            r = 165
            g = 255
            b = 0
            break
        case 3:
            r = 197
            g = 0
            b = 255
            // note, this  slightly breaks the square pallette in favor of accessibility
            break
        case 4:
            r = 255
            g = 117
            b = 0
            break
    }

    int mainStat = expect int(data.mainStat)
    int statNameIndex = mainStat
    string stat = STAT_NAMES[statNameIndex]
    var statPanel = Hud_GetChild(panel, "Stat0")
    int value = CHIP_MAIN_STAT_MULT
    value *= expect int(data.energy)

    var bar = Hud_GetChild(statPanel, "Bar")
    var label = Hud_GetChild(statPanel, "Label")
    var valueText = Hud_GetChild(statPanel, "Value")
    Hud_SetColor( title, r, g, b, 255 )
    Hud_SetColor( levelBar, r, g, b, 255 )

    Hud_SetColor(bar, r, g, b, 255)
    Hud_SetColor(label, r, g, b, 255)
    Hud_SetColor(valueText, r, g, b, 255)

    Hud_SetBarProgress(bar, value / 72.0)
    Hud_SetText(label, stat)
    Hud_SetText(valueText, "+" + value)

    string text = ""
    foreach (int i, int subStat in data.subStats)
    {
        int count = 1
        if (data.rarity == RARITY_EPIC)
            count = 2
        if (data.rarity == RARITY_LEGENDARY)
            count = 3
        foreach (int boost in data.boosts)
        {
            if (boost == i)
                count++
        }
        text += "<chip>" + STAT_NAMES[subStat] + "</> +" + (count * CHIP_SUB_STAT_MULT) + "\n"
    }
    text = FormatDescription( text )
    text = StringReplace( text, "<chip>", format("^%02X%02X%02X00", r, g, b), true )
    //print(text)
    Hud_SetText(Hud_GetChild(panel, "SubStats"), text)


    if (data != equippedChip)
    {
        for (int i = 0; i < 6; i++)
        {
            string statName = STAT_NAMES[i]
            var statPanel = Hud_GetChild( file.menu, statName + "Stat" )
            int diff = ArmorChip_GetStats(data)[i] - ArmorChip_GetStats( equippedChip )[i]

            Hud_SetText(Hud_GetChild( statPanel, "Diff"), diff > 0 ? "+" + diff : string(diff))
            if (diff > 0)
            {
            Hud_SetColor(Hud_GetChild( statPanel, "Diff"), 0, 255,0, 255)
            }
            else if (diff == 0)
            {
            Hud_SetColor(Hud_GetChild( statPanel, "Diff"), 128, 128,128, 255)
            }
            else
            {
            Hud_SetColor(Hud_GetChild( statPanel, "Diff"), 255, 0,0, 255)
            }
        }
        if (panel.GetPanelAlpha() > 0.0)
            lastDiffSetTime = Time()
    }

    if (file.startDismantleTime != -1.0)
    {
        Hud_SetBarProgress( Hud_GetChild( panel, "FooterBar" ), GraphCapped(Time(), file.startDismantleTime, file.endDismantleTime, 0, 1) )
    }
    else
    {
        Hud_SetBarProgress( Hud_GetChild( panel, "FooterBar" ), 0.0 )
    }
}

void function UpdateMenuState()
{
	for ( ;; )
	{
		WaitSignal( uiGlobal.signalDummy, "ActiveMenuChanged" )

		if ( IsFullyConnected() )
		{
			int newState = 0
			if ( IsDialogOnlyActiveMenu() )
				newState = 2
			else if ( uiGlobal.activeMenu != null)
				newState = 1

			RunClientScript( "Healthbars_SetMenuState", newState )
		}
	}
}

void function UpdateInventory()
{
	for ( ;; )
	{
		WaitSignal( uiGlobal.signalDummy, "LevelStartedLoading" )

        if (!Roguelike_IsRunActive())
        {
            Roguelike_StartNewRun()
        }

        RefreshInventory()
	}
}

void function Roguelike_ForceRefreshInventory()
{
    RefreshInventory()
}

bool function Roguelike_HasMod( string mod )
{
    int modIndex = GetModByName(mod).index
    return split( GetConVarString("player_mods"), " " ).contains(string(modIndex))
}
int function Roguelike_GetStat( int stat )
{
    return minint(int( split( GetConVarString("player_stats"), " " )[stat] ), STAT_CAP)
}
int function Roguelike_GetStatRaw( int stat )
{
    return int( split( GetConVarString("player_stats"), " " )[stat] )
}
