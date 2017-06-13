/mob/living/simple_animal/hostile/helperslime
	name = "Yuu"
	desc = "A cute slime that picks up slime cores"
	icon_state = "helperslime"
	icon_living = "helperslime"
	icon_dead = "helperslime_dead"
	speak_emote = list("goops")
	health = 90
	maxHealth = 90
	attacktext = "glomps"
	response_help  = "hugs"
	response_disarm = "shoos"
	response_harm   = "slaps"
	can_butcher = 0
	meat_type = null
	wander = 1
	move_to_delay = 10
	environment_smash = 0
	faction = list("neutral","slimesummon")
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	search_objects = 2
	stop_automated_movement_when_pulled = 1
	size = SIZE_BIG
	var/obj/item/weapon/storage/bag/slime/B
	var/obj/item/slime_extract/S
	var/store = 1
	var/harvest = 1
	var/collect = 1

/mob/living/simple_animal/hostile/helperslime/New()
	..()
	B = new/obj/item/weapon/storage/bag/slime(src)
	B.name = "internal core holder"

/mob/living/simple_animal/hostile/helperslime/CanAttack(var/atom/new_target)
	if(stop_automated_movement_when_pulled && pulledby) //So you can pull it to stop it
		return 0
	if(istype(new_target, /obj/item/slime_extract) && B.can_be_inserted(new_target,1) && collect)
		var/obj/item/slime_extract/S = new_target
		if(S.Uses) //Only pick up useful slime extracts, no duds
			if(new_target != target)
				visible_message("<span class = 'notice'>\The [src] lights up as it [pick("slides","glompfs","motions")] towards \the [new_target]</span>")
			return 1
	if(istype(new_target, /obj/machinery/smartfridge/extract) && B.contents.len && store) //Attempt to store when possible
		return 1
	if(istype(new_target, /mob/living/carbon/slime) && harvest)
		var/mob/living/carbon/slime/S = new_target
		if(harvest && S.cores && S.isDead()) //Only butcher slimes if we're told to, and they're useful
			if(new_target != target)
				visible_message("<span class = 'warning'>\The [src] [pick("glares","glorps","leers")] at \the [new_target] hungrily</span>")
			return 1
	return 0


/mob/living/simple_animal/hostile/helperslime/AttackingTarget()
	if(istype(target,/obj/item/slime_extract))
		visible_message("<span class = 'notice'>\The [src] picks up \the [target]</span>")
		B.preattack(get_turf(target),src, 1)
		return
	if(istype(target, /obj/machinery/smartfridge/extract))
		visible_message("<span class = 'notice'>\The [src] stores the cores it has collected in \the [target]</span>")
		target.attackby(B, src)
		return
	if(istype(target, /mob/living/carbon/slime))
		var/mob/living/carbon/slime/S = target
		var/target_loc = S.loc
		var/self_loc = src.loc
		spawn(5 SECONDS)
			if(S.loc == target_loc && self_loc == src.loc) //Not moved
				var/C = S.cores
				for(var/i = 1, i <= C, i++)
					new S.coretype(loc)
					feedback_add_details("slime_core_harvested","[replacetext(S.colour," ","_")]")
				S.gib()
		return


/mob/living/simple_animal/hostile/helperslime/attack_hand(mob/living/carbon/human/M)
	switch(M.a_intent)
		if(I_HELP)
			B.show_to(M)
		if(I_DISARM)
			store = !store
			to_chat(M, "<span class = 'notice'>\The [src] will now [store ? "attempt to store" : "not attempt to store"] collected cores.</span>")
		if(I_HURT)
			harvest = !harvest
			to_chat(M, "<span class = 'notice'>\The [src] will now [harvest ? "harvest" : "not harvest"] dead slimes.</span>")
		if(I_GRAB)
			collect = !collect
			to_chat(M, "<span class = 'notice'>\The [src] will now [collect ? "collect" : "not collect"] stray cores.</span>")
			if(!collect && B.contents.len)
				visible_message("<span class = 'warning'>\The [src] drops its consumed cores!</span>")
				B.empty_contents_to(loc)

	..()


/obj/item/weapon/storage/bag/slime
	name = "slime bag"
	desc = "If you can see this this means something messed up"
	storage_slots = 25
	can_only_hold = list("/obj/item/slime_extract")
