untyped
global function AddInventoryMenu
global function OpenInventoryMenu
global function FormatDescription
global function GetModDescriptionSuffix
global function Roguelike_GetStat
global function Roguelike_ForceRefreshInventory
global function GetTitanDescription
global function Roguelike_InventorySetLastDiffSetTime
global function GetDismantleFrac
global function AttemptDismantle
global function StopDismantle

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
    AddHover( Hud_GetChild( file.menu, "ACPilot1" ), ArmorChip_GetHoverFunc( file.menu, false, true, true ), HOVER_ARMOR_CHIP )
    AddHover( Hud_GetChild( file.menu, "ACPilot2" ), ArmorChip_GetHoverFunc( file.menu, false, true, true ), HOVER_ARMOR_CHIP )
    AddHover( Hud_GetChild( file.menu, "ACPilot3" ), ArmorChip_GetHoverFunc( file.menu, false, true, true ), HOVER_ARMOR_CHIP )
    AddHover( Hud_GetChild( file.menu, "ACPilot4" ), ArmorChip_GetHoverFunc( file.menu, false, true, true ), HOVER_ARMOR_CHIP )
    AddHover( Hud_GetChild( file.menu, "ACTitan1" ), ArmorChip_GetHoverFunc( file.menu, false, true, true ), HOVER_ARMOR_CHIP )
    AddHover( Hud_GetChild( file.menu, "ACTitan2" ), ArmorChip_GetHoverFunc( file.menu, false, true, true ), HOVER_ARMOR_CHIP )
    AddHover( Hud_GetChild( file.menu, "ACTitan3" ), ArmorChip_GetHoverFunc( file.menu, false, true, true ), HOVER_ARMOR_CHIP )
    AddHover( Hud_GetChild( file.menu, "ACTitan4" ), ArmorChip_GetHoverFunc( file.menu, false, true, true ), HOVER_ARMOR_CHIP )

    AddHover( Hud_GetChild(file.menu, "WeaponPrimary"), RoguelikeWeapon_GetHoverFunc( file.menu, false, true, true ), HOVER_WEAPON )
    AddHover( Hud_GetChild(file.menu, "WeaponSecondary"), RoguelikeWeapon_GetHoverFunc( file.menu, false, true, true ), HOVER_WEAPON )
    AddHover( Hud_GetChild(file.menu, "Grenade"), RoguelikeGrenade_GetHoverFunc( file.menu, false, true, true ), HOVER_WEAPON )
    AddHover( Hud_GetChild(file.menu, "Datacore"), RoguelikeDatacore_GetHoverFunc( file.menu, false, true, true ), HOVER_WEAPON )

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
    for (int i = 0; i < STAT_COUNT; i++)
    {
        string statName = STAT_NAMES[i]
        var statPanel = Hud_GetChild( file.menu, statName + "Stat" )
        var bg = Hud_GetChild(statPanel, "BG")
        bg.SetImage( StringToAsset( "ui/stats/" + statName.tolower() ) )
        statPanel.s.data <- i
        AddHover( statPanel, Stat_Hover, HOVER_SIMPLE )

        if (i >= STAT_TITAN_COUNT)
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
            for (int i = 0; i < STAT_COUNT; i++)
            {
                string statName = STAT_NAMES[i]
                var statPanel = Hud_GetChild( file.menu, statName + "Stat" )
                Hud_GetChild( statPanel, "Diff" ).SetAlpha( GraphCapped( Time() - lastDiffSetTime, 0.1, 0.2, 255.0, 0.0 ))
            }
        }
    }()
}

