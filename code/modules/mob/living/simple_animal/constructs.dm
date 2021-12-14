
/mob/living/simple_animal/construct
	name = "\improper Construct"
	real_name = "\improper Construct"
	desc = ""
	speak_emote = list("hisses")
	emote_hear = list("wails","screeches")
	response_help  = "thinks better of touching"
	response_disarm = "flails at"
	response_harm   = "punches"
	speed = 1
	a_intent = I_HURT
	stop_automated_movement = 1
	status_flags = CANPUSH
	attack_sound = 'sound/weapons/spiderlunge.ogg'
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	show_stat_health = 0
	faction = "cult"
	supernatural = 1
	flying = 1
	treadmill_speed = 0 //It floats!
	mutations = list(M_NO_SHOCK)
	see_in_dark = 9

	mob_property_flags = MOB_CONSTRUCT
	mob_swap_flags = HUMAN|SIMPLE_ANIMAL|SLIME|MONKEY
	mob_push_flags = ALLMOBS

	meat_type = /obj/item/weapon/ectoplasm

	var/list/construct_spells = list()

	var/list/healers = list()

	var/construct_color = rgb(255,255,255)

	var/floating_amplitude = 4

	// for constructs with one spell, locate() that spell and use it.
	var/spell/spell_on_use_inhand = /spell

	blooded = FALSE


/mob/living/simple_animal/construct/New()
	..()
	update_icons()//adds glowing eyes and bars

	//Floating!
	animate(src, pixel_y = (2 + floating_amplitude) * PIXEL_MULTIPLIER , time = 7, loop = -1, easing = SINE_EASING)
	animate(pixel_y = 2 * PIXEL_MULTIPLIER, time = 7, loop = -1, easing = SINE_EASING)

	add_language(LANGUAGE_CULT)
	add_language(LANGUAGE_GALACTIC_COMMON)
	default_language = all_languages[LANGUAGE_CULT]
	init_language = default_language
	hud_list[CONSTRUCT_HUD] = image('icons/mob/hud.dmi', src, "consthealth100")
	for(var/spell in construct_spells)
		src.add_spell(new spell, "cult_spell_ready", /obj/abstract/screen/movable/spell_master/bloodcult)

/mob/living/simple_animal/construct/update_perception()
	if(dark_plane)
		dark_plane.alphas["construct"] = 75
		client.color = list(
					1,0,0,0,
					0,1.3,0,0,
	 				0,0,1.3,0,
		 			0,-0.3,-0.3,1,
		 			0,0,0,0)

	check_dark_vision()


/mob/living/simple_animal/construct/Move(NewLoc,Dir=0,step_x=0,step_y=0,var/glide_size_override = 0)
	. = ..()
	if (healers.len > 0)
		for (var/mob/living/simple_animal/construct/builder/perfect/P in healers)
			P.move_ray()

/mob/living/simple_animal/construct/say(var/message)
	. = ..(message, "C")

/mob/living/simple_animal/construct/cult_chat_check(setting)
	if(!mind)
		return
	if(find_active_faction_by_member(iscultist(src)))
		return 1
	if(find_active_faction_by_member(mind.GetRole(LEGACY_CULTIST)))
		return 1

#define SPEAK_OVER_GENERAL_CULT_CHAT 0
#define SPEAK_OVER_CHANNEL_INTO_CULT_CHAT 1
#define HEAR_CULT_CHAT 2

/mob/living/simple_animal/construct/handle_inherent_channels(var/datum/speech/speech, var/message_mode)
	if(..())
		return 1
	if(message_mode == MODE_HEADSET && cult_chat_check(SPEAK_OVER_GENERAL_CULT_CHAT))
		var/turf/T = get_turf(src)
		log_say("[key_name(src)] (@[T.x],[T.y],[T.z]) Cult channel: [html_encode(speech.message)]")
		for(var/mob/M in mob_list)
			if(M.cult_chat_check(HEAR_CULT_CHAT) || ((M in dead_mob_list) && !istype(M, /mob/new_player)))
				to_chat(M, "<span class='sinister'><b>[src.name]:</b> [html_encode(speech.message)]</span>")
		return 1

