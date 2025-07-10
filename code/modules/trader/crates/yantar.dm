/obj/structure/closet/crate/medical/yantar
	name = "Yantar medical crate"
	desc = "From the forbidden 'X' laboratory focused on medical research."
	has_lock_type = null

var/global/list/yantar_stuff = list(
	//2 of a kind
	/obj/item/weapon/depocket_wand/suit,/obj/item/weapon/depocket_wand/suit,
	//1 of a kind
	/obj/item/weapon/storage/trader_chemistry,
	/obj/structure/closet/crate/flatpack/ancient/chemmaster_electrolyzer,
	/obj/structure/largecrate/secure/frankenstein,
	/obj/item/weapon/reagent_containers/hypospray/autoinjector/self_refilling,
	/obj/item/weapon/melee/defibrillator/advanced,
	/obj/item/weapon/virusdish/super_meme,
	/obj/item/weapon/storage/panacea_storage,
	/obj/item/device/antibody_resetter,
	/obj/item/weapon/storage/box/advanced_surgeon
	)

var/global/list/yantar_freebies = list(
	/obj/item/weapon/medbot_cube,
	/obj/item/weapon/medbot_cube,
	/obj/item/weapon/medbot_cube,
	/obj/item/weapon/storage/firstaid/adv,
	/obj/item/weapon/storage/firstaid/adv,
	/obj/item/weapon/storage/firstaid/adv
)

/obj/structure/closet/crate/medical/yantar/New()
	..()
	for(var/i = 1 to 6)
		if(!yantar_stuff.len)
			return
		var/path = pick_n_take(yantar_stuff)
		new path(src)
	for(var/i = 1 to 3)
		if(!yantar_freebies.len)
			return
		var/freebie_path = pick_n_take(yantar_freebies)
		new freebie_path(src)

/obj/item/weapon/storage/trader_chemistry
	name = "chemist's pallet"
	desc = "Everything you need to make art."
	icon = 'icons/obj/storage/smallboxes.dmi'
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/boxes_and_storage.dmi', "right_hand" = 'icons/mob/in-hand/right/boxes_and_storage.dmi')
	icon_state = "box_of_doom"
	item_state = "box_of_doom"

/obj/item/weapon/storage/trader_chemistry/New()
	..()
	new /obj/item/weapon/reagent_containers/glass/bottle/peridaxon(src)
	new /obj/item/weapon/reagent_containers/glass/bottle/rezadone(src)
	new /obj/item/weapon/reagent_containers/glass/bottle/nanobotssmall(src)
	new /obj/item/weapon/reagent_containers/glass/beaker/large/supermatter(src)
	new /obj/item/weapon/reagent_containers/glass/beaker/bluespace(src)
	new /obj/item/weapon/reagent_containers/glass/jar/erlenmeyer(src)

/obj/structure/largecrate/secure/frankenstein
	name = "medical livestock crate"
	desc = "An access-locked crate containing medical horrors. Handlers are advised to scream 'It's alive!' repeatedly."
	req_access = list(access_surgery)
	mob_path = null
	bonus_path = /mob/living/carbon/human/frankenstein

/obj/item/weapon/depocket_wand/suit
	name = "suit sensing wand"
	desc = "Used by medical staff to ensure compliance with vitals tracking regulations and to save vocal cord wear from demanding it over communications systems."
	var/wand_mode = 3

/obj/item/weapon/depocket_wand/suit/attack_self(mob/user)
	var/static/list/modes = list("Off", "Binary sensors", "Vitals tracker", "Tracking beacon")
	var/switchMode = input("Select a sensor mode:", "Suit Sensor Mode", modes[wand_mode + 1]) in modes
	if(user.incapacitated())
		return
	wand_mode = modes.Find(switchMode) - 1

	switch(wand_mode)
		if(0)
			to_chat(user, "<span class='notice'>\The [src] will now disable suit remote sensing equipment.</span>")
		if(1)
			to_chat(user, "<span class='notice'>\The [src] will now make suits report whether the wearer is live or dead.</span>")
		if(2)
			to_chat(user, "<span class='notice'>\The [src] will now make suits report vital lifesigns.</span>")
		if(3)
			to_chat(user, "<span class='notice'>\The [src] will now make suits report vital lifesigns as well as coordinate positions.</span>")

