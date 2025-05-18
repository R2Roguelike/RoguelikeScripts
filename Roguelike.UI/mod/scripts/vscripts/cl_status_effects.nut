global function Cl_StatusEffects_Init

struct {
    array<var> rui = []
} file

void function Cl_StatusEffects_Init()
{
    return
    for (int i = 0; i < 4; i++)
    {
        var rui = RuiCreate( $"ui/cockpit_console_text_top_left.rpak", clGlobal.topoCockpitHud, RUI_DRAW_COCKPIT, 0)
        RuiSetInt( rui, "maxLines", 1 );
        RuiSetInt( rui, "lineNum", 0 );
        RuiSetFloat2( rui, "msgPos", <0.02, 0.6 + i * 0.03, 0.0> )
        RuiSetString( rui, "msgText",  "`10:05 - `0Burn x100" )
        RuiSetFloat3( rui, "msgColor", <1.0, 1.0, 1.0> )
        RuiSetFloat( rui, "msgFontSize", 28.0)
        RuiSetFloat( rui, "msgAlpha", 0.9 )
        RuiSetFloat( rui, "thicken", 0.05 )

        file.rui.append(rui)
    }
}

void function StatusEffects_Update()
{
    while (true)
    {
        wait 0.001
    }
}