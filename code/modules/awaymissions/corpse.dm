#define G_MALE   0
#define G_FEMALE 1
#define G_BOTH   2

/obj/effect/landmark/corpse
	name = "Unknown"
	var/mobname = "Unknown"  //Unused now but it'd fuck up maps to remove it now

	var/generate_random_mob_name = 0
	var/generate_random_appearance = 1

	var/corpsegender = G_MALE
	var/list/possible_names

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
	AddToProfiler()
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
	else if(islist(possible_names))
		M.real_name = pick(possible_names)

	M.adjustOxyLoss(oxy_dmg) //Kills the new mob
	M.adjustBruteLoss(brute_dmg)
	M.adjustFireLoss(burn_dmg)
	M.adjustToxLoss(toxin_dmg)

	M.iscorpse = 1

	M.pixel_x = src.pixel_x
	M.pixel_y = src.pixel_y

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

		if(istype(L))
			src.corpseuniform = pick(L)

		var/obj/item/clothing/under/U = new src.corpseuniform(M)

		if(suit_sensors != -1)
			U.sensor_mode = suit_sensors

		M.equip_to_slot_or_del(U, slot_w_uniform)

	if(src.corpsesuit)
		var/list/L = src.corpsesuit

		if(istype(L))
			src.corpsesuit = pick(L)
		M.equip_to_slot_or_del(new src.corpsesuit(M), slot_wear_suit)

	if(src.corpseshoes)
		var/list/L = src.corpseshoes

		if(istype(L))
			src.corpseshoes = pick(L)
		M.equip_to_slot_or_del(new src.corpseshoes(M), slot_shoes)

	if(src.corpsegloves)
		var/list/L = src.corpsegloves

		if(istype(L))
			src.corpsegloves = pick(L)
		M.equip_to_slot_or_del(new src.corpsegloves(M), slot_gloves)

	if(src.corpseradio)
		var/list/L = src.corpseradio

		if(istype(L))
			src.corpseradio = pick(L)
		M.equip_to_slot_or_del(new src.corpseradio(M), slot_ears)

	if(src.corpseglasses)
		var/list/L = src.corpseglasses

		if(istype(L))
			src.corpseglasses = pick(L)
		M.equip_to_slot_or_del(new src.corpseglasses(M), slot_glasses)

	if(src.corpsemask)
		var/list/L = src.corpsemask

		if(istype(L))
			src.corpsemask = pick(L)
		M.equip_to_slot_or_del(new src.corpsemask(M), slot_wear_mask)

	if(src.corpsehelmet)
		var/list/L = src.corpsehelmet

		if(istype(L))
			src.corpsehelmet = pick(L)

		M.equip_to_slot_or_del(new src.corpsehelmet(M), slot_head)

	if(src.corpsebelt)
		var/list/L = src.corpsebelt

		if(istype(L))
			src.corpsebelt = pick(L)
		M.equip_to_slot_or_del(new src.corpsebelt(M), slot_belt)

	if(src.corpsepocket1)
		var/list/L = src.corpsepocket1

		if(istype(L))
			src.corpsepocket1 = pick(L)
		M.equip_to_slot_or_del(new src.corpsepocket1(M), slot_r_store)

	if(src.corpsepocket2)
		var/list/L = src.corpsepocket2

		if(istype(L))
			src.corpsepocket2 = pick(L)
		M.equip_to_slot_or_del(new src.corpsepocket2(M), slot_l_store)

	if(src.corpseback)
		var/list/L = src.corpseback

		if(istype(L))
			src.corpseback = pick(L)

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
			W.name = "[W.name] ([W.assignment])"
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



/////////////////Crew//////////////////////

/obj/effect/landmark/corpse/assistant
	name = "Assistant"
	corpseuniform = /obj/item/clothing/under/color/grey
	corpseshoes = /obj/item/clothing/shoes/black
	corpsebelt = /obj/item/weapon/storage/bag/plasticbag
	corpseback = /obj/item/weapon/storage/backpack
	corpseradio = /obj/item/device/radio/headset
	corpseid = 1
	corpseidjob = "Assistant"
	corpseidaccess = "Assistant"