#undef SPEAK_OVER_GENERAL_CULT_CHAT
#undef SPEAK_OVER_CHANNEL_INTO_CULT_CHAT
#undef HEAR_CULT_CHAT


/mob/living/simple_animal/construct/occult_muted()
	. = ..()
	if (.)
		return 1
	if (purge > 0)
		return 1
	return 0

/mob/living/simple_animal/construct/gib(var/animation = 0, var/meat = 1)
	if(!isUnconscious())
		forcesay("-")
	death(1)
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101

	dead_mob_list -= src

	qdel(src)

/mob/living/simple_animal/construct/cultify()
	return

/mob/living/simple_animal/construct/proc/setup_type(var/mob/living/carbon/creator)
	if(istype(creator, /mob/living/carbon))
		//Determine construct color	and set languages
		if(!iscultist(creator))
			universal_understand = 1
			default_language = all_languages[LANGUAGE_GALACTIC_COMMON]
			init_language = default_language
			if(iswizard(creator) || isapprentice(creator))
				construct_color = rgb(157, 1, 196) // WIZARDS -> purple
				faction = "wizard" // so they get along with other wizard mobs
			else
				construct_color = rgb(0, 153, 255) // CREW -> blue
		else

			var/datum/role/streamer/streamer_role = creator.mind.GetRole(STREAMER)
			if(streamer_role && streamer_role.team == ESPORTS_CULTISTS)
				if(streamer_role.followers.len == 0 && streamer_role.subscribers.len == 0) //No followers and subscribers, use normal cult colors.
					construct_color = rgb(235,0,0) // STREAMER (no subs) -> RED
				else
					construct_color = rgb(30,255,30) // STREAMER (with subs) -> GREEN
			else
				construct_color = rgb(235,0,0)
	else if (istype(creator, /mob/living/simple_animal/shade))//shade beacon
		if (iscultist(creator))
			construct_color = rgb(235,0,0) // CULTIST -> red
		else
			construct_color = rgb(0, 153, 255) // CREW -> blue
	update_icons()

/mob/living/simple_animal/construct/Login()
	..()
	if (default_language == all_languages[LANGUAGE_GALACTIC_COMMON])
		to_chat(src,"<span class='notice'>You can speak in cult chants by using :5.</span>")
	else
		to_chat(src,"<span class='notice'>To be understood by non-cult speaking humans, use :1.</span>")

/mob/living/simple_animal/construct/death(var/gibbed = FALSE)
	..(TRUE) //If they qdel, they gib regardless
	for(var/i=0;i<3;i++)
		new /obj/item/weapon/ectoplasm (src.loc, construct_color)
	for(var/mob/M in viewers(src, null))
		if((M.client && !( M.blinded )))
			M.show_message("<span class='warning'>[src] collapses in a shattered heap. </span>")
	if(client && iscultist(src))
		var/turf/T = get_turf(src)
		if (T)
			var/mob/living/simple_animal/shade/shade = new (T)
			shade.name = "[real_name] the Shade"
			shade.real_name = "[real_name]"
			mind.transfer_to(shade)
			update_faction_icons()
			to_chat(shade, "<span class='sinister'>Dark energies rip your dying body appart, anchoring your soul inside the form of a Shade. You retain your memories, and devotion to the cult.</span>")
	else
		ghostize()
	qdel (src)

/mob/living/simple_animal/construct/examine(mob/user)
	var/msg = "<span cass='info'>*---------*\nThis is [bicon(src)] \a <EM>[src]</EM>!\n"
	if (src.health < src.maxHealth)
		msg += "<span class='warning'>"
		if (src.health >= src.maxHealth/2)
			msg += "It looks slightly dented.\n"
		else
			msg += "<B>It looks severely dented!</B>\n"
		msg += "</span>"
	if(!client)
		msg += "<span class='warning'>The spirit animating it seems to be dormant.</span>\n"
	msg += "*---------*</span>"

	to_chat(user, msg)

/mob/living/simple_animal/construct/attack_construct(var/mob/user)
	if(istype(user,/mob/living/simple_animal/construct/builder/perfect) && get_dist(user,src)<=2)
		attack_animal(user)
		return 1
	return 0

