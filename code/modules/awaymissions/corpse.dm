#define G_MALE   0
#define G_FEMALE 1
#define G_BOTH   2

/obj/effect/landmark/corpse
	name = "Unknown"
	var/mobname = "Unknown"  //Unused now but it'd fuck up maps to remove it now

	var/generate_random_mob_name = 0
	var/generate_random_appearance = 0

	var/corpsegender = G_MALE

	var/corpseuniform = null //Set this to an object path to have the slot filled with said object on the corpse.
	var/corpsesuit = null
	var/corpseshoes = null
	var/corpsegloves = null
	var/corpseradio = null
	var/corpseglasses = null
	var/corpsemask = null
	var/corpsehelmet = null
	var/corpsebelt = null
	var/corpsepocket1 = null
	var/corpsepocket2 = null
	var/corpseback = null
	var/corpseid = 0     //Just set to 1 if you want them to have an ID
	var/corpseidjob = null // Needs to be in quotes, such as "Clown" or "Chef." This just determines what the ID reads as, not their access
	var/corpseidaccess = null //This is for access. See access.dm for which jobs give what access. Again, put in quotes. Use "Captain" if you want it to be all access.
	var/corpseidicon = null //For setting it to be a gold, silver, centcomm etc ID
	var/mutantrace = null

	var/suit_sensors = 0 //-1 - default for the jumpsuit. 0, 1, 2, 3 - disabled, binary, vitals, tracker
	var/husk = 0

	var/oxy_dmg = 200
	var/brute_dmg = 0
	var/burn_dmg = 0
	var/toxin_dmg = 0

/obj/effect/landmark/corpse/New()
	if(ticker)
		initialize()

/obj/effect/landmark/corpse/initialize()
	var/mob/living/carbon/human/H = createCorpse()
	equipCorpse(H)


/obj/effect/landmark/corpse/proc/createCorpse() //Creates a mob and checks for gear in each slot before attempting to equip it.
	var/mob/living/carbon/human/M = new /mob/living/carbon/human(loc, mutantrace)

	M.dna.mutantrace = mutantrace
	M.real_name = src.name

	switch(corpsegender)
		if(G_BOTH)
			M.setGender(pick(MALE, FEMALE))
		if(G_MALE)
			M.setGender(MALE)
		if(G_FEMALE)
			M.setGender(FEMALE)

	if(generate_random_mob_name)
		M.real_name = random_name(M.gender, mutantrace)

	M.adjustOxyLoss(oxy_dmg) //Kills the new mob
	M.adjustBruteLoss(brute_dmg)
	M.adjustFireLoss(burn_dmg)
	M.adjustToxLoss(toxin_dmg)

	M.iscorpse = 1

	if(generate_random_appearance)
		M.dna.ResetSE()
		M.dna.ResetUI()
		M.dna.real_name = M.real_name
		M.dna.unique_enzymes = md5(M.real_name)

		M.dna.SetUIState(DNA_UI_GENDER, M.gender != MALE, 1)

		M.dna.UpdateUI()
		M.UpdateAppearance()

	if(husk)
		M.ChangeToHusk()

	qdel(src)
	return M