/obj/effect/landmark/corpse/assistant/robust
	corpseuniform = list(/obj/item/clothing/under/syndicate, /obj/item/clothing/under/rank/captain, /obj/item/clothing/under/rank/head_of_personnel, /obj/item/clothing/under/rank/head_of_security, /obj/item/clothing/under/rank/chief_medical_officer, /obj/item/clothing/under/rank/chief_engineer)
	corpsesuit = list(/obj/item/clothing/suit/space/ancient, /obj/item/clothing/suit/space/rig/ror, /obj/item/clothing/suit/space/rig/syndi, /obj/item/clothing/suit/space/rig/atmos/, /obj/item/clothing/suit/armor/captain, /obj/item/clothing/suit/armor/vest, /obj/item/clothing/suit/armor/riot, /obj/item/clothing/suit/armor/laserproof, /obj/item/clothing/suit/armor/hos, /obj/item/clothing/suit/fire/firefighter, /obj/item/clothing/suit/space/rig/security, /obj/item/clothing/suit/space/rig/mining)
	corpseshoes = list(/obj/item/clothing/shoes/magboots, /obj/item/clothing/shoes/magboots/atmos, /obj/item/clothing/shoes/magboots/captain, /obj/item/clothing/shoes/jackboots/knifeholster, /obj/item/clothing/shoes/galoshes)
	corpsegloves = list(/obj/item/clothing/gloves/yellow, /obj/item/clothing/gloves/yellow, /obj/item/clothing/gloves/yellow, /obj/item/clothing/gloves/yellow, /obj/item/clothing/gloves/black, /obj/item/clothing/gloves/captain)
	corpseradio = list(/obj/item/device/radio/headset/headset_sec, /obj/item/device/radio/headset/heads/captain, /obj/item/device/radio/headset/heads/hos, /obj/item/device/radio/headset/heads/hop)
	corpseglasses = list(/obj/item/clothing/glasses/hud/health, /obj/item/clothing/glasses/sunglasses, /obj/item/clothing/glasses/sunglasses/sechud, /obj/item/clothing/glasses/welding)
	corpsemask = list(/obj/item/clothing/mask/cigarette/cigar, /obj/item/clothing/mask/gas, /obj/item/clothing/mask/gas, /obj/item/clothing/mask/gas, /obj/item/clothing/mask/gas/swat, /obj/item/clothing/mask/balaclava)
	corpsehelmet = list(/obj/item/clothing/head/helmet/space/ancient, /obj/item/clothing/head/helmet/space/rig/ror, /obj/item/clothing/head/helmet/space/rig/syndi, /obj/item/clothing/head/helmet/space/rig/atmos, /obj/item/clothing/head/helmet/cap, /obj/item/clothing/head/helmet/tactical, /obj/item/clothing/head/helmet/tactical/HoS/dermal, /obj/item/clothing/head/helmet/siren, /obj/item/clothing/head/collectable/petehat, /obj/item/clothing/head/hardhat/red, /obj/item/clothing/head/welding, /obj/item/clothing/head/collectable/welding, /obj/item/clothing/head/helmet/space/rig/security, /obj/item/clothing/head/helmet/space/rig/mining)
	corpsebelt = list(/obj/item/weapon/gun/energy/laser/retro/ancient, /obj/item/weapon/storage/belt/utility/full, /obj/item/weapon/storage/belt/utility/chief/full, /obj/item/weapon/storage/belt/slim, /obj/item/weapon/storage/belt/security, /obj/item/weapon/gun/energy/gun, /obj/item/weapon/sword, /obj/item/weapon/pickaxe, /obj/item/weapon/gun/energy/taser, /obj/item/weapon/melee/baton/loaded, /obj/item/weapon/melee/telebaton)
	corpsepocket1 = list(/obj/item/device/radio/off, /obj/item/weapon/crowbar, /obj/item/weapon/reagent_containers/hypospray/autoinjector, /obj/item/weapon/reagent_containers/food/snacks/magbites, /obj/item/weapon/reagent_containers/food/snacks/donkpocket, /obj/item/device/flash, /obj/item/weapon/grenade/flashbang, /obj/item/device/flashlight, /obj/item/weapon/handcuffs, /obj/item/weapon/handcuffs/cable/red, /obj/item/weapon/legcuffs/bolas)
	corpsepocket2 = list(/obj/item/device/radio/off, /obj/item/weapon/crowbar, /obj/item/weapon/reagent_containers/hypospray/autoinjector, /obj/item/weapon/reagent_containers/food/snacks/magbites, /obj/item/weapon/reagent_containers/food/snacks/donkpocket, /obj/item/device/flash, /obj/item/weapon/grenade/flashbang, /obj/item/device/flashlight, /obj/item/weapon/handcuffs, /obj/item/weapon/handcuffs/cable/red, /obj/item/weapon/legcuffs/bolas)
	corpseback = list(/obj/item/weapon/fireaxe, /obj/item/weapon/storage/backpack/clown, /obj/item/weapon/storage/backpack/security, /obj/item/weapon/storage/backpack/captain, /obj/item/weapon/storage/backpack/holding, /obj/item/weapon/storage/backpack)
	corpseidaccess = "Captain"

/obj/effect/landmark/corpse/bartender
	name = "Bartender"
	corpseuniform = /obj/item/clothing/under/rank/bartender
	corpsesuit = /obj/item/clothing/suit/armor/vest
	corpseshoes = /obj/item/clothing/shoes/black
	corpseback = /obj/item/weapon/gun/projectile/shotgun/doublebarrel
	corpseradio = /obj/item/device/radio/headset
	corpseid = 1
	corpseidjob = "Bartender"
	corpseidaccess = "Bartender"

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

/obj/effect/landmark/corpse/botanist
	name = "Botanist"
	corpseuniform = /obj/item/clothing/under/rank/hydroponics
	corpsesuit = /obj/item/clothing/suit/apron
	corpseshoes = /obj/item/clothing/shoes/black
	corpsegloves = /obj/item/clothing/gloves/botanic_leather
	corpsehelmet = /obj/item/clothing/head/greenbandana
	corpseback = /obj/item/weapon/storage/backpack
	corpseradio = /obj/item/device/radio/headset
	corpseid = 1
	corpseidjob = "Botanist"
	corpseidaccess = "Botanist"

