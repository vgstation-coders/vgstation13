/mob/living/carbon/monkey
	name = "monkey"
	voice_name = "monkey"
	//speak_emote = list("chimpers")
	icon_state = "monkey1"
	icon = 'icons/mob/monkey.dmi'
	gender = NEUTER
	pass_flags = PASSTABLE
	update_icon = 0		///no need to call regenerate_icon
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/animal/monkey
	species_type = /mob/living/carbon/monkey
	treadmill_speed = 0.8 //Slow apes!
	var/attack_text = "bites"
	var/languagetoadd = LANGUAGE_MONKEY
	var/namenumbers = TRUE
	var/flag = 0

	mob_bump_flag = MONKEY
	mob_swap_flags = MONKEY|SLIME|SIMPLE_ANIMAL
	mob_push_flags = MONKEY|SLIME|SIMPLE_ANIMAL|ALIEN

	flags = HEAR_ALWAYS | PROXMOVE

	size = SIZE_SMALL

	var/canWearClothes = 1
	var/canWearHats = 1
	var/canWearGlasses = 1
	var/canWearMasks = 1
	var/canWearBack = 1

	var/obj/item/clothing/monkeyclothes/uniform = null
	var/obj/item/clothing/head/hat = null
	var/obj/item/clothing/glasses/glasses = null

	var/obj/item/weapon/card/id/wear_id = null // Fix for station bounced radios -- Skie
	var/greaterform = "Human"                  // Used when humanizing a monkey.
	icon_state = "monkey1"
	//var/uni_append = "12C4E2"                // Small appearance modifier for different species.
	var/list/uni_append = list(0x12C,0x4E2)    // Same as above for DNA2.
	var/update_muts = 1                        // Monkey gene must be set at start.
	var/alien = 0								//Used for reagent metabolism.
	var/canPossess = FALSE

/mob/living/carbon/monkey/New()
	var/datum/reagents/R = new/datum/reagents(1000)
	reagents = R
	R.my_atom = src

	if(namenumbers)
		name = "[name] ([rand(1, 1000)])"
	real_name = name

	if (!(dna))
		if(gender == NEUTER)
			setGender(pick(MALE, FEMALE))
		dna = new /datum/dna( null )
		dna.real_name = real_name
		dna.b_type = random_blood_type()
		dna.ResetSE()
		dna.ResetUI()
		//dna.uni_identity = "00600200A00E0110148FC01300B009"
		//dna.SetUI(list(0x006,0x002,0x00A,0x00E,0x011,0x014,0x8FC,0x013,0x00B,0x009))
		//dna.struc_enzymes = "43359156756131E13763334D1C369012032164D4FE4CD61544B6C03F251B6C60A42821D26BA3B0FD6"
		//dna.SetSE(list(0x433,0x591,0x567,0x561,0x31E,0x137,0x633,0x34D,0x1C3,0x690,0x120,0x321,0x64D,0x4FE,0x4CD,0x615,0x44B,0x6C0,0x3F2,0x51B,0x6C6,0x0A4,0x282,0x1D2,0x6BA,0x3B0,0xFD6))
		dna.unique_enzymes = md5(name) //Possibly not working?

		// We're a monkey
		dna.SetSEState(MONKEYBLOCK,   1)
		dna.SetSEValueRange(MONKEYBLOCK,0xDAC, 0xFFF)
		// Fix gender
		dna.SetUIState(DNA_UI_GENDER, gender != MALE, 1)

		// Set the blocks to uni_append, if needed.
		if(uni_append.len>0)
			for(var/b=1;b<=uni_append.len;b++)
				dna.SetUIValue(DNA_UI_LENGTH-(uni_append.len-b),uni_append[b], 1)
		dna.UpdateUI()

		update_muts=1

		add_language(languagetoadd)
		default_language = all_languages[languagetoadd]

	hud_list[HEALTH_HUD]      = image('icons/mob/hud.dmi', src, "hudhealth100")
	hud_list[STATUS_HUD]      = image('icons/mob/hud.dmi', src, "hudhealthy")

	..()
	update_icons()
	return

