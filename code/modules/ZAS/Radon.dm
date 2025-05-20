/mob/proc/radon_effects()

/mob/living/radon_effects()
	if(flags & INVULNERABLE)
		return
	if(!src.loc)
		return
	
	
	var/datum/gas_mixture/environment=src.loc.return_air()
	var/molesofradon=(environment?.molar_density(GAS_RADON) || 0)  *CELL_VOLUME
	src.apply_radiation(molesofradon*1.5, RAD_EXTERNAL)