/obj/item/weapon/depocket_wand/suit/scan(mob/living/carbon/human/H, mob/living/user)
	var/obj/item/clothing/under/suit = H.w_uniform
	if(!suit)
		to_chat(user, "<span class='warning'>\The [H] is not wearing a suit.</span>")
		return
	if(!suit.has_sensor)
		to_chat(user, "<span class='warning'>\The [H]'s suit does not have sensors.</span>")
		return
	if(suit.has_sensor >= 2)
		to_chat(user, "<span class='warning'>\The [H]'s suit sensor controls are locked.</span>")
		return
	suit.sensor_mode = wand_mode
	switch(suit.sensor_mode)
		if(0)
			user.visible_message("<span class='danger'>[user] has set [H]'s suit sensors to disable suit remote sensing equipment with \the [src].</span>",\
								"<span class='danger'>You set [H]'s sensors to disable suit remote sensing equipment.</span>")
		if(1)
			user.visible_message("<span class='danger'>[user] has set [H]'s suit sensors to whether the wearer is live or dead with \the [src].</span>",\
								"<span class='danger'>You set [H]'s sensors to report whether the wearer is live or dead.</span>")
		if(2)
			user.visible_message("<span class='danger'>[user] has set [H]'s suit sensors to report vital lifesigns with \the [src].</span>",\
								"<span class='danger'>You set [H]'s sensors to report vital lifesigns.</span>")
		if(3)
			user.visible_message("<span class='danger'>[user] has set [H]'s suit sensors to report vital lifesigns as well as coordinate positions with \the [src].</span>",\
								"<span class='danger'>You set [H]'s sensors to report vital lifesigns as well as coordinate positions.</span>")
	H.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their sensors set to [wand_mode] by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Set [H.name]'s suit sensors ([H.ckey]).</font>")
	log_attack("[user.name] ([user.ckey]) has set [H.name]'s suit sensors ([H.ckey]) to [wand_mode].")


//Autoinjector that self-recharges with Doctor's Delight every 5 minutes. Useful to carry around in an emergency without having to find a new one.
/obj/item/weapon/reagent_containers/hypospray/autoinjector/self_refilling
	name = "self-refilling autoinjector"
	desc = "Created in the 'X' laboratory, this device uses a miniaturized hybrid-substance dispenser and a radio-isotope thermoelectric setup to slowly refill itself. However, due to a design flaw, it will not permit injection until it is fully refueled."
	mech_flags = MECH_SCAN_FAIL
	item_state = "hypo_refilling"
	icon_state = "hypo_refilling"
	starting_materials = list(MAT_IRON = 50, MAT_GLASS = 50, MAT_URANIUM = 50, MAT_DIAMOND = 50)
	origin_tech = Tc_BIOTECH + "=5" + Tc_ANOMALY + "=2"
	examine_text = FALSE
	refill_reagent_list = list(DOCTORSDELIGHT = 5)
	var/max_charge = 150 //1 processing tick = 2 seconds. 150 ticks = 300 seconds = 5 minutes
	var/charge = 150 //Once it is equal to max_charge it is ready to inject

/obj/item/weapon/reagent_containers/hypospray/autoinjector/self_refilling/New()
	..()
	processing_objects.Add(src)

/obj/item/weapon/reagent_containers/hypospray/autoinjector/self_refilling/process()
	if(reagents.total_volume < reagents.maximum_volume)
		charge++
		if(charge >= max_charge)
			reagent_refill()
			update_icon()

/obj/item/weapon/reagent_containers/hypospray/autoinjector/self_refilling/update_icon()
	icon_state = "hypo_refilling[charge >= max_charge ? 1 : 0]"

/obj/item/weapon/reagent_containers/hypospray/autoinjector/self_refilling/attack(mob/M, mob/user)
	..()
	if(charge >= max_charge) //We're only doing all of this when the autoinjector has been activated
		if(reagents.total_volume < reagents.maximum_volume) //There's less chems than there is capacity, start refilling
			if(reagents.total_volume > 0) //In the rare case that an injector failed to fully spend itself, add some charge proportional to how many reagents there are
				charge = round(reagents.total_volume * (max_charge/reagents.maximum_volume))
			else
				charge = 0
			update_icon()