/mob/living/carbon/monkey/Destroy()
	..()
	uniform = null
	hat = null
	glasses = null

/mob/living/carbon/monkey/abiotic()
	for(var/obj/item/I in held_items)
		if(I.abstract)
			continue

		return 1

	return (wear_mask || back || uniform || hat)

/mob/living/carbon/monkey/punpun
	name = "Pun Pun"
	namenumbers = FALSE

/mob/living/carbon/monkey/punpun/New()
	var/obj/item/clothing/monkeyclothes/suit = new /obj/item/clothing/monkeyclothes
	equip_to_slot(suit, slot_w_uniform)
	..()

/mob/living/carbon/monkey/tajara
	name = "farwa"
	voice_name = "farwa"
	speak_emote = list("mews")
	icon_state = "tajkey1"
	uni_append = list(0x0A0,0xE00) // 0A0E00
	species_type = /mob/living/carbon/monkey/tajara
	languagetoadd = LANGUAGE_CATBEAST
	greaterform = "Tajaran"

/mob/living/carbon/monkey/tajara/New()
	..()
	add_language(LANGUAGE_MOUSE)
	dna.mutantrace = "tajaran"

/mob/living/carbon/monkey/skrell
	name = "neaera"
	voice_name = "neaera"
	speak_emote = list("squicks")
	icon_state = "skrellkey1"
	uni_append = list(0x01C,0xC92) // 01CC92
	species_type = /mob/living/carbon/monkey/skrell
	languagetoadd = LANGUAGE_SKRELLIAN
	greaterform = "Skrell"

/mob/living/carbon/monkey/skrell/New()
	..()
	dna.mutantrace = "skrell"

/mob/living/carbon/monkey/unathi
	name = "stok"
	voice_name = "stok"
	speak_emote = list("hisses")
	icon_state = "stokkey1"
	uni_append = list(0x044,0xC5D) // 044C5D
	canWearClothes = 0
	species_type = /mob/living/carbon/monkey/unathi
	languagetoadd = LANGUAGE_UNATHI
	greaterform = "Unathi"

/mob/living/carbon/monkey/unathi/New()
	..()
	dna.mutantrace = "lizard"

/mob/living/carbon/monkey/grey
	name = "greyling"
	voice_name = "greyling"
	icon_state = "grey"
	canWearGlasses = 0
	languagetoadd = LANGUAGE_GREY
	greaterform = "Grey"

/mob/living/carbon/monkey/grey/passive_emote()
	emote(pick("scratch","jump","roll"))

///mob/living/carbon/monkey/diona/New()
//Moved to it's duplicate declaration modules\mob\living\carbon\monkey\diona.dm

/mob/living/carbon/monkey/base_movement_tally()
	. = ..()
	if(reagents.has_any_reagents(HYPERZINES))
		return // Hyperzine ignores slowdown
	if(istype(loc, /turf/space))
		return // Space ignores slowdown

	if (bodytemperature < 283.222)
		. += (283.222 - bodytemperature) / 10 * 1.75

