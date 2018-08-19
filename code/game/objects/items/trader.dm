/*
 *	Here defined the boxes contained in the trader vending machine.
 *	Feel free to add stuff. Don't forget to add them to the vmachine afterwards.
*/

/obj/item/weapon/coin/trader
	material=MAT_GOLD
	name = "trader coin"
	icon_state = "coin_mythril"

/obj/item/weapon/storage/trader_marauder
	name = "box of Marauder circuits"
	desc = "All in one box!"
	icon = 'icons/obj/storage/smallboxes.dmi'
	icon_state = "box_of_doom"
	item_state = "box_of_doom"

/obj/item/weapon/storage/trader_marauder/New() //Because we're good jews, they won't be able to finish the marauder. The box is missing a circuit.
	..()
	new /obj/item/weapon/circuitboard/mecha/marauder(src)
	new /obj/item/weapon/circuitboard/mecha/marauder/peripherals(src)
	//new /obj/item/weapon/circuitboard/mecha/marauder/targeting(src)
	new /obj/item/weapon/circuitboard/mecha/marauder/main(src)

/obj/item/weapon/storage/trader_chemistry
	name = "chemist's pallet"
	desc = "Everything you need to make art."
	icon = 'icons/obj/storage/smallboxes.dmi'
	icon_state = "box_of_doom"
	item_state = "box_of_doom"

/obj/item/weapon/storage/trader_chemistry/New()
	..()
	new /obj/item/weapon/reagent_containers/glass/bottle/peridaxon(src)
	new /obj/item/weapon/reagent_containers/glass/bottle/rezadone(src)
	new /obj/item/weapon/reagent_containers/glass/bottle/nanobotssmall(src)

/obj/item/weapon/storage/bluespace_crystal
	name = "natural bluespace crystals box"
	desc = "Hmmm... it smells like tomato"
	icon = 'icons/obj/storage/smallboxes.dmi'
	icon_state = "box_of_doom"
	item_state = "box_of_doom"

/obj/item/weapon/storage/bluespace_crystal/New()
	..()
	for(var/amount = 1 to 6)
		new /obj/item/bluespace_crystal(src)
	new /obj/item/weapon/reagent_containers/food/snacks/grown/bluespacetomato(src)

/obj/structure/closet/secure_closet/wonderful
	name = "wonderful wardrobe"
	desc = "Stolen from Space Narnia."
	req_access = list(access_trade)
	icon_state = "cabinetdetective_locked"
	icon_closed = "cabinetdetective"
	icon_locked = "cabinetdetective_locked"
	icon_opened = "cabinetdetective_open"
	icon_broken = "cabinetdetective_broken"
	icon_off = "cabinetdetective_broken"
	var/wonder_whitelist = list(
	/obj/item/clothing/mask/morphing/corgi,
	/obj/item/clothing/under/rank/vice,
	/obj/item/clothing/shoes/clown_shoes/advanced,
	list(/obj/item/clothing/suit/space/clown, /obj/item/clothing/head/helmet/space/clown),
	/obj/item/clothing/shoes/magboots/magnificent,
	list(/obj/item/clothing/suit/space/plasmaman/bee, /obj/item/clothing/head/helmet/space/plasmaman/bee),
	list(/obj/item/clothing/head/wizard/lich, /obj/item/clothing/suit/wizrobe/lich, /obj/item/clothing/suit/wizrobe/skelelich),
	list(/obj/item/clothing/suit/space/plasmaman/cultist, /obj/item/clothing/head/helmet/space/plasmaman/cultist),
	list(/obj/item/clothing/head/helmet/space/plasmaman/security/captain, /obj/item/clothing/suit/space/plasmaman/security/captain),
	/obj/item/clothing/under/skelevoxsuit,
	list(/obj/item/clothing/suit/wintercoat/ce, /obj/item/clothing/suit/wintercoat/cmo, /obj/item/clothing/suit/wintercoat/security/hos, /obj/item/clothing/suit/wintercoat/hop, /obj/item/clothing/suit/wintercoat/captain, /obj/item/clothing/suit/wintercoat/clown, /obj/item/clothing/suit/wintercoat/slimecoat),
	list(/obj/item/clothing/head/helmet/space/rig/wizard, /obj/item/clothing/suit/space/rig/wizard, /obj/item/clothing/gloves/purple, /obj/item/clothing/shoes/sandal),
	list(/obj/item/clothing/head/helmet/space/rig/knight, /obj/item/clothing/head/helmet/space/rig/knight),
	list(/obj/item/clothing/suit/space/ancient, /obj/item/clothing/suit/space/ancient),
	list(/obj/item/clothing/shoes/clockwork_boots, /obj/item/clothing/head/clockwork_hood, /obj/item/clothing/suit/clockwork_robes),
	/obj/item/clothing/mask/necklace/xeno_claw
	)

