//wip wip wup
/obj/structure/mirror
	name = "mirror"
	desc = "Mirror mirror on the wall, who's the most robust of them all? Touching the mirror will bring out Nanotrasen's state of the art hair modification system."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mirror"
	density = 0
	anchored = 1
	var/shattered = 0

/obj/structure/mirror/proc/can_use(mob/living/user, mob/living/carbon/human/target)
	if(shattered)
		return FALSE
	if(!ishigherbeing(user) || !ishuman(target))
		return FALSE
	if(!isturf(user.loc) || !isturf(target.loc))
		return FALSE
	if(!Adjacent(user) || !Adjacent(target))
		return FALSE
	if(user.incapacitated())
		return FALSE
	return TRUE

/obj/structure/mirror/proc/delay(mob/living/user, mob/living/carbon/human/target, which)
	if(user == target)
		return TRUE
	which = lowertext(which)
	visible_message("<span class='danger'>[user] tries to change [target]'s [which].</span>")
	if(do_after_many(user, list(target, src), 3 SECONDS))
		visible_message("<span class='notice'>[user] changes [target]'s [which].</span>")
		return TRUE
	return FALSE

/obj/structure/mirror/proc/vampire_check(mob/living/user, mob/living/carbon/human/target)
	var/datum/role/vampire/V = isvampire(target)
	if(V && !(/datum/power/vampire/mature in V.current_powers))
		to_chat(user, "<span class='notice'>You don't see anything in \the [src].</span>")
		return FALSE
	return TRUE

/obj/structure/mirror/proc/attempt(mob/living/user, mob/living/carbon/human/target, which)
	if(!can_use(user, target))
		return FALSE
	if(!delay(user, target, which))
		return FALSE
	if(!can_use(user, target))
		return FALSE
	if(!vampire_check(user, target))
		return FALSE
	return TRUE

/obj/structure/mirror/proc/choose(mob/living/user, mob/living/carbon/human/target)
	if(!can_use(user, target))
		return
	if(user.hallucinating())
		switch(rand(1,100))
			if(1 to 20)
				to_chat(user, "<span class='sinister'>You look like [pick("a monster","a goliath","a catbeast","a ghost","a chicken","the mailman","a demon")]! Your heart skips a beat.</span>")
				user.Knockdown(4)
				user.Stun(4)
				return
			if(21 to 40)
				to_chat(user, "<span class='sinister'>There's [pick("somebody","a monster","a little girl","a zombie","a ghost","a catbeast","a demon")] standing behind you!</span>")
				user.audible_scream()
				user.dir = turn(user.dir, 180)
				return
			if(41 to 50)
				to_chat(user, "<span class='notice'>You don't see anything.</span>")
				return

	var/which = alert(user, "What would you like to change?", "Appearance", "Hair", "Beard", "Undies")

	if(!which || !can_use(user, target))
		return

	//copypasted from user prefs, check there for more info

	switch(which)
		if("Beard")
			var/list/species_facial_hair = valid_sprite_accessories(facial_hair_styles_list, target.gender, target.species.name)
			if(species_facial_hair.len)
				var/new_style = input(user, "Select a facial hair style", "Grooming") as null|anything in species_facial_hair
				if(!new_style || !attempt(user, target, which))
					return
				target.my_appearance.f_style = new_style
				target.update_hair()

		if("Hair")
			var/list/species_hair = valid_sprite_accessories(hair_styles_list, null, target.species.name) //gender intentionally left null so speshul snowflakes can cross-hairdress
			if(species_hair.len)
				var/new_style = input(user, "Select a hair style", "Grooming") as null|anything in species_hair
				if(!new_style || !attempt(user, target, which))
					return
				target.my_appearance.h_style = new_style
				target.update_hair()

		if("Undies")
			var/list/underwear_options
			if(target.gender == MALE)
				underwear_options = underwear_m
			else
				underwear_options = underwear_f

			var/new_underwear = input(user, "Select your underwear:", "Undies") as null|anything in underwear_options
			if(!new_underwear || !attempt(user, target, which))
				return
			target.underwear = underwear_options.Find(new_underwear)
			target.regenerate_icons()
	add_fingerprint(user)

