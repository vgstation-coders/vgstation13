//REESE////

/spell/reeseEat
	name = "Consume Dewey"
	desc = "The small feed the large. As is nature, as is Wilkerson. That is Malcolm's belief."

/spell/reeseEat/cast(var/list/targets, var/mob/user)
	var/list/consumedDeweys = list()
	for(var/mob/living/simple_animal/hostile/dewey/D in orange(1, src))
		consumedDeweys.Add(D)
		//do something good I guess

/spell/reeseLocker
	name = "Invoke Locker Stuffing"
	desc = "Malcolm always saw reese as the big dumb character. Of course he'd be the school bully in a show like this. Reese had no say in it."
	charge_max = 250

/spell/reeseLocker/cast(var/list/targets, var/mob/user)
	for(var/mob/living/carbon/human/H in view)
		var/obj/structure/closet/C = new /obj/structure/closet(get_turf(H))
		C.open()
		C.close()
		C.welded = TRUE
		var/lockTime = rand(1, 3)
		spawn(lockTime SECONDS)
			C.welded = FALSE
			C.open()
			C.ex_act(1)	//Used instead of directly qdel() as a safety for if a mob is somehow still inside

/spell/targeted/reeseGrab
	name = "Manhandle"
	desc = "Reese was always a behemoth in Malcolm's eyes. All the other students were mice in comparison."
	amt_knockdown = 10
	amt_stunned = 10	//So they can't just leave
	compatible_mobs = list(/mob/living/carbon/human)
	range = 4

/spell/targeted/reeseGrab/cast(var/list/targets, var/mob/user)
	..()
	for(var/mob/living/carbon/human/target in targets)
		var/obj/item/weapon/holder/animal/grabHold = new /obj/item/weapon/holder/animal(loc, target)
		put_in_active_hand(grabHold)


/spell/malcolmDark
	name = "Unbulb"
	desc = "Hal fixed what he could, he replaced all the bulbs in the house. Malcolm continued to act up."

/spell/malcolmDark/choose_targets(var/mob/user = usr)
	return list(user)

/spell/malcolmDark/cast(var/list/targets, var/mob/user)
	var/mD = new /obj/effect/malcolmDark(user.loc)
	mD.set_light(2,-20)

/obj/effect/malcolmDark
	name = "Malcolm Unbulb"
	desc = "Hal fixed what he could, he replaced all the bulbs in the house. Malcolm continued to act up."
