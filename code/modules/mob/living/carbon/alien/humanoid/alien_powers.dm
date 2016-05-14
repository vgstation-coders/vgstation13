/*NOTES:
These are general powers. Specific powers are stored under the appropriate alien creature type.
*/

/*Alien spit now works like a taser shot. It won't home in on the target but will act the same once it does hit.
Doesn't work on other aliens/AI.*/


/mob/living/carbon/alien/proc/powerc(X, Y)//Y is optional, checks for weed planting. X can be null.
	if(stat)
		to_chat(src, "<span class='alien'>You must be conscious to do this.</span>")
		return 0
	else if(X && getPlasma() < X)
		to_chat(src, "<span class='alien'>Not enough plasma stored.</span>")
		return 0
	else if(Y && (!isturf(src.loc) || istype(src.loc, /turf/space)))
		to_chat(src, "<span class='alien'>Bad place for a garden!</span>")
		return 0
	else	return 1

/mob/living/carbon/alien/humanoid/verb/plant()
	set name = "Plant Weeds (50)"
	set desc = "Plants some alien weeds"
	set category = "Alien"

	if(powerc(50,1))
		adjustToxLoss(-50)
		visible_message("<span class='alien'>[src] has planted some alien weeds!</span>")
		new /obj/effect/alien/weeds/node(loc)
	return

/*
/mob/living/carbon/alien/humanoid/verb/ActivateHuggers()
	set name = "Activate facehuggers (5)"
	set desc = "Makes all nearby facehuggers activate"
	set category = "Alien"

	if(powerc(5))
		adjustToxLoss(-5)
		for(var/obj/item/clothing/mask/facehugger/F in range(8,src))
			F.GoActive()
		emote("roar")
	return
*/
/mob/living/carbon/alien/humanoid/verb/whisp(mob/M as mob in oview())
	set name = "Whisper (10)"
	set desc = "Whisper to someone"
	set category = "Alien"

	if(powerc(10))
		adjustToxLoss(-10)
		var/msg = sanitize(input("Message:", "Alien Whisper") as text|null)
		if(msg)
			var/turf/T = get_turf(src)
			log_say("[key_name(src)] (@[T.x],[T.y],[T.z]) Alien Whisper: [msg]")
			to_chat(M, "<span class='alien'>You hear a strange, alien voice in your head... <em>[msg]</span></em>")
			to_chat(src, "<span class='alien'>You said: [msg] to [M]</span>")
	return

/mob/living/carbon/alien/humanoid/verb/transfer_plasma(mob/living/carbon/alien/M as mob in oview())
	set name = "Transfer Plasma"
	set desc = "Transfer Plasma to another alien"
	set category = "Alien"

	if(isalien(M))
		var/amount = input("Amount:", "Transfer Plasma to [M]") as num
		if (amount)
			amount = abs(round(amount))
			if(powerc(amount))
				if (get_dist(src,M) <= 1)
					M.adjustToxLoss(amount)
					adjustToxLoss(-amount)
					to_chat(M, "<span class='alien'>\The [src] has transfered [amount] plasma to you.</span>")
					to_chat(src, "<span class='alien'>You have trasferred [amount] plasma to [M]</span>")
				else
					to_chat(src, "<span class='alien'>You need to be closer.</span>")
	return


/mob/living/carbon/alien/humanoid/proc/corrosive_acid(O as obj|turf in oview(1)) //If they right click to corrode, an error will flash if its an invalid target./N
	set name = "Corrossive Acid (200)"
	set desc = "Drench an object in acid, destroying it over time."
	set category = "Alien"

	if(powerc(200))
		if(O in oview(1))
			// OBJ CHECK
			if(isobj(O))
				var/obj/I = O
				if(I.unacidable)	//So the aliens don't destroy energy fields/singularies/other aliens/etc with their acid.
					to_chat(src, "<span class='alien'>You cannot dissolve this object.</span>")
					return
			// TURF CHECK
			else if(istype(O, /turf/simulated))
				var/turf/T = O
				// R WALL
				if(istype(T, /turf/simulated/wall/r_wall))
					to_chat(src, "<span class='alien'>You cannot dissolve this object.</span>")
					return
				// R FLOOR
				if(istype(T, /turf/simulated/floor/engine))
					to_chat(src, "<span class='alien'>You cannot dissolve this object.</span>")
					return
			else // Not a type we can acid.
				return

			adjustToxLoss(-200)
			new /obj/effect/alien/acid(get_turf(O), O)
			visible_message("<span class='alien'>\The [src] vomits globs of vile stuff all over [O]. It begins to sizzle and melt under the bubbling mess of acid!</span>")
		else
			to_chat(src, "<span class='alien'>Target is too far away.</span>")
	return


