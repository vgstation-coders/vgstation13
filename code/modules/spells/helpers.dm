/* User_type

 * wiz : a classical wizard spell (found in simple spellbook)
 * cult
 * genetic
 * alien
 * Spellbook : found in spellbooks
 * artifacts : used by artifacts
 * no_user :generic/abstract spells
 * other : misc (not debug)
 */

/proc/getAllSpellsByType(var/type)
	var/list/spell/spellList = list()
	for (var/type_S in typesof(/spell))
		var/spell/S = type_S
		if (initial(S.user_type) == type)
			spellList += S

	return spellList

/proc/getAllWizSpells()
	return getAllSpellsByType("wiz")
/proc/getAllCultSpells()
	return getAllSpellsByType("cult")
/proc/getAllGeneticSpells()
	return getAllSpellsByType("genetic")
/proc/getAllMalfSpells()
	return getAllSpellsByType("malf")
/proc/getAllXenoSpells()
	return getAllSpellsByType("xeno")