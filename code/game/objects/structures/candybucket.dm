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
	if(is_type_in_list(I, allowedTreats) && contents.len < candypacity)
		if(user.drop_item(I, src))
			to_chat(user, "<span class='notice'>You add \the [I] to \the [src].</span>")
			updateBucket()
	if(I.is_wrench(user))
		I.playtoolsound(loc, 50)
		anchored = !anchored

/obj/structure/candybucket/attack_hand(var/mob/living/user)
	if(contents.len)
		trickOrTreat(user)

/obj/structure/candybucket/proc/trickOrTreat(mob/living/user)
	var/theTreat = pick(contents)
	if(istype(theTreat, /obj/item/weapon/reagent_containers/syringe))
		syringeTrick(user, theTreat)
	if(user.put_in_hands(theTreat))
		to_chat(user, "<span class='notice'>You pull [theTreat] from \the [src]!</span>")
		updateBucket()

/obj/structure/candybucket/proc/syringeTrick(mob/living/user, var/obj/item/weapon/reagent_containers/syringe/theTrick)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.species && (H.species.chem_flags & NO_INJECT))
			return
	var/trickVol = 0
	trickVol = rand(0, theTrick.reagents.total_volume)
	theTrick.reagents.trans_to(user, trickVol)
	to_chat(user, "<span class='danger'>You feel a prick!</span>")

/obj/structure/candybucket/proc/updateBucket()
	if(contents.len)
		icon_state = bucketType + "_full"
	else
		icon_state = bucketType + "_empty"

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


/obj/structure/candybucket/candy_jack/spook()
	if(..())
		becomeSpooky()

/obj/structure/candybucket/candy_jack/proc/becomeSpooky()
	var/mob/living/simple_animal/hostile/skeletonjack/ourJack = new /mob/living/simple_animal/hostile/skeletonjack(src.loc)
	src.forceMove(ourJack)
	ourJack.trickOrTreat(contents.len)
	ourJack.ourBucket = src
	spooky = FALSE //So ghosts can't just infinitely revive the thing. One haunting per bucket.