/obj/effect/landmark/corpse/proc/equipCorpse(mob/living/carbon/human/M)
	if(src.corpseuniform)
		var/list/L = src.corpseuniform

		if(istype(L)) src.corpseuniform = pick(L)

		var/obj/item/clothing/under/U = new src.corpseuniform(M)

		if(suit_sensors != -1)
			U.sensor_mode = suit_sensors

		M.equip_to_slot_or_del(U, slot_w_uniform)

	if(src.corpsesuit)
		var/list/L = src.corpsesuit

		if(istype(L)) src.corpsesuit = pick(L)
		M.equip_to_slot_or_del(new src.corpsesuit(M), slot_wear_suit)

	if(src.corpseshoes)
		var/list/L = src.corpseshoes

		if(istype(L)) src.corpseshoes = pick(L)
		M.equip_to_slot_or_del(new src.corpseshoes(M), slot_shoes)

	if(src.corpsegloves)
		var/list/L = src.corpsegloves

		if(istype(L)) src.corpsegloves = pick(L)
		M.equip_to_slot_or_del(new src.corpsegloves(M), slot_gloves)

	if(src.corpseradio)
		var/list/L = src.corpseradio

		if(istype(L)) src.corpseradio = pick(L)
		M.equip_to_slot_or_del(new src.corpseradio(M), slot_ears)

	if(src.corpseglasses)
		var/list/L = src.corpseglasses

		if(istype(L)) src.corpseglasses = pick(L)
		M.equip_to_slot_or_del(new src.corpseglasses(M), slot_glasses)

	if(src.corpsemask)
		var/list/L = src.corpsemask

		if(istype(L)) src.corpsemask = pick(L)
		M.equip_to_slot_or_del(new src.corpsemask(M), slot_wear_mask)

	if(src.corpsehelmet)
		var/list/L = src.corpsehelmet

		if(istype(L)) src.corpsehelmet = pick(L)

		M.equip_to_slot_or_del(new src.corpsehelmet(M), slot_head)

	if(src.corpsebelt)
		var/list/L = src.corpsebelt

		if(istype(L)) src.corpsebelt = pick(L)
		M.equip_to_slot_or_del(new src.corpsebelt(M), slot_belt)

	if(src.corpsepocket1)
		var/list/L = src.corpsepocket1

		if(istype(L)) src.corpsepocket1 = pick(L)
		M.equip_to_slot_or_del(new src.corpsepocket1(M), slot_r_store)

	if(src.corpsepocket2)
		var/list/L = src.corpsepocket2

		if(istype(L)) src.corpsepocket2 = pick(L)
		M.equip_to_slot_or_del(new src.corpsepocket2(M), slot_l_store)

	if(src.corpseback)
		var/list/L = src.corpseback

		if(istype(L)) src.corpseback = pick(L)

		M.equip_to_slot_or_del(new src.corpseback(M), slot_back)

	if(src.corpseid == 1)
		var/obj/item/weapon/card/id/W = new(M)
		W.name = "[M.real_name]'s ID Card"
		var/datum/job/jobdatum
		for(var/jobtype in typesof(/datum/job))
			var/datum/job/J = new jobtype
			if(J.title == corpseidaccess)
				jobdatum = J
				break
		if(src.corpseidicon)
			W.icon_state = corpseidicon
		if(src.corpseidaccess)
			if(jobdatum)
				W.access = jobdatum.get_access()
			else
				W.access = list()
		if(corpseidjob)
			W.assignment = corpseidjob
		W.registered_name = M.real_name
		M.equip_to_slot_or_del(W, slot_wear_id)

// I'll work on making a list of corpses people request for maps, or that I think will be commonly used. Syndicate operatives for example.





/obj/effect/landmark/corpse/syndicatesoldier
	name = "Syndicate Operative"
	corpseuniform = /obj/item/clothing/under/syndicate
	corpsesuit = /obj/item/clothing/suit/armor/vest
	corpseshoes = /obj/item/clothing/shoes/swat
	corpsegloves = /obj/item/clothing/gloves/swat
	corpseradio = /obj/item/device/radio/headset
	corpsemask = /obj/item/clothing/mask/gas
	corpsehelmet = /obj/item/clothing/head/helmet/tactical/swat
	corpseback = /obj/item/weapon/storage/backpack
	corpseid = 1
	corpseidjob = "Operative"
	corpseidaccess = "Syndicate"