/obj/structure/closet/secure_closet/wonderful/spawn_contents()
	..()
	for(var/amount = 1 to 10)
		var/wonder_clothing = pick_n_take(wonder_whitelist)
		if(islist(wonder_clothing))
			for(var/i in wonder_clothing)
				new i(src)
		else
			new wonder_clothing(src)

/*/obj/structure/cage/with_random_slime
	..()

	add_mob

/mob/living/carbon/slime/proc/randomSlime()
*/

/area/vault/mecha_graveyard

/obj/item/weapon/disk/shuttle_coords/vault/mecha_graveyard
	name = "Coordinates to the Mecha Graveyard"
	desc = "Here lay the dead steel of lost mechas, so says some gypsy."
	destination = /obj/docking_port/destination/vault/mecha_graveyard

/obj/docking_port/destination/vault/mecha_graveyard
	areaname = "mecha graveyard"

/datum/map_element/dungeon/mecha_graveyard
	file_path = "maps/randomvaults/dungeons/mecha_graveyard.dmm"
	unique = TRUE

/obj/effect/decal/mecha_wreckage/graveyard_ripley
	name = "Ripley wreckage"
	desc = "Surprisingly well preserved."
	icon_state = "ripley-broken"

/obj/effect/decal/mecha_wreckage/graveyard_ripley/New()
	..()
	var/list/parts = list(/obj/item/mecha_parts/part/ripley_torso,
								/obj/item/mecha_parts/part/ripley_left_arm,
								/obj/item/mecha_parts/part/ripley_right_arm,
								/obj/item/mecha_parts/part/ripley_left_leg,
								/obj/item/mecha_parts/part/ripley_right_leg)
	welder_salvage += parts

	if(prob(80))
		add_salvagable_equipment(new /obj/item/mecha_parts/mecha_equipment/tool/drill,100)
	else
		add_salvagable_equipment(new /obj/item/mecha_parts/mecha_equipment/tool/drill/diamonddrill,100)
	add_salvagable_equipment(new /obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp,100)
	add_salvagable_equipment(new /obj/item/mecha_parts/mecha_equipment/jetpack,100)

/obj/effect/decal/mecha_wreckage/graveyard_clarke
	name = "Clarke wreckage"
	desc = "Surprisingly well preserved."
	icon_state = "clarke-broken"

/obj/effect/decal/mecha_wreckage/graveyard_clarke/New()
	..()
	var/list/parts = list(
								/obj/item/mecha_parts/part/clarke_torso,
								/obj/item/mecha_parts/part/clarke_head,
								/obj/item/mecha_parts/part/clarke_left_arm,
								/obj/item/mecha_parts/part/clarke_right_arm,
								/obj/item/mecha_parts/part/clarke_left_tread,
								/obj/item/mecha_parts/part/clarke_right_tread)
	welder_salvage += parts

	add_salvagable_equipment(new /obj/item/mecha_parts/mecha_equipment/tool/collector,100)
	add_salvagable_equipment(new /obj/item/mecha_parts/mecha_equipment/tool/tiler,100)
	add_salvagable_equipment(new /obj/item/mecha_parts/mecha_equipment/tool/switchtool,100)

