globalize_all_functions

void function __open( string m )
{
    if (uiGlobal.activeMenu == GetMenu("MainMenu"))
        return
    
    var menu
    try
    {
        menu = GetMenu(m)
        if (menu != null)
            AdvanceMenu(menu)
    }
    catch (ex)
    {
        print(ex)
    }
}

float function EaseOutExpo( float t )
{
    return 1 - pow(1 - t, 5)
}

void function Sequence( float duration, void functionref( float ) update )
{
    float startTime = Time()
    float endTime = Time() + duration
    while (true)
    {
        update( GraphCapped( Time(), startTime, endTime, 0, 1 ) )
        if (Time() >= endTime)
            break
        wait 0
    }
}