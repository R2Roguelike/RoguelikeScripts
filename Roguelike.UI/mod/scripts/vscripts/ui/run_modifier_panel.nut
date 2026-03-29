untyped
global function RunModifier_Init
global function RunModifierPanel_ParseConvar

table<var, void functionref( var )> callbacks
table<var, string > modifiers
table<string, int> states

void function RunModifier_Init( var panel, string modifier )
{
    RoguelikeRunModifier mod = GetRunModifierDataByName( modifier )
    var button = Hud_GetChild( panel, "Button" )
    var button2 = Hud_GetChild( panel, "Button2" )
    var label = Hud_GetChild( panel, "Label" )
    var label2 = Hud_GetChild( panel, "Label2" )
    var value = Hud_GetChild( panel, "Value" )
    modifiers[panel] <- modifier
    if (!(modifier in states))
    {
        states[modifier] <- mod.defaultValue
    }
    Hud_SetText( label, mod.name )

    AddHover( panel, void function( var slot, var panel ) : (mod) {
        HoverSimpleData data
        data.title = mod.name
        data.description = mod.description
        HoverSimple_SetData(data)
    }, HOVER_SIMPLE )
    
    Hud_AddEventHandler( button, UIE_GET_FOCUS, OnGetFocus )
    Hud_AddEventHandler( button, UIE_LOSE_FOCUS, OnLoseFocus )
    Hud_AddEventHandler( button2, UIE_GET_FOCUS, OnGetFocus2 )
    Hud_AddEventHandler( button2, UIE_LOSE_FOCUS, OnLoseFocus2 )
    Hud_AddEventHandler( button, UIE_CLICK, OnClick )
    Hud_AddEventHandler( button2, UIE_CLICK, OnClick2 )

    UpdateValueLabel( panel )
}

void function RunModifierPanel_ParseConvar()
{
    array<string> convar = split( GetConVarString("roguelike_run_modifiers"), " " )
    for (int i = 0; i < convar.len(); i+=2)
    {
        string modifier = convar[i]
        int value = int(convar[i + 1])
        try
        {
            RoguelikeRunModifier mod = GetRunModifierDataByName(modifier)
            states[modifier] <- value
        }
        catch (e)
        {}
    }
}

void function OnClick( var button )
{
    var panel = Hud_GetParent( button )
    RoguelikeRunModifier mod = GetRunModifierDataByName(modifiers[panel])
    int state = states[mod.uniqueName]
    states[mod.uniqueName] <- maxint(--state, 0)

    UpdateValueLabel( panel )
}

void function OnClick2( var button )
{
    var panel = Hud_GetParent( button )
    RoguelikeRunModifier mod = GetRunModifierDataByName(modifiers[panel])
    int state = states[mod.uniqueName]
    states[mod.uniqueName] <- minint(state + 1, mod.options.len() - 1)

    UpdateValueLabel( panel )
}

void function OnGetFocus( var button )
{
    var panel = Hud_GetParent( button )
    panel.s["1"] <- true
    UpdateValueLabel( panel )
}
void function OnGetFocus2( var button )
{
    var panel = Hud_GetParent( button )
    panel.s["2"] <- true
    UpdateValueLabel( panel )
}

void function OnLoseFocus( var button )
{
    var panel = Hud_GetParent( button )
    delete panel.s["1"]
    UpdateValueLabel( panel )
}
void function OnLoseFocus2( var button )
{
    var panel = Hud_GetParent( button )
    delete panel.s["2"]
    UpdateValueLabel( panel )
}

void function UpdateValueLabel( var panel )
{
    RoguelikeRunModifier mod = GetRunModifierDataByName(modifiers[panel])

    bool minusOn = "1" in panel.s
    bool plusOn = "2" in panel.s
    string off = "^80808000"
    string on = "^FFFFFF00"
    if (states[mod.uniqueName] >= mod.options.len())
    {
        states[mod.uniqueName] = mod.options.len() - 1
    }
    int state = states[mod.uniqueName]

    int cost = 0
    if (state > mod.defaultValue)
        cost += (state - mod.defaultValue - 1) * mod.costPerLevel + mod.baseCost
    if (state < mod.defaultValue)
        cost += mod.negativeCost * (mod.defaultValue - state)

    string text =  format("%s-^FFFFFFFF %s %s+", (minusOn ? on : off), mod.options[state], (plusOn ? on : off))

    Hud_SetText( Hud_GetChild( panel, "Value" ), text )
    if (cost > 0)
    {
        Hud_SetColor( Hud_GetChild( panel, "Value" ), 255, 128, 0, 255 )
        Hud_SetColor( Hud_GetChild( panel, "Label2" ), 255, 128, 0, 255 )
         Hud_SetText( Hud_GetChild( panel, "Label2" ), " (+" + cost + ")" )
    }
    else if (cost < 0)
    {
        Hud_SetColor( Hud_GetChild( panel, "Value" ), 0, 255, 128, 255 )
        Hud_SetColor( Hud_GetChild( panel, "Label2" ), 0, 255, 128, 255 )
        Hud_SetText( Hud_GetChild( panel, "Label2" ), " (" + cost + ")" )
    }
    else
    {
        Hud_SetColor( Hud_GetChild( panel, "Value" ), 200, 200, 200, 255 )
        Hud_SetColor( Hud_GetChild( panel, "Label2" ), 200, 200, 200, 255 )
         Hud_SetText( Hud_GetChild( panel, "Label2" ), "" )
    }

    UpdateConvar()
}

void function UpdateConvar()
{
    array<string> list = []
    int cost = 0
    foreach (string k, int v in states)
    {
        RoguelikeRunModifier mod = GetRunModifierDataByName(k)
        if (v == mod.defaultValue)
            continue
        int modCost = 0
        if (v > mod.defaultValue)
            modCost += (v - mod.defaultValue - 1) * mod.costPerLevel + mod.baseCost
        if (v < mod.defaultValue)
            modCost += mod.negativeCost * (mod.defaultValue - v)
            
        cost += modCost
        list.append(k)
        list.append(string(v))
    }

    SetConVarString("roguelike_run_modifiers", JoinStringArray(list, " "))
    SetConVarInt("roguelike_run_heat", cost)
}
