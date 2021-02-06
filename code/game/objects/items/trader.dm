/*
 *	Here defined the boxes contained in the trader vending machine.
 *	Feel free to add stuff. Don't forget to add them to the vmachine afterwards.
*/

/obj/item/weapon/coin/trader
	material=MAT_GOLD
	name = "trader coin"
	icon_state = "coin_mythril"

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

/obj/item/weapon/storage/bluespace_crystal
	name = "natural bluespace crystals box"
	desc = "Hmmm... it smells like tomato."
	icon = 'icons/obj/storage/smallboxes.dmi'
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/boxes_and_storage.dmi', "right_hand" = 'icons/mob/in-hand/right/boxes_and_storage.dmi')
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
	list(/obj/item/clothing/suit/space/plasmaman/bee, /obj/item/clothing/head/helmet/space/plasmaman/bee, /obj/item/clothing/suit/space/plasmaman/cultist, /obj/item/clothing/head/helmet/space/plasmaman/cultist, /obj/item/clothing/head/helmet/space/plasmaman/security/captain, /obj/item/clothing/suit/space/plasmaman/security/captain, /obj/item/clothing/head/helmet/space/plasmaman/security/hos, /obj/item/clothing/suit/space/plasmaman/security/hos, /obj/item/clothing/head/helmet/space/plasmaman/security/hop, /obj/item/clothing/suit/space/plasmaman/security/hop),
	list(/obj/item/clothing/head/wizard/lich, /obj/item/clothing/suit/wizrobe/lich, /obj/item/clothing/suit/wizrobe/skelelich),
	/obj/item/clothing/under/skelesuit,
	list(/obj/item/clothing/suit/storage/wintercoat/engineering/ce, /obj/item/clothing/suit/storage/wintercoat/medical/cmo, /obj/item/clothing/suit/storage/wintercoat/security/hos, /obj/item/clothing/suit/storage/wintercoat/hop, /obj/item/clothing/suit/storage/wintercoat/security/captain, /obj/item/clothing/suit/storage/wintercoat/clown, /obj/item/clothing/suit/storage/wintercoat/slimecoat),
	list(/obj/item/clothing/suit/space/rig/wizard, /obj/item/clothing/gloves/purple/wizard, /obj/item/clothing/shoes/sandal),
	list(/obj/item/clothing/suit/space/ancient, /obj/item/clothing/head/helmet/space/ancient),
	list(/obj/item/clothing/shoes/clockwork_boots, /obj/item/clothing/head/clockwork_hood, /obj/item/clothing/suit/clockwork_robes),
	/obj/item/clothing/mask/necklace/xeno_claw,
	/obj/item/clothing/under/newclothes,
	/obj/item/clothing/suit/storage/draculacoat,
	list(/obj/item/clothing/head/helmet/richard, /obj/item/clothing/under/jacketsuit),
	list(/obj/item/clothing/under/rank/security/sneaksuit, /obj/item/clothing/head/headband),
	/obj/item/clothing/under/galo,
	/obj/item/clothing/suit/raincoat,
	list(/obj/item/clothing/accessory/armband, /obj/item/clothing/accessory/armband/cargo, /obj/item/clothing/accessory/armband/engine, /obj/item/clothing/accessory/armband/science, /obj/item/clothing/accessory/armband/hydro, /obj/item/clothing/accessory/armband/medgreen),
	list(/obj/item/clothing/head/helmet/space/grey, /obj/item/clothing/suit/space/grey),
	list(/obj/item/clothing/under/bikersuit, /obj/item/clothing/gloves/bikergloves, /obj/item/clothing/head/helmet/biker, /obj/item/clothing/shoes/mime/biker),
	list(/obj/item/clothing/monkeyclothes/space, /obj/item/clothing/head/helmet/space),
	/obj/item/device/radio/headset/headset_earmuffs,
	/obj/item/clothing/under/vault13,
	list(/obj/item/clothing/head/leather/xeno, /obj/item/clothing/suit/leather/xeno),
	/obj/item/clothing/accessory/rabbit_foot
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

	//6+6+6=18
var/global/list/alcatraz_stuff = list(
	//3 of a kind
	/obj/item/weapon/depocket_wand,/obj/item/weapon/depocket_wand,/obj/item/weapon/depocket_wand,
	/obj/item/pedometer,/obj/item/pedometer,/obj/item/pedometer,
	//2 of a kind
	/obj/item/weapon/autocuffer,/obj/item/weapon/autocuffer,
	/obj/item/clothing/mask/gas/hecu,/obj/item/clothing/mask/gas/hecu,
	/obj/item/clothing/gloves/swat/operator,/obj/item/clothing/gloves/swat/operator,
	//1 of a kind
	/obj/item/clothing/under/securityskirt/elite,
	/obj/item/clothing/head/helmet/donutgiver,
	/obj/item/clothing/accessory/bangerboy,
	/obj/item/key/security/spare,
	/obj/item/weapon/ram_kit,
	/obj/item/device/vampirehead,)

/obj/structure/closet/crate/chest/alcatraz/New()
	..()
	for(var/i = 1 to 6)
		if(!alcatraz_stuff.len)
			return
		var/path = pick_n_take(alcatraz_stuff)
		new path(src)

/obj/item/clothing/accessory/bangerboy
	name = "\improper Banger Boy Advance"
	desc = "The beloved sequel to the Banger Boy Color. Tap it or the clothing item it is attached to with grenades to trigger them for early detonation. Straps nicely onto security armor."
	icon_state = "bangerboy"
	mech_flags = MECH_SCAN_FAIL
	var/obj/item/weapon/screwdriver/S

/obj/item/clothing/accessory/bangerboy/New()
	..()
	S = new(src)

