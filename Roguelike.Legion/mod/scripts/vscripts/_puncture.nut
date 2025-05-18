global function Puncture_Init

void function Puncture_Init()
{
    AddDamageCallbackSourceID( eDamageSourceId.mp_titanweapon_predator_cannon, PrimaryDamage )
}

void function PrimaryDamage( entity ent, var damageInfo )
{
    entity attacker = DamageInfo_GetAttacker( damageInfo )
    if (!attacker.IsPlayer())
        return

	int scriptDamageType = DamageInfo_GetCustomDamageType( damageInfo )
	if ( scriptDamageType & DF_EXPLOSION && !IsHumanSized( ent ) ) // DF_KNOCK_BACK filters for powershot???
	{
		RSE_Apply( ent, RoguelikeEffect.legion_puncture, 1.0, 10.0, 10.0 )
	}
}