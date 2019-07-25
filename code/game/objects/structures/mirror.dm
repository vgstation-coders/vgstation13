//wip wip wup
/obj/structure/mirror
	name = "mirror"
	desc = "Mirror mirror on the wall, who's the most robust of them all? Touching the mirror will bring out Nanotrasen's state of the art hair modification system."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mirror"
	density = 0
	anchored = 1
	var/shattered = 0


/obj/structure/mirror/attack_hand(mob/user as mob)
	if(shattered)
		return

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/datum/role/vampire/V = isvampire(H)
		if(isvampire(H))
			if(!(VAMP_MATURE in V.powers))
				to_chat(H, "<span class='notice'>You don't see anything.</span>")
				return
		if(user.hallucinating())
			switch(rand(1,100))
				if(1 to 20)
					to_chat(H, "<span class='sinister'>You look like [pick("a monster","a goliath","a catbeast","a ghost","a chicken","the mailman","a demon")]! Your heart skips a beat.</span>")
					H.Knockdown(4)
					H.Stun(4)
					return
				if(21 to 40)
					to_chat(H, "<span class='sinister'>There's [pick("somebody","a monster","a little girl","a zombie","a ghost","a catbeast","a demon")] standing behind you!</span>")
					H.audible_scream()
					H.dir = turn(H.dir, 180)
					return
				if(41 to 50)
					to_chat(H, "<span class='notice'>You don't see anything.</span>")
					return
		
		var/which = alert("What would you like to change?", "Appearance", "Hair", "Beard", "Undies")

		if((!which) || (!Adjacent(user)))
			return
		
		//copypasted from user prefs, check there for more info

		switch(which)
			if("Beard")
				var/list/species_facial_hair = valid_sprite_accessories(facial_hair_styles_list, H.gender, (H.species.name || null))
				if(species_facial_hair.len)
					var/new_style = input(user, "Select a facial hair style", "Grooming")  as null|anything in species_facial_hair
					if(!Adjacent(user))
						return	//no tele-grooming
					if(new_style)
						H.my_appearance.f_style = new_style
						H.update_hair()

			if("Hair")
				var/list/species_hair = valid_sprite_accessories(hair_styles_list, null, (H.species.name || null)) //gender intentionally left null so speshul snowflakes can cross-hairdress
				if(species_hair.len)
					var/new_style = input(user, "Select a hair style", "Grooming")  as null|anything in species_hair
					if(!Adjacent(user))
						return
					if(new_style)
						H.my_appearance.h_style = new_style
						H.update_hair()
			
			if("Undies")
				var/list/underwear_options
				if(H.gender == MALE)
					underwear_options = underwear_m
				else
					underwear_options = underwear_f

				var/new_underwear = input(user, "Select your underwear:", "Undies")  as null|anything in underwear_options
				if(!Adjacent(user))
					return
				if(new_underwear)
					H.underwear = underwear_options.Find(new_underwear)
					H.regenerate_icons()

/obj/structure/mirror/proc/shatter()
	if(shattered)
		return
	shattered = 1
	icon_state = "mirror_broke"
	playsound(src, "shatter", 70, 1)
	desc = "Oh no, seven years of bad luck!"


/obj/structure/mirror/bullet_act(var/obj/item/projectile/Proj)
	if(prob(Proj.damage * 2))
		if(!shattered)
			shatter()
		else
			playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
	..()


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