/obj/structure/mirror/attack_hand(mob/user)
	choose(user, user)

/obj/structure/mirror/MouseDropTo(mob/living/carbon/human/victim, mob/user)
	choose(user, victim)

/obj/structure/mirror/proc/shatter()
	if(shattered)
		return
	shattered = 1
	icon_state = "[icon_state]_broke"
	playsound(src, "shatter", 70, 1)
	desc = "Oh no, seven years of bad luck!"


/obj/structure/mirror/bullet_act(var/obj/item/projectile/Proj)
	if(prob(Proj.damage * 2))
		if(!shattered)
			shatter()
		else
			playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
	return ..()


/obj/structure/mirror/attackby(obj/item/I as obj, mob/living/user as mob)
	if ((shattered) && (istype(I, /obj/item/stack/sheet/glass/glass)))
		var/obj/item/stack/sheet/glass/glass/stack = I
		if ((stack.amount - 2) < 0)
			to_chat(user, "<span class='warning'>You need more glass to do that.</span>")
		else
			stack.use(2)
			shattered = 0
			icon_state = "mirror"
			playsound(src, 'sound/items/Deconstruct.ogg', 80, 1)

	else if(istype(I, /obj/item/weapon/crowbar))
		to_chat(user, "<span class='notice'>You begin to disassemble \the [src].</span>")
		I.playtoolsound(src, 50)
		if(do_after(user, src, 3 SECONDS))
			if(shattered)
				new /obj/item/weapon/shard(loc)
				new /obj/item/stack/sheet/metal(loc, 1)
			else
				new /obj/item/stack/sheet/metal(loc, 1)
				new /obj/item/stack/sheet/glass/glass(loc, 2)
			qdel(src)
		return

	else
		user.do_attack_animation(src, I)
		if(shattered)
			playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
			return
		else if(prob(I.force * 2))
			visible_message("<span class='warning'>[user] smashes [src] with [I]!</span>")
			shatter()
		else
			visible_message("<span class='warning'>[user] hits [src] with [I]!</span>")
			playsound(src, 'sound/effects/Glasshit.ogg', 70, 1)


/obj/structure/mirror/attack_alien(mob/living/user as mob)
	if(islarva(user))
		return
	user.do_attack_animation(src, user)
	if(shattered)
		playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
		return
	user.visible_message("<span class='danger'>[user] smashes [src]!</span>")
	shatter()


/obj/structure/mirror/attack_animal(mob/living/user as mob)
	if(!isanimal(user))
		return
	var/mob/living/simple_animal/M = user
	if(M.melee_damage_upper <= 0)
		return
	user.do_attack_animation(src, user)
	if(shattered)
		playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
		return
	user.visible_message("<span class='danger'>[user] smashes [src]!</span>")
	shatter()


/obj/structure/mirror/attack_slime(mob/living/user as mob)
	if(!isslimeadult(user))
		return
	user.do_attack_animation(src, user)
	if(shattered)
		playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
		return
	user.visible_message("<span class='danger'>[user] smashes [src]!</span>")
	shatter()

/obj/structure/mirror/kick_act()
	..()
	shatter()

/obj/structure/mirror/magic
	name = "magic mirror"
	desc = "Mirror mirror on the wall, who's the most powerful of them all? It hums with arcane power."
	icon_state = "mirrormagic"

/obj/structure/mirror/magic/attack_hand(mob/M)
	if(!shattered)
		var/which = input("Change what?", "Magic Mirror") as null|anything in list("Name","Gender","Appearance")
		var/mob/living/carbon/human/targ = M

		switch(which)

			if("Name")
				var/stagename = copytext(sanitize(input(targ, "Pick a name","Name") as null|text), 1, MAX_NAME_LEN)
				targ.real_name = stagename
				targ.name = stagename

			if("Gender")
				targ.pick_gender(M)

			if("Appearance")
				targ.pick_appearance(M)

		to_chat(targ, "<span class='notice'>You gaze into the [src].</span>")