/obj/item/crackerbox
	name = "crackerbox"
	desc = "The greatest invention known to birdkind. Converts unwanted, unneeded cash, into useful, beautiful crackers!"
	icon = 'icons/obj/toy.dmi'
	icon_state = "fingerbox"
	var/status //if true, is in use.

/obj/item/crackerbox/examine(mob/user)
	..()
	to_chat(user, "<span class = 'notice'>Currently the conversion rate reads at [get_cash2cracker_rate()] per cracker.</span>")

/obj/item/crackerbox/proc/get_cash2cracker_rate()
	return round(10, nanocoins_rates)

/obj/item/crackerbox/attackby(obj/item/I, mob/user)
	if(!status && istype(I, /obj/item/weapon/spacecash) && user.drop_item(I, src))
		status = TRUE
		var/obj/item/weapon/spacecash/S = I
		var/crackers_to_dispense = round((S.worth*S.amount)/get_cash2cracker_rate())
		playsound(loc, 'sound/items/polaroid2.ogg', 50, 1)
		if(!crackers_to_dispense)
			say("Not enough! Never enough!")
		spawn(3 SECONDS)
			say("That is enough for [crackers_to_dispense] crackers!")
			if(crackers_to_dispense > 100)
				visible_message("<span class = 'warning'>\The [src]'s matter fabrication unit overloads!</span>")
				explosion(loc, 0, prob(15), 2, 0)
				qdel(src)
				return
			for(var/x = 1 to crackers_to_dispense)
				var/obj/II = new /obj/item/weapon/reagent_containers/food/snacks/cracker(get_turf(src))
				II.throw_at(get_turf(pick(orange(7,src))), 1*crackers_to_dispense, 1*crackers_to_dispense)
				sleep(1)
			status = FALSE
		qdel(S)
		return
	..()

/obj/structure/closet/crate/chest/alcatraz
	name = "Alcatraz IV security crate"
	desc = "It came from Alcatraz IV!"

/obj/structure/closet/crate/chest/alcatraz/New()
	..()
	new /obj/item/clothing/head/helmet/donutgiver(src)
	new /obj/item/weapon/ram_kit(src)
	new /obj/item/clothing/under/securityskirt/elite(src)
	new /obj/item/device/law_planner(src)
	new /obj/item/clothing/accessory/bangerboy(src)
	new /obj/item/weapon/autocuffer(src)
	new /obj/item/device/vampirehead(src)
	new /obj/item/key/security/spare(src)
	new /obj/item/weapon/depocket_wand(src)

/obj/item/clothing/accessory/bangerboy
	name = "Banger Boy Advance"
	desc = "The beloved sequel to the Banger Boy Color. Tap it or the clothing item it is attached to with grenades to easily configure their onboard timers. Straps nicely onto security armor."
	icon_state = "bangerboy"
	origin_tech = Tc_COMBAT + "=2"
	var/obj/item/weapon/screwdriver/S

/obj/item/clothing/accessory/bangerboy/attackby(obj/item/W, mob/user)
	if(istype(W,/obj/item/weapon/grenade))
		W.attackby(S,user)
	else
		..()

/obj/item/clothing/accessory/can_attach_to(obj/item/clothing/C)
	return istype(C, /obj/item/clothing/suit/armor/vest)

/obj/item/clothing/head/helmet/donutgiver
	name = "donutgiver"
	desc = "The Donutgiver III. A twenty-five sprinkle headgear with mission-variable voice-programmed confections."
	icon_state = "helmet_sec"
	item_state = "helmet"
	flags = HEAR | FPRINT
	var/dna_profile = null

/obj/item/clothing/head/helmet/donutgiver/GetVoice()
	var/the_name = "The [name]"
	return the_name

