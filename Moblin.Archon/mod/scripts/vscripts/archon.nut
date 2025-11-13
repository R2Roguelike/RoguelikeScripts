global function Archon_Init
#if SERVER
global function ApplyShock
#endif
global array<int> archonDMGSources = []

void function Archon_Init()
{
	AddCallback_ModRegistration( ArchonUIInit )
}

void function ArchonUIInit()
{
	//========================================//-NAMES AND STATS-//========================================//

	// HELLO MODDERS/GAMERS/ETC
	// this is a template to make your own titan loadout for roguelike
	// first of all, i am honored that you might want to do this!
	// second, i tried to make it as easy as possible with this template.
	// These are the ONLY roguelike-specific things you need to do, the rest
	// is just you, the game.  

	// DESIGN GUIDE:
	/* 
	* 0.1) This is a GUIDE, not a hard requirement. There is no hard formula for fun,
	* but this guide exists explain MY way to design the original 8 (ok fine, 9) loadouts.
	* Breaking rules is how you discover new things!
	*
	* [1. THE LOADOUT]
	* 
	* 1.1) try to make the loadout interact with a system that can be affected by other loadouts
	* this can be damage, cooldowns, a weapon stat, or in this case, shields.
	* 1.2) the loadout should be fun without any upgrades.
	* if the loadout isnt fun without upgrades, it isnt going to be fun with them.
	* this also means that the loadout ITSELF, NOT only it's upgrades, needs to have interactions.
	* 1.3) try to not waste the player's time with windup time. Archon kind of breaks this rule because
	* it's primary has charge up time.
	* 1.4) while i can't really help you with designing the loadout itself (since all the loadouts i made
	* are either vanilla or stolen **with permission** from the community), do try to make it unique!
	*
	* [2. THE UPGRADES]
	*
	* 2.1) Cost should be determined by how useful something will be to the AVERAGE player.
	* If someone makes a build work with just 1 costs, it probably doesn't need a nerf,
	* the person that is playing is just that good. (*cough* tilaly...)
	* 2.2) Cost is 1-3. If something is so OP it should be a 4 cost, it should generally be a datacore perk (_cough_ lmao) instead.
	* 2.3) Loadout-Specific Upgrades should do things that require the loadout to exist to work.
	* EXAMPLE 1: Increasing damage by 30% when using a defensive ability for 15s shouldn't be a loadout specific upgrade.
	* EXAMPLE 2: Scorch's Flame Core stuns enemies should be a Loadout specific upgrade.
	* note - while i kind of break this rule with archon, it works because i make archon synonymous with shield
	* 
	* [3. THE STATUS EFFECT]
	* 3.1) The status effect needs to interact with other loadouts, but should be able to be activated 
	* by the loadout itself ()
	* 3.2) idk make it useful or smth
	*
	*/



	ROGUELIKE_ELECTRIC_WEAPONS.extend(
		["mp_titanweapon_archon_arc_cannon", "mp_titanweapon_shock_shield", 
		"mp_titanweapon_charge_ball","mp_titanweapon_tesla_node", "mp_titancore_storm_core", "shock_dmg"])
	
	RoguelikeLoadout loadout
	loadout.name = "#DEFAULT_TITAN_1" // name of titan
	loadout.description = "<note>just dont get hit bro :)</>\n\n" +
						  "Archon's abilities have <cyan>no cooldowns</>, but consume shields.\n\n" +
						  "Archon's status effect is <fulm>Shock.</>\n\n" +
						  "<fulm>Shock</> is filled up with <daze>Archon's kit,</> and when active, all hits trigger a <hack>Shock Proc</> that deals 100 base damage." +
						  "\n\n<daze>Originally by GalacticMoblin, Hurbski, Dinorush, EXRILL, Peepeepoopoo man, and Spoon." // description
	// weapon & abilities
	loadout.primary = "mp_titanweapon_archon_arc_cannon"
	loadout.defensive = "mp_titanweapon_shock_shield"
	loadout.offensive = "mp_titanweapon_charge_ball"
	loadout.utility = "mp_titanweapon_tesla_node"
	loadout.core = "mp_titancore_storm_core"
	// status effect
	loadout.statusEffectName = "Shock"
	// element and role - display only but do make it match
	// sidenote, its highly recommended to make all abilities of a titan deal the same damage element
	loadout.element = RoguelikeElement.electric
	loadout.role = "Shield Consumer"
	loadout.unlockBit = 6 // CHANGE THIS TO -1 WHEN MAKING YOUR OWN TO UNLOCK BY DEFAULT!
	loadout.color = [32, 192, 255, 255]
	Roguelike_AddLoadout(loadout)

	const string BENEFIT_1 = "<cyan>+10% Shield Regen Rate.</>\n\n"
	// -5% Shield Regen Delay
    {
        RoguelikeMod mod = NewMod("pylon_shield")
        mod.name = "Arc Shield"
        mod.abbreviation = "AS"
        mod.description = "<cyan>+10% Shield Regen Rate.</>\n\nArc Pylons restore 20 shields on hit."
        mod.shortdesc = "Arc Pylons restore shields on hit."
        mod.cost = 3
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("health_convert")
        mod.name = "Health Converter"
        mod.abbreviation = "HC"
        mod.description = "<cyan>+10% Shield Regen Rate.</>\n\nIf you do not have enough shields for Archon's abilities, <red>consume health instead.</> Shield regeneration delay reduced by <cyan>25%.</>"
        mod.shortdesc = "Health may be converted to shields.\nShield Regen Delay reduced."
        mod.cost = 2
        mod.chip = TITAN_CHIP_UTILITY
    }
    {
        RoguelikeMod mod = NewMod("shock_shield_shield")
        mod.name = "Shock Shield Converter"
        mod.abbreviation = "SSC"
        mod.description = "<cyan>-5% Shield Regen Delay.</>\n\nShock Shield restores damage absorbed as shields."
        mod.shortdesc = "Shock Shield restores shields."
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("shield_unprotect")
        mod.name = "Shield Loss"
        mod.abbreviation = "SL"
        mod.description = "<cyan>-5% Shield Regen Delay.</>\n\n<red>Shields do not protect incoming damage.</> <cyan>+25% Crit Rate.</>"
        mod.shortdesc = "<red>Shields don't take damage.</>\n+25% Crit Rate."
        mod.cost = 2
        mod.chip = TITAN_CHIP_UTILITY
    }
    {
        RoguelikeMod mod = NewMod("eye_of_the_storm")
        mod.name = "Eye of The Storm"
        mod.abbreviation = "ETS"
        mod.description = "<cyan>-5% Shield Regen Delay.</>\n\nShock Shield produces a damaging arc field."
        mod.shortdesc = "Shock Shield gets DoT while active."
        mod.cost = 2
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("charge_balls")
        mod.name = "Balling"
        mod.abbreviation = "Bln"
        mod.description = "<cyan>-5% Shield Regen Delay.</>\n\nCharge Ball fires 2 more balls in all forms."
        mod.shortdesc = "Charge Ball fires more balls."
        mod.cost = 1
        mod.chip = TITAN_CHIP_ABILITIES
    }
    {
        RoguelikeMod mod = NewMod("chain_reaction")
        mod.name = "Chain Reaction"
        mod.abbreviation = "ChR"
        mod.description = "<cyan>+10% Shield Regen Rate</>\n\nArc Cannon chains between targets."
        mod.shortdesc = "Arc Cannon chains between targets."
        mod.cost = 2
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("arc_cannon_charge")
        mod.name = "Arc Charger"
        mod.abbreviation = "AC"
        mod.description = "<cyan>+10% Shield Regen Rate</>\n\nArc Cannon charges 200% faster."
        mod.shortdesc = "Arc Cannon charges faster."
        mod.cost = 2
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("other_loadout_shield")
        mod.name = "ShieldSwap"
        mod.abbreviation = "SSw"
        mod.description = "<cyan>+10% Shield Regen Rate</>\n\nRestore shields on loadout swap. <note>This may trigger every 2s.</>"
        mod.shortdesc = "Restore shields on swap."
        mod.cost = 2
        mod.chip = TITAN_CHIP_UTILITY
    }
    {
        RoguelikeMod mod = NewMod("shield_buff")
        mod.name = "Backup Power"
        mod.abbreviation = "BP"
        mod.description = "<cyan>-5% Shield Regen Delay</>\n\nWhile you don't have shields, <cyan>+25% DMG</>"
        mod.shortdesc = "<cyan>+DMG%</> when shields are empty."
        mod.cost = 2
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("shock_power")
        mod.name = "Shock Power"
        mod.abbreviation = "ShP"
        mod.description = "<cyan>-5% Shield Regen Delay</>\n\nShock procs additionaly deal 25% damage of the original hit."
        mod.shortdesc = "Shock hits scale with DMG."
        mod.cost = 3
        mod.chip = TITAN_CHIP_WEAPON
    }
    {
        RoguelikeMod mod = NewMod("shock_cycle")
        mod.name = "Shock Cycle"
        mod.abbreviation = "ShC"
        mod.description = "<cyan>+10% Shield Regen Rate</>\n\nNon-shocked enemies provide <cyan>shields on hit.</> Shocked enemies provide <cyan>+35% DMG to your other loadout.</>"
        mod.shortdesc = "Enemies cycle between debuffs\ndepending on Shock state."
        mod.cost = 3
        mod.chip = TITAN_CHIP_WEAPON
    }
		
	#if SERVER || CLIENT
	Roguelike_RegisterStatusEffect("archon_shock")
	Roguelike_RegisterStatusEffect("archon_shock_active")

	// BOTH SERVER AND CLIENT
	AddCallback_ApplyModWeaponVars( WEAPON_VAR_PRIORITY_OVERRIDE, void function (entity weapon ) : ()
	{
		if (weapon.GetWeaponClassName() != "mp_titanweapon_archon_arc_cannon")
			return
		entity owner = weapon.GetWeaponOwner()
		if (!IsValid(owner) || !owner.IsPlayer())
			return

		if (Roguelike_HasMod( owner, "arc_cannon_charge"))
			ModWeaponVars_ScaleVar( weapon, eWeaponVar.charge_time, 0.333 )
	})

	#endif
	#if SERVER
	AddCallback_CritRate( float function( entity ent, entity player, var damageInfo ) : () {
		float result = 0.0
		if (Roguelike_HasMod( player, "shield_unprotect"))
			result += 0.25 // +25%

		return result
	})
	AddCallback_CritDMG( float function( entity ent, entity player, var damageInfo ) : () {
		float result = 0.0
		if (Roguelike_HasMod( player, "shield_buff") && (player.IsTitan() && player.GetTitanSoul().GetShieldHealth() < 50))
			result += 0.25 // +25%

		return result
	})
	AddCallback_ShieldDamageModifier( void function(ShieldDamageModifier modifier, var damageInfo, entity ent) : (){
		if (IsValid(ent) && Roguelike_HasMod( ent, "shield_unprotect" ))
			modifier.permanentDamageFrac = 1.0
	})
	AddShieldRegenDelayModifier( float function ( entity player ) : ()
	{
		float rate = 1.0

		if (Roguelike_HasMod( player, "health_convert"))
			rate *= 0.75
		
		return rate
	})
	AddShieldRegenRateModifier( float function ( entity player ) : ()
	{
		float rate = 1.0
		
		array<string> mods = []
		
		return rate
	})
	AddDamageByCallback( "player", PlayerDealtDamage )
	AddCallback_Procs( PlayerProcs )
	archonDMGSources = RegisterWeaponDamageSources(
		{
			mp_titanweapon_archon_arc_cannon = "#WPN_TITAN_ARCHON_ARC_CANNON",
			mp_titanweapon_tesla_node = "#WPN_TITAN_TESLA_NODE",
			mp_titanweapon_charge_ball = "#WPN_TITAN_CHARGE_BALL",
			mp_titanweapon_shock_shield = "#WPN_TITAN_SHOCK_SHIELD",
			mp_titanweapon_shock_shield_field = "#FD_UPGRADE_ARCHON_UTILITY_TIER_2",
			mp_titancore_storm_core = "#TITANCORE_STORM",
			mp_titancore_storm_core_smoke = "#GEAR_ARCHON_SMOKE",
			shock_dmg = "Shock"
		}
	)
	AddCallback_OnPlayerRespawned( PlayerDidRespawn )
	#endif
	#if CLIENT
	AddCallback_DisplaySignatureStatusEffect( loadout.primary, void function( var bar, var text, var icon, entity ent, entity player ) : () {
		float cur = RSE_Get( ent, RoguelikeEffect.archon_shock )
		bool active = (RSE_Get( ent, RoguelikeEffect.archon_shock_active ) > 0)
		if (active)
		{
			cur = RSE_Get( ent, RoguelikeEffect.archon_shock_active )
		}
		Hud_SetBarProgress( bar, cur )
		Hud_SetText( text, "Shock")
		Hud_SetImage( icon, $"ui/daze")
		Hud_SetColor( bar, active ? 255 : 32, active ? 255 : 128, 255, 255 )
		Hud_SetColor( text, active ? 255 : 32, active ? 255 : 128, 255, 255 )
	})
	#endif
}

