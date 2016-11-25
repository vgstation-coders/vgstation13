// Tiny green chickens from outer space

/mob/living/carbon/monkey/vox
	name = "chicken"
	voice_name = "chicken"
	icon_state = "chickengreen"
	speak_emote = list("clucks","croons")
	attack_text = "pecks"
	species_type = /mob/living/carbon/monkey/vox
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/rawchicken
	canWearClothes = 0
	canWearGlasses = 0
	safe_oxygen_min = 0
	var/eggsleft
	var/eggcost = 250
	languagetoadd = LANGUAGE_VOX

/mob/living/carbon/monkey/vox/attack_hand(mob/living/carbon/human/M as mob)


	if((M.a_intent == I_HELP) && !(locked_to) && (isturf(src.loc)) && (M.get_active_hand() == null)) //Unless their location isn't a turf!
		scoop_up(M)

	..()


/mob/living/carbon/monkey/vox/New()

	..()
	setGender(NEUTER)
	dna.mutantrace = "vox"
	greaterform = "Vox"
	alien = 1
	eggsleft = rand(1,6)
	set_hand_amount(1)

/mob/living/carbon/monkey/vox/Life()
	..()
	if(prob(5) && eggsleft > 4)
		lay_egg()

/mob/living/carbon/monkey/vox/say(var/message)
	if (prob(25))
		message += pick("  sqrk", "  bok bok", ",bwak", ",cluck!")

	return ..(message)

/mob/living/carbon/monkey/vox/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/grown/wheat)) //feedin' dem chickens
		if(!stat && eggsleft < 8)
			if(!user.drop_item(O))
				to_chat(user, "<span class='notice'>You can't let go of \the [O]!</span>")
				return

			user.visible_message("<span class='notice'>[user] feeds [O] to [name]! It clucks happily.</span>","<span class='notice'>You feed [O] to [name]! It clucks happily.</span>")
			qdel(O)
			eggsleft += rand(1, 4)
//			to_chat(world, eggsleft)
		else
			to_chat(user, "<span class='notice'>[name] doesn't seem hungry!</span>")
	else
		..()

/mob/living/carbon/monkey/vox/put_in_hand_check(var/obj/item/W) //Silly chicken, you don't have hands
	if(src.reagents.has_reagent(GRAVY) || src.reagents.has_reagent(METHYLIN))
		return 1
	else
		return 0

//Cant believe I'm doing this
/mob/living/carbon/monkey/vox/proc/lay_egg()
	if(!stat && nutrition > 250 && eggsleft > 0)
		visible_message("[src] [pick("lays an egg.","squats down and croons.","begins making a huge racket.","begins clucking raucously.")]")
		nutrition -= eggcost
		eggsleft--
		var/obj/item/weapon/reagent_containers/food/snacks/egg/vox/E = new(get_turf(src))
		E.pixel_x = rand(-6,6) * PIXEL_MULTIPLIER
		E.pixel_y = rand(-6,6) * PIXEL_MULTIPLIER
		if(prob(25))
			processing_objects.Add(E)

/mob/living/carbon/monkey/vox/verb/layegg()
	set name = "Lay egg"
	set category = "IC"
	lay_egg()
	return

/mob/living/carbon/monkey/vox/proc/eggstats()
	stat(null, "Nutrition level - [nutrition]")
	stat(null, "Eggs left - [eggsleft]")

/mob/living/carbon/monkey/vox/Stat()
	..()
	if(statpanel("Status"))
		eggstats()