/obj/item/clothing/head/helmet/donutgiver/mob_can_equip(mob/M, slot, disable_warning = 0, automatic = 0)
	if(!..())
		return CANNOT_EQUIP
	if(!isjusthuman(H))
		to_chat(usr, "<span class='warning'>Your nonhuman DNA is rejected by \the [src].</span>")
		return CANNOT_EQUIP
	if(!dna_profile)
		to_chat(usr, "<span class='warning'>There is no stored DNA profile.</span>")
		return CANNOT_EQUIP
	if(!(dna_profile == H.dna.unique_enzymes))
		to_chat(usr, "<span class='warning'>Your DNA does not match the stored DNA sample.</span>")
		return CANNOT_EQUIP
	else
		return CAN_EQUIP

/obj/item/clothing/head/helmet/donutgiver/verb/submit_DNA_sample()
	set name = "Submit DNA sample"
	set category = "Object"
	set src in usr

	var/mob/living/carbon/human/H = loc

	if(!isjusthuman(H))
		to_chat(usr, "<span class='warning'>Your nonhuman DNA is rejected by \the [src].</span>")
		return 0

	if(!dna_profile)
		dna_profile = H.dna.unique_enzymes
		to_chat(usr, "<span class='notice'>You submit a DNA sample to \the [src].</span>")
		verbs += /obj/item/weapon/gun/lawgiver/verb/erase_DNA_sample
		verbs -= /obj/item/weapon/gun/lawgiver/verb/submit_DNA_sample
		update_icon()
		return 1

/obj/item/clothing/head/helmet/donutgiver/AltClick()
	if(submit_DNA_sample())
		return
	return ..()

/obj/item/clothing/head/helmet/donutgiver/verb/erase_DNA_sample()
	set name = "Erase DNA sample"
	set category = "Object"
	set src in usr

	var/mob/living/carbon/human/H = loc

	if(dna_profile)
		if(dna_profile == H.dna.unique_enzymes)
			dna_profile = null
			to_chat(usr, "<span class='notice'>You erase the DNA profile from \the [src].</span>")
			verbs += /obj/item/weapon/gun/lawgiver/verb/submit_DNA_sample
			verbs -= /obj/item/weapon/gun/lawgiver/verb/erase_DNA_sample
			update_icon()
		else
			self_destruct(H)

/obj/item/clothing/head/helmet/donutgiver/proc/self_destruct(mob/user)
	var/req_access = list(access_security)
	if(can_access(user.GetAccess(),req_access))
		say("ERROR: DNA PROFILE DOES NOT MATCH.")
		return
	say("UNAUTHORIZED ACCESS DETECTED.")
	var/datum/organ/external/active_hand = user.get_active_hand_organ()
	if(active_hand)
		active_hand.explode()
	explosion(user, -1, 0, 2)
	qdel(src)

