untyped
global function Healthbars_Init
global function Healthbars_SetMenuState

const int HEALTHBAR_INSTANCES = 7
const array<int> INVULNERABLE_BAR_COLOR = [200, 150, 50, 255]
const array<int> ENEMY_TITAN_BAR_COLOR = [200, 50, 50, 255]
const array<int> ENEMY_BAR_COLOR = [200, 50, 50, 255]
const array<int> FRIENDLY_BAR_COLOR = [70, 130, 255, 255]

struct {
    array<entity> hitEnts
    array<entity> healthbarEntities = [ null, null, null, null, null, null, null, null ]
    array<entity> eliteHealthbarEntities = [ null, null, null, null, null, null, null, null ]
    array<entity> titanHealthbarEntities = [ null, null, null, null, null, null, null, null ]
    int healthbarIndex = 0
    int titanHealthbarIndex = 0
} file

void function Healthbars_Init()
{
    RegisterSignal("EndTargetInfo")
    delaythread(0.001) Healthbars_Think()
}

void function Healthbars_Think()
{
    entity player = GetLocalClientPlayer()
    var healthbarsPanel = HudElement("Healthbars")

    while (true)
    {
        wait 0.001
        file.hitEnts.clear()

        // HEALTHBAR CHECKS
        // side note - mem leak. can't fix because traceline creates a new instance of
        // the traceresults stack every time it's called :(
        vector attackDir = AnglesToForward( player.CameraAngles() )
        if (IsValid(player.GetActiveWeapon()) && player.GetActiveWeapon().GetWeaponOwner() == player)
            attackDir = player.GetActiveWeapon().GetAttackDirection()

        array<VisibleEntityInCone> results = FindVisibleEntitiesInCone( player.CameraPosition(), attackDir, 5000, player.GetFOV() / 10.0, [ ], TRACE_MASK_BLOCKLOS, VIS_CONE_ENTS_IGNORE_VORTEX, player )

        foreach (VisibleEntityInCone coneEnt in results)
        {
            entity ent = coneEnt.ent
            // dont show player healthbar above them???
            if (ent == player)
                continue
            if (ent.GetTitleForUI() == "Laser Tripwire")
                continue
            file.hitEnts.append(ent)

            if (ent.IsTitan())
            {
                if (!file.titanHealthbarEntities.contains(ent))
                {
                    thread TitanHealthBar( healthbarsPanel, ent )
                }
            }
            else
            {
                if (!file.healthbarEntities.contains(ent))
                {
                    thread HealthBar( healthbarsPanel, ent )
                }
            }
        }

        entity lastPrimary = player.GetLatestPrimaryWeapon()
        bool isUsingRonin = IsValid(lastPrimary) && lastPrimary.GetWeaponClassName() == PRIMARY_RONIN
        if (player.IsTitan() && isUsingRonin)
        {
            bool hasMod = Roguelike_HasMod( player, "reflective_sword" )
            Hud_SetVisible( HudElement("CrosshairBar"), hasMod )
            Hud_SetBarProgress( HudElement("CrosshairBar"), GraphCapped(RSE_Get( player, RoguelikeEffect.ronin_block_buff ), 0, 1, 0.370, 0.625) )
        }
        else if (!player.IsTitan())
        {
            Hud_SetVisible( HudElement("CrosshairBar"), true )
            float speed = player.GetDodgePower()
            float maxDashPower = 20.0
            if (Roguelike_HasMod( player, "double_dash" ))
                maxDashPower = 40.0
            Hud_SetBarProgress( HudElement("CrosshairBar"), GraphCapped(speed, 0, maxDashPower, 0.370, 0.625))
            if (speed >= 19.99)
                Hud_SetColor( HudElement("CrosshairBar"), 0, 255, 255, 255 )
            else
                Hud_SetColor( HudElement("CrosshairBar"), 144, 144, 144, 255 )
        }
        else
        {
            Hud_SetVisible( HudElement("CrosshairBar"), false )
        }
    }

}

