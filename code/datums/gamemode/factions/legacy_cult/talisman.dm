/obj/item/weapon/paper/talisman
	icon_state = "paper_talisman"
	var/imbue = null
	var/uses = 1
	var/nullblock = 0

/obj/item/weapon/paper/talisman/update_icon()
	var/suffix = ""
	if(imbue)
		suffix = imbue
		if(imbue in list("ire", "ego", "nahlizet", "certum", "veri", "jatkaa", "balaq", "mgar", "karazet", "geeri"))
			suffix = "travel" // if the imbue is one of the words, it means it's a travel rune. a single "travel" sprite is used, instead of one per-word.
	if(suffix)
		icon_state = "[initial(icon_state)]_[suffix]"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/weapon/paper/talisman/examine(mob/user)
	..()
	if(islegacycultist(user) || isobserver(user))
		switch(imbue)
			if("newtome")
				to_chat(user, "This talisman has been imbued with the power of spawning a new Arcane Tome.")
			if("armor")
				to_chat(user, "This talisman has been imbued with the power of clothing yourself in cult fighting gear.")
			if("emp")
				to_chat(user, "This talisman has been imbued with the power of disabling technology in a small radius around you.")
			if("conceal")
				to_chat(user, "This talisman has been imbued with the power of concealing nearby runes.")
			if("revealrunes")
				to_chat(user, "This talisman has been imbued with the power of revealing hidden nearby runes.")
			if("ire", "ego", "nahlizet", "certum", "veri", "jatkaa", "balaq", "mgar", "karazet", "geeri")
				to_chat(user, "This talisman has been imbued with the power of taking you to someplace else. You can read <i>[imbue]</i> on it.")
			if("communicate")
				to_chat(user, "This talisman has been imbued with the power of communicating your whispers to your allies.")
			if("deafen")
				to_chat(user, "This talisman has been imbued with the power of deafening visible enemies.")
			if("blind")
				to_chat(user, "This talisman has been imbued with the power of blinding visible enemies.")
			if("runestun")
				to_chat(user, "This talisman has been imbued with the power of paralyzing the beings you touch with it. The effect works on silicons as well, but humans will also be muted for a short time.")
			if("supply")
				to_chat(user, "This talisman has been imbued with the power of providing you and your allies with some supplies to start your cult.")
			else
				to_chat(user, "This talisman.....has no particular power. Is this some kind of joke?")
	else
		to_chat(user, "Something about the blood stains on this paper fills you with uneasiness.")

/obj/item/weapon/paper/talisman/proc/findNullRod(var/atom/target)
	if(isholyprotection(target))
		var/turf/T = get_turf(target)
		nullblock = 1
		T.turf_animation('icons/effects/96x96.dmi',"nullding",-WORLD_ICON_SIZE,-WORLD_ICON_SIZE,MOB_LAYER+1,'sound/instruments/piano/Ab7.ogg',anim_plane = EFFECTS_PLANE)
		return 1
	else if(target.contents)
		for(var/atom/A in target.contents)
			findNullRod(A)
	return 0

/obj/item/weapon/paper/talisman/New()
	..()
	pixel_x=0
	pixel_y=0


/obj/item/weapon/paper/talisman/attack_self(mob/living/user as mob)
	if(islegacycultist(user))
		var/use_charge = 1
		var/obj/effect/rune_legacy/R = new
		R.my_cult = find_active_faction_by_type(/datum/faction/cult/narsie)
		switch(imbue)
			if("newtome")
				R.tomesummon(user, TRUE) // We whisper this one
			if("armor") //Fuck off with your shit /tg/. This isn't Edgy Rev+
				R.armor(user)
			if("emp")
				R.emp(user.loc, 3)
			if("conceal")
				R.obscure(2)
			if("revealrunes")
				R.revealrunes(src)
			if("ire", "ego", "nahlizet", "certum", "veri", "jatkaa", "balaq", "mgar", "karazet", "geeri")
				var/turf/T1 = get_turf(user)
				R.teleport(imbue)
				var/turf/T2 = get_turf(user)
				if(T1!=T2)
					T1.turf_animation('icons/effects/effects.dmi',"rune_teleport")
			if("communicate")
				use_charge = R.communicate(TRUE)
			if("deafen")
				deafen()
				qdel(src)
			if("blind")
				blind()
				qdel(src)
			if("runestun")
				to_chat(user, "<span class='warning'>To use this talisman, attack your target directly.</span>")
				return
			if("supply")
				use_charge = 0
				supply()
		qdel(R)
		user.take_organ_damage(5, 0)
		if(use_charge)
			uses--
		if(!src.uses)
			qdel(src)
		return
	else
		to_chat(user, "You see strange symbols on the paper. Are they supposed to mean something?")
		return


/obj/item/weapon/paper/talisman/attack(mob/living/carbon/T as mob, mob/living/user as mob)
	if(islegacycultist(user))
		if(imbue == "runestun")
			user.take_organ_damage(5, 0)
			runestun(T)
			qdel(src)
		else
			..()   ///If its some other talisman, use the generic attack code, is this supposed to work this way?
	else
		..()

/obj/item/weapon/paper/talisman/attack_animal(var/mob/living/simple_animal/M as mob)
	if(istype(M, /mob/living/simple_animal/construct/harvester))
		attack_self(M)