/obj/item/clothing/accessory/bangerboy/Destroy()
	qdel(S)
	S = null
	..()

/obj/item/clothing/accessory/bangerboy/attackby(obj/item/W, mob/user)
	if(istype(W,/obj/item/weapon/grenade))
		var/obj/item/weapon/grenade/G = W
		G.det_time = 1.5 SECONDS
		G.activate(user)
	else
		..()

/obj/item/clothing/accessory/bangerboy/can_attach_to(obj/item/clothing/C)
	return istype(C, /obj/item/clothing/suit/armor/vest)

/obj/item/clothing/head/helmet/donutgiver
	name = "donutgiver"
	desc = "The Donutgiver III. A twenty-five sprinkle headgear with mission-variable voice-programmed confections. It has the words SPRINKLE, JELLY, CHAOS and FAVORITE etched onto its sides."
	icon_state = "donutgiver"
	item_state = "helmet_donuts"
	species_fit = list(INSECT_SHAPED)
	flags = HEAR | FPRINT
	var/dna_profile = null
	var/last_donut = 0

/obj/item/clothing/head/helmet/donutgiver/GetVoice()
	var/the_name = "The [name]"
	return the_name

/obj/item/clothing/head/helmet/donutgiver/mob_can_equip(mob/M, slot, disable_warning = 0, automatic = 0)
	if(!..())
		return CANNOT_EQUIP
	if(!isjusthuman(M))
		to_chat(usr, "<span class='warning'>Your nonhuman DNA is rejected by \the [src].</span>")
		return CANNOT_EQUIP
	if(!dna_profile)
		to_chat(usr, "<span class='warning'>There is no stored DNA profile.</span>")
		return CANNOT_EQUIP
	var/mob/living/carbon/human/H = M
	if(!(dna_profile == H.dna.unique_enzymes))
		to_chat(usr, "<span class='warning'>Your DNA does not match the stored DNA sample.</span>")
		return CANNOT_EQUIP
	else
		if(!H.head)
			return CAN_EQUIP
		if(H.head.canremove)
			return CAN_EQUIP_BUT_SLOT_TAKEN
		return CAN_EQUIP

/obj/item/clothing/head/helmet/donutgiver/verb/submit_DNA_sample()
	set name = "Submit DNA sample"
	set category = "Object"
	set src in usr

	if(!ishuman(loc))
		return
	var/mob/living/carbon/human/H = loc

	if(!isjusthuman(H))
		to_chat(usr, "<span class='warning'>Your nonhuman DNA is rejected by \the [src].</span>")
		return 0

	if(!dna_profile)
		dna_profile = H.dna.unique_enzymes
		to_chat(usr, "<span class='notice'>You submit a DNA sample to \the [src].</span>")
		verbs += /obj/item/clothing/head/helmet/donutgiver/verb/erase_DNA_sample
		verbs -= /obj/item/clothing/head/helmet/donutgiver/verb/submit_DNA_sample
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

	if(!ishuman(loc))
		return
	var/mob/living/carbon/human/H = loc

	if(dna_profile)
		if(dna_profile == H.dna.unique_enzymes)
			dna_profile = null
			to_chat(usr, "<span class='notice'>You erase the DNA profile from \the [src].</span>")
			verbs += /obj/item/clothing/head/helmet/donutgiver/verb/submit_DNA_sample
			verbs -= /obj/item/clothing/head/helmet/donutgiver/verb/erase_DNA_sample
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
	set waitfor = FALSE // speak AFTER the user
	if(world.timeofday < last_donut+300)
		return
	if(!ishuman(speech.speaker))
		return
	var/dispense_path
	if(speech.speaker == loc && !speech.frequency && dna_profile)
		var/mob/living/carbon/human/H = loc
		if(dna_profile == H.dna.unique_enzymes)
			if(findtext(speech.message, "standard") || findtext(speech.message, "sprinkle") || findtext(speech.message, "traditional"))
				dispense_path = /obj/item/weapon/reagent_containers/food/snacks/donut/normal
				sleep(3)
				say("SPRINKLE.")
			else if(findtext(speech.message, "jelly") || findtext(speech.message, "berry") || findtext(speech.message, "juicy"))
				dispense_path = /obj/item/weapon/reagent_containers/food/snacks/donut/jelly
				sleep(3)
				say("JELLY.")
			else if(findtext(speech.message, "chaos") || findtext(speech.message, "gump") || findtext(speech.message, "two-face"))
				dispense_path = /obj/item/weapon/reagent_containers/food/snacks/donut/chaos
				sleep(3)
				say("CHAOS.")
			else if(findtext(speech.message, "favorite") || findtext(speech.message, "4Kids") || findtext(speech.message, "rice"))
				dispense_path = /obj/item/weapon/reagent_containers/food/snacks/riceball
				sleep(3)
				say("FAVORITE.")
		if(dispense_path)
			var/obj/item/I = new dispense_path(get_turf(src))
			H.put_in_hands(I)
			last_donut = world.timeofday

//Security Skirt spritework is coutesy of TG, CC BY-SA 3.0 license
/obj/item/clothing/under/securityskirt/elite
	name = "elite security skirt"
	desc = "For demonstrating who is in charge."
	icon_state = "secskirt"
	item_state = "r_suit"
	_color = "secskirt"
	origin_tech = Tc_COMBAT + "=2"
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
	if(ishuman(loc) && prob(1)) //Processing only happens when equipped anyway
		var/mob/living/carbon/human/H = loc
		if(!(H.wear_suit && H.wear_suit.body_parts_covered & LEGS)) //It doesn't make sense to swish about if it's covered under something
			H.visible_message("<span class='warning'>[H]'s [src.name] swishes threateningly.</span>",
				"\The [src] fills you with confidence.",
				"Something cracks like a whip.")
			H.reagents.add_reagent(PARACETAMOL,1)