/obj/effect/landmark/corpse/cargotechnician
	name = "Cargo Technician"
	corpseuniform = /obj/item/clothing/under/rank/cargotech
	corpseshoes = /obj/item/clothing/shoes/black
	corpsehelmet = /obj/item/clothing/head/soft
	corpseback = /obj/item/weapon/storage/backpack
	corpseradio = /obj/item/device/radio/headset
	corpseid = 1
	corpseidjob = "Cargo Technician"
	corpseidaccess = "Cargo Technician"

/obj/effect/landmark/corpse/miner
	name = "Shaft Miner"
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

/obj/effect/landmark/corpse/janitor
	name = "Janitor"
	corpseradio = /obj/item/device/radio/headset/headset_cargo
	corpseuniform = /obj/item/clothing/under/rank/janitor
	corpseshoes = /obj/item/clothing/shoes/black
	corpseback = /obj/item/weapon/storage/backpack
	corpsebelt = /obj/item/weapon/storage/belt/janitor
	corpsegloves = /obj/item/clothing/gloves/purple
	corpsehelmet = /obj/item/clothing/head/soft/purple
	corpseid = 1
	corpseidjob = "Janitor"
	corpseidaccess = "Janitor"

/obj/effect/landmark/corpse/janitor/chempack
	corpseback = /obj/item/weapon/reagent_containers/chempack
	corpseglasses = /obj/item/clothing/glasses/sunglasses

/obj/effect/landmark/corpse/librarian
	name = "Librarian"
	corpseuniform = /obj/item/clothing/under/suit_jacket/red
	corpseshoes = /obj/item/clothing/shoes/black
	corpseback = /obj/item/weapon/storage/backpack
	corpseradio = /obj/item/device/radio/headset
	corpseid = 1
	corpseidjob = "Librarian"
	corpseidaccess = "Librarian"

/obj/effect/landmark/corpse/internalaffairsagent
	name = "Internal Affairs Agent"
	corpseuniform = /obj/item/clothing/under/rank/internalaffairs
	corpsesuit = /obj/item/clothing/suit/storage/internalaffairs
	corpseshoes = /obj/item/clothing/shoes/centcom
	corpseback = /obj/item/weapon/storage/backpack
	corpseradio = /obj/item/device/radio/headset
	corpseglasses = /obj/item/clothing/glasses/sunglasses
	corpseid = 1
	corpseidjob = "Internal Affairs Agent"
	corpseidaccess = "Internal Affairs Agent"

/obj/effect/landmark/corpse/internalaffairsagent/lawyer
	name = "Lawyer"
	corpseuniform = /obj/item/clothing/under/lawyer/bluesuit
	corpsesuit = /obj/item/clothing/suit/storage/lawyer/bluejacket
	corpseshoes = /obj/item/clothing/shoes/leather
	corpseidjob = "Lawyer"

/obj/effect/landmark/corpse/internalaffairsagent/bridgeofficer
	name = "Bridge Officer"
	corpseuniform = /obj/item/clothing/under/bridgeofficer
	corpsesuit = /obj/item/clothing/suit/storage/lawyer/bridgeofficer
	corpsegloves = /obj/item/clothing/gloves/white
	corpsehelmet = /obj/item/clothing/head/soft/bridgeofficer
	corpseidjob = "Bridge Officer"

/obj/effect/landmark/corpse/chaplain
	name = "Chaplain"
	corpseuniform = /obj/item/clothing/under/rank/chaplain
	corpseback = /obj/item/weapon/storage/backpack
	corpseradio = /obj/item/device/radio/headset
	corpseshoes = /obj/item/clothing/shoes/laceup
	corpseid = 1
	corpseidjob = "Chaplain"
	corpseidaccess = "Chaplain"

/obj/effect/landmark/corpse/quartermaster
	name = "Quartermaster"
	corpseuniform = /obj/item/clothing/under/rank/cargo
	corpseshoes = /obj/item/clothing/shoes/black
	corpsegloves = /obj/item/clothing/gloves/black
	corpsehelmet = /obj/item/clothing/head/soft
	corpseback = /obj/item/weapon/storage/backpack
	corpseradio = /obj/item/device/radio/headset
	corpseglasses = /obj/item/clothing/glasses/sunglasses
	corpseid = 1
	corpseidjob = "Quartermaster"
	corpseidaccess = "Quartermaster"

/obj/effect/landmark/corpse/doctor
	name = "Doctor"
	corpseradio = /obj/item/device/radio/headset/headset_med
	corpseuniform = /obj/item/clothing/under/rank/medical
	corpsesuit = /obj/item/clothing/suit/storage/labcoat
	corpseback = /obj/item/weapon/storage/backpack/medic
	corpsepocket1 = /obj/item/device/flashlight/pen
	corpseshoes = /obj/item/clothing/shoes/white
	corpseid = 1
	corpseidjob = "Medical Doctor"
	corpseidaccess = "Medical Doctor"

/obj/effect/landmark/corpse/surgeon
	name = "Surgeon"
	corpseradio = /obj/item/device/radio/headset/headset_med
	corpsehelmet = /obj/item/clothing/head/surgery/green
	corpseuniform = /obj/item/clothing/under/rank/medical/green
	corpsesuit = /obj/item/clothing/suit/storage/labcoat
	corpsepocket1 = /obj/item/weapon/scalpel
	corpseshoes = /obj/item/clothing/shoes/leather
	corpseid = 1
	corpseidjob = "Surgeon"
	corpseidaccess = "Medical Doctor"