/obj/item/clothing/head/helmet/donutgiver/Hear(var/datum/speech/speech, var/rendered_speech="")
	if(world.timeofday < last_donut+60)
		return
	var/dispense_path
	set waitfor = FALSE // The lawgiver should speak AFTER the user
	if(speech.speaker == loc && !speech.frequency && dna_profile)
		var/mob/living/carbon/human/H = loc
		if(dna_profile == H.dna.unique_enzymes)
			if((findtext(speech.message, "standard")) || (findtext(speech.message, "sprinkle" || (findtext(speech.message, "traditional")))
				dispense_path = /obj/item/weapon/reagent_containers/food/snacks/donut/normal
				sleep(3)
				say("SPRINKLE.")
			else if((findtext(speech.message, "jelly")) || (findtext(speech.message, "berry")) || (findtext(speech.message, "juicy")))
				dispense_path = /obj/item/weapon/reagent_containers/food/snacks/donut/jelly
				sleep(3)
				say("JELLY.")
			else if((findtext(speech.message, "chaos")) || (findtext(speech.message, "gump")) || (findtext(speech.message, "two-face")))
				dispense_path = /obj/item/weapon/reagent_containers/food/snacks/donut/chaos
				sleep(3)
				say("CHAOS.")
			else if((findtext(speech.message, "favorite") || (findtext(speech.message, "4Kids") || (findtext(speech.message, "rice"))
				dispense_path = /obj/item/weapon/reagent_containers/food/snacks/riceball
				sleep(3)
				say("FAVORITE.")
		if(dispense_path)
			var/obj/item/I = new dispense_path(get_turf(src))
			I.put_in_hands(H)
			last_donut = timeofday

//Security Skirt spritework is coutesy of TG, AGPL license
/obj/item/clothing/under/securityskirt/elite
	name = "elite security skirt"
	desc = "For demonstrating who is in charge."
	icon_state = "secskirt"
	item_state = "r_suit"
	_color = "secskirt"
	armor = list(melee = 10, bullet = 10, laser = 10,energy = 0, bomb = 0, bio = 0, rad = 0)
	clothing_flags = ONESIZEFITSALL
	siemens_coefficient = 0.9
	species_fit = list(GREY_SHAPED) //Unlike normal skirts this is not VOX_SHAPED
	body_parts_covered = FULL_TORSO|ARMS

/obj/item/clothing/under/securityskirt/elite/equipped(var/mob/user, var/slot)
	..()
	processing_objects += src

/obj/item/clothing/under/securityskirt/elite/unequipped(mob/user, var/from_slot = null)
	processing_objects -= src
	..()

/obj/item/clothing/under/securityskirt/elite/process()
	if(prob(1))
		if(ishuman(loc))
			visible_message("<span class='warning'>[loc]'s [src] swishes threateningly.</span>")

/obj/item/weapon/ram_kit
	name = "battering ram drop-leaf kit"
	desc = "A device so ingenius there is no way the Vox invented it. Exploits volt-induced superposition to allow battering ram to fold into itself."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "kit"
	flags = FPRINT
	siemens_coefficient = 0
	w_class = W_CLASS_SMALL
	origin_tech = Tc_COMBAT + "=5"

/obj/structure/largecrate/wolf
	name = "security wolf crate"
	desc = "An access-locked crate containing a security wolf. Handlers are responsible for obedience: wolves require regular meat or they will lash out at small animals and, if desperate, humans."
	req_access = (access_brig)
	icon = 'icons/obj/cage.dmi'
	icon_state = "cage_secure"

/obj/structure/largecrate/wolf/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(!allowed(user))
		to_chat("<span class='warning'>\The [src]'s secure bolting system flashes hostily.</span>")
		//Not using elseif here because we want it to continue to attack_hand
	if(iscrowbar(W) && allowed(user))
		new /obj/item/stack/sheet/metal(src)
		var/turf/T = get_turf(src)
		for(var/i = 1 to 4)
			new /obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh(T)
		new /mob/living/simple_animal/hostile/wolf(T)
		user.visible_message("<span class='notice'>[user] pries \the [src] open.</span>", \
							 "<span class='notice'>You pry open \the [src].</span>", \
							 "<span class='notice'>You hear creaking metal.</span>")
		qdel(src)
	else
		return attack_hand(user)

/obj/item/device/law_planner
	name = "law planning frame"
	desc = "A large data pad with buttons for crimes. Used for planning a brig sentence."
	w_class = W_CLASS_SMALL
	origin_tech = Tc_PROGRAMMING + "=6"
	icon = 'icons/obj/pda.dmi'
	icon_state = "aicard"
	item_state = "electronic"
	req_access = list(access_brig)
	var/announce = 1 //0 = Off, 1 = On select, 2 = On upload
	var/start_timer = FALSE //If true, automatically start the timer on upload
	var/upload_crimes = null //If has DNA, will look for an associated datacore file and upload crimes
	var/list/rapsheet = list()
	var/total_time = 0

	var/list/minor_crimes = list(
							"RESISTING ARREST"=2
							"PETTY CRIME"=3
							"DRUGGING"=4
							"POSSESSION"=5
							"MANHUNT"=5
							"ESCAPE"=5
							"FRAMING"=5
							"WORKPLACE HAZARD"=5
							"ASSAULT"=6
							"POSS. WEAPON"=7
							"POSS. EXPLOSIVE"=8)
	var/list/major_crimes = list(
							"B&E RESTRICTED"=10
							"INTERFERENCE"=10
							"UNLAWFUL UPLOAD"=10
							"ABUSE OF POWER"=10
							"ASSAULT ON SEC"=10
							"MAJOR TRESPASS"=10
							"MAJOR B&E"=15
							"GRAND THEFT"=15)

/obj/item/device/law_planner/proc/announce()
	say(english_list(rapsheet))
	say("[total_time] minutes.")

/obj/item/device/law_planner/afterattack(var/atom/A, var/mob/user, var/proximity_flag)
	if(!proximity_flag)
		to_chat(user, "<span class='warning'>You can't seem to reach \the [A].</span>")
		return 0
	if(!allowed)
		to_chat(user, "<span class='warning'>You must wear your ID!</span>")
		return 0
	if(ishuman(A)&&!(A==user))
		for(var/datum/data/record/E in data_core.security)
			if(E.fields["name"] == A.name)
				say("Verified. Found record match for [A].")
				upload_crimes = E
	if(istype(A,/obj/machinery/door_timer))
		if(announce==2)
			announce()
		if(upload_crimes)
			upload_crimes.fields["criminal"] = "Incarcerated"
			var/counter = 1
			while(upload_crimes.fields["com_[counter]"])
				counter++
			upload_crimes.fields["com_[counter]"] = text("Made by [user] (Automated) on [time2text(world.realtime, "DDD MMM DD")]<BR>[english_list(rapsheet)]")
		var/obj/machinery/door_timer/D = A
		if(D.timeleft())
			//We're adding time
			D.releasetime += total_time*60
		else
			//Setting time
			D.timeset(total_time*60)
		if(start_timer && !D.timing)
			D.timer_start()
		upload_crimes = null
		rapsheet = null
		total_time = null
	else
		..()


/obj/item/weapon/boxofsnow
	name = "box of winter"
	desc = "It has a single red button on top. Probably want to be careful where you open this."
	icon = 'icons/obj/storage/smallboxes.dmi'
	icon_state = "box_of_doom"
	item_state = "box_of_doom"

/obj/item/weapon/boxofsnow/attack_self(mob/user)
	var/turf/center = get_turf(loc)
	for(var/i = 1 to rand(8,24))
		new /obj/item/stack/sheet/snow(center)
	for(var/turf/simulated/T in view(3))
		if(istype(T,/turf/simulated/floor))
			new /obj/structure/snow(T) //Floors get snow
		if(istype(T,/turf/simulated/wall))
			new /obj/machinery/xmas_light(T) //Walls get lights
	if(prob(50)) //Snowman or St. Corgi
		/mob/living/simple_animal/hostile/retaliate/snowman(center)
	else
		/mob/living/simple_animal/corgi/saint(center)
	qdel(src)
<<<<<<< 2fe3ffac9e2182b35df6f17383ae1fd3a5d4df92
=======

/obj/item/key/security/spare
	name = "warden's spare secway key"
	desc = "It has a tag that reads:"
	var/home_map

/New()
	..()
	var/list/map_names = list("Defficiency","Bagelstation","Meta Club","Packed Station","Asteroid Station","Box Station")
	map_names -= map.nameLong
	home_map = pick(map_names)

/obj/item/key/security/spare/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>If found, please return to [home_map]."

/obj/item/weapon/depocket_wand
	name = "depocket wand"
	desc = "Depocketers were invented by thieves to read pocket contents and identify marks, then force them to drop those items for muggings. This one has been permanently peace-bonded so that it can only check pocket contents."

/obj/item/weapon/depocket_wand/attack(mob/living/M as mob, mob/living/user as mob)
	playsound(user, 'sound/items/healthanalyzer.ogg', 50, 1)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		to_chat(user,"<span class='info'>Pocket Scan Results:<BR>Left: [M.l_store]<BR>Right: [M.r_store]</span>")
	else
		..()
>>>>>>> added chest