/obj/item/weapon/ram_kit
	name = "battering ram drop-leaf kit"
	desc = "A device so ingenius there is no way the Vox invented it. Exploits volt-induced superposition to allow battering ram to fold into itself."
	icon = 'icons/obj/device.dmi'
	icon_state = "modkit"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/newsprites_lefthand.dmi', "right_hand" = 'icons/mob/in-hand/right/newsprites_righthand.dmi')
	flags = FPRINT
	siemens_coefficient = 0
	w_class = W_CLASS_SMALL
	origin_tech = Tc_COMBAT + "=5"

/obj/structure/largecrate/secure
	name = "security livestock crate"
	desc = "An access-locked crate containing a security wolf. Handlers are responsible for obedience: wolves require regular meat or they will lash out at small animals and, if desperate, humans."
	req_access = list(access_brig)
	icon = 'icons/obj/cage.dmi'
	icon_state = "cage_secure"
	var/mob_path = /mob/living/simple_animal/hostile/wolf/pliable
	var/bonus_path = /obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh

/obj/structure/largecrate/secure/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(!allowed(user))
		to_chat(user,"<span class='warning'>\The [src]'s secure bolting system flashes hostily.</span>")
		//Not using elseif here because we want it to continue to attack_hand
	if(iscrowbar(W) && allowed(user))
		new /obj/item/stack/sheet/metal(src)
		var/turf/T = get_turf(src)
		if(bonus_path)
			for(var/i = 1 to 4)
				new bonus_path(T)
		if(mob_path)
			new mob_path(T)
		user.visible_message("<span class='notice'>[user] pries \the [src] open.</span>", \
							 "<span class='notice'>You pry open \the [src].</span>", \
							 "<span class='notice'>You hear creaking metal.</span>")
		qdel(src)
	else
		attack_hand(user)

/obj/structure/largecrate/secure/magmaw
	name = "engineering livestock crate"
	desc = "An access-locked crate containing a magmaw. Handlers are advised to stand back when administering plasma to the animal."
	req_access = list(access_engine)
	mob_path = /mob/living/simple_animal/hostile/asteroid/magmaw
	bonus_path = null //originally was /obj/item/stack/sheet/mineral/plasma resulting in immediate FIRE

/obj/structure/largecrate/secure/frankenstein
	name = "medical livestock crate"
	desc = "An access-locked crate containing medical horrors. Handlers are advised to scream 'It's alive!' repeatedly."
	req_access = list(access_surgery)
	mob_path = null
	bonus_path = /mob/living/carbon/human/frankenstein

/obj/item/weapon/boxofsnow
	name = "box of winter"
	desc = "It has a single red button on top. Probably want to be careful where you open this."
	icon = 'icons/obj/storage/smallboxes.dmi'
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/boxes_and_storage.dmi', "right_hand" = 'icons/mob/in-hand/right/boxes_and_storage.dmi')
	icon_state = "box_of_doom"
	item_state = "box_of_doom"

/obj/item/weapon/boxofsnow/attack_self(mob/user)
	var/turf/center = get_turf(loc)
	for(var/i = 1 to rand(8,24))
		new /obj/item/stack/sheet/snow(center)
	for(var/turf/simulated/T in circleview(user,5))
		if(istype(T,/turf/simulated/floor))
			new /obj/structure/snow(T) //Floors get snow
		if(istype(T,/turf/simulated/wall))
			new /obj/machinery/xmas_light(T) //Walls get lights
	if(prob(66)) //Snowman or St. Corgi
		new /mob/living/simple_animal/hostile/retaliate/snowman(center)
	else
		new /mob/living/simple_animal/corgi/saint(center)
	visible_message("<span class='danger'>[user] lets loose \the [src]!</span>")
	qdel(src)

/obj/item/key/security/spare
	name = "warden's spare secway key"
	desc = "It has a tag that reads:"
	var/home_map

/obj/item/key/security/spare/New()
	..()
	var/list/map_names = list("Defficiency","Bagelstation","Meta Club","Packed Station","Asteroid Station","Box Station")
	map_names -= map.nameLong
	home_map = pick(map_names)

/obj/item/key/security/spare/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>If found, please return to [home_map].")

/obj/item/weapon/depocket_wand
	name = "depocket wand"
	desc = "Depocketers were invented by thieves to read pocket contents and identify marks, then force them to drop those items for muggings. This one has been permanently peace-bonded so that it can only check pocket contents."
	icon_state = "telebaton_1"
	item_state = "telebaton_1"
	w_class = W_CLASS_SMALL

/obj/item/weapon/depocket_wand/attack(mob/living/M, mob/living/user)

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.handcuffed)
			scan(H,user)
		else
			user.visible_message("<span class='danger'>[user] begins waving \the [src] over [M].</span>","<span class='danger'>You begin waving \the [src] over [M].</span>")
			if(do_after(user,H, 2 SECONDS))
				scan(H,user)
	else
		..()

/obj/item/weapon/depocket_wand/proc/scan(mob/living/carbon/human/H, mob/living/user)
	playsound(user, 'sound/items/healthanalyzer.ogg', 50, 1)
	to_chat(user,"<span class='info'>Pocket Scan Results:<BR>Left: [H.l_store ? H.l_store : "empty"]<BR>Right: [H.r_store ? H.r_store : "empty"]</span>")



#define VAMP_FLASH_CD 50
#define VAMP_SCREAM_CD 600