/obj/effect/landmark/corpse/chemist
	name = "Chemist"
	corpseradio = /obj/item/device/radio/headset/headset_med
	corpseuniform = /obj/item/clothing/under/rank/chemist
	corpsesuit = /obj/item/clothing/suit/storage/labcoat/chemist
	corpseback = /obj/item/weapon/storage/backpack/medic
	corpseshoes = /obj/item/clothing/shoes/white
	corpseid = 1
	corpseidjob = "Chemist"
	corpseidaccess = "Chemist"

/obj/effect/landmark/corpse/geneticist
	name = "Geneticist"
	corpseradio = /obj/item/device/radio/headset/headset_med
	corpseuniform = /obj/item/clothing/under/rank/geneticist
	corpsesuit = /obj/item/clothing/suit/storage/labcoat/genetics
	corpseback = /obj/item/weapon/storage/backpack/medic
	corpsepocket1 = /obj/item/device/flashlight/pen
	corpseshoes = /obj/item/clothing/shoes/white
	corpseid = 1
	corpseidjob = "Geneticist"
	corpseidaccess = "Geneticist"

/obj/effect/landmark/corpse/virologist
	name = "Virologist"
	corpseradio = /obj/item/device/radio/headset/headset_med
	corpseuniform = /obj/item/clothing/under/rank/virologist
	corpsesuit = /obj/item/clothing/suit/storage/labcoat/virologist
	corpsemask = /obj/item/clothing/mask/surgical
	corpseback = /obj/item/weapon/storage/backpack/medic
	corpsepocket1 = /obj/item/device/flashlight/pen
	corpseshoes = /obj/item/clothing/shoes/white
	corpseid = 1
	corpseidjob = "Geneticist"
	corpseidaccess = "Geneticist"

/obj/effect/landmark/corpse/paramedic
	name = "Paramedic"
	corpseradio = /obj/item/device/radio/headset/headset_med
	corpseuniform = /obj/item/clothing/under/rank/medical/paramedic
	corpsemask = /obj/item/clothing/mask/cigarette
	corpseback = /obj/item/weapon/storage/backpack/medic
	corpsepocket1 = /obj/item/weapon/reagent_containers/hypospray/autoinjector/biofoam_injector
	corpseshoes = /obj/item/clothing/shoes/black
	corpsehelmet = /obj/item/clothing/head/soft/paramedic
	corpseid = 1
	corpseidjob = "Paramedic"
	corpseidaccess = "Paramedic"

/obj/effect/landmark/corpse/paramedic/rig
	corpsesuit = /obj/item/clothing/suit/space/rig/medical
	corpseback = /obj/item/weapon/tank/oxygen
	corpsemask = /obj/item/clothing/mask/breath
	corpsehelmet = /obj/item/clothing/head/helmet/space/rig/medical

/obj/effect/landmark/corpse/cmo
	name = "Chief Medical Officer"
	corpseradio = /obj/item/device/radio/headset/heads/cmo
	corpseuniform = /obj/item/clothing/under/rank/chief_medical_officer
	corpsesuit = /obj/item/clothing/suit/storage/labcoat/cmo
	corpseback = /obj/item/weapon/storage/backpack/medic
	corpsepocket1 = /obj/item/device/flashlight/pen
	corpseshoes = /obj/item/clothing/shoes/brown
	corpseid = 1
	corpseidjob = "Chief Medical Officer"
	corpseidaccess = "Chief Medical Officer"

/obj/effect/landmark/corpse/engineer
	name = "Engineer"
	corpseradio = /obj/item/device/radio/headset/headset_eng
	corpseuniform = /obj/item/clothing/under/rank/engineer
	corpseback = /obj/item/weapon/storage/backpack/industrial
	corpseshoes = /obj/item/clothing/shoes/workboots
	corpsebelt = /obj/item/weapon/storage/belt/utility/full
	corpsegloves = /obj/item/clothing/gloves/yellow
	corpsehelmet = /obj/item/clothing/head/hardhat
	corpseid = 1
	corpseidjob = "Station Engineer"
	corpseidaccess = "Station Engineer"

/obj/effect/landmark/corpse/engineer/rig
	corpsesuit = /obj/item/clothing/suit/space/rig
	corpseback = /obj/item/weapon/tank/oxygen
	corpsemask = /obj/item/clothing/mask/breath
	corpsehelmet = /obj/item/clothing/head/helmet/space/rig

/obj/effect/landmark/corpse/atmostech
	name = "Atmospheric Technician"
	corpseradio = /obj/item/device/radio/headset/headset_eng
	corpseuniform = /obj/item/clothing/under/rank/atmospheric_technician
	corpseback = /obj/item/weapon/storage/backpack/industrial
	corpseshoes = /obj/item/clothing/shoes/workboots
	corpsebelt = /obj/item/weapon/storage/belt/utility/atmostech
	corpsegloves = /obj/item/clothing/gloves/yellow
	corpseid = 1
	corpseidjob = "Atmospheric Technician"
	corpseidaccess = "Atmospheric Technician"

/obj/effect/landmark/corpse/atmostech/rig
	corpsesuit = /obj/item/clothing/suit/space/rig/atmos
	corpseback = /obj/item/weapon/tank/oxygen
	corpsemask = /obj/item/clothing/mask/breath
	corpsehelmet = /obj/item/clothing/head/helmet/space/rig/atmos