/mob/living/simple_animal/construct/attack_animal(mob/living/simple_animal/M)
	if(istype(M, /mob/living/simple_animal/construct/builder/perfect))
		if(src.health >= src.maxHealth)
			to_chat(M, "<span class='notice'>\The [src] has nothing to mend.</span>")
			return
		var/mob/living/simple_animal/construct/builder/perfect/P = M
		P.start_ray(src)
	else if(istype(M, /mob/living/simple_animal/construct/builder))
		if(src.health >= src.maxHealth)
			to_chat(M, "<span class='notice'>\The [src] has nothing to mend.</span>")
			return
		health = min(maxHealth, health + 5) // Constraining health to maxHealth
		anim(target = src, a_icon = 'icons/effects/effects.dmi', flick_anim = "const_heal", lay = NARSIE_GLOW, plane = ABOVE_LIGHTING_PLANE)
		M.visible_message("[M] mends some of \the <EM>[src]'s</EM> wounds.","You mend some of \the <em>[src]'s</em> wounds.")
		update_icons()
	else
		M.unarmed_attack_mob(src)

/mob/living/simple_animal/construct/attackby(var/obj/item/O as obj, var/mob/user as mob)
	user.delayNextAttack(8)
	if(O.force)
		var/damage = O.force
		if (O.damtype == HALLOSS)
			damage = 0
		if(isholyweapon(O))
			damage *= 2
			purge = 3
		adjustBruteLoss(damage)
		O.on_attack(src, user)
		user.visible_message("<span class='danger'>[src] has been attacked with [O] by [user]. </span>")
	else
		to_chat(usr, "<span class='warning'>This weapon is ineffective, it does no damage.</span>")
		user.visible_message("<span class='warning'>[user] gently taps [src] with [O]. </span>")


/mob/living/simple_animal/construct/mode()
	set name = "Activate Held Object"
	set category = "IC"
	set src = usr
	set hidden = TRUE

	var/mob/living/simple_animal/construct/C = src
	var/spell/S = locate(C.spell_on_use_inhand) in C.spell_list
	if(S)
		S.perform(C)
		S.connected_button.update_charge(1)


/////////////////Juggernaut///////////////



/mob/living/simple_animal/construct/armoured
	name = "\improper Juggernaut"
	real_name = "\improper Juggernaut"
	desc = "A possessed suit of armour driven by the will of the restless dead."
	icon = 'icons/mob/mob.dmi'
	icon_state = "behemoth"
	icon_living = "behemoth"
	icon_dead = "behemoth"
	maxHealth = 250
	health = 250
	response_harm   = "harmlessly punches"
	harm_intent_damage = 0
	melee_damage_lower = 30
	melee_damage_upper = 30
	attacktext = "smashes their armoured gauntlet into"
	speed = 4
	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | SMASH_WALLS
	attack_sound = 'sound/weapons/heavysmash.ogg'
	status_flags = 0
	construct_spells = list(/spell/aoe_turf/conjure/forcewall/lesser)
	floating_amplitude = 2
	var/damageblock = 10

/mob/living/simple_animal/construct/armoured/proc/juggerblock(var/damage, var/atom/A)//juggernauts ignore damage of 10 and bellow if they aren't showing cracks yet (which happens when they are at 66% hp)
	var/hurt = maxHealth - health
	if (hurt <= (maxHealth/3) && (!damage || damage <= damageblock))//when cracks start to appear
		if (A)
			visible_message("<span class='danger'>\The [A] bounces harmlessly off of \the [src]'s shell. </span>")
		anim(target = src, a_icon = 'icons/effects/64x64.dmi', flick_anim = "juggernaut_armor", lay = NARSIE_GLOW, offX = -WORLD_ICON_SIZE/2, offY = -WORLD_ICON_SIZE/2 + 4, plane = ABOVE_LIGHTING_PLANE)
		playsound(src, 'sound/items/metal_impact.ogg', 25)
		return TRUE
	return FALSE

