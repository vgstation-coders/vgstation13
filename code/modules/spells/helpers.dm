/* User_type

 * USER_TYPE_WIZARD 	: a classical wizard spell (found in simple spellbook)
 * USER_TYPE_CULT
 * USER_TYPE_GENETIC
 * USER_TYPE_XENOMORPH
 * USER_TYPE_MALFAI
 * USER_TYPE_VAMPIRE
 * USER_TYPE_SPELLBOOK 	: found in spellbooks
 * USER_TYPE_ARTIFACT  	: used by artifacts
 * USER_TYPE_NOUSER    	: generic/abstract spells
 * USER_TYPE_OTHER 		: misc (not debug)
 */

/proc/getAllSpellsByType(var/type)
	var/list/spell/spellList = list()
	for (var/type_S in typesof(/spell))
		var/spell/S = type_S
		if (initial(S.user_type) == type)
			spellList += S
	return spellList

/proc/getAllWizSpells()
	return getAllSpellsByType(USER_TYPE_WIZARD)
/proc/getAllCultSpells()
	return getAllSpellsByType(USER_TYPE_CULT)
/proc/getAllGeneticSpells()
	return getAllSpellsByType(USER_TYPE_GENETIC)
/proc/getAllMalfSpells()
	return getAllSpellsByType(USER_TYPE_MALFAI)
/proc/getAllXenoSpells()
	return getAllSpellsByType(USER_TYPE_XENOMORPH)
/proc/getAllVampSpells()
	return getAllSpellsByType(USER_TYPE_VAMPIRE)

/mob/proc/has_spell_with_flag(var/spell_flag)
	for(var/spell/S in spell_list)
		if(S.spell_aspect_flags & spell_flag)
			return S
	return 0