/obj/item/weapon/reagent_containers/hypospray/autoinjector/self_refilling/examine(mob/user)
	..()
	if(charge <= max_charge) //It is still charging
		var/time_left = (max_charge - charge) * 2
		to_chat(user, "<span class='info'>\The [src] will recharge in [time_left] seconds.</span>")
	else
		to_chat(user, "<span class='info'>It is ready for injection.</span>")


//Advanced Defibrillator, passively recharges off of the local area's power and works through clothes. Also works a second faster.
/obj/item/weapon/melee/defibrillator/advanced
	name = "advanced emergency defibrillator"
	desc = "An experimental improvement over the regular defibrillator, this variant uses a form of 'bluespace lightning' that skips the patient's clothes, allowing defibrillation while wearing clothes. In addition, it also makes use of a miniaturized Tesla Energy Relay to slowly drain an area's power to replenish its charges, and it works faster than conventional defibrillators."
	icon_state = "advanced_defibpaddlein_full"
	mech_flags = MECH_SCAN_FAIL
	ignores_clothes = TRUE
	defib_delay = 2 SECONDS
	var/tick = 0
	var/ticks_required = 10 //20 seconds

/obj/item/weapon/melee/defibrillator/advanced/New()
	..()
	processing_objects.Add(src)

/obj/item/weapon/melee/defibrillator/advanced/process()
	if(charges < initial(charges))
		tick++
		if(tick >= ticks_required) //Ready to receive extra energy
			//Now copy most of the Tesla Energy Relay code
			var/area/A = get_area(src)
			if(A)
				var/pow_chan
				for(var/c in list(EQUIP,ENVIRON,LIGHT)) //Draw from one of these, whichever is active
					if(A.powered(c))
						pow_chan = c
						break
				if(pow_chan)
					charges++
					tick = 0
					A.use_power(150, pow_chan)
					update_icon()
				else
					tick = ticks_required
	else //Already full of charges
		tick = 0

/obj/item/weapon/melee/defibrillator/advanced/update_icon()
	icon_state = "advanced_defib"
	if(ready)
		icon_state += "paddleout"
	else
		icon_state += "paddlein"
	switch(charges/initial(charges))
		if(0.7 to INFINITY)
			icon_state += "_full"
		if(0.4 to 0.6)
			icon_state += "_half"
		if(0.01 to 0.3)
			icon_state += "_low"
		else
			icon_state += "_empty"

/obj/item/weapon/virusdish/super_meme
	name = "anomalous memetic disease growth dish"
	desc = "Created to solve the medical dilemma of a beneficial disease not spreading fast enough, this dish contains an anomalous variant of a memetic disease that is able to cause a far wider variety of symptoms."
	mech_flags = MECH_SCAN_FAIL

/obj/item/weapon/virusdish/super_meme/New(loc)
	..()
	contained_virus = new /datum/disease2/disease/meme/super
	//Copypaste the random virus dish, except that antigens can only be the rare sort
	var/list/anti = list(
		ANTIGEN_BLOOD	= 0,
		ANTIGEN_COMMON	= 0,
		ANTIGEN_RARE	= 1,
		ANTIGEN_ALIEN	= 0,
	)
	var/list/bad = list(
		EFFECT_DANGER_HELPFUL	= 1,
		EFFECT_DANGER_FLAVOR	= 2,
		EFFECT_DANGER_ANNOYING	= 2,
		EFFECT_DANGER_HINDRANCE	= 2,
		EFFECT_DANGER_HARMFUL	= 2,
		EFFECT_DANGER_DEADLY	= 0,
	)
	contained_virus.makerandom(list(50,90),list(10,100),anti,bad,src)
	growth = 100
	update_icon()

