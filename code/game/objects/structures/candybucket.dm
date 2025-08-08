/obj/structure/candybucket
	name = "candy bucket"
	icon = 'icons/obj/candybucket.dmi'
	icon_state = "jackbucket_empty"
	desc = "A thematically appropriate bucket for filling with candy or other goodies."
	density = 1
	anchored = 1
	var/bucketType = "jackbucket"
	var/candypacity = 30
	var/spooky = FALSE
	var/list/allowedTreats = list(
		/obj/item/weapon/reagent_containers/pill,
		/obj/item/weapon/reagent_containers/syringe,
		/obj/item/weapon/reagent_containers/food/snacks
	)

/obj/structure/candybucket/attackby(var/obj/item/I, var/mob/user)
	..()
	if(user.isDead() || user.lying || user.incapacitated())
		return
	if(!user.Adjacent(src))
		return
	if(is_type_in_list(I, allowedTreats) && contents.len < candypacity)
		if(user.drop_item(I, src))
			to_chat(user, "<span class='notice'>You add \the [I] to \the [src].</span>")
			if(istype(I, /obj/item/weapon/reagent_containers/syringe))
				log_admin("[key_name(user)] added a [I] to [src] at [formatJumpTo(get_turf(user))], it contains:")
				if(I.reagents.reagent_list.len)
					for(var/datum/reagent/R in I.reagents.reagent_list)
						log_admin("[R.volume] units of [R.name]")
						if(R in reagents_to_log)
							message_admins("[key_name(user)] has added [I] containing [R] to [formatJumpTo(get_turf(user))]")
				else
					log_admin("nothing")
			update_icon()
	if(I.is_wrench(user))
		I.playtoolsound(loc, 50)
		anchored = !anchored

/obj/structure/candybucket/attack_hand(var/mob/living/user)
	if(user.isDead() || user.lying || user.incapacitated())
		return
	if(contents.len && user.Adjacent(src))
		trickOrTreat(user)

/obj/structure/candybucket/proc/trickOrTreat(mob/living/user)
	var/theTreat = pick(contents)
	if(istype(theTreat, /obj/item/weapon/reagent_containers/syringe))
		syringeTrick(user, theTreat)
	if(user.put_in_hands(theTreat))
		to_chat(user, "<span class='notice'>You pull [theTreat] from \the [src]!</span>")
		update_icon()

/obj/structure/candybucket/proc/syringeTrick(mob/living/user, var/obj/item/weapon/reagent_containers/syringe/theTrick)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.species && (H.species.chem_flags & NO_INJECT))
			return
		if(H.gloves)
			var/obj/item/clothing/gloves/G = H.gloves
			if(G.armor["melee"] >= 5)
				to_chat(user, "<span class='notice'>You feel something push against your glove, but it's unable to pierce it!</span>")
				return
	var/trickVol = 0
	trickVol = rand(0, theTrick.reagents.total_volume)
	theTrick.reagents.trans_to(user, trickVol)
	if(theTrick.reagents.total_volume == 0 && theTrick.mode == SYRINGE_INJECT)
		theTrick.mode = SYRINGE_DRAW
	to_chat(user, "<span class='danger'>You feel a prick!</span>")

/obj/structure/candybucket/update_icon()
	icon_state = "[bucketType]_[contents.len ? "full" : "empty"]"

/obj/structure/candybucket/spook()
	if(!spooky)
		return FALSE
	return TRUE


/obj/structure/candybucket/candy_jack
	name = "jack-o-lantern candy bucket"
	desc = "A spooky bucket for spooky treats or spookier tricks!"
	density = 1
	anchored = 1

/obj/structure/candybucket/candy_jack/New()
	..()
	if(text2num(time2text(world.timeofday, "MM")) == 10)
		spooky = TRUE


/obj/structure/candybucket/candy_jack/spook(mob/dead/observer/ghost)
	if(..())
		becomeSpooky(ghost)
	else
		to_chat(ghost,"<span class='notice'>That jack-o-lantern has spooked its last spook.</span>")

/obj/structure/candybucket/candy_jack/proc/becomeSpooky(mob/dead/observer/ghost)
	var/mob/living/simple_animal/hostile/skeletonjack/ourJack = new /mob/living/simple_animal/hostile/skeletonjack(loc)
	forceMove(ourJack)
	ourJack.candyEnhance(contents.len)
	ourJack.ourBucket = src
	spooky = FALSE //So ghosts can't just infinitely revive the thing. One haunting per bucket.
	if(ghost)
		switch(alert(ghost,"Are you sure you wish to become a spooky bucket-boy? You won't be able to re-enter any previous body.","To spook or not to spook","DOKTOR, TURN OFF MY SPOOK INHIBITORS","I just want to animate it"))
			if("DOKTOR, TURN OFF MY SPOOK INHIBITORS")
				ghost.mind.transfer_to(ourJack)