/obj/effect/landmark/corpse/syndicatecommando
	name = "Syndicate Commando"
	corpseuniform = /obj/item/clothing/under/syndicate
	corpsesuit = /obj/item/clothing/suit/space/rig/syndi
	corpseshoes = /obj/item/clothing/shoes/swat
	corpsegloves = /obj/item/clothing/gloves/swat
	corpseradio = /obj/item/device/radio/headset
	corpsemask = /obj/item/clothing/mask/gas/syndicate
	corpsehelmet = /obj/item/clothing/head/helmet/space/rig/syndi
	corpseback = /obj/item/weapon/tank/jetpack/oxygen
	corpsepocket1 = /obj/item/weapon/tank/emergency_oxygen
	corpseid = 1
	corpseidjob = "Operative"
	corpseidaccess = "Syndicate"



///////////Civilians//////////////////////

/obj/effect/landmark/corpse/chef
	name = "Chef"
	corpseuniform = /obj/item/clothing/under/rank/chef
	corpsesuit = /obj/item/clothing/suit/chef/classic
	corpseshoes = /obj/item/clothing/shoes/black
	corpsehelmet = /obj/item/clothing/head/chefhat
	corpseback = /obj/item/weapon/storage/backpack
	corpseradio = /obj/item/device/radio/headset
	corpseid = 1
	corpseidjob = "Chef"
	corpseidaccess = "Chef"


/obj/effect/landmark/corpse/doctor
	name = "Doctor"
	corpseradio = /obj/item/device/radio/headset/headset_med
	corpseuniform = /obj/item/clothing/under/rank/medical
	corpsesuit = /obj/item/clothing/suit/storage/labcoat
	corpseback = /obj/item/weapon/storage/backpack/medic
	corpsepocket1 = /obj/item/device/flashlight/pen
	corpseshoes = /obj/item/clothing/shoes/black
	corpseid = 1
	corpseidjob = "Medical Doctor"
	corpseidaccess = "Medical Doctor"

/obj/effect/landmark/corpse/engineer
	name = "Engineer"
	corpseradio = /obj/item/device/radio/headset/headset_eng
	corpseuniform = /obj/item/clothing/under/rank/engineer
	corpseback = /obj/item/weapon/storage/backpack/industrial
	corpseshoes = /obj/item/clothing/shoes/orange
	corpsebelt = /obj/item/weapon/storage/belt/utility/full
	corpsegloves = /obj/item/clothing/gloves/yellow
	corpsehelmet = /obj/item/clothing/head/hardhat
	corpseid = 1
	corpseidjob = "Station Engineer"
	corpseidaccess = "Station Engineer"

/obj/effect/landmark/corpse/engineer/rig
	corpsesuit = /obj/item/clothing/suit/space/rig
	corpsemask = /obj/item/clothing/mask/breath
	corpsehelmet = /obj/item/clothing/head/helmet/space/rig

/obj/effect/landmark/corpse/clown
	name = "Clown"
	corpseuniform = /obj/item/clothing/under/rank/clown
	corpseshoes = /obj/item/clothing/shoes/clown_shoes
	corpseradio = /obj/item/device/radio/headset
	corpsemask = /obj/item/clothing/mask/gas/clown_hat
	corpsepocket1 = /obj/item/weapon/bikehorn
	corpseback = /obj/item/weapon/storage/backpack/clown
	corpseid = 1
	corpseidjob = "Clown"
	corpseidaccess = "Clown"

/obj/effect/landmark/corpse/mime
	name = "Mime"
	corpseuniform = /obj/item/clothing/under/mime
	corpseshoes = /obj/item/clothing/shoes/black
	corpseradio = /obj/item/device/radio/headset
	corpsemask = /obj/item/clothing/mask/gas/mime
	corpsegloves = /obj/item/clothing/gloves/white/stunglove // Spawn with empty, crappy batteries.
	corpseback = /obj/item/weapon/storage/backpack
	corpseid = 1
	corpseidjob = "Mime"
	corpseidaccess = "Mime"

/obj/effect/landmark/corpse/scientist
	name = "Scientist"
	corpseradio = /obj/item/device/radio/headset/headset_sci
	corpseuniform = /obj/item/clothing/under/rank/scientist
	corpsesuit = /obj/item/clothing/suit/storage/labcoat/science
	corpseback = /obj/item/weapon/storage/backpack
	corpseshoes = /obj/item/clothing/shoes/white
	corpseid = 1
	corpseidjob = "Scientist"
	corpseidaccess = "Scientist"

