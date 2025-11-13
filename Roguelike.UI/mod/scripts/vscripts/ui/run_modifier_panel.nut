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
        states[modifier] <- 0
    panel.s.state <- 0
    Hud_SetText( label, mod.name )
    
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
        states[modifier] <- value
    }
}

void function OnClick( var button )
{
    var panel = Hud_GetParent( button )
    RoguelikeRunModifier mod = GetRunModifierDataByName(modifiers[panel])
    int state = states[mod.uniqueName]
    states[mod.uniqueName] = maxint(--state, 0)

    UpdateValueLabel( panel )
}

void function OnClick2( var button )
{
    var panel = Hud_GetParent( button )
    RoguelikeRunModifier mod = GetRunModifierDataByName(modifiers[panel])
    int state = states[mod.uniqueName]
    states[mod.uniqueName] = minint(state + 1, mod.options.len() - 1)

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
    int state = states[mod.uniqueName]

    int cost = state > 0 ? ((state - 1) * mod.costPerLevel + mod.baseCost) : 0

    string text =  format("%s-^FFFFFFFF %s %s+", (minusOn ? on : off), mod.options[state], (plusOn ? on : off))

    Hud_SetText( Hud_GetChild( panel, "Value" ), text )
    if (cost > 0)
    {
        Hud_SetColor( Hud_GetChild( panel, "Label2" ), 255, 128, 0, 255 )
         Hud_SetText( Hud_GetChild( panel, "Label2" ), " (+" + cost + ")" )
    }
    else
    {
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
        if (v <= 0)
            continue
        RoguelikeRunModifier mod = GetRunModifierDataByName(k)
        cost += v > 0 ? ((v - 1) * mod.costPerLevel + mod.baseCost) : 0
        list.append(k)
        list.append(string(v))
    }

    SetConVarString("roguelike_run_modifiers", JoinStringArray(list, " "))
    SetConVarInt("roguelike_run_heat", cost)
}
