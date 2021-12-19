/obj/item/nanocoral
	name = "nanocoral"
	desc = "Nanocoral is the result of drifting nanites making contact with wreckage and being allowed to absorb the materials and technologies contained. Nanocoral 'blooms' from this points of contact."
	icon = ''
	icon_state = ""
	w_class = W_CLASS_SMALL
	origin_tech = null
	mech_flags = MECH_SCAN_FAIL	//Infinite research mechanic
	var/techMinPower = 1
	var/techMaxPower = 2
	var/list/junk = list(
		/obj/item/stack/cable_coil,
		/obj/item/stack/sheet/metal,
		/obj/item/stack/sheet/glass,
		/obj/item/stack/rods,
		/obj/item/weapon/circuitboard/blank
	)

/obj/item/nanocoral/angler_effect(obj/item/weapon/bait/baitUsed)
	var/coralRange = baitUsed.catchPower + (baitUsed.salvagePower * 3)
	var/salvMod = min(20, baitUsed.salvagePower)
	techMaxPower += min(9, coralRange / (40 - salvMod))
	techMinPower += min(8, coralRange / (60 - (salvMod / 2)))
	techMaxPower = rand(techMinPower, techMaxPower)	//RNGcoral
	techMinPower = rand(1, techMinPower)	//Max being RNG-rolled first is intentional to cause variation
	techRoll()

/obj/item/nanocoral/proc/techRoll()
	var/list/techSchools = techSchoolRoll()
	var/tCount = 1
	for(var/techs in techSchools)
		var/tLevel = 0
		tLevel = rand(techMinPower, techMaxPower)
		tCount++
		if(tCount >= techSchools.len)
			origin_tech += techs + "=[tLevel]"
		else
			origin_tech += techs + "=[tLevel];"

/obj/item/nanocoral/proc/techSchoolRoll()
	var/list/techs = list()
	var/list/potentialTechs = list(Tc_PROGRAMMING, Tc_ENGINEERING, Tc_MATERIALS, Tc_PLASMATECH, Tc_MAGNETS, Tc_BLUESPACE, Tc_COMBAT, Tc_BIOTECH, Tc_POWERSTORAGE, Tc_ANOMALY, Tc_SYNDICATE)
	var/techPow = techMinPower + techMaxPower
	for(var/i=1, i<=3, i++)
		techs += pick_n_take(potentialTechs)
		if(prob(50 - techPow))
			break
	return techs

/obj/item/nanocoral/attackby(var/obj/item/T, var/mob/user)
	..()
	if(istool(T) && !iscablecoil(T))
		to_chat(user, "<span class='notice'>You attempt to salvage some scrap from \the [src].</span>")
		theTool.playtoolsound(src, 50)
		if(do_after(1 SECONDS))
			for(var/i=1 to techMinPower)
				if(attemptSalvage())
					salvageScrap()
				else
					salvageJunk()
			qdel(src)
	if(issolder(T))
		var/obj/item/weapon/solder/S = T
		if(S.remove_fuel(1,user))
			to_chat(user, "<span class='notice'>You delicately try to salvage some circuitry from \the [src].</span>")
			S.playtoolsound(src, 50)
			if(do_after(1 SECONDS))
				if(attemptSalvage())
					salvageCircuit()
				else
					salvageJunk()
				qdel(src)

/obj/item/nanocoral/proc/attemptSalvage()
		var/techPow = techMinPower + techMaxPower
		if(prob(techPow*3))
			return TRUE
	return FALSE

/obj/item/nanocoral/proc/salvageJunk()
	var/theJunk = pick(junk)
	new theJunk(src.loc)

/obj/item/nanocoral/proc/salvageScrap()
	//something with salvage lists, come back to this

/obj/item/nanocoral/proc/salvageCircuit()
	var/obj/item/weapon/circuitboard/theCircuit = pick(existing_typesof(/obj/item/weapon/circuitboard))	//What could go wrong?
	new theCircuit(src.loc)
