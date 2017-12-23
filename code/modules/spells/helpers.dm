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

/proc/getAllWizSpells()
	var/list/spell/spellList = list()
	for (var/type_S in typesof(/spell))
		var/spell/S = type_S
		if (initial(S.user_type) == "wiz")
			spellList += S

	return spellList

/proc/getAllCultSpells()
	var/list/spell/spellList = list()
	for (var/type_S in typesof(/spell))
		var/spell/S = type_S
		if (initial(S.user_type) == "cult")
			spellList += S

	return spellList

/proc/getAllGeneticSpells()
	var/list/spell/spellList = list()
	for (var/type_S in typesof(/spell))
		var/spell/S = type_S
		if (initial(S.user_type) == "genetic")
			spellList += S

	return spellList

/proc/getAllMalfSpells()
	var/list/spell/spellList = list()
	for (var/type_S in typesof(/spell))
		var/spell/S = type_S
		if (initial(S.user_type) == "malf")
			spellList += S

	return spellList