/obj/effect/landmark/corpse/mechanic
	name = "Mechanic"
	corpseradio = /obj/item/device/radio/headset/headset_engsci
	corpseuniform = /obj/item/clothing/under/rank/mechanic
	corpseback = /obj/item/weapon/storage/backpack/industrial
	corpseshoes = /obj/item/clothing/shoes/workboots
	corpsebelt = /obj/item/weapon/storage/belt/utility/full
	corpsehelmet = /obj/item/clothing/head/welding
	corpseid = 1
	corpseidjob = "Mechanic"
	corpseidaccess = "Mechanic"

/obj/effect/landmark/corpse/chiefengineer
	name = "Chief Engineer"
	corpseradio = /obj/item/device/radio/headset/heads/ce
	corpseuniform = /obj/item/clothing/under/rank/chief_engineer
	corpseback = /obj/item/weapon/storage/backpack/industrial
	corpseshoes = /obj/item/clothing/shoes/workboots
	corpsebelt = /obj/item/weapon/storage/belt/utility/complete
	corpsegloves = /obj/item/clothing/gloves/yellow
	corpsehelmet = /obj/item/clothing/head/hardhat/white
	corpseid = 1
	corpseidjob = "Chief Engineer"
	corpseidaccess = "Chief Engineer"

/obj/effect/landmark/corpse/chiefengineer/rig
	corpsesuit = /obj/item/clothing/suit/space/rig/elite
	corpseback = /obj/item/weapon/tank/oxygen
	corpsemask = /obj/item/clothing/mask/breath
	corpsehelmet = /obj/item/clothing/head/helmet/space/rig/elite

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

/obj/effect/landmark/corpse/xenoarchaeologist
	name = "Xenoarchaeologist"
	corpseradio = /obj/item/device/radio/headset/headset_sci
	corpseuniform = /obj/item/clothing/under/rank/xenoarch
	corpsesuit = /obj/item/clothing/suit/storage/labcoat/science
	corpseback = /obj/item/weapon/storage/backpack
	corpseshoes = /obj/item/clothing/shoes/white
	corpseid = 1
	corpseidjob = "Xenoarchaeologist"
	corpseidaccess = "Scientist"

/obj/effect/landmark/corpse/xenoarchaeologist/space
	corpsesuit = /obj/item/clothing/suit/space/anomaly
	corpseback = /obj/item/weapon/tank/oxygen
	corpsemask = /obj/item/clothing/mask/breath
	corpsehelmet = /obj/item/clothing/head/helmet/space/anomaly

/obj/effect/landmark/corpse/scientist/voxresearch
	name = "Research Geneticist"
	corpseradio = /obj/item/device/radio/headset/headset_sci
	corpseuniform = /obj/item/clothing/under/rank/scientist
	corpsesuit = /obj/item/clothing/suit/storage/labcoat/science
	corpseback = /obj/item/weapon/storage/backpack
	corpseshoes = /obj/item/clothing/shoes/white
	corpseid = 0

/obj/effect/landmark/corpse/roboticist
	name = "Roboticist"
	corpseradio = /obj/item/device/radio/headset/headset_rob
	corpseuniform = /obj/item/clothing/under/rank/roboticist
	corpsesuit = /obj/item/clothing/suit/storage/labcoat/science
	corpseback = /obj/item/weapon/storage/backpack
	corpseshoes = /obj/item/clothing/shoes/white
	corpseid = 1
	corpseidjob = "Roboticist"
	corpseidaccess = "Roboticist"

/obj/effect/landmark/corpse/researchdirector
	name = "Research Director"
	corpseradio = /obj/item/device/radio/headset/heads/rd
	corpseuniform = /obj/item/clothing/under/rank/research_director
	corpsesuit = /obj/item/clothing/suit/storage/labcoat/rd
	corpseback = /obj/item/weapon/storage/backpack
	corpseshoes = /obj/item/clothing/shoes/brown
	corpseid = 1
	corpseidjob = "Research Director"
	corpseidaccess = "Research Director"

/obj/effect/landmark/corpse/securityofficer
	name = "Security Officer"
	corpseuniform = /obj/item/clothing/under/rank/security
	corpsesuit = /obj/item/clothing/suit/armor/vest/security
	corpseback = /obj/item/weapon/storage/backpack/security
	corpseradio = /obj/item/device/radio/headset/headset_sec
	corpseglasses = /obj/item/clothing/glasses/sunglasses/sechud
	corpsebelt = /obj/item/weapon/storage/belt/security
	corpsegloves = /obj/item/clothing/gloves/black
	corpseshoes = /obj/item/clothing/shoes/jackboots
	corpsepocket1 = /obj/item/weapon/handcuffs
	corpsepocket2 = /obj/item/device/flash
	corpseid = 1
	corpseidjob = "Security Officer"
	corpseidaccess = "Security Officer"

/obj/effect/landmark/corpse/securityofficer/rig
	corpsesuit = /obj/item/clothing/suit/space/rig/security
	corpseback = /obj/item/weapon/tank/oxygen
	corpsemask = /obj/item/clothing/mask/breath
	corpsehelmet = /obj/item/clothing/head/helmet/space/rig/security