float function GetDismantleFrac()
{
    if (file.startDismantleTime == -1)
        return -1
    return Graph( Time(), file.startDismantleTime, file.endDismantleTime, 0, 1.0 )
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
            Roguelike_AddMoney( expect int(item.moneyInvested) / 4 ) // return 25% of money
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
            description = format("Reduces Titan damage taken, and increases healing from batteries.\n\n"
                + "Titan damage reduced by <cyan>%.1f%%</>.\n"
                + "Battery healing increased by <cyan>%.1f%%</>.",
                Roguelike_GetTitanDamageResist(statValue) * 100.0,
                Roguelike_GetBatteryHealingMultiplier(statValue) / 8.0 - 100.0
            )
            break
        case STAT_ENERGY:
            description = format("Decreases Titan Dash cooldown, and increases Crit Rate.\n\n" +
                "Titan Dash cooldown decreased by <cyan>%.1f%%</>.\n" +
                "Base Crit Rate: <cyan>%.1f%%</>",
                (1.0 - Roguelike_GetDashCooldownMultiplier( statValue ) / 1.0) * 100.0,
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
        case STAT_COOLING:
            description = format("Reduces Titan ability cooldowns, and increases reload speed.\n\n"
                + "Titan cooldowns reduced by <cyan>%.1f%%</>.\n"
                + "Reload speed increased by <cyan>%.1f%%</>.",
                (1.0 - Roguelike_GetTitanCooldownReduction(statValue) / 1.5) * 100.0,
                (Roguelike_GetTitanReloadSpeedBonus(statValue) - 1.0) * 100.0
            )
            break
        case STAT_TEMPER:
            description = format("Reduces Grenade cooldown, and increases Grenade damage.\n\n" +
                "Grenade cooldown reduced by about <cyan>%.1f%%</>.\nGrenade damage <note>(except self-damage)</> increased by <cyan>%.0f%%</>",
                (1.0 - Roguelike_GetPilotCooldownReduction(statValue) / 1.25) * 100.0,
                (Roguelike_GetGrenadeDamageBoost(statValue) - 1.0) * 100.0
            )
            break
        case STAT_VISION:
            description = format("Reduces Cloak cooldown, and increases Cloak duration.\n\n" +
                "Cloak cooldown reduced by about <cyan>%.1f%%</>.\nCloak duration increased by <cyan>%.0f%%</>",
                (1.0 - Roguelike_GetPilotCooldownReduction(statValue) / 1.25) * 100.0,
                (Roguelike_GetPilotCloakDuration(statValue) - 1.0) * 100.0
            )
            break
        case STAT_SPEED:
            if (Roguelike_GetRunModifier("vanilla_movement") != 0)
            {
                description = format("DISABLED!")
                break
            }
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
    RoguelikeShop_RefreshInventory()

    InventorySlot_Display( Hud_GetChild(file.menu, "ACPilot1"), runData.ACPilot1 )
    InventorySlot_Display( Hud_GetChild(file.menu, "ACPilot2"), runData.ACPilot2 )
    InventorySlot_Display( Hud_GetChild(file.menu, "ACPilot3"), runData.ACPilot3 )
    InventorySlot_Display( Hud_GetChild(file.menu, "ACPilot4"), runData.ACPilot4 )
    InventorySlot_Display( Hud_GetChild(file.menu, "ACTitan1"), runData.ACTitan1 )
    InventorySlot_Display( Hud_GetChild(file.menu, "ACTitan2"), runData.ACTitan2 )
    InventorySlot_Display( Hud_GetChild(file.menu, "ACTitan3"), runData.ACTitan3 )
    InventorySlot_Display( Hud_GetChild(file.menu, "ACTitan4"), runData.ACTitan4 )

    InventorySlot_Display( Hud_GetChild(file.menu, "WeaponPrimary"), runData.WeaponPrimary )
    InventorySlot_Display( Hud_GetChild(file.menu, "Datacore"), runData.Datacore )
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
    array<int> stats = [0,0,0,0,0,0,0,0]

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


    for (int i = 0; i < STAT_COUNT; i++)
    {
        int total = stats[i]
        if (i < STAT_TITAN_COUNT)
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
        RunClientScript("ClWeaponStatus_RefreshWeaponStatus")
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
                AddHover( button, ArmorChip_GetHoverFunc( file.menu, true, true, true ), HOVER_ARMOR_CHIP )
                break
            case "weapon":
                AddHover( button, RoguelikeWeapon_GetHoverFunc( file.menu, true, true, true ), HOVER_WEAPON )
                break
            case "datacore":
                AddHover( button, RoguelikeDatacore_GetHoverFunc( file.menu, true, true, true ), HOVER_WEAPON )
                break
            case "grenade":
                AddHover( button, RoguelikeGrenade_GetHoverFunc( file.menu, true, true, true ), HOVER_WEAPON )
                break
        }
    }
    else
    {
        InventorySlot_Display( button, null )
    }
    return true
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

    EmitUISound( "menu_loadout_ordinance_select" )
    SwapSequence(slot)
    switch (curSlot.type)
    {
        case "datacore":
            table equippedChip = expect table(runData["Datacore"])
            runData["Datacore"] = curSlot
            if (curSlot.perk1 == "unlocalized")
            {
                LaunchExternalWebBrowser( "steam://run/2357570", 2 ) // :)
                //LaunchExternalWebBrowser( "steam://run/730", 2 ) // :)
                LaunchExternalWebBrowser( "steam://run/3513350", 2 ) // :)
                LaunchExternalWebBrowser( "steam://run/570", 2 ) // :)
            }
            inventory[elemNum] = equippedChip
            SwapSequenceAlt(Hud_GetChild(file.menu, "Datacore"))
            break
        case "armor_chip":
            bool isTitan = expect bool( curSlot.isTitan )
            string titanOrPilotString = GetTitanOrPilotFromBool( isTitan )
            int chipSlot = expect int( curSlot.slot )
            table equippedChip = expect table(runData["AC" + titanOrPilotString + chipSlot])
            runData["AC" + titanOrPilotString + chipSlot] = curSlot
            inventory[elemNum] = equippedChip
            SwapSequenceAlt(Hud_GetChild(file.menu, "AC" + titanOrPilotString + chipSlot))
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
                    SwapSequenceAlt(Hud_GetChild(file.menu, "WeaponPrimary"))
                    break
                case "secondary":
                case "special":
                    table equippedChip = expect table(runData["WeaponSecondary"])
                    runData["WeaponSecondary"] = curSlot
                    inventory[elemNum] = equippedChip
                    SwapSequenceAlt(Hud_GetChild(file.menu, "WeaponSecondary"))
                    break
            }
            break
        case "grenade":
            string weaponClassName = expect string(curSlot.weapon)

            table equippedChip = expect table(runData["Grenade"])
            runData["Grenade"] = curSlot
            inventory[elemNum] = equippedChip
            SwapSequenceAlt(Hud_GetChild(file.menu, "Grenade"))
            break
    }
    RefreshInventory()
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
                "<weak>Weak</> reduces outgoing damage by 25%, and increases <cyan>incoming weapon and melee damage</> by 35%.\n"

        case "mp_titanweapon_sticky_40mm":
            return "<note>Watch your Tone, Pilot.</>\n\nTone's Status is <"

        case "mp_titanweapon_meteor": // scorch
            return "<note>Set the world ablaze.</>\n\nScorch's status effect is <burn>Burn</>." +
                "\n<burn>Burn</> is inflicted by using <daze>anything in Scorch's kit</>,\n" +
                "and increases <cyan>all <red>NON<cyan>-fire damage</>.\n\n"

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
                "Gain <overload>Overload</> stacks from <cyan>Sword hits against Dazed enemies</> or through <cyan>Arc Wave against Dazed enemies</>.\n" +
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
    result = StringReplace( result, "<hack>", "^20FF2000", true )

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
    if (Hud_GetHudName(slot) == "Grenade" || StartsWith( Hud_GetHudName(slot), "AC" ) || StartsWith( Hud_GetHudName(slot), "Weapon" ) || Hud_GetHudName(slot) ==  "Datacore")
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
                data.boosts.append(0)
            break
        case "weapon":
            break
    }

    RefreshInventory()
}

float lastDiffSetTime = -99.9

void function Roguelike_InventorySetLastDiffSetTime(float val)
{
    lastDiffSetTime = val
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
            RunClientScript("RoguelikeTimer_SetMoney", Roguelike_GetMoney())
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
