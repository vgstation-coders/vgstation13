/obj/structure/closet/crate/chest/alcatraz
	name = "Alcatraz IV security crate"
	desc = "It came from Alcatraz IV!"

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
	/obj/structure/ammotree,
	/obj/item/weapon/ram_kit,
	/obj/item/device/vampirehead,
	/obj/item/weapon/storage/lockbox/unlockable/peace,
	/obj/item/clothing/head/helmet/stun,
	/obj/item/weapon/secway_kit,
	/obj/structure/largecrate/secure,
	/obj/item/weapon/storage/lockbox/advanced/ricochettaser,
	/obj/structure/closet/crate/flatpack/ancient/prisoner_autoclother,
	/obj/item/weapon/storage/lockbox/advanced/energyshotgun
	)

/obj/structure/closet/crate/chest/alcatraz/New()
	..()
	for(var/i = 1 to 6)
		if(!alcatraz_stuff.len)
			return
		var/path = pick_n_take(alcatraz_stuff)
		new path(src)


/obj/item/clothing/head/helmet/stun
	name = "stun helmet"
	desc = "For the experimental program of deploying armless security officers. Its complex wiring is known to block out psychic powers and 5G signals."
	icon_state = "helmetstun"
	light_power = 2.5
	light_range = 4
	light_color = LIGHT_COLOR_ORANGE
	mech_flags = MECH_SCAN_FAIL
	var/obj/item/weapon/cell/bcell

/obj/item/clothing/head/helmet/stun/New()
	..()
	bcell = new(src)
	bcell.charge = bcell.maxcharge
	update_icon()

/obj/item/clothing/head/helmet/stun/Destroy()
	if (bcell)
		QDEL_NULL(bcell)

	return ..()

/obj/item/clothing/head/helmet/stun/get_cell()
	return bcell

/obj/item/clothing/head/helmet/stun/examine(mob/user)
	..()
	if(bcell)
		to_chat(user, "<span class='info'>The helmet is [round(bcell.percent())]% charged.</span>")

/obj/item/clothing/head/helmet/stun/mob_can_equip(mob/M, slot, disable_warning = 0, automatic = 0)
	if(!..() || !ishuman(M))
		return CANNOT_EQUIP
	if(clumsy_check(M))
		to_chat(M, "<span class='warning'>You get stunned trying to don \the [src].</span>")
		return CANNOT_EQUIP
	var/mob/living/carbon/human/C = M
	if(!C.head)
		return CAN_EQUIP
	if(C.head.canremove)
		return CAN_EQUIP_BUT_SLOT_TAKEN
	return CAN_EQUIP

/obj/item/clothing/head/helmet/stun/proc/use(var/amount)
	if(!bcell || bcell.charge < amount)
		return FALSE
	bcell.use(amount)
	return TRUE

#define STUN_HELMET_STRENGTH 10
/obj/item/clothing/head/helmet/stun/bite_action(mob/target)
	if(!isliving(loc) || !isliving(target) || !use(STUN_HELMET_STRENGTH**2))
		return FALSE
	var/mob/living/user = loc
	var/mob/living/L = target
	if(iscarbon(target))
		var/mob/living/carbon/C = L
		if(C.check_shields(0,src))
			return FALSE
		L.apply_effect(STUN_HELMET_STRENGTH, STUTTER)
	playsound(loc, 'sound/weapons/Egloves.ogg', 50, 1, -1)
	L.Knockdown(STUN_HELMET_STRENGTH)
	L.Stun(STUN_HELMET_STRENGTH)
	user.attack_log += "\[[time_stamp()]\]<font color='red'> Stunned [L.name] ([L.ckey]) with [name]</font>"
	L.attack_log += "\[[time_stamp()]\]<font color='orange'> Stunned by [user.name] ([user.ckey]) with [name]</font>"
	log_attack("<font color='red'>[user.name] ([user.ckey]) stunned [L.name] ([L.ckey]) with [name]</font>" )
	return TRUE

/obj/item/clothing/accessory/bangerboy
	name = "\improper Banger Boy Advance"
	desc = "The beloved sequel to the Banger Boy Color. Tap it or the clothing item it is attached to with grenades to trigger them for early detonation. Straps nicely onto security armor."
	icon_state = "bangerboy"
	mech_flags = MECH_SCAN_FAIL
	var/obj/item/tool/screwdriver/S
	autoignition_temperature = AUTOIGNITION_PLASTIC

/obj/item/clothing/accessory/bangerboy/New()
	..()
	S = new(src)

/obj/item/clothing/accessory/bangerboy/Destroy()
	QDEL_NULL(S)
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
	item_state = "donutgiver"
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
	if(!ishuman(M))
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
	explosion(user, -1, 0, 2, whodunnit = user)
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
	species_fit = list(GREY_SHAPED, VOX_SHAPED)
	body_parts_covered = FULL_TORSO|ARMS
	autoignition_temperature = AUTOIGNITION_PROTECTIVE

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


/obj/item/key/security/spare
	name = "warden's spare secway key"
	desc = "It has a tag that reads:"
	var/home_map