/obj/effect/landmark/corpse/detective
	name = "Detective"
	corpseuniform = /obj/item/clothing/under/det
	corpsesuit = /obj/item/clothing/suit/storage/det_suit
	corpseback = /obj/item/weapon/storage/backpack
	corpseradio = /obj/item/device/radio/headset/headset_sec
	corpsegloves = /obj/item/clothing/gloves/black
	corpseshoes = /obj/item/clothing/shoes/brown
	corpsepocket1 = /obj/item/weapon/lighter/zippo
	corpsepocket2 = /obj/item/weapon/reagent_containers/food/drinks/mug/joe
	corpseid = 1
	corpseidjob = "Detective"
	corpseidaccess = "Detective"

/obj/effect/landmark/corpse/headofsecurity
	name = "Head of Security"
	corpseuniform = /obj/item/clothing/under/rank/security
	corpsesuit = /obj/item/clothing/suit/armor/hos/jensen
	corpseback = /obj/item/weapon/storage/backpack/security
	corpseradio = /obj/item/device/radio/headset/heads/hos
	corpseglasses = /obj/item/clothing/glasses/sunglasses/sechud
	corpsebelt = /obj/item/weapon/gun/energy/gun
	corpsegloves = /obj/item/clothing/gloves/black
	corpseshoes = /obj/item/clothing/shoes/jackboots/knifeholster
	corpsepocket1 = /obj/item/weapon/handcuffs
	corpsepocket2 = /obj/item/weapon/implanter/loyalty
	corpseid = 1
	corpseidjob = "Head of Security"
	corpseidaccess = "Head of Security"

/obj/effect/landmark/corpse/headofsecurity/rig
	corpsesuit = /obj/item/clothing/suit/space/rig/security
	corpseback = /obj/item/weapon/tank/oxygen
	corpsemask = /obj/item/clothing/mask/breath
	corpsehelmet = /obj/item/clothing/head/helmet/space/rig/security

/obj/effect/landmark/corpse/headofpersonnel
	name = "Head of Personnel"
	corpseuniform = /obj/item/clothing/under/rank/head_of_personnel
	corpsesuit = /obj/item/clothing/suit/armor/vest
	corpseback = /obj/item/weapon/storage/backpack
	corpseradio = /obj/item/device/radio/headset/heads/hop
	corpseglasses = /obj/item/clothing/glasses/sunglasses
	corpsebelt = /obj/item/weapon/gun/energy/gun
	corpseshoes = /obj/item/clothing/shoes/brown
	corpseid = 1
	corpseidjob = "Head of Personnel"
	corpseidaccess = "Head of Personnel"

/obj/effect/landmark/corpse/captain
	name = "Captain"
	corpseuniform = /obj/item/clothing/under/rank/captain
	corpsesuit = /obj/item/clothing/suit/armor/captain
	corpseback = /obj/item/weapon/storage/backpack/captain
	corpseradio = /obj/item/device/radio/headset/heads/captain
	corpseglasses = /obj/item/clothing/glasses/sunglasses
	corpsebelt = /obj/item/weapon/gun/energy/gun
	corpsemask = /obj/item/clothing/mask/cigarette/cigar
	corpsehelmet = /obj/item/clothing/head/caphat
	corpsegloves = /obj/item/clothing/gloves/captain
	corpseshoes = /obj/item/clothing/shoes/brown
	corpseid = 1
	corpseidjob = "Captain"
	corpseidaccess = "Captain"

/obj/effect/landmark/corpse/captain/rig
	corpseback = /obj/item/weapon/tank/oxygen
	corpsemask = /obj/item/clothing/mask/breath
	corpsehelmet = /obj/item/clothing/head/helmet/space/capspace

/obj/effect/landmark/corpse/waifu
	name = "Waifu"
	corpseuniform = /obj/item/clothing/under/schoolgirl
	corpseshoes = /obj/item/clothing/shoes/kneesocks
	corpsehelmet = /obj/item/clothing/head/kitty
	corpseradio = /obj/item/device/radio/headset
	corpseid = 1
	corpseidjob = "Waifu"
	corpseidaccess = "Assistant"
	corpsegender = G_FEMALE

/obj/effect/landmark/corpse/waifu/secfu //bodybag sold separately.
	corpseuniform = /obj/item/clothing/under/securityskirt/elite
	corpsehelmet = /obj/item/clothing/head/beret/sec
	corpseback = /obj/item/weapon/storage/backpack/security
	corpseradio = /obj/item/device/radio/headset/headset_sec
	corpseglasses = /obj/item/clothing/glasses/sunglasses/sechud
	corpsebelt = /obj/item/weapon/storage/belt/security
	corpsegloves = /obj/item/clothing/gloves/black
	corpseshoes = /obj/item/clothing/shoes/jackboots
	corpsepocket1 = /obj/item/weapon/handcuffs
	corpsepocket2 = /obj/item/device/flash
	corpseid = 1
	name = "Lucy Pinata"
	corpseidjob = "Waifu"
	corpseidaccess = "Security Officer"
	corpsegender = G_FEMALE

/////////////////Non-Crew (but still playable at roundstart)//////////////////////

/obj/effect/landmark/corpse/trader
	name = "Trader"
	mutantrace = "Vox"
	corpseuniform = /obj/item/clothing/under/vox/vox_robes
	corpseshoes = /obj/item/clothing/shoes/magboots/vox
	corpseback = /obj/item/weapon/tank/nitrogen
	corpsemask = /obj/item/clothing/mask/breath/vox
	corpsepocket1 = /obj/item/weapon/coin/trader
	corpsepocket2 = /obj/item/weapon/storage/wallet/random
	corpseid = 1
	corpseidjob = "Trader"
	corpseidaccess = "Trader"