void function HealthBar( var healthbarsPanel, entity ent )
{
    ent.EndSignal( "EndTargetInfo" )
    ent.EndSignal( "OnDestroy" )

    // allocate healthbar
    int index = file.healthbarIndex++
    if (file.healthbarIndex > HEALTHBAR_INSTANCES)
        file.healthbarIndex = 0

    if (IsValid(file.healthbarEntities[index]))
    {
        file.healthbarEntities[index].Signal("EndTargetInfo")
    }
    file.healthbarEntities[index] = ent

    var healthbar = Hud_GetChild( healthbarsPanel, "Healthbar" + index )
    Hud_SetVisible( healthbar, true )

    OnThreadEnd(
        function() : ( ent, index, healthbar )
		{
            Hud_SetVisible( healthbar, false )
            file.healthbarEntities[index] = null
		}
    )

    // set title
    string title = GetHealthbarTitle( ent )
    Hud_SetText( Hud_GetChild( healthbar, "Name" ), "" )

    // children
    var bar = Hud_GetChild( healthbar, "Bar" )

    // alpha vars
    float alpha = 0.0
    float lastLookTime = Time()
    float lastFrameTime = Time()

    while (true)
    {
        if (ent.IsTitan())
        {
            file.healthbarEntities[index] = null
            ent.Signal("EndTargetInfo")
        }

        Hud_SetVisible( healthbar, !clGlobal.isMenuOpen )

        // check team
        entity player = GetLocalClientPlayer()
        bool isFriendly = player.GetTeam() == ent.GetTeam()

        // check if we're being looked at
        float delta = Time() - lastFrameTime
        if (file.hitEnts.contains(ent) && IsAlive(ent))
            lastLookTime = Time()

        // set alpha
        if (Time() - lastLookTime > 1.5)
            alpha -= 8.0 * delta
        else alpha += 8.0 * delta
        alpha = clamp(alpha, 0, 0.8)
        healthbar.SetPanelAlpha( alpha * 255.0 )

        if (isFriendly)
        {
            bar.SetColor( FRIENDLY_BAR_COLOR )
        }
        else
        {
            bar.SetColor( ENEMY_BAR_COLOR )
        }
        Hud_SetBarProgress( bar, GetHealthFrac(ent) )

        // calculate screen pos
        vector mins = ent.GetBoundingMins()
        vector maxs = ent.GetBoundingMaxs()
        vector worldPos = ent.GetOrigin() + <(mins.x + maxs.x) / 2, (mins.y + maxs.y) / 2, maxs.z + 8>

        vector screenPos = WorldToScreenPos( worldPos )
        vector size = <128, Hud_GetHeight( healthbar ), 0>

        Hud_SetPos( healthbar, screenPos.x - size.x / 2, screenPos.y - size.y )
        Hud_SetZ( healthbar, 10000.0 / Distance(worldPos, player.CameraPosition()))

        // set health frac
        // TODO: set shield frac
        float healthFrac = GetHealthFrac(ent)

        lastFrameTime = Time()
        wait 0
    }
}