#if SERVER
void function ApplyShock( entity ent, float amount )
{
	if (RSE_Get( ent, RoguelikeEffect.archon_shock_active ) > 0)
		return
	
	if (RSE_Get( ent, RoguelikeEffect.archon_shock) + amount >= 1) // important, dont RSE_Apply then RSE_Stop to save on remotefunc calls
	{
		RSE_Stop( ent, RoguelikeEffect.archon_shock )
		RSE_Apply( ent, RoguelikeEffect.archon_shock_active, 1.0, 10.0, 10.0 )
	}
	else
	{
		RSE_Apply( ent, RoguelikeEffect.archon_shock, RSE_Get( ent, RoguelikeEffect.archon_shock ) + amount )
	}
}

void function PlayerDealtDamage( entity ent, var damageInfo )
{
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	if (Roguelike_HasMod(attacker, "shield_buff") && attacker.IsTitan() && attacker.GetTitanSoul().GetShieldHealth() < 50)
	{
		DamageInfo_AddDamageBonus( damageInfo, 0.25 ) // +DMG%
	}
	if (Roguelike_HasMod( attacker, "shock_cycle") && attacker.IsTitan())
	{
		if (RSE_Get( ent, RoguelikeEffect.archon_shock_active ) > 0 && !archonDMGSources.contains(DamageInfo_GetDamageSourceIdentifier(damageInfo)))
			DamageInfo_AddDamageBonus( damageInfo, 0.35 ) // +DMG%
		else if (RSE_Get( ent, RoguelikeEffect.archon_shock_active ) <= 0)
		{
			Archon_RestoreShield( attacker, int(DamageInfo_GetDamage( damageInfo ) * 0.2) )
		}
	}
}