/obj/effect/landmark/corpse/trader/powergaming
	corpsehelmet = /obj/item/clothing/head/helmet/siren
	corpsesuit = /obj/item/clothing/suit/storage/trader
	corpseglasses = /obj/item/clothing/glasses/sunglasses
	corpsepocket1 = /obj/item/weapon/handcuffs
	corpsepocket2 = /obj/item/device/flash

/obj/effect/landmark/corpse/trader/pressure
	corpsehelmet = /obj/item/clothing/head/helmet/space/vox/civ/trader
	corpsesuit = /obj/item/clothing/suit/space/vox/civ/trader

/obj/effect/landmark/corpse/trader/carapace
	corpsehelmet = /obj/item/clothing/head/helmet/space/vox/civ/trader/carapace
	corpsesuit = /obj/item/clothing/suit/space/vox/civ/trader/carapace

/obj/effect/landmark/corpse/trader/medic
	corpsehelmet = /obj/item/clothing/head/helmet/space/vox/civ/trader/medic
	corpsesuit = /obj/item/clothing/suit/space/vox/civ/trader/medic

/obj/effect/landmark/corpse/trader/stealth
	corpsehelmet = /obj/item/clothing/head/helmet/space/vox/civ/trader/stealth
	corpsesuit = /obj/item/clothing/suit/space/vox/civ/trader/stealth

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

/obj/effect/landmark/corpse/nazi
	name = "Nazi"
	corpseshoes = /obj/item/clothing/shoes/jackboots
	corpseuniform = /obj/item/clothing/under/soldieruniform
	corpsehelmet = /obj/item/clothing/head/panzer

/obj/effect/landmark/corpse/nazi/soldier
	name = "Nazi Soldier"
	corpsehelmet = /obj/item/clothing/head/stalhelm
	corpsesuit = /obj/item/clothing/suit/soldiercoat
	corpsegloves = /obj/item/clothing/gloves/black
	corpsemask = /obj/item/clothing/mask/gas

/obj/effect/landmark/corpse/nazi/officer
	name = "Nazi Officer"
	corpseuniform = /obj/item/clothing/under/officeruniform
	corpsehelmet = /obj/item/clothing/head/naziofficer
	corpsesuit = /obj/item/clothing/suit/officercoat
	corpsegloves = /obj/item/clothing/gloves/black
	corpseglasses = /obj/item/clothing/glasses/sunglasses/sechud

/obj/effect/landmark/corpse/nazi/spacetrooper
	name = "Nazi Trooper"
	corpsehelmet = /obj/item/clothing/head/helmet/space/rig/nazi
	corpsesuit = /obj/item/clothing/suit/space/rig/nazi

//////////////////Admin Use//////////////////////////////

/obj/effect/landmark/corpse/ertleader
	name = "Emergency Response Organizer"
	corpseuniform = /obj/item/clothing/under/rank/centcom/captain
	corpsesuit = /obj/item/clothing/suit/armor/swat/officer
	corpseglasses = /obj/item/clothing/glasses/sunglasses/sechud
	corpsehelmet = /obj/item/clothing/head/beret/centcom/captain
	corpseshoes = /obj/item/clothing/shoes/centcom
	corpsebelt = /obj/item/weapon/storage/belt/security

/obj/effect/landmark/corpse/centcom
	name = "Central Commander Green"
	corpseuniform = /obj/item/clothing/under/rank/centcom_commander
	corpseglasses = /obj/item/clothing/glasses/sunglasses/sechud
	corpsemask = /obj/item/clothing/mask/cigarette/cigar/cohiba
	corpsehelmet = /obj/item/clothing/head/centhat
	corpsegloves = /obj/item/clothing/gloves/combat
	corpseshoes = /obj/item/clothing/shoes/combat
	corpsepocket1 = /obj/item/weapon/storage/fancy/matchbox
	corpsebelt = /obj/item/weapon/storage/belt/security

/obj/effect/landmark/corpse/creed
	name = "Major Creed"
	corpseuniform = /obj/item/clothing/under/darkred
	corpsesuit = /obj/item/clothing/suit/armor/hos/jensen
	corpseglasses = /obj/item/clothing/glasses/thermal/eyepatch
	corpsemask = /obj/item/clothing/mask/cigarette/cigar/cohiba
	corpsehelmet = /obj/item/clothing/head/helmet/tactical/HoS/dermal
	corpsegloves = /obj/item/clothing/gloves/combat
	corpseshoes = /obj/item/clothing/shoes/combat
	corpsepocket1 = /obj/item/weapon/storage/fancy/matchbox
	corpsebelt = /obj/item/weapon/storage/belt/security

/obj/effect/landmark/corpse/batman
	name = "Batman"
	corpseuniform = /obj/item/clothing/under/batmansuit
	corpsesuit = /obj/item/clothing/suit/armor/bulletproof
	corpseglasses = /obj/item/clothing/glasses/thermal/jensen
	corpsemask = /obj/item/clothing/mask/gas/swat
	corpsehelmet = /obj/item/clothing/head/batman
	corpsegloves = /obj/item/clothing/gloves/batmangloves
	corpseshoes = /obj/item/clothing/shoes/jackboots/batmanboots
	corpsebelt = /obj/item/weapon/storage/belt/security/batmanbelt