/obj/effect/landmark/corpse/scientist/voxresearch
	name = "Research Geneticist"
	corpseradio = /obj/item/device/radio/headset/headset_sci
	corpseuniform = /obj/item/clothing/under/rank/scientist
	corpsesuit = /obj/item/clothing/suit/storage/labcoat/science
	corpseback = /obj/item/weapon/storage/backpack
	corpseshoes = /obj/item/clothing/shoes/white
	corpseid = 0
	
/obj/effect/landmark/corpse/miner
	corpseradio = /obj/item/device/radio/headset/headset_mining
	corpseuniform = /obj/item/clothing/under/rank/miner
	corpsegloves = /obj/item/clothing/gloves/black
	corpseback = /obj/item/weapon/storage/backpack/industrial
	corpseshoes = /obj/item/clothing/shoes/black
	corpseid = 1
	corpseidjob = "Shaft Miner"
	corpseidaccess = "Shaft Miner"

/obj/effect/landmark/corpse/miner/rig
	corpsesuit = /obj/item/clothing/suit/space/rig/mining
	corpsemask = /obj/item/clothing/mask/breath
	corpsehelmet = /obj/item/clothing/head/helmet/space/rig/mining


/////////////////Officers//////////////////////

/obj/effect/landmark/corpse/bridgeofficer
	name = "Bridge Officer"
	corpseradio = /obj/item/device/radio/headset/heads/hop
	corpseuniform = /obj/item/clothing/under/rank/centcom_officer
	corpsesuit = /obj/item/clothing/suit/armor/bulletproof
	corpseshoes = /obj/item/clothing/shoes/black
	corpseglasses = /obj/item/clothing/glasses/sunglasses
	corpseid = 1
	corpseidjob = "Bridge Officer"
	corpseidaccess = "Captain"

/obj/effect/landmark/corpse/commander
	name = "Commander"
	corpseuniform = /obj/item/clothing/under/rank/centcom_commander
	corpsesuit = /obj/item/clothing/suit/armor/bulletproof
	corpseradio = /obj/item/device/radio/headset/heads/captain
	corpseglasses = /obj/item/clothing/glasses/eyepatch
	corpsemask = /obj/item/clothing/mask/cigarette/cigar/cohiba
	corpsehelmet = /obj/item/clothing/head/centhat
	corpsegloves = /obj/item/clothing/gloves/swat
	corpseshoes = /obj/item/clothing/shoes/swat
	corpsepocket1 = /obj/item/weapon/lighter/zippo
	corpseid = 1
	corpseidjob = "Commander"
	corpseidaccess = "Captain"

/////////////////Simple-Mob Corpses/////////////////////

/obj/effect/landmark/corpse/pirate
	name = "Pirate"
	corpseuniform = /obj/item/clothing/under/pirate
	corpseshoes = /obj/item/clothing/shoes/jackboots
	corpseglasses = /obj/item/clothing/glasses/eyepatch
	corpsehelmet = /obj/item/clothing/head/bandana

/obj/effect/landmark/corpse/pirate
	name = "Pirate"
	corpseuniform = /obj/item/clothing/under/pirate
	corpseshoes = /obj/item/clothing/shoes/jackboots
	corpseglasses = /obj/item/clothing/glasses/eyepatch
	corpsehelmet = /obj/item/clothing/head/bandana

/obj/effect/landmark/corpse/pirate/ranged
	name = "Pirate Gunner"
	corpsesuit = /obj/item/clothing/suit/pirate
	corpsehelmet = /obj/item/clothing/head/pirate

/obj/effect/landmark/corpse/russian
	name = "Russian"
	corpseuniform = /obj/item/clothing/under/soviet
	corpseshoes = /obj/item/clothing/shoes/jackboots
	corpsehelmet = /obj/item/clothing/head/bearpelt/real

