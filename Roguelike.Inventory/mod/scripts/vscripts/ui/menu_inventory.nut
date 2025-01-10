untyped
global function AddInventoryMenu
global function OpenInventoryMenu
global function FormatDescription
global function GetModDescriptionSuffix
global function Roguelike_GetStat
global function Roguelike_ForceRefreshInventory

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
    AddHover( Hud_GetChild( file.menu, "AC1" ), ArmorChip_Hover, HOVER_ARMOR_CHIP )
    AddHover( Hud_GetChild( file.menu, "AC2" ), ArmorChip_Hover, HOVER_ARMOR_CHIP )
    AddHover( Hud_GetChild( file.menu, "AC3" ), ArmorChip_Hover, HOVER_ARMOR_CHIP )
    AddHover( Hud_GetChild( file.menu, "AC4" ), ArmorChip_Hover, HOVER_ARMOR_CHIP )

    AddHover( Hud_GetChild(file.menu, "WeaponPrimary"), Weapon_Hover, HOVER_WEAPON )
    AddHover( Hud_GetChild(file.menu, "WeaponSecondary"), Weapon_Hover, HOVER_WEAPON )

    AddHover( Hud_GetChild( file.menu, "BalanceSymbol" ), void function( var symbol, var panel ) : (){
        table runData = Roguelike_GetRunData()
        if (runData.balanced)
        {
            Hud_SetColor( Hud_GetChild(panel, "TitleStrip"), 255, 122, 244, 255 )
            Hud_SetColor( Hud_GetChild(panel, "BG"), 204, 98, 195, 255 )
            Hud_SetText( Hud_GetChild(panel, "Title"), FormatDescription("Augment of Balance"))
            Hud_SetText( Hud_GetChild(panel, "Description"), FormatDescription("Your mind is cleared, and you see through the fog.\n\n25% bonus damage to all sources.") )
            return
        }
        else
        {
            Hud_SetText( Hud_GetChild(panel, "Title"), "???")
            bool tooMuchTitan = file.totalTitan > file.totalPilot
            Hud_SetText( Hud_GetChild(panel, "Description"), FormatDescription(format("You lack balance in your perspective...\n\n%i titan | %i pilot", file.totalTitan / 7, file.totalPilot / 7)) )
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
        file.endDismantleTime = Time() + 0.5
        wait 0.5
        
        // DISMANTLE
        int elemNum = Grid_GetElemNumForButton( slot )
        array inventory = Roguelike_GetInventory()
        table item = expect table(inventory[elemNum])
        
        SwapSequence(slot)
        if ("moneyInvested" in item)
            Roguelike_AddMoney( expect int(item.moneyInvested) * 2 / 3 ) // return 66% of money
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
            float gain = 1.0 + Roguelike_GetCoreGainBonus( statValue )
            description = format("Increases Titan Core gain rate and decreases Titan Dash cooldown.\n\n" +
                "Core gain increased by <cyan>%.1f%%</>.\nTitan Dash cooldown decreased by <cyan>%.1f%%</>.",
                (gain / 0.8 - 1.0) * 100.0,
                (1.0 - Roguelike_GetDashCooldownMultiplier( statValue ) / 1.2) * 100.0
            )
            break
        case STAT_POWER:
            description = format("Reduces Titan ability cooldowns.\n\n" +
                "Titan ability cooldowns reduced by about <cyan>%.1f%%</>.",
                (1.0 - Roguelike_GetTitanCooldownReduction(statValue) / 1.2) * 100.0
            )
            break
        case STAT_TEMPER:
            description = format("Reduces Pilot ability cooldowns.\n\n" +
                "Pilot ability cooldowns reduced by about <cyan>%.1f%%</>.",
                (1.0 - Roguelike_GetPilotCooldownReduction(statValue) / 1.2) * 100.0
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
            description = format("Increases Pilot max health.\n\n" +
                "Max health increased by <cyan>%i%%</>.",
                int((multiplier / 0.8 - 1.0) * 100.0)
            )
            break
    }
    if (statValueRaw > 150)
    {
        description += "\n\n<red>Increasing a stat above 150 has no effect.</>"
    }
    Hud_SetText( Hud_GetChild(panel, "Title"), title)
    Hud_SetText( Hud_GetChild(panel, "Description"), FormatDescription(description) )
}

string function GetModDescriptionSuffix( RoguelikeMod mod )
{
    string result = ""
    if (mod.loadouts.len() > 1)
        return "\n\n<warn>Equipping this mod applies it to the ability GLOBALLY, regardless of loadout."

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

    InventorySlot_Display( Hud_GetChild(file.menu, "AC1"), runData.AC1 )
    InventorySlot_Display( Hud_GetChild(file.menu, "AC2"), runData.AC2 )
    InventorySlot_Display( Hud_GetChild(file.menu, "AC3"), runData.AC3 )
    InventorySlot_Display( Hud_GetChild(file.menu, "AC4"), runData.AC4 )

    InventorySlot_Display( Hud_GetChild(file.menu, "WeaponPrimary"), runData.WeaponPrimary )
    InventorySlot_Display( Hud_GetChild(file.menu, "WeaponSecondary"), runData.WeaponSecondary )

    Hud_SetText( Hud_GetChild(file.menu, "AC3_TitanHelp"), GetTitanNameFromWeapon(Roguelike_GetTitanLoadouts()[0]) )
    Hud_SetText( Hud_GetChild(file.menu, "AC4_TitanHelp"), GetTitanNameFromWeapon(Roguelike_GetTitanLoadouts()[1]) )

    bool hasTitanLoadoutPassive = GetTitanLoadoutPassiveData()[0] != "No Passive"
    Hud_SetVisible( Hud_GetChild(file.menu, "TitanPassive"), hasTitanLoadoutPassive )

    for (int i = 1; i < 5; i++)
    {
        int totalEnergyUsed = GetTotalEnergyUsed( i, false )
        if (totalEnergyUsed > expect int(runData["AC" + i].pilotEnergy))
        {
            // remove mods until energy debt is gone
            // may not remove debt completely if mods are not swappable
            // but we dont care since that means the user cant equip 
            // anything regardless
            for (int j = 0; j < MOD_SLOTS; j++)
            {
                string modIndex = FormatModIndex(i, false, j)
                RoguelikeMod mod = GetModForIndex(runData[modIndex])
                
                if (mod.isSwappable)
                {
                    runData[modIndex] <- GetModByName("empty").index
                }
            }
            totalEnergyUsed = 0
        }
        Hud_SetText(Hud_GetChild(file.menu, format("AC%i_PilotEnergy", i)), format("%i/%i", totalEnergyUsed, runData["AC" + i].pilotEnergy))

        totalEnergyUsed = GetTotalEnergyUsed( i, true )
        if (totalEnergyUsed > expect int(runData["AC" + i].titanEnergy))
        {
            // remove mods until energy debt is gone
            // may not remove debt completely if mods are not swappable
            // but we dont care since that means the user cant equip 
            // anything regardless
            for (int j = 0; j < MOD_SLOTS; j++)
            {
                string modIndex = FormatModIndex(i, true, j)
                RoguelikeMod mod = GetModForIndex(runData[modIndex])

                if (mod.isSwappable)
                {
                    runData[modIndex] <- GetModByName("empty").index
                }
            }
            totalEnergyUsed = 0
        }
        Hud_SetText(Hud_GetChild(file.menu, format("AC%i_TitanEnergy", i)), format("%i/%i", totalEnergyUsed, runData["AC" + i].titanEnergy))
    }

    array<var> modButtons = GetElementsByClassname( file.menu, "ModSlot" )
    foreach (var modSlot in modButtons)
    {
        RemoveHover(modSlot)
        string modIndex = expect string(modSlot.s.data)
        if (runData[modIndex] != "")
        {
            ModSlot_DisplayMod( modSlot, GetModForIndex(runData[modIndex]) )
            AddHover( modSlot, ModSlot_Hover, HOVER_SIMPLE )
        }
    }

    string statsConVar = ""

    file.totalPilot = 0
    file.totalTitan = 0
    for (int i = 0; i < 6; i++)
    {
        bool isPilot = i >= 3
        int total = 0
        string statName = STAT_NAMES[i]
        
        for (int chip = 1; chip <= 4; chip++)
        {
            table data = expect table(runData["AC" + chip])

            int value = expect int(data.stats[i])
            if (i < 3)
                total += value * expect int(data.titanEnergy)
            else
                total += value * expect int(data.pilotEnergy)
        }

        if (isPilot)
            file.totalPilot += total
        else
            file.totalTitan += total

        var statPanel = Hud_GetChild( file.menu, statName + "Stat" )
        Hud_SetText( Hud_GetChild(statPanel, "Value"), string( total ) )
        statsConVar += total + " "
    }
    runData.balanced = file.totalPilot == file.totalTitan
    if (runData.balanced)
    { 
        Hud_SetColor(Hud_GetChild( file.menu, "BalanceSymbol" ), 255,122, 244, 255 )
    }
    else
    {
        Hud_SetColor(Hud_GetChild( file.menu, "BalanceSymbol" ), 64, 64, 64, 255 )
    }
    // HACK: should be moved to Roguelike_ApplyRunDataToConVars
    SetConVarString( "player_stats", strip( statsConVar ) )

    Roguelike_ApplyRunDataToConVars()

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
        }
    }
    else
    {
        InventorySlot_Display( button, null )
    }
    return true
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
            description = "<green>Special Weapon"
            break
        case "secondary":
            description = "Secondary Weapon"
            break
    }
    Hud_SetText( Hud_GetChild( panel, "SubTitle" ), FormatDescription( description ) )

    Hud_SetText( Hud_GetChild(panel, "Title"), GetWeaponInfoFileKeyField_GlobalString( weaponClassName, "shortprintname" ))
    string weaponDesc = GetWeaponInfoFileKeyField_GlobalString( weaponClassName, "description" )
    weaponDesc += "\n\n"

    int rarity = expect int(data.rarity)
    switch (rarity)
    {
        case RARITY_UNCOMMON:
            weaponDesc += FormatDescription(format("Uncommon: x%.2f Damage\n\n", 1.15))
            break
        case RARITY_RARE:
            weaponDesc += FormatDescription(format("Rare: x%.2f Damage\n\n", 1.2))
            break
        case RARITY_EPIC:
            weaponDesc += FormatDescription(format("Epic: x%.2f Damage\n\n", 1.25))
            break
        case RARITY_LEGENDARY:
            weaponDesc += FormatDescription(format("Legendary: x%.2f Damage\n\n", 1.))
            break
    }

    if (level > 0)
    {
        weaponDesc += FormatDescription(format("Level %i: x%.2f Damage\n\n", level, 1.0 + 0.15 * level))
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
            int chipSlot = expect int( curSlot.slot )
            table equippedChip = expect table(runData["AC" + chipSlot])
            runData["AC" + chipSlot] = curSlot
            inventory[elemNum] = equippedChip
            EmitUISound( "menu_loadout_ordinance_select" )
            SwapSequence(slot)
            SwapSequenceAlt(Hud_GetChild(file.menu, "AC" + chipSlot))

            var equippedChipPanel = Hud_GetChild(file.menu, "AC" + chipSlot)
            
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
                case "special":
                case "secondary":
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

    }    
}