/obj/item/device/vampirehead
	name = "shrunken vampire head"
	desc = "The head of an immortal lord of the night. If only he had the right straight man partner, he'd make a good half of a crime fighting duo."
	w_class = W_CLASS_TINY
	icon_state = "vamphead0"
	flags = HEAR | FPRINT
	force = 7
	var/obj/effect/decal/cleanable/blood/located_blood
	var/flash_last_used = 0
	var/scream_last_used = 0

/obj/item/device/vampirehead/New()
	..()
	processing_objects += src

/obj/item/device/vampirehead/Destroy()
	processing_objects -= src
	..()

/obj/item/device/vampirehead/process()
	if(located_blood && get_dist(located_blood,get_turf(src))<=5)
		return //Don't process further, we still smell our old blood
	located_blood = null
	if(genecheck(loc,prob(97))) //Annoy unqualified bearers with messages about 3% of the time, contains sanity in proc
		find_blood()
	update_icon()

/obj/item/device/vampirehead/dropped()
	..()
	located_blood = null

/obj/item/device/vampirehead/update_icon()
	icon_state = "vamphead[located_blood ? "1" : "0"]"

/obj/item/device/vampirehead/proc/find_blood()
	if(!ishuman(loc))
		return
	for(var/obj/effect/decal/cleanable/C in range(5,loc))
		if(C.counts_as_blood)
			located_blood = C
			/*var/list/blood_phrases = list("Can you smell it?",
											"Ah, sweet blood...",
											"So close, yet so far...",
											"Sanquine. Delicious.",
											"There. The blood is close...",
											"Do you hear its call?")
			to_chat(loc,"<B>[src]</B> [pick("murmurs","shrieks","hisses","groans","complains")], \"<span class='sinister'>[pick(blood_phrases)]</span>\"")*/
			update_icon()
			return
	update_icon()

/obj/item/device/vampirehead/on_enter_storage(obj/item/weapon/storage/S)
	..()
	var/mob/living/carbon/human/H = get_holder_of_type(src, /mob/living/carbon/human)
	if(H && genecheck(H,TRUE)) //If we've been stashed by a valid user. Don't send normal reject messages.
		var/list/reject_phrases = list("Don't put me in there, I can't see!",
								"Miserable churl! Un[S.name] me at once!",
								"I hope you realize the view inside here is terribly boring.",
								"What do you want of me? To curate the inside of this [S.name]?",
								"Miserable. Sealed inside \a [S].",
								"Can't make it! Can't make it! [capitalize(S.name)] stuck! Please, I beg you!",
								"This is really no substitute for a coffin.",
								"What, pray tell, am I supposed to be doing inside here?")
		to_chat(H,"<B>[src]</B> [pick("murmurs","shrieks","hisses","groans","complains")], \"<span class='sinister'>[pick(reject_phrases)]</span>\"")

/obj/item/device/vampirehead/proc/genecheck(mob/user,silent=FALSE)
	if(!ishuman(user))

		return FALSE
	if(M_SOBER in user.mutations)
		return TRUE
	else
		if(!silent)
			var/list/reject_phrases = list("Blah! I'd never work with someone who can't hold their drink.",
										"You are not meant for this line of work, featherweight.",
										"Try again when you can relate to the intoxicating taste of blood.",
										"What is a man? A miserable little pile of soft drinks.",
										"You mortals all look underage to me. Pray tell, can you even manage a bottle?",
										"Bah. You mock Le Confrérie des Chevaliers du Tastevin with your plebian visage.",
										"I will not associate with any less than an iron liver.",
										"You dare ask my service when you cannot even hold your liquor?")
			to_chat(user,"<B>[src]</B> [pick("murmurs","insults","mocks","groans","complains")], \"<span class='sinister'>[pick(reject_phrases)]</span>\"")
		return FALSE

/obj/item/device/vampirehead/attack_self(mob/user)
	if(!istype(user) || !genecheck(user))
		return

	if(scream_last_used + VAMP_SCREAM_CD > world.timeofday)
		var/list/reject_phrases = list("Bah. You can't be serious.",
										"Again? You work me harder than I beat my slaves.",
										"Enough. I must recover, first.",
										"Cease your incessant squeezing, mortal.",
										"I am not a flashbang, you blithering idiot."
										)
		to_chat(user,"<B>[src]</B> [pick("murmurs","insults","mocks","groans","complains")], \"<span class='sinister'>[pick(reject_phrases)]</span>\"")
		return

	user.attack_log += "\[[time_stamp()]\] <font color='red'>Used the [name] to perform a vampire screech.</font>"
	log_attack("<font color='red'>[key_name(user)] Used the [name] to perform a vampire screech.</font>")
	for(var/obj/structure/window/W in view(1))
		W.shatter()

	playsound(user, 'sound/effects/creepyshriek.ogg', 100, 1)

	scream_last_used = world.timeofday

/obj/item/device/vampirehead/attack(mob/living/M as mob, mob/user as mob)
	if(!user || !M) //sanity
		return

	if(!genecheck(user))
		return

	if(flash_last_used + VAMP_FLASH_CD > world.timeofday)
		var/list/reject_phrases = list("Bah. You can't be serious.",
										"Again? You work me harder than I beat my slaves.",
										"Enough. I must recover, first.",
										"Cease your incessant squeezing, mortal.",
										"I am not a flash, you blithering idiot."
										)
		to_chat(user,"<B>[src]</B> [pick("murmurs","insults","mocks","groans","complains")], \"<span class='sinister'>[pick(reject_phrases)]</span>\"")
		return

	M.attack_log += "\[[time_stamp()]\] <font color='orange'>Has been flashed (attempt) with [name] by [key_name(user)]</font>"
	user.attack_log += "\[[time_stamp()]\] <font color='red'>Used the [name] to flash [key_name(M)]</font>"

	log_attack("<font color='red'>[key_name(user)] Used the [name] to flash [key_name(M)]</font>")

	if(!iscarbon(user))
		M.LAssailant = null
	else
		M.LAssailant = user

	if(!iscarbon(M))
		return
	var/mob/living/carbon/Subject = M

	Subject.Knockdown(Subject.eyecheck() * 5 * -1 +10)

	visible_message("<span class='danger'>The eyes of [user]'s [name] emit a blinding flash toward [M]!</span>")
	flash_last_used = world.timeofday