/obj/item/key/security/spare/New()
	..()
	var/list/map_names = list("Defficiency","Bagelstation","Meta Club","Packed Station","Asteroid Station","Box Station",
		 "Snow Station", "Synergy Station", "Lamprey Station")
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
	var/obj/effect/located_blood
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

	for(var/obj/effect/rune/R in range(5,loc))
		located_blood = R

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
										"Bah. You mock Le Confr�rie des Chevaliers du Tastevin with your plebian visage.",
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
		M.assaulted_by(user)


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
	autoignition_temperature = AUTOIGNITION_PLASTIC

/obj/item/weapon/autocuffer/Destroy()
	if(stored)
		QDEL_NULL(stored)
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

#define REWARD_FREQUENCY 1000
/obj/item/pedometer
	name = "patrolmens' pedometer"
	desc = "A device which estimates steps taken. This one dispenses prizes for patrolling maintenance or major hallways. It needs to be on your belt, pockets, or in hand to register movement."
	icon = 'icons/obj/device.dmi'
	icon_state = "pedometer"
	w_class = W_CLASS_SMALL
	slot_flags = SLOT_BELT
	autoignition_temperature = AUTOIGNITION_PLASTIC
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
	user.register_event(/event/moved, src, nameof(src::mob_moved()))

/obj/item/pedometer/dropped(mob/user)
	..()
	user.unregister_event(/event/moved, src, nameof(src::mob_moved()))

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

#define AT_SEED 0
#define AT_PLANTED 1
#define AT_SAPLING 2
#define AT_MATURE 3
#define AT_FLOWERING 4

/obj/structure/ammotree
	name = "ammo tree seed"
	desc = "The seed of an ammo tree. A gene-modified plant that was developed to synthesize metals. <B>If it was rammed in with enough force, you could get it to grow.</B>"
	icon = 'icons/obj/flora/big_pots.dmi'
	icon_state = "ammotree-0"
	density = FALSE
	anchored = FALSE
	pixel_x = -16
	plane = ABOVE_HUMAN_PLANE
	var/state = AT_SEED
	var/pity_timer = 0
	autoignition_temperature = AUTOIGNITION_PAPER

/obj/structure/ammotree/attackby(obj/item/I, mob/user)
	if(state == AT_SEED && istype(I, /obj/item/weapon/batteringram))
		state = AT_PLANTED
		playsound(src, 'sound/effects/shieldbash.ogg', 50, 1)
		processing_objects += src
	else
		..()
	update_icon()

/obj/structure/ammotree/attack_hand(mob/user)
	if(state != AT_FLOWERING)
		return
	visible_message("<span class='notice>[user] picks some ammo fruit from \the [src].</span>")
	state = AT_MATURE
	update_icon()
	processing_objects += src
	playsound(loc, "sound/effects/plant_rustle.ogg", 50, 1, -1)
	for(var/i = 1 to 4)
		new /obj/item/ammofruit(user.loc)

/obj/structure/ammotree/update_icon()
	icon_state = "ammotree-[state]"
	switch(state)
		if(AT_PLANTED)
			name = "strange pot"
			desc = "Something is clearly putting down roots below."
		if(AT_SAPLING)
			name = "ammo tree sapling"
			desc = "An ammo tree sapling. It looks thin enough to snap like a twig."
		if(AT_MATURE)
			name = "ammo tree"
			desc = "A gene-modified plant that was developed to synthesize metals."

/obj/structure/ammotree/process()
	if(state >= AT_FLOWERING)
		processing_objects -= src
		return
	if(prob(1) || pity_timer > 99)
		state++
		pity_timer = 0
		update_icon()
	else
		pity_timer++

/obj/item/ammofruit
	name = "ammofruit"
	desc = "Not edible. Feed it into your local ammolathe."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "ammofruit"
	w_class = W_CLASS_SMALL
	autoignition_temperature = 	AUTOIGNITION_PAPER

/obj/item/ammofruit/New()
	..()
	pixel_x = rand(-3,3)
	pixel_y = rand(-3,3)
	materials = new /datum/materials(src)
	materials.addAmount(MAT_IRON,CC_PER_SHEET_METAL*2)
	if(prob(25))
		if(prob(60))
			materials.addAmount(MAT_PLASMA,CC_PER_SHEET_MISC*2)
			name = "dragonbreath ammofruit"
			icon_state = "ammofruit_plasma"
		else
			materials.addAmount(MAT_GLASS,CC_PER_SHEET_GLASS)
			materials.addAmount(MAT_PLASTIC,CC_PER_SHEET_MISC)
			materials.addAmount(MAT_WOOD, CC_PER_SHEET_MISC)
			name = "gunstock ammofruit"
			icon_state = "ammofruit_glass"
	else
		materials.addAmount(MAT_IRON,CC_PER_SHEET_METAL)

/obj/item/ammofruit/recyclable(var/obj/machinery/r_n_d/fabricator/F)
	if(!istype(F, /obj/machinery/r_n_d/fabricator/mechanic_fab/autolathe/ammolathe))
		return FALSE
	return TRUE