/mob/living/carbon/monkey/show_inv(mob/living/carbon/user as mob)
	user.set_machine(src)

	var/dat

	for(var/i = 1 to held_items.len) //Hands
		var/obj/item/I = held_items[i]
		dat += "<B>[capitalize(get_index_limb_name(i))]</B> <A href='?src=\ref[src];hands=[i]'>[makeStrippingButton(I)]</A><BR>"

	dat += "<BR><B>Back:</B> <A href='?src=\ref[src];item=[slot_back]'>[makeStrippingButton(back)]</A>"

	dat += "<BR>"

	if(canWearHats)
		dat +=	"<br><b>Headwear:</b> <A href='?src=\ref[src];item=[slot_head]'>[makeStrippingButton(hat)]</A>"

	dat += "<BR><B>Mask:</B> <A href='?src=\ref[src];item=[slot_wear_mask]'>[makeStrippingButton(wear_mask)]</A>"
	if(has_breathing_mask())
		dat += "<BR>[HTMLTAB]&#8627;<B>Internals:</B> [src.internal ? "On" : "Off"]  <A href='?src=\ref[src];internals=1'>(Toggle)</A>"

	if(canWearGlasses)
		dat +=	"<br><b>Glasses:</b> <A href='?src=\ref[src];item=[slot_glasses]'>[makeStrippingButton(glasses)]</A>"

	if(canWearClothes)
		dat +=	"<br><b>Uniform:</b> <A href='?src=\ref[src];item=[slot_w_uniform]'>[makeStrippingButton(uniform)]</A>"

	if(handcuffed || mutual_handcuffs)
		dat += "<BR><B>Handcuffed:</B> <A href='?src=\ref[src];item=[slot_handcuffed]'>Remove</A>"

	dat += {"
	<BR>
	<BR><A href='?src=\ref[user];mach_close=mob\ref[src]'>Close</A>
	"}

	var/datum/browser/popup = new(user, "mob\ref[src]", "[src]", 340, 500)
	popup.set_content(dat)
	popup.open()

//mob/living/carbon/monkey/bullet_act(var/obj/item/projectile/Proj)taken care of in living

/mob/living/carbon/monkey/getarmor(var/def_zone, var/type)

	var/armorscore = 0
	if((def_zone == LIMB_HEAD) || (def_zone == "eyes") || (def_zone == LIMB_HEAD))
		if(hat)
			armorscore = hat.armor[type]
	else
		if(uniform)
			armorscore = uniform.armor[type]
	return armorscore

/mob/living/carbon/monkey/attack_paw(mob/living/M)
	..()

	switch(M.a_intent)
		if(I_HELP)
			help_shake_act(M)
		if(I_HURT)
			M.unarmed_attack_mob(src)
		if(I_DISARM)
			M.disarm_mob(src)
		if(I_GRAB)
			M.grab_mob(src)


/mob/living/carbon/monkey/proc/defense(var/power, var/def_zone)
	var/armor = run_armor_check(def_zone, "melee", "Your armor has protected your [def_zone].", "Your armor has softened hit to your [def_zone].")
	if(armor >= 2)
		return 0
	if(!power)
		return 0

	var/damage = power
	if(armor)
		damage = (damage/(armor+1))
	return damage

/mob/living/carbon/monkey/attack_hand(var/mob/living/carbon/human/M)
	var/touch_zone = get_part_from_limb(M.zone_sel.selecting)
	var/block = 0
	if (M.check_contact_sterility(HANDS) || check_contact_sterility(touch_zone))//only one side has to wear protective clothing to prevent contact infection
		block = 1
	share_contact_diseases(M,block,0)//monkeys can't bleed right now

	switch(M.a_intent)
		if(I_HELP)
			help_shake_act(M)

		if(I_HURT)
			M.unarmed_attack_mob(src)

		if(I_GRAB)
			M.grab_mob(src)

		if(I_DISARM)
			M.disarm_mob(src)
	return

/mob/living/carbon/monkey/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
	switch(M.a_intent)
		if (I_HELP)
			visible_message("<span class='notice'>[M] caresses [src] with its scythe like arm.</span>")

		if (I_HURT)
			return M.unarmed_attack_mob(src)

		if (I_GRAB)
			return M.grab_mob(src)

		if (I_DISARM)
			return M.disarm_mob(src)

/mob/living/carbon/monkey/attack_slime(mob/living/carbon/slime/M)
	M.unarmed_attack_mob(src)

/mob/living/carbon/monkey/attack_ghost(var/mob/dead/observer/O)
	if(canPossess)
		if(!(src.key))
			if(O.can_reenter_corpse)
				var/response = alert(O,"Do you want to take over \the [src]?","Monkey Madness","Yes","No")
				if(response == "Yes")
					if(!(src.key))
						ckey = O.ckey
						canPossess = FALSE
						var/newname = input(src,"Enter a name, or leave blank for the default name.", "Name change","") as text
						newname = copytext(sanitize(newname),1,MAX_NAME_LEN)
						if (newname != "")
							fully_replace_character_name(newname = newname)
					else if(src.key)
						to_chat(src, "<span class='notice'>Somebody jumped your claim on \the [src] and is already controlling it. Try another </span>")
			else if(!(O.can_reenter_corpse))
				to_chat(O,"<span class='notice'>While \the [src] may be mindless, you have recently ghosted and thus are not allowed to take over for now.</span>")



/mob/living/carbon/monkey/attacked_by(var/obj/item/I, var/mob/living/user, var/def_zone, var/originator = null)
	if(!..())
		return

	I.disease_contact(src,get_part_from_limb(def_zone))

/mob/living/carbon/monkey/Stat()
	..()
	if(statpanel("Status"))
		stat(null, text("Intent: []", a_intent))
		stat(null, text("Move Mode: []", m_intent))
		/*if(client && mind)
			if (client.statpanel == "Status")
				if(mind.changeling)
					stat("Chemical Storage", mind.changeling.chem_charges)
					stat("Genetic Damage Time", mind.changeling.geneticdamage)
	return
	*/


/mob/living/carbon/monkey/verb/removeinternal()
	set name = "Remove Internals"
	set category = "IC"
	internal = null
	return

/mob/living/carbon/monkey/var/co2overloadtime = null
/mob/living/carbon/monkey/var/temperature_resistance = T0C+75

/mob/living/carbon/monkey/emp_act(severity)
	for(var/obj/item/stickybomb/B in src)
		if(B.stuck_to)
			visible_message("<span class='warning'>\the [B] stuck on \the [src] suddenly deactivates itself and falls to the ground.</span>")
			B.deactivate()
			B.unstick()

	if(flags & INVULNERABLE)
		return

	if(wear_id)
		wear_id.emp_act(severity)
	..()

/mob/living/carbon/monkey/ex_act(severity)
	if(flags & INVULNERABLE)
		return

	if(!blinded)
		flash_eyes(visual = 1)

	switch(severity)
		if(1.0)
			if (stat != 2)
				adjustBruteLoss(200)
				health = 100 - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()
		if(2.0)
			if (stat != 2)
				adjustBruteLoss(60)
				adjustFireLoss(60)
				health = 100 - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()
		if(3.0)
			if (stat != 2)
				adjustBruteLoss(30)
				health = 100 - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()
			if (prob(50))
				Paralyse(10)
		else
	return

/mob/living/carbon/monkey/blob_act()
	if(flags & INVULNERABLE)
		return
	..()
	playsound(loc, 'sound/effects/blobattack.ogg',50,1)
	if (stat != DEAD)
		adjustFireLoss(60)
		health = 100 - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()
	if (prob(50))
		Paralyse(10)
	if (stat == DEAD && client)
		gib()
		return
	if (stat == DEAD && !client)
		gibs(loc, virus2)
		qdel(src)
		return


/mob/living/carbon/monkey/IsAdvancedToolUser()//Unless its monkey mode monkeys cant use advanced tools
	return dexterity_check()

// Get ALL accesses available.
/mob/living/carbon/monkey/GetAccess()
	var/list/ACL=list()
	var/obj/item/I = get_active_hand()
	if(istype(I))
		ACL |= I.GetAccess()
	return ACL

/mob/living/carbon/monkey/get_visible_id()
	var/id = null
	for(var/obj/item/I in held_items)
		id = I.GetID()
		if(id)
			break
	return id

/mob/living/carbon/monkey/assess_threat(var/obj/machinery/bot/secbot/judgebot, var/lasercolor)
	if(judgebot.emagged == 2)
		return 10 //Everyone is a criminal!
	var/threatcount = 0

	//Lasertag bullshit
	if(lasercolor)
		if(lasercolor == "b")//Lasertag turrets target the opposing team, how great is that? -Sieve
			if(find_held_item_by_type(/obj/item/weapon/gun/energy/tag/red))
				threatcount += 4

		if(lasercolor == "r")
			if(find_held_item_by_type(/obj/item/weapon/gun/energy/tag/blue))
				threatcount += 4

		return threatcount

	//Check for weapons
	if(judgebot.weaponscheck)
		for(var/obj/item/I in held_items)
			if(judgebot.check_for_weapons(I))
				threatcount += 4

	//Loyalty implants imply trustworthyness
	if(isloyal(src))
		threatcount -= 1

	return threatcount

/mob/living/carbon/monkey/dexterity_check()
	if(stat != CONSCIOUS)
		return 0
	if(ticker.mode.name == "monkey")
		return 1
	if(reagents.has_reagent(METHYLIN))
		return 1
	return 0

/mob/living/carbon/monkey/reset_layer()
	if(lying)
		plane = LYING_MOB_PLANE
	else
		plane = MOB_PLANE

/mob/living/carbon/monkey/send_to_past(var/duration)
	..()
	var/static/list/resettable_vars = list(
		"uniform",
		"hat",
		"glasses",
		"wear_id")

	reset_vars_after_duration(resettable_vars, duration)

/mob/living/carbon/monkey/can_wield(obj/item/I)
	//used for making wield exceptions for 2 handed items
	if (istype(I,/obj/item/device/instrument/drum/drum_makeshift/bongos))
		return 1


/mob/living/carbon/monkey/mushroom
	name = "walking mushroom"
	icon = 'icons/mob/animal.dmi'
	icon_state = "mushroom"
	greaterform = "Mushroom"
	species_type = /mob/living/carbon/monkey/mushroom
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/hugemushroomslice/mushroom_man
	canWearClothes = 0
	canWearHats = 0
	canWearGlasses = 0
	canWearMasks = 0
	canWearBack = 0
	held_items = list()
	flag = NO_BREATHE
	canPossess = TRUE
	var/growth = 0

/mob/living/carbon/monkey/mushroom/say()
	return 0

/mob/living/carbon/monkey/mushroom/put_in_hand_check(var/obj/item/W)
	return 0

/mob/living/carbon/monkey/mushroom/Life()
	..()
	if(!isDead() && !gcDestroyed && client)
		var/light_amount = 0
		if(isturf(loc))
			var/turf/T = loc
			light_amount = T.get_lumcount() * 10

		growth = Clamp(growth + rand(1,3)/(10*light_amount>1 ? light_amount : 1),0,100)

		if(growth >= 100)
			growth = 0
			var/mob/living/carbon/human/adult = new()
			adult.alpha = 0
			var/matrix/smol = matrix()
			smol.Scale(0)
			var/matrix/large = matrix()
			var/matrix/M = adult.transform
			M.Scale(0)
			adult.set_species("Mushroom")
			for(var/datum/language/L in languages)
				adult.add_language(L.name)

			adult.regenerate_icons()
			adult.forceMove(get_turf(src))
			animate(src, alpha = 0, transform = smol, time = 3 SECONDS, easing = SINE_EASING)
			animate(adult, alpha = 255, transform = large, time = 3 SECONDS, easing = SINE_EASING)
			transferImplantsTo(adult)
			transferBorers(adult)

			if(istype(loc,/obj/item/weapon/holder))
				var/obj/item/weapon/holder/L = loc
				src.forceMove(get_turf(L))
				L = null
				qdel(L)

			if(mind)
				src.mind.transfer_to(adult)
			adult.fully_replace_character_name(newname = src.real_name)
			src.drop_all()
			qdel(src)

/mob/living/carbon/monkey/mushroom/Stat()
	..()
	if(statpanel("Status"))
		stat(null, "Growth completing: [growth]%")

/mob/living/carbon/monkey/mushroom/passive_emote()
	emote(pick("scratch","jump","roll"))

/mob/living/carbon/monkey/can_be_infected()
	return 1