/obj/item/device/vampirehead/afterattack(atom/A, mob/user)
	..()
	if(isobj(A))
		var/list/impact_phrases =  list("Oof.",
										"Ow.",
										"Ack.",
										"JUST.",
										"Eugh.")
		to_chat(user,"<B>[src]</B> [pick("moans","chokes","groans","complains")], \"<span class='sinister'>[pick(impact_phrases)]</span>\"")

//Autocuffer is like a cyborg handcuff dispenser for carbons
/obj/item/weapon/autocuffer
	name = "autocuffer"
	desc = "An experimental prototype handcuff dispenser that mysteriously went missing from a research facility on Alcatraz VI."
	icon = 'icons/obj/items.dmi'
	icon_state = "autocuffer"
	siemens_coefficient = 0
	slot_flags = SLOT_BELT
	w_class = W_CLASS_SMALL
	origin_tech = Tc_COMBAT + "=4"
	restraint_resist_time = TRUE //This doesn't actually matter as long as it is nonzero
	req_access = list(access_brig) //Brig timers
	var/obj/item/weapon/handcuffs/cyborg/stored

/obj/item/weapon/autocuffer/Destroy()
	if(stored)
		qdel(stored)
		stored = null
	..()

/obj/item/weapon/autocuffer/restraint_apply_intent_check(mob/user)
	return TRUE

/obj/item/weapon/autocuffer/attempt_apply_restraints(mob/M, mob/user)
	if(!allowed(user))
		to_chat(user, "<span class='warning'>The access light on \the [src] blinks red.</span>")
		return FALSE
	if(!stored) //No cuffs primed. Let's generate new ones.
		stored = new(src)
	if(stored.attempt_apply_restraints(M,user))
		stored = null //We applied these, so next time make new ones.
		return TRUE
	else
		return FALSE

/obj/item/weapon/card/id/vox/extra
	name = "Spare trader ID"
	desc = "A worn looking ID with access to the tradepost, able to be set once for aspiring traders."
	assignment = "Trader"
	var/canSet = TRUE

/obj/item/weapon/card/id/vox/extra/attack_self(mob/user as mob)
	if(canSet)
		var t = reject_bad_name(input(user, "What name would you like to put on this card?", "Trader ID Card Name", ishuman(user) ? user.real_name : user.name))
		if(!t) //Same as mob/new_player/prefrences.dm
			alert("Invalid name.")
			return
		src.registered_name = t
		canSet = FALSE
		name = "[t]'s ID card ([assignment])"
	else
		return


/obj/item/weapon/mech_expansion_kit
	name = "exosuit expansion kit"
	desc = "All the equipment you need to replace that useless legroom with a useful bonus equipment slot on your mech."
	icon = 'icons/obj/device.dmi'
	icon_state = "modkit"
	flags = FPRINT
	siemens_coefficient = 0
	w_class = W_CLASS_SMALL
	var/working = FALSE

/obj/item/weapon/mech_expansion_kit/preattack(atom/target, mob/user , proximity)
	if(!proximity)
		return
	if(!istype(target,/obj/mecha))
		to_chat(user,"<span class='warning'>That isn't an exosuit!</span>")
		return
	if(working)
		to_chat(user,"<span class='warning'>This is already being used to upgrade something!</span>")
		return
	var/obj/mecha/M = target
	if(M.max_equip > initial(M.max_equip))
		to_chat(user,"<span class='warning'>That exosuit cannot be modified any further. There's no more legroom to eliminate!</span>")
		return
	to_chat(user,"<span class='notice'>You begin modifying the exosuit.</span>")
	working = TRUE
	if(do_after(user,target,4 SECONDS))
		to_chat(user,"<span class='notice'>You finish modifying the exosuit!</span>")
		M.max_equip++
		qdel(src)
	else
		to_chat(user,"<span class='notice'>You stop modifying the exosuit.</span>")
		working = FALSE
	return 1

/obj/structure/wetdryvac
	name = "wet/dry vacuum"
	desc = "A powerful vacuum cleaner that can collect both trash and fluids."
	density = TRUE
	icon = 'icons/obj/objects.dmi'
	icon_state = "wetdryvac1"
	var/max_trash = 50
	var/list/trash = list()
	var/obj/item/vachandle/myhandle

/obj/structure/wetdryvac/New()
	..()
	create_reagents(50)
	myhandle = new /obj/item/vachandle(src)

/obj/structure/wetdryvac/Destroy()
	if(myhandle)
		if(myhandle.loc == src)
			qdel(myhandle)
		else
			myhandle.myvac = null
		myhandle = null
	for(var/obj/item/I in trash)
		qdel(I)
	trash.Cut()
	..()

/obj/structure/wetdryvac/examine(mob/user)
	..()
	to_chat(user,"<span class='info'>The wet tank gauge reads: [reagents.total_volume]/[reagents.maximum_volume]</span>")
	to_chat(user,"<span class='info'>The dry storage gauge reads: [trash.len]/[max_trash]</span>")

/obj/structure/wetdryvac/attackby(obj/item/W, mob/user)
	if(istype(W,/obj/item/vachandle))
		if(!myhandle)
			myhandle = W
		if(myhandle == W)
			to_chat(user,"<span class='notice'>You insert \the [W] into \the [src].")
			user.drop_item(W,src)
			update_icon()
	else
		..()