//Panacea pill bottle
//Contains 3 pills that each contain 0.2u of Adminordrazine, the most potent healing chemical in the game.
//The pill bottle is a reskinned lockbox.
/obj/item/weapon/storage/panacea_storage
	name = "Panacea pill bottle"
	desc = "A pill bottle that has been tailor-made to store 3 doses of an incredibly potent healing substance."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "pill_canister_panacea3"
	item_state = "contsolid_panacea"
	can_only_hold = list("/obj/item/weapon/reagent_containers/pill/panacea")
	w_class = W_CLASS_SMALL
	fits_max_w_class = W_CLASS_TINY
	mech_flags = MECH_SCAN_FAIL
	max_combined_w_class = 3
	storage_slots = 3
	items_to_spawn = list(/obj/item/weapon/reagent_containers/pill/panacea = 3)
	starting_materials = list(MAT_IRON = 10, MAT_GLASS = 60, MAT_URANIUM = 30, MAT_DIAMOND = 50, MAT_PHAZON = 20) //A powerful pill storage

/obj/item/weapon/storage/panacea_storage/update_icon()
	var/base_sprite = "pill_canister_panacea"
	var/amount_of_pills = clamp(contents.len, 0, 3) //If it somehow has less or more than the amount
	icon_state = "[base_sprite][amount_of_pills]"

/obj/item/weapon/reagent_containers/pill/panacea
	name = "Panacea"
	desc = "The final product of the 'X' Laboratory's Substance Division before the entire division was obliterated in a freak accident, this incredibly rare and incredibly potent substance was 'stolen' through esoteric research that could have involved the Wizards Federation, the brightest minds in bluespace research and a clown."
	icon_state = "pill_panacea"
	mech_flags = MECH_SCAN_FAIL

/obj/item/weapon/reagent_containers/pill/panacea/New()
	..()
	reagents.add_reagent(PANACEA, 0.2)
	set_light(1, 1, "#EECE19") //It glows!

//Antigen Resetter
//After 5 seconds of using it on a target, sets all of the target's antigens to 0%
//Useful for virologists that spread a cure around but wanted to make beneficial diseases. Can also be used by evil virologists.
/obj/item/device/antibody_resetter
	name = "antibody resetter"
	desc = "A device with 3 injection ports, it uses a combination of biochemical and eletrical inputs that causes a human patient's immune system to 'forget' their antibodies. Created in the 'X' Laboratory to tackle the problem of widespread disease immunities preventing the more beneficial applications of diseases."
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/misc_tools.dmi', "right_hand" = 'icons/mob/in-hand/right/misc_tools.dmi')
	icon_state = "immunity_resetter"
	item_state = "healthanalyzer"
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	throwforce = 3
	w_class = W_CLASS_TINY
	throw_speed = 5
	starting_materials = list(MAT_IRON = 200)
	w_type = RECYK_ELECTRONIC
	origin_tech = Tc_MAGNETS + "=2;" + Tc_BIOTECH + "=3"

/obj/item/device/antibody_resetter/attack(mob/living/M, mob/living/user, def_zone, originator)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.immune_system.overloaded)
			to_chat(user, "<span class='warning'>This patient's immune system is ruined!</span>")
			return
		user.visible_message("<span class='warning'>[user] is attempting to reset [H]'s antibodies!</span>", "<span class='notice'>You attempt to reset [H]'s antibodies.</span>")
		if(do_after(user, H, 5 SECONDS))
			playsound(user, 'sound/items/healthanalyzer.ogg', 50, 1)
			user.visible_message("<span class='warning'>[user] resets [H]'s antibodies!</span>", "<span class='notice'>You reset [H]'s antibodies.</span>")
			for(var/antibody in H.immune_system.antibodies)
				if(H.immune_system.antibodies[antibody] > 5)
					H.immune_system.antibodies[antibody] = rand(1, 5)

//Just a box of advanced surgeon tools
/obj/item/weapon/storage/box/advanced_surgeon
	name = "advanced surgeon tools"
	desc = "A box containing a full set of high-end surgery tools, for the distinguished surgeon."
	icon_state = "medical_box"
	mech_flags = MECH_SCAN_FAIL
	items_to_spawn = list(
		/obj/item/tool/scalpel/laser/tier2 = 1,
		/obj/item/tool/circular_saw/plasmasaw = 1,
		/obj/item/tool/surgicaldrill/diamond = 1,
		/obj/item/tool/hemostat/pico = 1,
		/obj/item/tool/retractor/manager = 1,
		/obj/item/tool/bonesetter/bone_mender = 1,
		/obj/item/tool/FixOVein/clot = 1
	)
