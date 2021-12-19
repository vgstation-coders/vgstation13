/mob/living/simple_animal/hostile/fishing/star_jelly
	name = "star jelly"
	desc = "A distant ancestor of Earth jellyfish. Their adaptation to the void of space is far from the strangest thing about them."
	icon_state = "jellyfish"
	icon_living = "jellyfish"
	icon_dead = "jellyfish_dead"
	melee_damage_type = BURN
	attacktext = "zaps"
	can_butcher = 0
	size = SIZE_SMALL
	canRegenerate = 1
	minRegenTime = 100
	maxRegenTime = 1200
	minCatchSize = 10
	maxCatchSize = 20
	search_objects = 1
	wanted_objects = list(/obj/item/slime_extract)
	var/mob/living/carbon/slime/lastSlimeEaten = null
	var/eatenCores = 0
	var/eatCooldown = 150 // 15 seconds
	var/lastEat = 0
	var/zapCooldown = 600 //1 minute
	var/lastZap = 0


/datum/locking_category/star_jelly

/mob/living/simple_animal/hostile/fishing/star_jelly/delayedRegen()
	if(..())
		visible_message("The [src]'s old body releases a polyp which quickly develops into a new [src]!")
		new /obj/item/clothing/head/helmet/space/star_jelly(loc)
		if(eatenCores)
			convertSlimeCore()
		catchSize -= rand(5,10)
		if(catchSize < 10)
			canRegenerate = 0

/mob/living/simple_animal/hostile/fishing/star_jelly/proc/jellyChargeCheck()
	if(world.time - lastZap >= zapCooldown)
		lastZap = world.time
		return TRUE

/mob/living/simple_animal/hostile/fishing/star_jelly/CanAttack(var/atom/the_target)	//to-do: Convert this to found() to override check
	if(search_objects)	//Just re-using the variable to make sure the jelly hasn't been attacked. Attacks slimes regardless.
		if(isslime(target) || isslimeperson(target))	//Slimes ignore invisible check something something electric waves
			return TRUE
	..()

/mob/living/simple_animal/hostile/fishing/star_jelly/UnarmedAttack(var/atom/A)
	if(isslime(A) || isslimeperson(A))
		jellyLatchOn(A)
		return
	if(ishuman(A))
		if(jellyChargeCheck())
			A.electrocute_act(catchSize, src, incapacitation_duration = catchSize)
	..()

/mob/living/simple_animal/hostile/fishing/star_jelly/proc/jellyLatchOn(var/mob/living/S)
	lock_atom(src, S)
	if(isslime(S))
		jellyFeed(S)
	if(isslimeperson(S))
		jellyFeedSPerson(S)

/mob/living/simple_animal/hostile/fishing/star_jelly/proc/jellyFeed(mob/living/S)
	var/mob/living/carbon/slime/SF = S
	visible_message("<span class='warning'>\the [src] latches onto the [SF] and begins draining it!</span>")
	var/timeToEat = round(SF.health/catchSize, 1)	//bigger jelly eats faster
	for(var/i=1, i >= timeToEat, i++)
		if(loc != SF.loc || stat)
			unlock_atom(src)
			return
		SF.Stun(1)
		if(SF.powerlevel)
			SF.powerlevel = 0
			lastZap = 0
		SF.health = min(0, SF.health - catchSize)
		playsound(src, )
		sleep(10)
		playsound(src, 'sound/effects/sparks3.off', 15, 1)
	lastSlimeEaten = SF
	if(!SF.stat)
		SF.death()
	catchSize++

/mob/living/simple_animal/hostile/fishing/star_jelly/proc/jellyFeedSPerson(mob/living/S)
	var/mob/living/carbon/human/SH = S	//to-do: Just replace this with what gourmongers do
	visible_message("<span class='warning'>\the [src] latches onto [SH] and starts feeding on them!</span>")
	var/targetL = pick(LIMB_LEFT_ARM, LIMB_RIGHT_ARM, LIMB_LEFT_LEG, LIMB_RIGHT_LEG) //Avoid insta-kills, that's just no fun
	if(!SH.has_organ(targetL))
		targetL = LIMB_HEAD	//On the other hand, don't start fights without arms
	for(var/i=1 to 5)
		sleep(10)
		if(!SH.has_organ(targetL))
			break
		SH.apply_damage(catchSize, CLONE, targetL)
	if(SH.has_organ(targetL))
		targetL.droplimb(1)
	unlock_atom(src)
	visible_message("<span class='warning'>\the [src] seems confused by its prey's form and decides not to finish.</span>")