/mob/living/simple_animal/construct/armoured/ex_act(severity)
	if(flags & INVULNERABLE)
		return

	switch (severity)
		if (1.0)
			adjustBruteLoss(220)//we can survive point blank devastation if we weren't previously damaged

		if (2.0)
			adjustBruteLoss(60 + max(0,round(health-(2*maxHealth/3))-59))//will actually deal a tiny bit more damage if we were full HP to ensure that we'll reach the first "cracking" threshold

		if (3.0)
			if (juggerblock())
				visible_message("<span class='danger'>\The [src]'s shell fully resists the weak explosion.</span>")
			else
				adjustBruteLoss(30)

/mob/living/simple_animal/construct/armoured/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(juggerblock(O.force, O))
		user.delayNextAttack(8)
	else
		..()

/mob/living/simple_animal/construct/armoured/bullet_act(var/obj/item/projectile/P)
	if(istype(P, /obj/item/projectile/energy) || istype(P, /obj/item/projectile/beam) || istype(P, /obj/item/projectile/forcebolt) || istype(P, /obj/item/projectile/change))
		var/reflectchance = 80 - round(P.damage/3)
		if(P.damage <= damageblock || prob(reflectchance))//low damage lasers always get reflected
			adjustBruteLoss(P.damage * 0.5)
			visible_message("<span class='danger'>\The [P.name] gets reflected by \the [src]'s shell!</span>", \
							"<span class='userdanger'>\The [P.name] gets reflected by \the [src]'s shell!</span>")


			if(!istype(P, /obj/item/projectile/beam)) //has seperate logic
				P.reflected = 1
				P.rebound(src)

			return PROJECTILE_COLLISION_REBOUND // complete projectile permutation
	else if (juggerblock(P.damage,P))
		return PROJECTILE_COLLISION_BLOCKED
	return (..(P))

/mob/living/simple_animal/construct/armoured/thrown_defense(var/obj/O)
	if(juggerblock(O.throwforce,O))
		return FALSE
	return TRUE

/mob/living/simple_animal/construct/armoured/apply_damage(var/damage = 0,var/damagetype = BRUTE, var/def_zone = null, var/blocked = 0, sharp, edge, var/used_weapon = null, ignore_events = 0)
	if (juggerblock(damage))
		return 0
	return ..()

////////////////////////Wraith/////////////////////////////////////////////



/mob/living/simple_animal/construct/wraith
	name = "\improper Wraith"
	real_name = "\improper Wraith"
	desc = "A wicked bladed shell contraption piloted by a bound spirit."
	icon = 'icons/mob/mob.dmi'
	icon_state = "floating"
	icon_living = "floating"
	icon_dead = "floating"
	maxHealth = 75
	health = 75
	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "slashes"
	speed = 1
	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | OPEN_DOOR_WEAK
	attack_sound = 'sound/weapons/rapidslice.ogg'
	construct_spells = list(/spell/targeted/ethereal_jaunt/shift)

/mob/living/simple_animal/construct/wraith/get_unarmed_sharpness(mob/living/victim)
	return 1.5

/////////////////////////////Artificer/////////////////////////



/mob/living/simple_animal/construct/builder
	name = "\improper Artificer"
	real_name = "\improper Artificer"
	desc = "A bulbous construct dedicated to building and maintaining the Cult of Nar-Sie's armies."
	icon = 'icons/mob/mob.dmi'
	icon_state = "artificer"
	icon_living = "artificer"
	icon_dead = "artificer"
	maxHealth = 100
	health = 100
	response_harm = "viciously beats"
	harm_intent_damage = 5
	melee_damage_lower = 5
	melee_damage_upper = 5
	attacktext = "rams"
	speed = 1
	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS
	attack_sound = 'sound/weapons/rapidslice.ogg'
	construct_spells = list(/spell/aoe_turf/conjure/construct/lesser,
							/spell/aoe_turf/conjure/wall,
							/spell/aoe_turf/conjure/floor,
							/spell/aoe_turf/conjure/soulstone,
							/spell/aoe_turf/conjure/pylon,
							///obj/effect/proc_holder/spell/targeted/projectile/magic_missile/lesser
							)
	floating_amplitude = 3

	// tactically deploy a wall under you and become immune to projectiles, I guess
	spell_on_use_inhand = /spell/aoe_turf/conjure/wall