/obj/structure/wetdryvac/attack_hand(mob/user)
	if(myhandle && myhandle.loc == src)
		user.put_in_hands(myhandle)
		update_icon()
	else
		..()

/obj/structure/wetdryvac/update_icon()
	if(myhandle)
		icon_state = "wetdryvac[myhandle.loc == src]"
	else
		icon_state = "wetdryvac0"

/obj/structure/wetdryvac/MouseDropFrom(var/obj/O, src_location, var/turf/over_location, src_control, over_control, params)
	if(!can_use(usr,O))
		return
	if(istype(O,/obj/structure/sink))
		if(!reagents.total_volume)
			to_chat(usr,"<span class='warning'>\The [src] wet tank is already empty!</span>")
			return
		playsound(src, 'sound/effects/slosh.ogg', 25, 1)
		reagents.clear_reagents()
		to_chat(usr, "<span class='notice'>You flush \the [src] wet contents down \the [O].</span>")
	else if(istype(O,/obj/item/weapon/reagent_containers) && O.is_open_container())
		if(!reagents.total_volume)
			to_chat(usr,"<span class='warning'>\The [src] wet tank is already empty!</span>")
			return
		playsound(src, 'sound/effects/slosh.ogg', 25, 1)
		to_chat(usr, "<span class='notice'>You pour \the [src] wet contents into \the [O].</span>")
		reagents.trans_to(O.reagents,reagents.total_volume)
	else if(istype(O,/obj/machinery/disposal))
		if(!contents.len)
			to_chat(usr,"<span class='warning'>\The [src] dry storage is already empty!</span>")
			return
		playsound(src, 'sound/effects/freeze.ogg', 25, 1) //this sounds like trash moving to me
		for(var/obj/item/I in trash)
			I.forceMove(O)
		trash.Cut()
		to_chat(usr, "<span class='notice'>You dump \the [src] dry contents into \the [O].</span>")

/obj/structure/wetdryvac/MouseDropTo(atom/O, mob/user)
	if(!can_use(user,O))
		return
	whrr(get_turf(O))

/obj/structure/wetdryvac/proc/whrr(var/turf/T)
	if(!T)
		return
	playsound(src, 'sound/effects/vacuum.ogg', 25, 1)
	for(var/obj/effect/decal/cleanable/C in T)
		if(C.reagent)
			if(reagents.is_full())
				visible_message("<span class='warning'>\The [src] sputters, wet tank full!</span>")
				break
			reagents.add_reagent(C.reagent,1)
		qdel(C)
	for(var/obj/effect/overlay/puddle/P in T)
		if(reagents.is_full())
			visible_message("<span class='warning'>\The [src] sputters, wet tank full!</span>")
			break
		if(P.wet == TURF_WET_LUBE)
			reagents.add_reagent(LUBE,1)
		else if(P.wet == TURF_WET_WATER)
			reagents.add_reagent(WATER,1)
		qdel(P)
	T.clean_blood()
	for(var/obj/item/trash/R in T)
		if(trash.len >= max_trash)
			visible_message("<span class='warning'>\The [src] sputters, dry storage full!</span>")
			return
		R.forceMove(src)
		trash += R

/obj/structure/wetdryvac/proc/can_use(mob/user, atom/target)
	if(!ishigherbeing(user) && !isrobot(user) || user.incapacitated() || user.lying)
		return FALSE
	if(!Adjacent(user) || !user.Adjacent(target))
		return FALSE
	return TRUE

/obj/item/vachandle
	name = "vacuum handle"
	desc = "Handy. It doesn't suck per se, it merely conveys suckage."
	w_class = W_CLASS_MEDIUM
	icon = 'icons/obj/objects.dmi'
	icon_state = "vachandle"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/misc_tools.dmi', "right_hand" = 'icons/mob/in-hand/right/misc_tools.dmi')
	item_state = "vachandle"
	w_class = W_CLASS_HUGE
	var/obj/structure/wetdryvac/myvac
	var/event_key = null

/obj/item/vachandle/New()
	..()
	myvac = loc

/obj/item/vachandle/Destroy()
	myvac.myhandle = null
	myvac = null
	..()

/obj/item/vachandle/pickup(mob/user)
	..()
	user.lazy_register_event(/lazy_event/on_moved, src, .proc/mob_moved)

/obj/item/vachandle/dropped(mob/user)
	user.lazy_unregister_event(/lazy_event/on_moved, src, .proc/mob_moved)
	if(loc != myvac)
		retract()

/obj/item/vachandle/throw_at()
	retract()

/obj/item/vachandle/proc/mob_moved(atom/movable/mover)
	if(myvac && get_dist(src,myvac) > 2) //Needs a little leeway because dragging isn't instant
		retract()

/obj/item/vachandle/proc/retract()
	if(loc == myvac)
		return
	visible_message("<span class='warning'>\The [src] snaps back into \the [myvac]!</span>")
	if(ismob(loc))
		var/mob/M = loc
		M.drop_item(src,myvac)
	else
		forceMove(myvac)
	myvac.update_icon()

/obj/item/vachandle/preattack(atom/target, mob/user , proximity)
	if(!myvac)
		to_chat(user, "<span class='warning'>\The [src] isn't attached to a vacuum!</span>")
		return
	if(!proximity || !myvac.can_use(user,target))
		return
	if(target == myvac)
		return ..()
	myvac.whrr(get_turf(target))
	return 1