void function TitanHealthBar( var healthbarsPanel, entity ent )
{
    ent.EndSignal( "EndTargetInfo" )
    ent.EndSignal( "OnDestroy" )

    // allocate healthbar
    int index = file.titanHealthbarIndex++
    if (file.titanHealthbarIndex > HEALTHBAR_INSTANCES)
        file.titanHealthbarIndex = 0
    if (IsValid(file.titanHealthbarEntities[index]))
    {
        file.titanHealthbarEntities[index].Signal("EndTargetInfo")
    }
    file.titanHealthbarEntities[index] = ent

    var healthbar = Hud_GetChild( healthbarsPanel, "HealthbarChampion" + index )
    Hud_SetVisible( healthbar, true )

    OnThreadEnd(
        function() : ( ent, index, healthbar )
		{
            Hud_SetVisible( healthbar, false )
		}
    )

    // children
    var bar = Hud_GetChild( healthbar, "Bar" )
    var shieldBar = Hud_GetChild( healthbar, "ShieldBar" )
    var barBG = Hud_GetChild( healthbar, "BG" )
    var changeBar = Hud_GetChild( healthbar, "ChangeBar" )
    // top, then bottom
    var statusEffectBars = [ Hud_GetChild( healthbar, "StatusEffectBar2" ), Hud_GetChild( healthbar, "StatusEffectBar" ) ]
    var statusEffectTexts = [ Hud_GetChild( healthbar, "StatusEffectText2" ), Hud_GetChild( healthbar, "StatusEffectText" ) ]

    // alpha variables
    float alpha = 0.0
    float lastLookTime = Time()
    float lastFrameTime = Time()
    float lastLastHealthFrac = 0.0
    float lastHealthFrac = GetHealthFrac(ent)
    float lastHealthChangeTime = -9.9
    print("init")
    Hud_SetBarProgress( changeBar, lastLastHealthFrac )

    while (true)
    {
        string title = GetHealthbarTitle( ent )
        if (!ent.IsTitan())
        {
            file.titanHealthbarEntities[index] = null
            ent.Signal("EndTargetInfo")
        }

        Hud_SetVisible( healthbar, !clGlobal.isMenuOpen )

        // check team
        entity player = GetLocalClientPlayer()
        bool isFriendly = player.GetTeam() == ent.GetTeam()

        if (isFriendly)
        {
            bar.SetColor( FRIENDLY_BAR_COLOR )
        }
        else
        {
            bar.SetColor( ENEMY_TITAN_BAR_COLOR )
        }

        if (ent.IsInvulnerable())
        {
            bar.SetColor( INVULNERABLE_BAR_COLOR )
        }

        // check if we're being looked at
        float delta = Time() - lastFrameTime
        if (file.hitEnts.contains(ent) && IsAlive(ent))
            lastLookTime = Time()

        // alpha calculation
        if (Time() - lastLookTime > 1.5)
            alpha -= 8.0 * delta
        else alpha += 8.0 * delta
        alpha = clamp(alpha, 0, 1.0)
        // P.S. no rui here since we don't use basic_images
        healthbar.SetPanelAlpha( alpha * 255.0 )

        // calculate bar width with segment count
        int baseBarWidth = 359
        float healthPerSegment = 2500.0
        if (IsSingleplayer())
        {
            healthPerSegment = 1500.0
            switch (GetConVarInt("sp_difficulty"))
            {
                case 1:
                    healthPerSegment = 2000.0
                    break
                case 2:
                    healthPerSegment = 2500.0
                    break
                case 3:
                    healthPerSegment = 2500.0
                    break
            }
            if (title == "BT-7274")
            {
                healthPerSegment = 2500.0
            }
        }
        float segments = ent.GetMaxHealth() / healthPerSegment
        int width = int(segments) * 21
        if (ent.GetMaxHealth() % healthPerSegment == 0)
            width -= 1
        else width += int((segments % 1.0) * 20)

        Hud_SetBarSegmentInfo( bar, 1, 20 )
        Hud_SetBarSegmentInfo( changeBar, 1, 20 )
        Hud_SetWidth( bar, width )
        Hud_SetWidth( changeBar, width )
        Hud_SetWidth( shieldBar, width )
        Hud_SetWidth( barBG, width )
        Hud_SetWidth( healthbar, width )

        // calculate screen pos
        vector mins = ent.GetBoundingMins()
        vector maxs = ent.GetBoundingMaxs()
        vector worldPos = ent.GetOrigin() + <(mins.x + maxs.x) / 2, (mins.y + maxs.y) / 2, maxs.z + 8>

        vector screenPos = WorldToScreenPos( worldPos )
        vector size = <Hud_GetWidth( healthbar ), Hud_GetHeight( healthbar ), 0>
        entity soul = ent.GetTitanSoul()

        Hud_SetPos( healthbar, screenPos.x - (width) / 2, screenPos.y - size.y )
        Hud_SetZ( healthbar, 10000.0 / Distance(worldPos, player.CameraPosition()))

        // set health frac
        float healthFrac = GetHealthFrac(ent)
        Hud_SetBarProgress( bar, healthFrac )
        if (healthFrac != lastHealthFrac)
        {
            lastHealthChangeTime = Time()
            lastLastHealthFrac = lastHealthFrac
            lastHealthFrac = healthFrac
        }
        Hud_SetBarProgress( changeBar, lastLastHealthFrac )
        Hud_SetBarProgress( shieldBar, IsValid(soul) && soul.GetShieldHealthMax() > 0.0 ?
            float(soul.GetShieldHealth()) / float(soul.GetShieldHealthMax()) : 0.0 )

        // set status frac

        array<string> titanLoadouts = Roguelike_GetTitanLoadouts()
        for (int i = 0; i < 2; i++)
        {
            var statusEffectBar = statusEffectBars[i]
            var statusEffectText = statusEffectTexts[i]

            bool shouldBeVisible = player.IsTitan() && !isFriendly
            Hud_SetWidth( statusEffectBar, width )
            Hud_SetVisible( statusEffectBar, shouldBeVisible )
            Hud_SetVisible( statusEffectText, shouldBeVisible )
            if (player.IsTitan())
            {
                switch (titanLoadouts[i])
                {
                    case "mp_titanweapon_leadwall":
                        Hud_SetBarProgress( statusEffectBar, RSE_Get( ent, RoguelikeEffect.ronin_daze ) / 3.0 )
                        Hud_SetText( statusEffectText, "Daze")
                        Hud_SetColor( statusEffectBar, 255, 225, 100, 255 )
                        Hud_SetColor( statusEffectText, 255, 225, 100, 255 )
                        break
                    case "mp_titanweapon_meteor":
                        float burn = max(RSE_Get( ent, RoguelikeEffect.burn ), RSE_Get( ent, RoguelikeEffect.burn_flame_core ))
                        Hud_SetBarProgress( statusEffectBar, burn / 50.0 )
                        Hud_SetText( statusEffectText, RoundToInt(burn + 100) + "% DMG")
                        Hud_SetColor( statusEffectBar, 255, 175, 75, 255 )
                        Hud_SetColor( statusEffectText, 255, 175, 75, 255 )
                        break
                    case "mp_titanweapon_xo16_shorty":
                        Hud_SetBarProgress( statusEffectBar, RSE_Get( ent, RoguelikeEffect.expedition_weaken ) )
                        Hud_SetText( statusEffectText, "Weaken")
                        Hud_SetColor( statusEffectBar, 177, 94, 255, 255 )
                        Hud_SetColor( statusEffectText, 177, 94, 255, 255 )
                        break
                    case "mp_titanweapon_predator_cannon":
                        Hud_SetBarProgress( statusEffectBar, RSE_Get( ent, RoguelikeEffect.legion_puncture ) )
                        Hud_SetText( statusEffectText, "Puncture")
                        Hud_SetColor( statusEffectBar, 255, 64, 64, 255 )
                        Hud_SetColor( statusEffectText, 255, 64, 64, 255 )
                        break
                    case "mp_titanweapon_sniper":
                        Hud_SetBarProgress( statusEffectBar, RSE_Get( ent, RoguelikeEffect.northstar_fulminate ) )
                        Hud_SetText( statusEffectText, "Fulminate")
                        Hud_SetColor( statusEffectBar, 64, 96, 255, 255 )
                        Hud_SetColor( statusEffectText, 64, 96, 255, 255 )
                        break
                    case "mp_titanweapon_particle_accelerator":
                        float cur = RSE_Get( ent, RoguelikeEffect.ion_charge )
                        Hud_SetBarProgress( statusEffectBar, cur )
                        Hud_SetText( statusEffectText, "Charge")
                        if (cur > 0.99)
                        {
                            Hud_SetColor( statusEffectBar, 64, 255, 255, 255 )
                            Hud_SetColor( statusEffectText, 64, 255, 255, 255 )
                        }
                        else
                        {
                            Hud_SetColor( statusEffectBar, 127, 127, 127, 255 )
                            Hud_SetColor( statusEffectText, 127, 127, 127, 255 )
                        }
                        break
                }
            }
        }

        lastFrameTime = Time()
        wait 0
    }
}

string function GetHealthbarTitle( entity ent )
{
    if (!IsValid(ent))
        return "\x1b[38;5;220mnull"
    string title = ent.GetTitleForUI()
    if (GetConVarBool("roguelike_timer_debug"))
        title += format("(%i/%i)", ent.GetHealth(), ent.GetMaxHealth())

    return title
}

// util function
vector function WorldToScreenPos( vector position )
{
    array pos = expect array( Hud.ToScreenSpace( position ) )

    vector result = <float( pos[0] ), float( pos[1] ), 0 >
    //print(result)
    return result
}

void function Healthbars_SetMenuState( int state )
{
    switch (state)
    {
        case 0:
            clGlobal.isMenuOpen = false
            Hud_SetVisible(HudElement("Healthbars"), true)
            break
        case 1:
        case 2:
            clGlobal.isMenuOpen = true
            Hud_SetVisible(HudElement("Healthbars"), false)
            break
    }
}