/////////////////////////////Behemoth/////////////////////////


/mob/living/simple_animal/construct/armoured/behemoth
	name = "\improper Behemoth"
	real_name = "\improper Behemoth"
	desc = "The pinnacle of occult technology, Behemoths are the ultimate weapon in the Cult of Nar-Sie's arsenal."
	icon = 'icons/mob/mob.dmi'
	icon_state = "behemoth"
	icon_living = "behemoth"
	icon_dead = "behemoth"
	maxHealth = 750
	health = 750
	speak_emote = list("rumbles")
	response_harm   = "harmlessly punches"
	harm_intent_damage = 0
	melee_damage_lower = 50
	melee_damage_upper = 50
	attacktext = "brutally crushes"
	speed = 6
	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | SMASH_WALLS
	attack_sound = 'sound/weapons/heavysmash.ogg'
	//var/energy = 0
	//var/max_energy = 1000
	construct_spells = list(/spell/aoe_turf/conjure/forcewall/lesser)



////////////////////////Harvester////////////////////////////////



/mob/living/simple_animal/construct/harvester
	name = "Harvester"
	real_name = "Harvester"
	desc = "The promised reward of the livings who follow Nar-Sie. Obtained by offering their bodies to the geometer of blood."
	icon = 'icons/mob/mob.dmi'
	icon_state = "harvester"
	icon_living = "harvester"
	icon_dead = "harvester"
	maxHealth = 150
	health = 150
	melee_damage_lower = 25
	melee_damage_upper = 25
	attacktext = "violently stabs"
	speed = 1
	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS
	see_in_dark = 7
	attack_sound = 'sound/weapons/pierce.ogg'

	construct_spells = list(
			/spell/targeted/harvest,
			/spell/aoe_turf/knock/harvester,
			/spell/rune_write
		)

/mob/living/simple_animal/construct/harvester/New()
	..()
	change_sight(adding = SEE_MOBS)

////////////////Glow & Damage//////////////////

/mob/living/simple_animal/construct/adjustBruteLoss(damage)
	..()
	update_icons()

/mob/living/simple_animal/construct/update_icons()
	overlays = 0
	var/overlay_layer = ABOVE_LIGHTING_LAYER
	var/overlay_plane = ABOVE_LIGHTING_PLANE
	if(layer != MOB_LAYER) // ie it's hiding
		overlay_layer = FLOAT_LAYER
		overlay_plane = FLOAT_PLANE

	//Damage
	var/damage = maxHealth - health
	var/icon/damageicon
	if (damage > (2*maxHealth/3))
		damageicon = icon(icon,"[icon_state]_damage_high")
	else if (damage > (maxHealth/3))
		damageicon = icon(icon,"[icon_state]_damage_low")
	if (damageicon)
		damageicon.Blend(construct_color, ICON_ADD)
		var/image/damage_overlay = image(icon = damageicon, layer = overlay_layer)
		damage_overlay.plane = overlay_plane
		overlays += damage_overlay


	//Eyes
	var/icon/glowicon = icon(icon,"glow-[icon_state]")
	glowicon.Blend(construct_color, ICON_ADD)
	var/image/glow = image(icon = glowicon, layer = overlay_layer)
	glow.plane = overlay_plane
	overlays += glow


////////////////Powers//////////////////


/*
/client/proc/summon_cultist()
	set category = "Behemoth"
	set name = "Summon Cultist (300)"
	set desc = "Teleport a cultist to your location"
	if (istype(usr,/mob/living/simple_animal/construct/armoured/behemoth))

		if(usr.energy<300)
			to_chat(usr, "<span class='warning'>You do not have enough power stored!</span>")
			return

		if(usr.stat)
			return

		usr.energy -= 300
	var/list/mob/living/cultists = new
	for(var/datum/mind/H in ticker.mode.cult)
		if (istype(H.current,/mob/living))
			cultists+=H.current
			var/mob/cultist = input("Choose the one who you want to summon", "Followers of Geometer") as null|anything in (cultists - usr)
			if(!cultist)
				return
			if (cultist == usr) //just to be sure.
				return
			cultist.forceMove(usr.loc)
			usr.visible_message("<span class='warning'>[cultist] appears in a flash of red light as [usr] glows with power</span>")*/