/mob/living/carbon/alien/humanoid/proc/neurotoxin(mob/target as mob in oview())
	set name = "Spit Neurotoxin (50)"
	set desc = "Spits neurotoxin at someone, paralyzing them for a short time if they are not wearing protective gear."
	set category = "Alien"
	if(neurotoxin_cooldown)
		to_chat(src, "<span class='alien'>You aren't ready to spit more neurotoxin yet.")
		return
	if(powerc(50))
		if(isalien(target))
			to_chat(src, "<span class='alien'>Your allies are not valid targets.</span>")
			return
		adjustToxLoss(-50)
		playsound(get_turf(src), 'sound/weapons/pierce.ogg', 30, 1)
		visible_message("<span class='alien'>\The [src] spits neurotoxin at [target] !</span>", "<span class='alien'>You spit neurotoxin at [target] !</span>")
		//I'm not motivated enough to revise this. Prjectile code in general needs update.
		var/turf/T = get_turf(src)
		var/turf/U = get_turf(target)

		if(!U || !T)
			return
		while(U && !istype(U,/turf))
			U = U.loc
		if(!istype(T, /turf))
			return
		if (U == T)
			usr.bullet_act(new /obj/item/projectile/energy/neurotoxin(usr.loc), get_organ_target())
			return
		if(!istype(U, /turf))
			return

		var/obj/item/projectile/energy/neurotoxin/A = new /obj/item/projectile/energy/neurotoxin(usr.loc)
		A.original = target
		A.target = U
		A.current = T
		A.starting = T
		A.yo = U.y - T.y
		A.xo = U.x - T.x
		spawn()
			A.OnFired()
			A.process()
		neurotoxin_cooldown = 1
		spawn(50)
			neurotoxin_cooldown = 0

	return

/mob/living/carbon/alien/humanoid/proc/resin() // -- TLE
	set name = "Secrete Resin (75)"
	set desc = "Secrete tough malleable resin."
	set category = "Alien"

	if(powerc(75))
		var/choice = input("Choose what you wish to shape.","Resin building") as null|anything in list("resin door","resin wall","resin membrane","resin nest") //would do it through typesof but then the player choice would have the type path and we don't want the internal workings to be exposed ICly - Urist
		if(!choice || !powerc(75))	return
		adjustToxLoss(-75)
		visible_message("<span class='alien'>\The [src] vomits up a thick purple substance and shapes it into some form of resin structure!</span>", "<span class='alien'>You shape a [choice]</span>")
		switch(choice)
			if("resin door")
				new /obj/machinery/door/mineral/resin(loc)
			if("resin wall")
				new /obj/effect/alien/resin/wall(loc)
			if("resin membrane")
				new /obj/effect/alien/resin/membrane(loc)
			if("resin nest")
				new /obj/structure/bed/nest(loc)
	return

/mob/living/carbon/alien/humanoid/verb/regurgitate()
	set name = "Regurgitate"
	set desc = "Empties the contents of your stomach"
	set category = "Alien"

	if(powerc())
		drop_stomach_contents()
		src.visible_message("<span class='alien'>\The [src] hurls out the contents of their stomach!</span>")
	return


/mob/living/carbon/alien/humanoid/AltClickOn(var/atom/A)
	if(ismob(A))
		neurotoxin(A)
		return
	. = ..()

/mob/living/carbon/alien/humanoid/CtrlClickOn(var/atom/A)
	if(isalien(A))
		transfer_plasma(A)
		return
	. = ..()