/obj/effect/landmark/corpse/doomguy
	name = "Doomguy"
	corpseuniform = /obj/item/clothing/under/doomguy
	corpsesuit = /obj/item/clothing/suit/armor/doomguy
	corpseglasses = /obj/item/clothing/glasses/thermal/jensen
	corpsehelmet = /obj/item/clothing/head/helmet/doomguy
	corpsegloves = /obj/item/clothing/gloves/doomguy
	corpseshoes = /obj/item/clothing/shoes/combat
	corpsebelt = /obj/item/weapon/storage/belt/security/doomguy

/obj/effect/landmark/corpse/dredd
	name = "Judge Dredd"
	corpseuniform = /obj/item/clothing/under/darkred
	corpsesuit = /obj/item/clothing/suit/armor/xcomsquaddie/dredd
	corpseglasses = /obj/item/clothing/glasses/hud/security
	corpsemask = /obj/item/clothing/mask/gas/swat
	corpsehelmet = /obj/item/clothing/head/helmet/dredd
	corpsegloves = /obj/item/clothing/gloves/combat
	corpseshoes = /obj/item/clothing/shoes/combat
	corpsebelt = /obj/item/weapon/storage/belt/security

/obj/effect/landmark/corpse/jensen
	name = "Agent Jensen"
	corpseuniform = /obj/item/clothing/under/acj
	corpsesuit = /obj/item/clothing/suit/armor/hos/jensen
	corpseglasses = /obj/item/clothing/glasses/hud/security/jensenshades
	corpsehelmet = /obj/item/clothing/head/helmet/tactical/HoS/dermal
	corpsegloves = /obj/item/clothing/gloves/combat
	corpseshoes = /obj/item/clothing/shoes/combat
	corpsebelt = /obj/item/weapon/storage/belt/security

/obj/effect/landmark/corpse/wizard
	name = "Wizard"
	corpseuniform = /obj/item/clothing/under/lightpurple
	corpsesuit = /obj/item/clothing/suit/wizrobe
	corpseback = /obj/item/weapon/storage/backpack
	corpsehelmet = /obj/item/clothing/head/wizard
	corpseshoes = /obj/item/clothing/shoes/sandal

/obj/effect/landmark/corpse/wizard/rig
	corpsesuit = /obj/item/clothing/suit/space/rig/wizard
	corpsehelmet = /obj/item/clothing/head/helmet/space/rig/wizard
	corpseback = /obj/item/weapon/tank/oxygen
	corpsemask = /obj/item/clothing/mask/breath

//////////////////Misc Corpses///////////////////////////

/obj/effect/landmark/corpse/roboticist/spessmart
	corpseidjob = "Spessmart Roboticist"
	generate_random_mob_name = 1
	generate_random_appearance = 1
	brute_dmg = 100
	toxin_dmg = 6

/obj/effect/landmark/corpse/pilot
	name = "pilot"
	corpseradio = /obj/item/device/radio/headset/headset_sec
	corpseuniform = /obj/item/clothing/under/aviatoruniform
	corpseshoes = /obj/item/clothing/shoes/jackboots
	corpsegloves = /obj/item/clothing/gloves/botanic_leather
	corpseglasses = /obj/item/clothing/glasses/sunglasses
	corpsemask = /obj/item/clothing/mask/scarf/red
	corpsepocket1 = /obj/item/ammo_storage/speedloader/a357
	corpsepocket2 = /obj/item/clothing/mask/cigarette/cigar

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

/obj/effect/landmark/corpse/stripper
	name = "Stripper"
	corpsegender = G_FEMALE

	generate_random_mob_name = FALSE
	possible_names = list("Candy", "Glitter", "Diamond", "Sugar", "Angel", "Queenie", "Tiffany", "Kitty")

	generate_random_appearance = TRUE

	corpseuniform = list(/obj/item/clothing/under/swimsuit/purple, /obj/item/clothing/under/swimsuit/green, /obj/item/clothing/under/swimsuit/red)
	corpseshoes = /obj/item/clothing/shoes/kneesocks

/obj/effect/landmark/corpse/stripper/russian
	possible_names = list("Konfetka", "Florida", "Matilda", "Ogonjok", "Almaz", "Kisulja")

	corpsehelmet = list(/obj/item/clothing/head/ushanka, /obj/item/clothing/head/squatter_hat) //heh

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

/obj/effect/landmark/corpse/mutilated
	husk = 1
	brute_dmg = 250
	burn_dmg = 100

/obj/effect/landmark/corpse/catbeast //only good catbeast is a dead one
	name = "Test Subject"
	generate_random_mob_name = 0
	generate_random_appearance = 1
	corpsegender = G_BOTH

	corpseuniform = /obj/item/clothing/under/color/prisoner
	corpsesuit = /obj/item/clothing/suit/straight_jacket
	corpsemask = /obj/item/clothing/mask/muzzle
	corpseglasses = /obj/item/clothing/glasses/sunglasses/blindfold

/obj/effect/landmark/corpse/catbeast/createCorpse()
	if(prob(50))
		corpsemask = null
	if(prob(50))
		corpsesuit = null
	if(prob(50))
		corpseglasses = null

#undef G_MALE
#undef G_FEMALE
#undef G_BOTH