////////////////HUD//////////////////////

/mob/living/simple_animal/construct/Life()
	if(timestopped)
		return 0 //under effects of time magick

	. = ..()

	if(.)
		regular_hud_updates()

		standard_damage_overlay_updates()


/mob/living/simple_animal/construct/regular_hud_updates()
	if(fire_alert)
		throw_alert(SCREEN_ALARM_FIRE, /obj/abstract/screen/alert/carbon/burn/fire/construct)
	else
		clear_alert(SCREEN_ALARM_FIRE)
	update_pull_icon()
	silence_spells(purge)


/mob/living/simple_animal/construct/armoured/regular_hud_updates()
	..()
	if(healths)
		switch(health)
			if(250 to INFINITY)
				healths.icon_state = "juggernaut_health0"
			if(208 to 249)
				healths.icon_state = "juggernaut_health1"
			if(167 to 207)
				healths.icon_state = "juggernaut_health2"
			if(125 to 166)
				healths.icon_state = "juggernaut_health3"
			if(84 to 124)
				healths.icon_state = "juggernaut_health4"
			if(42 to 83)
				healths.icon_state = "juggernaut_health5"
			if(1 to 41)
				healths.icon_state = "juggernaut_health6"
			else
				healths.icon_state = "juggernaut_health7"


/mob/living/simple_animal/construct/armoured/behemoth/regular_hud_updates()
	..()
	if(healths)
		switch(health)
			if(750 to INFINITY)
				healths.icon_state = "juggernaut_health0"
			if(625 to 749)
				healths.icon_state = "juggernaut_health1"
			if(500 to 624)
				healths.icon_state = "juggernaut_health2"
			if(375 to 499)
				healths.icon_state = "juggernaut_health3"
			if(250 to 374)
				healths.icon_state = "juggernaut_health4"
			if(125 to 249)
				healths.icon_state = "juggernaut_health5"
			if(1 to 124)
				healths.icon_state = "juggernaut_health6"
			else
				healths.icon_state = "juggernaut_health7"

/mob/living/simple_animal/construct/builder/regular_hud_updates()
	..()

	process_construct_hud(src)

	if(healths)
		switch(health)
			if(100 to INFINITY)
				healths.icon_state = "artificer_health0"
			if(84 to 99)
				healths.icon_state = "artificer_health1"
			if(68 to 83)
				healths.icon_state = "artificer_health2"
			if(52 to 67)
				healths.icon_state = "artificer_health3"
			if(36 to 51)
				healths.icon_state = "artificer_health4"
			if(20 to 35)
				healths.icon_state = "artificer_health5"
			if(1 to 19)
				healths.icon_state = "artificer_health6"
			else
				healths.icon_state = "artificer_health7"



/mob/living/simple_animal/construct/wraith/regular_hud_updates()
	..()
	if(healths)
		switch(health)
			if(75 to INFINITY)
				healths.icon_state = "wraith_health0"
			if(62 to 74)
				healths.icon_state = "wraith_health1"
			if(50 to 61)
				healths.icon_state = "wraith_health2"
			if(37 to 49)
				healths.icon_state = "wraith_health3"
			if(25 to 36)
				healths.icon_state = "wraith_health4"
			if(12 to 24)
				healths.icon_state = "wraith_health5"
			if(1 to 11)
				healths.icon_state = "wraith_health6"
			else
				healths.icon_state = "wraith_health7"


/mob/living/simple_animal/construct/harvester/regular_hud_updates()
	..()
	if(healths)
		switch(health)
			if(150 to INFINITY)
				healths.icon_state = "harvester_health0"
			if(125 to 149)
				healths.icon_state = "harvester_health1"
			if(100 to 124)
				healths.icon_state = "harvester_health2"
			if(75 to 99)
				healths.icon_state = "harvester_health3"
			if(50 to 74)
				healths.icon_state = "harvester_health4"
			if(25 to 49)
				healths.icon_state = "harvester_health5"
			if(1 to 24)
				healths.icon_state = "harvester_health6"
			else
				healths.icon_state = "harvester_health7"