void function PlayerProcs( entity ent, entity player, var damageInfo, entity procEnt )
{
	if (!procEnt.e.procs.contains("shock_dmg") && RSE_Get( ent, RoguelikeEffect.archon_shock_active ) > 0) // prevent shock from triggering itself...
	{
		procEnt.e.procs.append("shock_dmg")
		float damage = 100
		if (Roguelike_HasMod(player, "shock_power"))
			damage += DamageInfo_GetDamage( damageInfo ) * 0.25

		ent.TakeDamage(damage, player, procEnt, { damageSourceId = eDamageSourceId.shock_dmg, origin = (DamageInfo_GetDamagePosition( damageInfo ) - <0,0,32>) } )
		procEnt.e.procs.fastremovebyvalue("shock_dmg")
	}
}

void function PlayerDidRespawn( entity player )
{
	thread void function(entity player) : ()
	{
		while (IsValid(player) && IsAlive(player))
		{
			player.WaitSignal("LoadoutSwap")
			if (player.IsTitan() && Roguelike_HasMod( player, "other_loadout_shield" ))
				Archon_RestoreShield( player, 200 )
			wait 2
		}
	}(player)
}
#endif

RoguelikeMod function NewMod(string uniqueName)
{
    RoguelikeMod mod = Roguelike_NewMod(uniqueName)

    mod.useLoadoutChipSlot = false
    mod.loadouts = ["mp_titanweapon_archon_arc_cannon"]
    mod.isTitan = true

    return mod
}
