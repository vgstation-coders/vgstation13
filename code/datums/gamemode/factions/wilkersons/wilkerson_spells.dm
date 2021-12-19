/spell/wilkerson
	var/datum/faction/wilkersons/ourFamily = null
	var/deepLore = ""	//I accidentally made all the spell descriptions fanfiction deep lore but refuse to get rid of them
	var/loreChance = 25


/spell/wilkerson/proc/announceLore(var/mob/living/carbon/monkey/M)
	if(!ourFamily) //Might as well not have this on every cast
		if(M.mind && istype(M.mind.faction, /datum/faction/wilkersons)
			ourFamily = M.mind.faction
	else
		for(var/datum/role/wilkerson/familyMember in ourFamily.members)
			if(prob(loreChance))
				var/mob/living/fM = familyMember.host.current
				to_chat(fM, "<span class='blob'>[deepLore]</span>")

/spell/reeseEat
	name = "Consume Dewey"
	desc = ""
	deepLore = "The small feed the large. As is nature, as is Wilkerson. That is Malcolm's belief."

/spell/reeseEat/cast(var/list/targets, var/mob/user)
	var/list/consumedDeweys = list()
	for(var/mob/living/simple_animal/hostile/dewey/D in orange(1, src))
		consumedDeweys.Add(D)
		//do something good I guess

/spell/reeseLocker
	name = "Invoke Locker Stuffing"
	desc = "Summon lockers that stuff your enemies into themselves for a few seconds."
	deepLore = "Malcolm always saw reese as the big dumb character. Of course he'd be the school bully in a show like this. Reese had no say in it."
	charge_max = 250

/spell/reeseLocker/cast(var/list/targets, var/mob/user)
	for(var/mob/living/carbon/human/H in view(9, user))
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
	desc = "Extend your arm and pick up a target creature of your choice. It is briefly stunned and unable to fight your grip."
	deepLore = "Reese was a behemoth in Malcolm's eyes. All the other students were mice in comparison."
	amt_knockdown = 10
	amt_stunned = 10	//So they can't just leave
	compatible_mobs = list(/mob/living/carbon/human)
	range = 4

/spell/targeted/reeseGrab/cast(var/list/targets, var/mob/user)
	..()
	for(var/mob/living/carbon/human/target in targets)
		var/obj/item/weapon/holder/animal/grabHold = new /obj/item/weapon/holder/animal(loc, target)
		put_in_active_hand(grabHold)

/spell/reeseKick
	name = "Ureteral Kicking"
	desc = "Kick roughly 25% of the Hal and Lois population across time and space."
	deepLore = "Lois retold the story of Reese's constant kicking in her womb so often that it became part of how he saw his brother."

/spell/reeseKick/cast(var/list/targets, var/mob/user)
	for(var/mob/living/carbon/human/H in player_list)
		if(isrole(/datum/role/wilkerson/hal, H) || isrole(/datum/role/wilkerson/lois, H))
			if(prob(25))
				H.visible_message("<span class='warning'>A fetal leg manifests and kicks [H] before vanishing.</span>")
				var/kickDam = rand(3, 8)	//Simplified version of kick_act, essentially. Done so that Reese being huge doesn't absolutely ruin everyone, and also monkeys apparently can't kick.
				H.adjustBruteLoss(kickDam)
				if(prob(kickDam*10))
					H.Knockdown(kickDam/2)



//MALCOLM/////

/spell/malcolmTimeStop
	name = "Speak with Audience"
	desc = "Stop time in an area around yourself so you can speak with the audience. During this time you can move freely."
	deepLore = "Malcolm began his awakening when he first turned to the camera, the world around him stopped, and he spoke to the audience."
	charge_max = 1200

/spell/malcolmTimeStop/cast(var/list/targets, var/mob/user)
	var/mob/living/carbon/monkey/malcolm/M = user
	M.toggleMalcolmMovement(10)

/spell/malcolmUnfair
	name = "Life is Unfair"
	desc = "Immediately teleport yourself, Dewey, and Reese back to The Middle. This spell can only be cast a finite number of times."
	deepLore = "It's not chance or luck that makes Malcolm the Middle of All Things. That would imply there was any other option. No, there is only Malcolm."
	charge_type = Sp_CHARGES
	charge_max = 3

/spell/malcolmUnfair/cast(var/list/targets, var/mob/user)
	var/mob/living/carbon/monkey/malcolm/M = user
	M.forceMove(get_turf(M.theMiddle))	//Not even teleport blocking is possible. Life truly is unfair.
	for(var/datum/role/wilkerson/reese/R in M.mind.faction.members)
		var/turf/T = get_turf(get_step(M.theMiddle, EAST))
		R.host.forceMove(T)	//See it's theming
	for(var/datum/role/wilkerson/dewey/D in M.mind.faction.members)
		var/turf/T = get_turf(get_step(M.theMiddle, WEST))
		D.host.forceMove(T)	//Because he's in the middle, high art

/spell/malcolmBossOfMeNow
	name = "You're not the Boss of Me Now"
	deepLore = "Malcolm's defiant nature was usually explained as due to his age. Malcolm being exactly as old as the universe makes this seem unlikely."
	charge_max = 30

/spell/malcolmBossOfMeNow/cast(var/list/targets, var/mob/user)


//DEWEY//////

/spell/deweyVomit
	name = "Recall Birth"
	desc = "Cause all humans in the area to vomit. You and your brothers are no longer human, of course."
	deepLore = "Malcolm, being older than Dewey, was just old enough to have partial memories of his birth. Malcolm fills in the gaps and attaches the uncomfortable associations to Dewey."
	charge_max = 600

/spell/deweyVomit/cast(var/list/targets, var/mob/user)
	for(var/mob/living/carbon/human/H in view(9, user))
		H.vomit()
		H.Jitter(30)
		H.stuttering += 30

/spell/deweyPolyp
	name = "Split"
	desc = "Create a mindless copy of yourself."
	deepLore = "Dewey was always around. Malcolm had to rationize it, and so it was as he perceived."
	charge_max = 50

/spell/deweyPolyp/cast(var/list/targets, var/mob/user)
	var/mob/living/carbon/monkey/dewey/D = user
	D.visible_message("<span class='warning'>[D] grows dislodges a chunk of flesh from himself!</span>")
	D.splitDewey()

/spell/deweyEnrage
	name = "Forego Medication"
	desc = "All Dewey's will enter a curious fervor. They will latch on to their victims and jump them back to your side."
	deepLore = "Dewey is exceptionally curious. Hal and Lois tried to nurture this while also leashing it. Dewey will not be contained, he will not be denied."
	charge_max = 1800

/spell/deweyEnrage/cast(var/list/targets, var/mob/user)
	var/mob/living/carbon/monkey/dewey/D = user
	D.deweyEnrageToggle()



/spell/deweyJumpingBean
	name = "Dance of the Mexican Jumping Bean"
	desc = "If you would die within the next 10 seconds an alternate timeline version will replace you, this you is identical in every way, except that he is completely undamaged."
	deepLore = "By referencing an episode that only might have existed Dewey splits the timeline. Ensuring he continues in at least one."
	charge_max = 1800

/spell/deweyJumpingBean/cast(var/list/targets, var/mob/user)
	var/mob/living/carbon/monkey/dewey/D = user
	D.jumpingBeanActive = TRUE
	spawn(10 SECONDS)
		if(D.jumpingBeanActive)
			D.jumpingBeanActive = FALSE
			to_chat(D, "<span class='warning'>The dance of the mexican jumping bean has worn off.</span>")