/mob/living/simple_animal/hostile/fishing/star_jelly/AttackingTarget()
	if(istype(target, /obj/item/slime_extract))
		var/jellyGut = catchSize/5
		if(eatenCores >= jellyGut || world.time - lastEat < eatCooldown)
			LoseTarget()	//to-do: Maybe replace this with a custom version of canattack/found(). See how this acts in game first.
			return
		lastEat = world.time
		eatenCores++
		qdel(target)
		canmove = 0
		visible_message("<span class='warning'>\the [src] drags the [target] into its beak.</span>")
		spawn(10)
			canmove = 1
	else
		..()

/mob/living/simple_animal/hostile/fishing/star_jelly/proc/convertSlimeCore()
	for(var/i=0, i < eatenCores, i++)
		var/sCore = lastSlimeEaten.coretype
		new sCore(loc)
	visible_message("<span class='notice'>\the [src] spews out its consumed extracts, having converted them by the DNA of the last slime it consumed.</span>")

/obj/item/weapon/holder/animal/star_jelly
	name = "star jelly"
	desc = "Don't try to wear it"
	item_state = "star_jelly"
	slot_flags = SLOT_HEAD
	var/mob/living/carbon/human/elecMan = null
	var/mob/living/simple_animal/hostile/fishing/star_jelly/SJ = null

/obj/item/weapon/holder/animal/star_jelly/New()
	..()
	SJ = stored_mob

/obj/item/weapon/holder/animal/star_jelly/equipped(mob/living/carbon/human/H, HEAD_SLOT)
	..()
	if(H.flags & ELECTRIC_HEAL)
		elecMan = H
		elecMan.Stutter(SJ.catchSize)
		elecMan.Jittery(SJ.catchSize)
		elecMan.movement_speed_modifier *= 1.2
		to_chat(elecMan, "<span class='danger'>You feel incredible!</span>" )
	else
		var/sizeZap = SJ.catchSize/2
		H.Stun(sizeZap)
		H.Knockdown(sizeZap)
		H.Stutter(sizeZap)
		H.Jitter(sizeZap)
		H.adjustBurnLoss(SJ.catchSize)
		visible_message("<span class='danger'>[H] has been electrocuted by their [src] hat!</span>")

/obj/item/weapon/holder/animal/star_jelly/unequipped(mob/living/carbon/human/H, var/from_slot = null)
	..()
	if(H == elecMan)
		elecMan.movement_speed_modifier /= 1.2
		to_chat(elecMan, "You feel normal again.")
		elecMan = null

/obj/item/weapon/holder/animal/star_jelly/afterattack(var/atom/target, var/mob/user)
	..()
		if(!SJ.jellyChargeCheck())
			to_chat(user, "<span class='notice'>The [src] hasn't built up enough charge.</span>")
			return
		var/mob/living/simple_animal/hostile/fishing/SJ = stored_mob
		playsound(target, 'sound/weapons/electriczap.ogg, 50, 1')
		if(istype(target, /obj/item/weapon/cell))
			var/obj/item/weapon/cell/C = target
			C.charge = min(C.maxCharge, C.charge + (SJ.catchSize*SJ.catchSize))
			to_chat(user,"<span class='notice'>The [src] releases built up charge into the [C]!</span>")
		if(ishuman(target))
			electrocute_act(catchSize, src)

/obj/item/clothing/head/helmet/space/star_jelly
	name = "star jelly husk"
	desc = "What remains of a star jelly after it revived itself through unknown biological means. The flesh, if you can call it that, has hardened considerably yet it remains mostly transparent."
	icon_state = "helm_jelly"
	item_state = "star_jelly"
	slowdown = NO_SLOWDOWN
	species_restricted = list("exclude",VOX_SHAPED) //beaks
	armor = list(melee = 10, bullet = 5, laser = 45, energy = 15, bomb = 5, bio = 50, rad = 100)
	var/mob/living/carbon/human/elecMan = null

/obj/item/clothing/head/helmet/space/star_jelly/equipped(mob/living/carbon/human/H, HEAD_SLOT)
	..()
	if(H.flags & !ELECTRIC_HEAL)
		elecMan = H
		H.flags += ELECTRIC_HEAL //glubb power creep
	if(isslimeperson(H))
		sleep(2 SECONDS)
		to_chat(H, "<span class='danger'>It's as if the life is being sucked out of you!</span>")
		H.Knockdown(5)
		H.Stun(5)
		H.adjustBruteLoss(rand(15,40))
		H.nutrition = max(H.nutrition - 200,0)
		spawn(2 SECONDS)
			H.drop_item(src, force_drop = 1)
			new /mob/living/simple_animal/hostile/fishing/star_jelly(src.loc)
			qdel(src)

/obj/item/clothing/head/helmet/space/star_jelly/unequipped(mob/living/carbon/human/H, var/from_slot = null)
	..()
	if(H == elecMan)
		H.flags -= ELECTRIC_HEAL