/obj/item/weapon/fakeposter_kit
	name = "cargo cache kit"
	desc = "Used to create a hidden cache behind what appears to be a cargo poster."
	icon = 'icons/obj/barricade.dmi'
	icon_state = "barricade_kit"
	w_class = W_CLASS_MEDIUM

/obj/item/weapon/fakeposter_kit/preattack(atom/target, mob/user , proximity)
	if(!proximity)
		return
	if(istype(target,/turf/simulated/wall))
		playsound(user.loc, 'sound/effects/shieldbash.ogg', 50, 1)
		if(do_after(user,target,4 SECONDS))
			to_chat(user,"<span class='notice'>Using the kit, you hollow out the wall and hang the poster in front.</span>")
			var/obj/structure/fakecargoposter/FCP = new(target)
			FCP.access_loc = get_turf(user)
			qdel(src)
			return 1
	else
		return ..()

/obj/structure/fakecargoposter
	icon = 'icons/obj/posters.dmi'
	var/obj/item/weapon/storage/cargocache/cash
	var/turf/access_loc

/obj/structure/fakecargoposter/New()
	..()
	var/datum/poster/type = pick(/datum/poster/special/cargoflag,/datum/poster/special/cargofull)
	icon_state = initial(type.icon_state)
	desc = initial(type.desc)
	name = initial(type.name)
	cash = new(src)

/obj/structure/fakecargoposter/examine(mob/user)
	..()
	if(user.loc == access_loc)
		to_chat(user, "<span class='info'>Upon closer inspection, there's a hidden cache behind it accessible with a free hand.</span>")

/obj/structure/fakecargoposter/Destroy()
	for(var/atom/movable/A in cash.contents)
		A.forceMove(loc)
	qdel(cash)
	cash = null
	..()

/obj/structure/fakecargoposter/attackby(var/obj/item/weapon/W, mob/user)
	if(iswelder(W))
		visible_message("<span class='warning'>[user] is destroying the hidden cache disguised as a poster!</span>")
		var/obj/item/weapon/weldingtool/WT=W
		if(WT.do_weld(user, src, 10 SECONDS, 5))
			visible_message("<span class='warning'>[user] destroyed the hidden cache!</span>")
			qdel(src)
	else if(user.loc == access_loc)
		cash.attackby(W,user)
	else
		..()

/obj/structure/fakecargoposter/attack_hand(mob/user)
	if(user.loc == access_loc)
		cash.AltClick(user)

/obj/item/weapon/storage/cargocache
	name = "cargo cache"
	desc = "A large hidey hole for all your goodies."
	icon = 'icons/obj/posters.dmi'
	icon_state = "cargoposter-flag"
	fits_max_w_class = W_CLASS_LARGE
	max_combined_w_class = 28
	slot_flags = 0

/obj/item/weapon/storage/cargocache/distance_interact(mob/user)
	if(istype(loc,/obj/structure/fakecargoposter) && user.Adjacent(loc))
		return TRUE
	return FALSE

#define REWARD_FREQUENCY 1000
/obj/item/pedometer
	name = "patrolmens' pedometer"
	desc = "A device which estimates steps taken. This one dispenses prizes for patrolling maintenance or major hallways. It needs to be on your belt, pockets, or in hand to register movement."
	icon = 'icons/obj/device.dmi'
	icon_state = "pedometer"
	w_class = W_CLASS_SMALL
	slot_flags = SLOT_BELT
	var/count = 0
	var/list/approved_areas = list(/area/maintenance,/area/hallway)
	var/list/special_rewards = list(/obj/item/weapon/pen/tactical)
	var/list/regular_rewards = list(/obj/item/weapon/reagent_containers/food/drinks/soda_cans/cannedcopcoffee,
									/obj/item/weapon/reagent_containers/food/snacks/donutiron,
									/obj/item/ammo_storage/speedloader/energy)

/obj/item/pedometer/examine(mob/user)
	..()
	to_chat(user,"<span class='info'>The reward ticker reads [count].</span>")

/obj/item/pedometer/pickup(mob/user)
	..()
	user.lazy_register_event(/lazy_event/on_moved, src, .proc/mob_moved)

/obj/item/pedometer/dropped(mob/user)
	..()
	user.lazy_unregister_event(/lazy_event/on_moved, src, .proc/mob_moved)

/obj/item/pedometer/proc/mob_moved(atom/movable/mover)
	var/turf/T = get_turf(src)
	var/area/A = get_area(T)
	if(is_type_in_list(A,approved_areas))
		count++
		if(!(count % REWARD_FREQUENCY))
			var/path
			if(special_rewards.len)
				path = pick_n_take(special_rewards)
			else
				path = pick(regular_rewards)
			if(path)
				var/obj/item/I = new path(get_turf(src))
				if(isliving(mover))
					var/mob/living/living_mover = mover
					living_mover.put_in_hands(I)
				to_chat(mover,"<span class='good'>\The [src] dispenses a reward!</span>")


//Mystery mob cubes//////////////

/obj/item/weapon/storage/box/mysterycubes
	name = "mystery cube box"
	desc = "Dehydrated friends!"
	icon = 'icons/obj/pbag.dmi'
	icon_state = "pbag"	//Supposed to look kind of shitty, cubes aren't even wrapped
	foldable = /obj/item/weapon/paper
	can_only_hold = list("/obj/item/weapon/reagent_containers/food/snacks/monkeycube/mysterycube")

/obj/item/weapon/storage/box/mysterycubes/New()
	..()
	var/friendAmount = 1
	friendAmount = rand(1, 3)
	for(var/i = 1 to friendAmount)
		new /obj/item/weapon/reagent_containers/food/snacks/monkeycube/mysterycube(src)

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/mysterycube
	name = "mystery cube"
	desc = "A portable friend!"
	var/static/list/potentialFriends = list()

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/mysterycube/New()
	..()
	if(!length(potentialFriends))
		potentialFriends = existing_typesof(/mob/living/simple_animal) - (boss_mobs + blacklisted_mobs)
	contained_mob = pick(potentialFriends)