/obj/item/weapon/paper/talisman/proc/supply(var/key)
	if (!src.uses)
		qdel(src)
		return

	var/dat = {"<B>There are [src.uses] bloody runes on the parchment.</B>
<BR>Please choose the chant to be imbued into the fabric of reality.<BR>
<HR>
<A href='?src=\ref[src];rune=newtome'>N'ath reth sh'yro eth d'raggathnor!</A> - Allows you to summon a new arcane tome.<BR>
<A href='?src=\ref[src];rune=teleport'>Sas'so c'arta forbici!</A> - Allows you to move to a rune with the same last word.<BR>
<A href='?src=\ref[src];rune=emp'>Ta'gh fara'qha fel d'amar det!</A> - Allows you to destroy technology in a short range.<BR>
<A href='?src=\ref[src];rune=conceal'>Kla'atu barada nikt'o!</A> - Allows you to conceal the runes you placed on the floor.<BR>
<A href='?src=\ref[src];rune=communicate'>O bidai nabora se'sma!</A> - Allows you to coordinate with others of your cult.<BR>
<A href='?src=\ref[src];rune=runestun'>Fuu ma'jin</A> - Allows you to stun a person by attacking them with the talisman.<BR>
<A href='?src=\ref[src];rune=soulstone'>Kal om neth</A> - Summons a soul stone<BR>
<A href='?src=\ref[src];rune=construct'>Da A'ig Osk</A> - Summons a construct shell for use with captured souls. It is too large to carry on your person.<BR>"}
//<A href='?src=\ref[src];rune=armor'>Sa tatha najin</A> - Allows you to summon armored robes and an unholy blade<BR> //Kept for reference
	usr << browse(dat, "window=id_com;size=350x200")
	return


/obj/item/weapon/paper/talisman/Topic(href, href_list)
	if(!src)
		return
	if (usr.stat || usr.restrained() || !in_range(src, usr))
		return

	if (href_list["rune"])
		switch(href_list["rune"])
			if("newtome")
				var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(get_turf(usr))
				T.imbue = "newtome"
			if("teleport")
				var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(get_turf(usr))
				var/list/words = list("ire" = "ire", "ego" = "ego", "nahlizet" = "nahlizet", "certum" = "certum", "veri" = "veri", "jatkaa" = "jatkaa", "balaq" = "balaq", "mgar" = "mgar", "karazet" = "karazet", "geeri" = "geeri")
				T.imbue = input("Write your teleport destination rune:", "Rune Scribing") in words
			if("emp")
				var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(get_turf(usr))
				T.imbue = "emp"
			if("conceal")
				var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(get_turf(usr))
				T.imbue = "conceal"
			if("communicate")
				var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman/communicate(get_turf(usr))
				T.imbue = "communicate"
			if("runestun")
				var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(get_turf(usr))
				T.imbue = "runestun"
			//if("armor")
				//var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(get_turf(usr))
				//T.imbue = "armor"
			if("soulstone")
				new /obj/item/soulstone(get_turf(usr))
			if("construct")
				new /obj/structure/constructshell/cult(get_turf(usr))
		src.uses--
		supply()
	return


/obj/item/weapon/paper/talisman/supply
	imbue = "supply"
	uses = 5

/obj/item/weapon/paper/talisman/communicate
	imbue = "communicate"
	uses = 5

//imbued talismans invocation for a few runes, since calling the proc causes a runtime error due to src = null
/obj/item/weapon/paper/talisman/proc/runestun(var/mob/living/T as mob)//When invoked as talisman, stun and mute the target mob.
	usr.say("Dream sign ''Evil sealing talisman'[pick("'","`")]!")
	nullblock = 0
	for(var/turf/TU in range(T,1))
		findNullRod(TU)
	if(nullblock)
		usr.visible_message("<span class='danger'>[usr] invokes a talisman at [T], but they are unaffected!</span>")
	else
		usr.visible_message("<span class='danger'>[usr] invokes a talisman at [T]</span>")

		if(issilicon(T))
			T.Knockdown(15)

		else if(iscarbon(T))
			var/mob/living/carbon/C = T
			C.flash_eyes(visual = 1)
			if (!(M_HULK in C.mutations))
				C.silent += 15
			C.Knockdown(25)
			C.Stun(25)
	return

/obj/item/weapon/paper/talisman/proc/blind()
	var/affected = 0
	for(var/mob/living/carbon/C in view(3,usr))
		if (islegacycultist(C))
			continue
		nullblock = 0
		for(var/turf/T in range(C,1))
			findNullRod(T)
		if(nullblock)
			continue
		C.eye_blurry += 30
		C.eye_blind += 10
		//talismans is weaker.
		affected++
		to_chat(C, "<span class='warning'>You feel a sharp pain in your eyes, and the world disappears into darkness..</span>")
	if(affected)
		usr.whisper("Sti[pick("'","`")] kaliesin!")
		to_chat(usr, "<span class='warning'>Your talisman turns into gray dust, blinding those who not follow the Nar-Sie.</span>")


/obj/item/weapon/paper/talisman/proc/deafen()
	var/affected = 0
	for(var/mob/living/carbon/C in range(7,usr))
		if (islegacycultist(C))
			continue
		nullblock = 0
		for(var/turf/T in range(C,1))
			findNullRod(T)
		if(nullblock)
			continue
		C.ear_deaf += 30
		//talismans is weaker.
		C.show_message("<span class='notice'>The world around you suddenly becomes quiet.</span>")
		affected++
	if(affected)
		usr.whisper("Sti[pick("'","`")] kaliedir!")
		to_chat(usr, "<span class='warning'>Your talisman turns into gray dust, deafening everyone around.</span>")
		for (var/mob/V in orange(1,src))
			if(!(islegacycultist(V)))
				V.show_message("<span class='warning'>Dust flows from [usr]'s hands for a moment, and the world suddenly becomes quiet..</span>")

/proc/talisman_charges(var/imbue)
	switch(imbue)
		if("communicate")
			return 5
		if("supply")
			return 5
		else // Tele talisman's imbue is the final word.
			return 1