/obj/effect/landmark/corpse/russian/ranged
	corpsehelmet = /obj/item/clothing/head/ushanka

//////////////////Misc Corpses///////////////////////////

/obj/effect/landmark/corpse/civilian //Random corpse!
	name = "Civilian"
	generate_random_mob_name = 1
	generate_random_appearance = 1
	corpsegender = G_BOTH

	corpseuniform = list(/obj/item/clothing/under/aqua, /obj/item/clothing/under/casualhoodie, /obj/item/clothing/under/casualwear,\
	/obj/item/clothing/under/darkblue, /obj/item/clothing/under/darkred, /obj/item/clothing/under/libertyshirt,\
	/obj/item/clothing/under/keyholesweater, /obj/item/clothing/under/greaser, /obj/item/clothing/under/russobluecamooutfit,\
	/obj/item/clothing/under/sl_suit, /obj/item/clothing/under/waiter)

	corpsehelmet = list(/obj/item/clothing/head/bandana, /obj/item/clothing/head/beret, /obj/item/clothing/head/cowboy, /obj/item/clothing/head/fedora,\
	/obj/item/clothing/head/flatcap, /obj/item/clothing/head/russobluecamohat)

	corpsegloves = list(/obj/item/clothing/gloves/black, /obj/item/clothing/gloves/grey, /obj/item/clothing/gloves/green, /obj/item/clothing/gloves/orange, /obj/item/clothing/gloves/purple,\
	/obj/item/clothing/gloves/red, /obj/item/clothing/gloves/latex)

	corpseglasses = list(/obj/item/clothing/glasses/gglasses, /obj/item/clothing/glasses/hud/health, /obj/item/clothing/glasses/monocle, /obj/item/clothing/glasses/regular, /obj/item/clothing/glasses/regular/hipster,\
	/obj/item/clothing/glasses/science, /obj/item/clothing/glasses/sunglasses, /obj/item/clothing/glasses/sunglasses/big)

	corpseshoes = list(/obj/item/clothing/shoes/black, /obj/item/clothing/shoes/blue, /obj/item/clothing/shoes/brown, /obj/item/clothing/shoes/combat, /obj/item/clothing/shoes/galoshes, /obj/item/clothing/shoes/green,\
	/obj/item/clothing/shoes/jackboots, /obj/item/clothing/shoes/laceup, /obj/item/clothing/shoes/leather, /obj/item/clothing/shoes/orange, /obj/item/clothing/shoes/purple, /obj/item/clothing/shoes/red, /obj/item/clothing/shoes/white)

	corpsesuit = list(/obj/item/clothing/suit/doshjacket, /obj/item/clothing/suit/ianshirt, /obj/item/clothing/suit/simonjacket, /obj/item/clothing/suit/storage/lawyer/bluejacket, /obj/item/clothing/suit/storage/lawyer/purpjacket)

	corpsemask = /obj/item/clothing/mask/breath

/obj/effect/landmark/corpse/vox
	name = "Dead vox"
	mutantrace = "Vox"
	generate_random_mob_name = 1
	generate_random_appearance = 1
	corpsegender = G_BOTH
	burn_dmg = 100

/obj/effect/landmark/corpse/civilian/New()
	corpseuniform += existing_typesof(/obj/item/clothing/under/color)
	corpsehelmet += existing_typesof(/obj/item/clothing/head/soft)

	return ..()

/obj/effect/landmark/corpse/civilian/createCorpse()
	. = ..()

	var/mob/M = .
	if(M.gender == FEMALE)
		corpseuniform += existing_typesof(/obj/item/clothing/under/dress)

	if(prob(50))
		corpsemask = null
	if(prob(60))
		corpsesuit = null
	if(prob(60))
		corpsehelmet = null
	if(prob(70))
		corpsegloves = null
	if(prob(80))
		corpseglasses = null

#undef G_MALE
#undef G_FEMALE
#undef G_BOTH