void function SwapSequence( var slot )
{
    thread Sequence( 0.333, void function ( float t ) : (slot)
    {
        var swapEffect = Hud_GetChild(slot, "SwapEffect")
        var swapEffect2 = Hud_GetChild(slot, "SwapEffect2")
        
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
    })
}

void function SwapSequenceAlt( var slot )
{
    thread Sequence( 0.333, void function ( float t ) : (slot)
    {
        var swapEffect = Hud_GetChild(slot, "SwapEffect")
        var swapEffect2 = Hud_GetChild(slot, "SwapEffect2")
        
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
    })
}

string function GetTitanDescription(string weapon)
{
    switch (weapon)
    {
        case "mp_titanweapon_xo16_shorty":
            return "Ol' Reliable...\n\nExpedition's status effect is <weak>Weak</>." + 
                "\n<weak>Weak</> is inflicted by <cyan>hitting enemies with missiles</>.\n" +
                "Your primary gains bonus damage agains <weak>Weak</> enemies.\n\n" +
                "<weak>Weak</> Focusing a single target to cause an eruption will deal damage to nearby enemies as well."

        case "mp_titanweapon_sticky_40mm":
            return "Tone"

        case "mp_titanweapon_meteor": // scorch
            return "Set the world ablaze.\n\nScorch's status effect is <burn>Burn</>." + 
                "\n<burn>Burn</> is inflicted by using <cyan>any ability</>. Fully burnt enemies " +
                "<burn>Erupt</>, causing a massive explosion and tons of damage.\n\n" +
                "<burn>Blow Them Up.</> Focusing a single target to cause an eruption will deal damage to nearby enemies as well."

        case "mp_titanweapon_rocketeer_rocketstream":
            return "Brute"

        case "mp_titanweapon_particle_accelerator":
            return "Ion"

        case "mp_titanweapon_leadwall": // ronin
            return "No need for a shield if you've got a giant sword...\n\nRonin's status effect is <daze>Daze</>." + 
                "\n<daze>Daze</> is inflicted by using your <cyan>shotgun</>, and is consumed on <cyan>sword hits</> to " +
                "increase damage by up to 100%.\n\n" +
                "<daze>Stack The Deck.</> Most damage multipliers stack multiplicatively. Use multiple damage bonuses to create an advantage."

        case "mp_titanweapon_sniper":
            return "Northstar"

        case "mp_titanweapon_predator_cannon":
            return "Legion"
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
            title = GetTitanNameFromWeapon(Roguelike_GetTitanLoadouts()[0])
            description = GetTitanDescription(Roguelike_GetTitanLoadouts()[0])
            break
        case "AC4_TitanHelp":
            title = GetTitanNameFromWeapon(Roguelike_GetTitanLoadouts()[1])
            description = GetTitanDescription(Roguelike_GetTitanLoadouts()[1])
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
    result = StringReplace( result, "<cyan>",  "^40FFFF00", true )
    result = StringReplace( result, "<daze>",  "^FFE16400", true )
    result = StringReplace( result, "<warn>",  "^FFA00000", true )
    result = StringReplace( result, "<burn>",  "^FFAF4B00", true )
    result = StringReplace( result, "<green>", "^60FF6000", true )
    result = StringReplace( result, "<red>",   "^FF404000", true )
    result = StringReplace( result, "<weak>",  "^7424FF00", true )
    result = StringReplace( result, "<magic>", "^FF7AF400", true )

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
    if (StartsWith( Hud_GetHudName(slot), "AC" ) || StartsWith( Hud_GetHudName(slot), "Weapon" ))
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
            data.titanEnergy += 1
            data.pilotEnergy += 1
            break
        case "weapon":
            break
    }

    RefreshInventory()
}

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
    Hud_SetText( Hud_GetChild( panel, "FooterText" ), JoinStringArray( options, " " ) )

    var titleStrip = Hud_GetChild(panel, "TitleStrip")
    var title = Hud_GetChild(panel, "Title")
    var bg = Hud_GetChild(panel, "BG")
    var levelBar = Hud_GetChild(panel, "EnergyBar1")
    var barBG = Hud_GetChild(panel, "EnergyBarBG")
    var energyLabel = Hud_GetChild(panel, "EnergyCount")
    
    Hud_SetColor( energyLabel, 25, 25, 25, 255 )
    Hud_SetText( energyLabel, format("Level %i/%i", data.level + 1, Roguelike_GetItemMaxLevel( data ) + 1) )

    Hud_SetBarProgress( barBG, 1.0 )
    Hud_SetX( levelBar, 0 )
    
    
    int segmentCount = 14
    int length = Hud_GetWidth( levelBar )
    int gap = segmentCount - length % segmentCount
    if (segmentCount - length % segmentCount < 1)
        gap = (segmentCount - length % segmentCount) + segmentCount

    int segmentWidth = (length + gap) / segmentCount - gap

    Hud_SetBarSegmentInfo( levelBar, gap, segmentWidth )
    Hud_SetBarSegmentInfo( barBG, gap, segmentWidth )

    int totalEnergy = expect int(data.pilotEnergy) + expect int(data.titanEnergy)
    Hud_SetBarProgress( levelBar, float(totalEnergy) / 14.0 - 0.0001 )
    Hud_SetColor( levelBar, 25, 25, 25, 255 )
    Hud_SetColor( title, 25, 25, 25, 255 )

    int slot = expect int( data.slot )
    
    Hud_SetColor( title, 25, 25, 25, 255 )
    switch (slot)
    {
        case 1:
            Hud_SetColor( titleStrip, 0, 214, 255, 255 )
            Hud_SetColor( bg, 0, 173, 204, 255 )
            break
        case 2:
            Hud_SetColor( titleStrip, 165, 255, 0, 255 )
            Hud_SetColor( bg, 136, 204, 0, 255 )
            break
        case 3:
            // note, this  slightly breaks the square pallette in favor of accessibility
            Hud_SetColor( titleStrip, 197, 0, 255, 255 )
            Hud_SetColor( bg, 153, 0, 204, 255 )
            Hud_SetColor( energyLabel, 255, 255, 255, 255 )
            Hud_SetColor( title, 255, 255, 255, 255 )
            Hud_SetColor( levelBar, 255, 255, 255, 255 )
            break
        case 4:
            Hud_SetColor( titleStrip, 255, 117, 0, 255 )
            Hud_SetColor( bg, 204, 92, 0, 255 )
            break
    }

    for (int i = 0; i < 6; i++)
    {
        string stat = STAT_NAMES[i]
        var statPanel = Hud_GetChild(panel, stat)
        int value = expect int(data.stats[i])
        if (i < 3)
        {
            value *= expect int(data.titanEnergy)
        }
        else
        {
            value *= expect int(data.pilotEnergy) 
        }
        var bar = Hud_GetChild(statPanel, "Bar")
        var label = Hud_GetChild(statPanel, "Label")
        var valueText = Hud_GetChild(statPanel, "Value")
        switch (slot)
        {
            case 3:
                Hud_SetColor(bar, 255, 255, 255, 255)
                Hud_SetColor(label, 255, 255, 255, 255)
                Hud_SetColor(valueText, 255, 255, 255, 255)
                break
            default:
                Hud_SetColor(bar, 25, 25, 25, 255)
                Hud_SetColor(label, 25, 25, 25, 255)
                Hud_SetColor(valueText, 25, 25, 25, 255)
                break
        }
        Hud_SetBarProgress(bar, value / 72.0)
        Hud_SetText(label, stat)
        Hud_SetText(valueText, "+" + value)
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
    if (IsFullyConnected())
        Roguelike_StartNewRun()
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

int function Roguelike_GetStat( int stat )
{
    return minint(int( split( GetConVarString("player_stats"), " " )[stat] ), 150)
}
int function Roguelike_GetStatRaw( int stat )
{
    return int( split( GetConVarString("player_stats"), " " )[stat] )
}