//Mystery chem beakers//////////////

/obj/item/weapon/storage/box/mystery_vial
	name = "assorted chemical pack"
	desc = "A mix of reagents from who knows where."
	icon_state = "beaker"

/obj/item/weapon/storage/box/mystery_vial/New()
	..()
	for(var/i = 1 to 5)
		new /obj/item/weapon/reagent_containers/glass/beaker/vial/mystery(src)

/obj/item/weapon/reagent_containers/glass/beaker/vial/mystery
	name = "recycled vial"
	desc = "Slightly scratched and worn, it looks like this wasn't its original purpose. The label has been sloppily peeled off."
	mech_flags = MECH_SCAN_FAIL	//Nip that in the bud
	var/static/list/illegalChems = list(	//Just a bad idea
		ADMINORDRAZINE,
		BLOCKIZINE,
		AUTISTNANITES,
		XENOMICROBES,
		PAISMOKE
	)

/obj/item/weapon/reagent_containers/glass/beaker/vial/mystery/New()
	..()
	var/list/mysteryChems = chemical_reagents_list - illegalChems
	reagents.add_reagent(pick(mysteryChems), volume)


//Mystery circuits////////////

/obj/item/weapon/storage/box/mystery_circuit
	name = "children's circuitry circus educational toy booster pack"
	desc = "Ages 6 and up"
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "circuit"

/obj/item/weapon/storage/box/mystery_circuit/New()
	..()
	var/list/legalCircuits = existing_typesof(/obj/item/weapon/circuitboard) - /obj/item/weapon/circuitboard/card/centcom	//Identical to spessmart spawner
	for(var/i = 1 to 3)
		var/boosterPack = pick(legalCircuits)
		new boosterPack(src)
	new /obj/item/weapon/solder(src)
	new /obj/item/weapon/reagent_containers/glass/beaker/sulphuric(src)
	new /obj/item/weapon/paper/permissionslip(src)

/obj/item/weapon/paper/permissionslip
	name = "circuitry circus education toy booster pack legally binding permission slip"
	desc = "Very clearly hand written."

/obj/item/weapon/paper/permissionslip/New()
	..()
	info = "The purchaser or purchasers of this or any other Circuitry Circus Education Toy Booster Pack <i>TM</i> recognizes, accepts, and is bound to the terms and conditions found within any Circuitry Circus Education Toy Starter Pack <i>TM</i>. This includes but is not limited to: <BR>the relinquishment of any state, country, nation, or planetary given rights protecting those of select ages from legal action based on misuse of the product.<BR>All: injuries, dismemberments, trauma (mental or physical), diseases, invasive species, deaths, memory loss, time loss, genetic recombination, or quantum displacement is the sole responsibility of the owner of the Circuitry Circus Education Toy Booster Pack <i>TM</i> <BR><BR>Please ask for your parent or guardian's permission before playing. Have fun."


//Mystery material//////////////////////

/obj/item/weapon/storage/box/large/mystery_material
	name = "surplus material scrap box"
	desc = "Caked in layers of dust, smells like a warehouse."
	var/list/surplusMat= list(
		/obj/item/stack/sheet/metal = 50,
		/obj/item/stack/sheet/glass/glass = 35,
		/obj/item/stack/sheet/plasteel = 25,
		/obj/item/stack/sheet/mineral/uranium = 20,
		/obj/item/stack/sheet/mineral/silver = 20,
		/obj/item/stack/sheet/mineral/gold = 15,
		/obj/item/stack/sheet/mineral/diamond = 5,
		/obj/item/stack/sheet/mineral/phazon = 1,
		/obj/item/stack/sheet/mineral/clown = 1
	)

/obj/item/weapon/storage/box/large/mystery_material/odd
	name = "surplus odd material scrap box"
	surplusMat = list(
		/obj/item/stack/sheet/bone = 50,
		/obj/item/stack/sheet/mineral/sandstone = 50,
		/obj/item/stack/sheet/brass = 35,
		/obj/item/stack/sheet/mineral/gingerbread = 25,
		/obj/item/stack/sheet/animalhide/xeno = 10,
		/obj/item/stack/sheet/animalhide/human = 20,
		/obj/item/stack/sheet/snow = 25,
		/obj/item/stack/sheet/cardboard = 20,
		/obj/item/stack/telecrystal = 2,	//Emergent gameplay!
		/obj/item/stack/teeth/gold = 10,
		/obj/item/stack/tile/slime = 20
	)

/obj/item/weapon/storage/box/large/mystery_material/New()
	..()
	for(var/i = 1 to 6)
		var/theSurplus = pickweight(surplusMat)
		new theSurplus(src, surplusMat[theSurplus])


//Mystery food////////////////////

/obj/structure/closet/crate/freezer/bootlegpicnic
	name = "bootleg picnic supplies"
	desc = "Tangible proof against prohibition."

/obj/structure/closet/crate/freezer/bootlegpicnic/New()
	..()
	for(var/i = 1 to 4)
		var/bootlegSnack = pick(existing_typesof(/obj/item/weapon/reagent_containers/food/snacks))
		new bootlegSnack(src)
	for(var/i = 1 to 2)
		var/bootlegDrink = pick(existing_typesof(/obj/item/weapon/reagent_containers/food/drinks))
		new bootlegDrink(src)


//Restock//////////////////////

/obj/structure/vendomatpack/trader
	name = "trader supply recharge pack"
	targetvendomat = /obj/machinery/vending/trader
	icon_state = "sale"
