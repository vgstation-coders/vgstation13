//Fishing_mobs.dm///////////////

///Stonegulper//////////////

/mob/living/simple_animal/hostile/fishing/stonegulper
	name = "stonegulper"
	desc = "Stonegulpers are known to eats rocks to aid digestion. They're a favorite of many space anglers as although they grow larger the more rock they consume, they can't actually digest them, resulting in bellies full of potentially precious stones"
	icon_state = "stonegulper"
	icon_living = "stonegulper"
	icon_dead = "stonegulper_dead"
	melee_damage_lower = 5
	melee_damage_upper = 10
	minCatchSize = 6
	maxCatchSize = 15
	var/list/possibleEatenOre = list()
	var/list/bellyOre = list()
	var/beenKicked = FALSE

/mob/living/simple_animal/hostile/fishing/stonegulper/New()
	..()
	var/oresMeal = catchSize/3
	for(1 to oresMeal)
		var/eatenOre = pick(possibleEatenOre)
		bellyOre += eatenOre

/mob/living/simple_animal/hostile/fishing/stonegulper/proc/coughUpOre()
	visible_message("<span class='notice'>\The [src]'s belly splits open as it dies.</span>")
	if(bellyOre.len)
		for(var/O in bellyOre)
			O.forceMove(src.loc)

/mob/living/simple_animal/hostile/fishing/stonegulper/death(var/gibbed = FALSE)
	coughUpOre()
	..(gibbed)

/mob/living/simple_animal/hostile/fishing/stonegulper/kick_act(mob/living/carbon/human/K)
	if(stat)
		visible_message("<span class='notice'>The [src]'s coughs up some ore.</span>")
		var/kickOre = pick(bellyOre)
		kickOre.forceMove(src.loc)
	if(!stat && !beenKicked)
		beenKicked = TRUE
		if(prob(catchSize))
			to_chat(K, "<span class='notice'>Looks like there was a little left in there</span>")
			var/leftOverOre = pick(possibleEatenOre)
			new leftOverOre(src.loc)

/mob/living/simple_animal/hostile/fishing/stonegulper/common
	possibleEatenOre = list(
			/obj/item/stack/ore/iron,
			/obj/item/stack/ore/iron,
			/obj/item/stack/ore/iron,
			/obj/item/stack/ore/silver,
			/obj/item/stack/ore/uranium
	)

/mob/living/simple_animal/hostile/fishing/stonegulper/uncommon
	possibleEatenOre = list(
			/obj/item/stack/ore/silver,
			/obj/item/stack/ore/silver,
			/obj/item/stack/ore/gold,
			/obj/item/stack/ore/gold,
			/obj/item/stack/ore/uranium,
	)

/mob/living/simple_animal/hostile/fishing/stonegulper/rare
	possibleEatenOre = list(
			/obj/item/stack/ore/gold,
			/obj/item/stack/ore/diamond,
			/obj/item/stack/ore/diamond,
	)

/mob/living/simple_animal/hostile/fishing/stonegulper/plasma
	desc = "While plasma is not poisonous to stonegulpers, it's not exactly healthy either."
	icon_state = "stonegulper_plasma"
	icon_living = "stonegulper_plasma"
	icon_dead = "stonegulper_plasma_dead"
	melee_damage_lower = 7
	melee_damage_upper = 15
	minCatchSize = 9
	maxCatchSize = 18
	possibleEatenOre = list(
		/obj/item/stack/ore/plasma,
		/obj/item/stack/ore/plasma,
		/obj/item/stack/ore/iron
	)

/mob/living/simple_animal/hostile/fishing/stonegulper/ultraRare
	desc = "This one has been eating well"
	icon_state "stonegulper_phazon"
	icon_living "stonegulper_phazon"
	icon_dead = "stonegulper_dead"
	melee_damage_lower = 15
	melee_damage_higher = 25
	minCatchSize = 12
	maxCatchSize = 24
	possibleEatenOre = list(
		/obj/item/stack/ore/phazon,
		/obj/item/stack/ore/phazon,
		/obj/item/stack/ore/clown,
		/obj/item/stack/ore/diamond
	)

//Space Shark/////////////

/mob/living/simple_animal/hostile/fishing/space_shark
	name = "space shark"
	desc = "Also known as 'star devourers', 'spaceman rippers', and 'angler's regret'. These ferocious creatures lurk the cosmos, as well as the memories of the few who have survived their hunger."
	icon_state = "spess_shark"
	icon_living = "spess_shark"
	icon_dead = "spess_shark_dead"
	meat_type =
	attacktext = list("chomps", "bites", "mauls")
	faction = "hostile"
	stat_attack = 2
	size = SIZE_BIG
	melee_damage_lower = 10
	melee_damage_upper = 25
	minCatchSize = 70
	maxCatchSize = 160
	tameEase = 5
	healEat = TRUE
	tameItem = list(/obj/item/weapon/reagent_containers/food/snacks, /obj/item/organ/external, /obj/item/weapon/holder)
	var/feedingFrenzy = FALSE

/mob/living/simple_animal/hostile/fishing/space_shark/New()
	..()
	maxHealth = catchSize
	health = maxHealth
	if(mutation == ROYAL)
		var/mob/living/simple_animal/hostile/fishing/space_shark/rShark = new /mob/living/simple_animal/hostile/fishing/space_shark(src.loc)
		rShark.catchSize =/2
		rShark.health =/2
		rShark.maxHealth = rShark.health
		friends += rShark
	for(var/mob/living/simple_animal/hostile/fishing/sf in friends)	//So the second shark will also befriend the normal royal mobs
		sf.friends = friends.copy

/mob/living/simple_animal/hostile/fishing/space_shark/fishFeed(obj/W, mob/user)
	..()
	if(feedingFrenzy && beenTamed)
		sharkWeekOver()
	if(prob(5))
		if(beenTamed && prob(50))
			return
		chumInTheWater()	//Equal chances between taming and the shark just going nuts. These are meant for bragging rights. Way too strong to consistently give to players.

/mob/living/simple_animal/hostile/fishing/space_shark/UnarmedAttack(var/atom/A)
	..()
	if(issilicon(target) || target.mob_property_flags & (MOB_CONSTRUCT | MOB_ROBOTIC | MOB_HOLOGRAPHIC))
		LoseTarget()	//They take one nibble and realize they aren't into it
		return
	if(iscarbon(target) && !feedingFrenzy)
		var/mob/living/carbon/T = target
		if(T.check_bodypart_bleeding(FULL_TORSO))
			prob(25)
				chumInTheWater()
	if(isanimal(target) && !feedingFrenzy)
		prob(10)
			chumInTheWater()
	if(feedingFrenzy)
		health += rand(0,5)
		if(mutation == FISH_GREEDY)
			health += rand(0,5)

/mob/living/simple_animal/hostile/fishing/space_shark/proc/chumInTheWater()
	visible_message("<span class='danger'>\The [src] begins drooling, its eyes focus and its muscles bulge! It looks very, very hungry.</span>")
	feedingFrenzy = TRUE
	melee_damage_lower += catchSize/10
	melee_damage_upper += catchSize/10
	speed = 0.8
	icon_state = "spess_shark_frenzied"
	environment_smash_flags = 1
	if(lastMutActivate && catchSize > 150)	//Big sharks are for bragging rights
		lastMutActivate = 0
		spawn(2 SECONDS)
			mutateActivate()
	faction = "hostile"
	friends.len = 0
	beenTamed = FALSE
	if(mutation == FISH_GRUE)	//He HUNGRY
		return
	spawn(catchSize SECONDS)
		sharkWeekOver()

/mob/living/simple_animal/hostile/fishing/space_shark/proc/sharkWeekOver()
	if(isDead())
		return
	visible_message("<span class='notice'>\The [src] regains its composure.</span>")
	feedingFrenzy = FALSE
	speed = 1
	melee_damage_lower -= catchSize/10
	melee_damage_upper -= catchSize/10
	environment_smash_flags = 0
	icon_state = "spess_shark"




//kleptopus/////////

/mob/living/simple_animal/hostile/fishing/kleptopus
	name = "kleptopus"
	desc = "A proven descendent of earth octopi, they are widely accepted to be the most intelligent species of space fish."
	icon_state = "kleptopus"
	icon_living = "kleptopus"
	icon_dead = "kleptopus_dead"
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/kleptopus
	attacktext = "slaps"
	projectiletype = null
	projectilesound = ""
	minimum_distance = 2
	casingtype = null
	ranged = 1
	projectiletype = /obj/item/projectile/hookshot/whip/kleptopus
	projectilesound = 'sound/weapons/whip_crack.ogg'
	ranged_message = "throws"
	ranged_cooldown = 2
	size = SIZE_NORMAL
	search_objects = 2
	maxHealth = 75
	health = 75
	minCatchSize = 30
	maxCatchSize = 60
	var/list/suctionItems = list()
	var/list/caughtBullets = list()
	var/armsToHold = 8

	wanted_objects = list(/obj/item) //He just likes to steal, he doesn't care what
	unwanted_objects = list(/obj/item/device/assembly_holder, /obj/item/weapon/disk/nuclear/nukedisk)

/mob/living/simple_animal/hostile/fishing/kleptopus/openFire(var/atom/A)
	if(istype(target, /obj/item))
		var/obj/item/O = A
		if(O.loc == src || O.anchored || is_type_in_list(unwanted_objects))
			LoseTarget()
			return
		if(armsToHold <= 0 && search_objects != 0)
			search_objects = 0
			LoseTarget() //Oh wait my hands are full, time to slap
			return
		if(I.w_class > W_CLASS_SMALL && mutation != FISH_STRONG | FISH_GRAVITY | FISH_TELEKINETIC)
			LoseTarget()
			return
		..()
		spawn(10)
			if(O.adjacent)
				visible_message("<span class='notice'>\The [src] picks up the [O] with its suction cups.</span>")
				O.forceMove(src)
				suctionItems += O
				armsToHold--
	else
		..()
		if(ishuman(target))
			var/mob/living/carbon/H = target
			if(mutation)
				switch(mutation)
					if(FISH_CLOWN)
						H.Knockdown(1)
					if(FISH_EMP)
						var/turf/T = get_turf(H)
						empulse(T, 0, 0)
					if(FISH_GREEDY)
						var/stealI = pick(get_contents_in_object(H))
						stealI.forcemove(H.loc)


/mob/living/simple_animal/hostile/fishing/kleptopus/Life()
	if(..())
		if(prob(catchSize/2))
			octoTinker()

/mob/living/simple_animal/hostile/fishing/kleptopus/death(var/gibbed = FALSE)
	if(suctionItems.len)
		for(var/i in suctionItems)
			i.forceMove(src.loc)
	..(gibbed)

/mob/living/simple_animal/hostile/fishing/kleptopus/bullet_act(var/obj/item/projectile/Proj)
	if((armsToHold <= 0) || (!istype(Proj, /obj/item/projectile/bullet)))
		..()
	else
		if(istype(Proj, /obj/item/projectile/bullet))
			var/obj/item/projectile/bullet/B = Proj
			armsToHold--
			caughtBullets += B //KA KA KA KA KACHI DAZE
			visible_message("<span class='danger'>The [src] catches the [B]!</span>")
			qdel(B)

/mob/living/simple_animal/hostile/fishing/kleptopus/create_projectile(var/mob/user)
	if(caughtBullets.len < 1)
		projectiletype = /obj/item/projectile/hookshot/whip/kleptopus
		return
	var/bToThrow = caughtBullets[1]
	projectiletype = bToThrow
	caughtBullets -= bToThrow
	armsToHold--
	return new projectiletype(user.loc)

/mob/living/simple_animal/hostile/fishing/kleptopus/proc/octoTinker()
	var/tI = pick(suctionItems)
	if(isassembly(tI))
		octoAssemble(tI)
		return
	if(istool(tI))
		octoGremlin(tI)
		return
	if(istype(tI, /obj/item/weapon/reagent_containers/glass))
		octoChemist(tI)
		return
	if(istype(tI, /obj/item/device/deskbell))
		var/obj/item/device/deskbell/B = tI
		B.ring()
		return
	var/list/can_see = view(src, vision_range)
	var/cTarg = pick(can_see)
	tI.attack(cTarg)	//If it isn't in his list of interactions he'll just try "using" it. Might whack someone, might take their picture.
	if(tI.gcDestroyed)
		suctionItems -= tI

/mob/living/simple_animal/hostile/fishing/kleptopus/proc/octoAssemble(var/obj/item/tI)
	for(var/obj/item/device/assembly/A in suctionItems)
		if(A != tI)
			var/obj/item/device/assembly/B = tI
			A.secured = 0
			B.secured = 0
			B.attack(A, src)
			suctionItems -= A
			suctionItems -= B

/mob/living/simple_animal/hostile/fishing/kleptopus/proc/octoGremlin(var/obj/item/tI)
	for(var/obj/machinery/M in orange(4))
		goto(M)
		if(M.adjacent)
			visible_message("<span class='notice'>\The [src] is trying to use a [tI] on [M]!</span>")
			tI.attack(M)

/mob/living/simple_animal/hostile/fishing/kleptopus/proc/octoChemist(var/obj/item/tI)
	for(var/obj/item/weapon/reagent_containers/R in suctionItems)
		if(istype(R, /obj/item/weapon/reagent_containers/pill))
			R.attack(tI)
			suctionItems -= R
			visible_message("<span class='notice'>\The [src] adds [R] to [tI].</span>")
		if(istype(R, /obj/item/weapon/reagent_containers/glass))
			R.attack(tI)
			tI.attack(R)
			visible_message("<span class='notice'>\The [src] is mixing something.</span>")

/obj/item/weapon/gun/hookshot/whip/kleptopus
	name = "klentacle"
	icon = ''
	icon-state = "klentacle"
	force = 3
	maxlength = 3
	hooktype = /obj/item/weapon/projectile/hookshot/whip/kleptopus
	cant_drop = 1
	mech_flags = MECH_SCAN_ILLEGAL
	slot_flags = null
	whipitgood_bonus = null


/obj/item/weapon/projectile/hookshot/whip/kleptopus
	name = "klentacle"
	icon_state = "klentacle"
	icon_name = "klentacle"
	damage = 5
	kill_count = 3
	sharpness = 0
	failure_message = "Your suction cups stick together"
	can_tether = TRUE

//Pufferfish//////////

/mob/living/simple_animal/hostile/fishing/puffbumper
	name = "puffbumper"
	desc = "In order to combat depressurization some creatures evolved dense shells or invented space suits. These fish instead evolved ridiculous, cartoonish levels of elasticisty."
	icon_state = "puffbumper"
	icon_living = "puffbumper"
	icon_dead = "puffbumper_dead"
	meat_type =
	attacktext = list("pokes", "quills")
	size = SIZE_TINY
	melee_damage_type = TOXIC
	minCatchSize = 2
	maxCatchSize = 8
	mutantPower = 1
	var/puffedUp = FALSE

/mob/living/simple_animal/hostile/fishing/puffbumper/Aggro()
	..()
	puffUp()

/mob/living/simple_animal/hostile/fishing/puffbumper/proc/puffUp()
	var/turf/T = get_turf(src)
	var/puffThrowForce = catchSize*5 + 30
	for(var/mob/living/M in range(src,catchSize/6))	//Just the tile they're on if catchSize is below 6, extra 1 around that above it. If you get it to 12+ you get a big knockback
		var/puffDir = get_dir(src, M)
		endLocation = get_ranged_target_turf(src, puffDir, catchSize)
		M.throw_at(endLocation, catchSize, puffThrowForce)
		M.Knockdown(1)
		if(mutation == GRAVITY)
			spawn(10)
				M.throw_at(src, catchSize, puffThrowForce)
				M.Knockdown(mutantPower)
	if(mutation)
		switch(mutation)
			if(EXPLODING)
				explosion(get_turf(src.loc), 0, mutantPower, mutantPower*2)
			if(EMP)
				empulse(get_turf(src.loc), 0, mutantPower, mutantPower*2)
			if(TIME)
				timestop(src, mutantPower, mutantPower)
	bigPuff()

/mob/living/simple_animal/hostile/fishing/puffbumper/proc/bigPuff()
	icon_state = "puffbumper_wall"
	puffedUp = TRUE
	size = SIZE_BIG
	wander = 0
	canmove = 0

/mob/living/simple_animal/hostile/fishing/puffbumper/death(var/gibbed = FALSE)
	if(puffedUp)
		sleep(1 SECOND)
		playsound(src, "sound/misc/balloon_pop" , 100)
	..(gibbed)

/obj/item/weapon/holder/animal/pufferFish
	name = "pufferfish holder"
	desc = "Not pocket sized for long"
	item_state = "pufferHand"

/obj/item/weapon/holder/animal/pufferFish/throw_impact(atom/hit_atom)
	var/mob/living/simple_animal/hostile/fishing/puffbumper/P = stored_mob
	..()
	spawn(rand(1,20))
		P.puffUp()

/obj/item/weapon/holder/animal/pufferFish/attack_self(mob/user)
	..()
	visible_message("[user] squeezes and pinches the [src]")
	if(prob(50))
		var/mob/living/simple_animal/hostile/fishing/puffbumper/P = stored_mob
		spawn(5)
			user.drop_item(src, force_drop=1)
			P.puffUp()

//star drake//////

/mob/living/simple_animal/hostile/fishing/star_drake
	name = "star drake"
	desc = "These odd creatures begin life only a few inches tall but quickly grow to be larger than an adult spaceman. Their ability to grow so quickly is almost certainly due to their unique diet of live space carp."
	icon_state = "star_drake"
	icon_living = "star_drake"
	icon_dead = "star_drake_dead"
	meat_type =
	size = SIZE_BIG
	minCatchSize = 75
	maxCatchSize = 130
	tameEase = 10
	illegalMutations = list()
	tameItem = list(/obj/item/weapon/holder/animal/carp)
	var/obj/structure/bed/chair/vehicle/star_drake/vehicleForm = null

/mob/living/simple_animal/hostile/fishing/star_drake/New()
	..()
	health = catchSize
	maxHealth = catchSize

/mob/living/simple_animal/hostile/fishing/star_drake/fishTame(mob/user)
	..()
	var/sDrakeNick = sanitize((input(user, "Give your star drake a nickname?", "Star drake nickname", 1, MAX_NAME_LEN)))
	vehicleForm = new /obj/structure/bed/chair/vehicle/star_drake(src.loc)
	vehicleForm.forceMove(src)
	vehicleForm.mobForm = src
	vehicleForm.inheritSDrake()
	if(sDrakeNick.len)
		vehicleForm.nick = sDrakeNick
	else if(prob(1))
		vehicleForm.nick = pick("Mystery", "Majesty", "Grace", "Debbie")
	else
		vehicleForm.nick = "Star Drake"
	mobForm.name = vehicleForm.nick

/mob/living/simple_animal/hostile/fishing/star_drake/attack_hand(mob/user)
	..()
	if(beenTamed)
		if(!is_type_in_list(user, friends))
			to_chat(user, "<span class='warning'>The [src] bucks as you try to mount it. It doesn't want you riding it.</span>")
			unarmed_attack(user)
			return
		sDrakeMount(user)

/mob/living/simple_animal/hostile/fishing/star_drake/proc/sDrakeMount(mob/user)
	vehicleForm.forceMove(src.loc)
	src.forceMove(vehicleForm)
	vehicleForm.buckle_mob(user, user)

/mob/living/simple_animal/hostile/fishing/star_drake/emeraldDrake

/mob/living/simple_animal/hostile/fishing/star_drake/topazDrake

/mob/living/simple_animal/hostile/fishing/star_drake/rubyDrake

/mob/living/simple_animal/hostile/fishing/star_drake/amethystDrake

/mob/living/simple_animal/hostile/fishing/star_drake/redEyesBlackDrake

/mob/living/simple_animal/hostile/fishing/star_drake/blueEyesWhiteDrake

/obj/structure/bed/chair/vehicle/star_drake
	name = "star drake"
	nick = null
	icon = ''
	icon_state = "star_drake"
	anchored = FALSE
	can_spacemove = TRUE
	can_have_carts = FALSE
	vehicle_actions = list()
	var/mob/living/simple_animal/hostile/fishing/star_drake/mobForm = null
	var/carpFuel = 0

/obj/structure/bed/chair/vehicle/star_drake/proc/inheritSDrake()
	health = mobForm.health
	max_health = mobForm.maxHealth
	sDrakeGainAbility()

/obj/structure/bed/chair/vehicle/star_drake/proc/sDrakeGainAbility()
	if(catchSize > 100)
		vehicle_actions += /datum/action/vehicle/sDrakeCharge
	if(mutation)
		switch(mutation)

/obj/structure/bed/chair/vehicle/star_drake/attackby(obj/item/W, mob/living/user)
	if(istype(W, var/obj/item/weapon/holder/animal/carp))
		var/obj/item/weapon/holder/animal/C = W
		if(istype(C.stored_mob, /mob/living/simple_animal/hostile/carp/baby)
			mobForm.health += 10
			carpFuel += 1
		else
			mobForm.health += 25
			carpFuel += 2
		inheritSDrake()

/obj/structure/bed/chair/vehicle/star_drake/manual_unbuckle(user)
	..()
	mobForm.forceMove(src.loc)
	src.forceMove(mobForm)
	mobForm.health = health

/obj/structure/bed/chair/vehicle/star_drake/die()
	visible_message("<span class='warning'>[nick] let's out a agonized cry and falls limps</span>")
	unlock_atom(occupant)
	mobForm.forceMove(get_turf(src))
	mobForm.death()
	qdel(src)

/obj/structure/bed/chair/vehicle/star_drake/Process_Spacemove(var/check_drift = 0)
	return TRUE

/datum/action/vehicle/sDrakeAbility
	name = "star drake ability"
	desc = "You should never see this"
	var/sDrakeCD = 0
	var/sDrakeLA = 0
	var/cFuelUse = 0
	var/list/yeehawAttire = list(
		/obj/item/clothing/head/cowboy,
		/obj/item/clothing/shoes/jackboots/cowboy,
		/obj/item/clothing/mask/cigarette,
	)

/datum/action/vehicle/sDrakeAbility/New(var/obj/structure/bed/chair/vehicle/Target)
	..()
	icon_icon = Target.icon
	button_icon_state = Target.icon_state
	Target.vehicle_actions += src

/datum/action/vehicle/sDrakeAbility/Trigger()
	if(!..())
		return FALSE
	var/obj/structure/bed/chair/vehicle/star_drake/SD = Target
	if(!world.time - sDrakeLA >= sDrakeCD)
		to_chat(SD.occupant, "<span class='notice'>[SD.nick] can't do that again yet.</span>")
		return
	if(SD.carpFuel < cFuelUse)
		to_chat(SD.occupant, "<span class='notice'>[SD.nick] is too hungry for that.</span>")
		return
	SD.carpFuel -= cFuelUse
	sDrakeLA = world.time


/datum/action/vehicle/sDrakeAbility/Gallop
	name = "star drake gallop"
	desc = "Spur your star drake to gallop forward."
	sDrakeCD = 300
	cFuelUse = 1

/datum/action/vehicle/sDrakeAbility/Gallop/Trigger()
	if(..())
		var/gDest = get_distant_turf(get_turf(Target), Target.dir, 5)
		Target.throw_at(gDest, 5, 2)


/datum/action/vehicle/sDrakeAbility/sDrakeMutationActiv
	name = "Activate Mutation"
	desc = "Coax your star drake to activate its mutation."
	cFuelUse = 5


/datum/action/vehicle/sDrakeMutationActiv/Trigger()
	if(..())
		mobForm.mutateActivate()

/datum/action/vehicle/sDrakeAbility/sDrakeRoudyRide
	name = "Roudy Bronco"
	desc = "Spur your star drake to buck wildly, hold on tight!"
	sDrakeCD = 15
	cFuelUse = 0

/datum/action/vehicle/sDrakeAbility/sDrakeRoudyRide/Trigger()
	if(..())
		spawn for(var/i=1, i<=8, i++)
			Target.dir = turn(Target.dir, 45)
		var/mob/living/carbon/human/sDRider = Target.occupant
		if(prob(40 - YeehawCheck()))
			Target.manual_unbuckle(sDRider)
			var/rDest = get_distant_turf(get_turf(Target), Target.dir, 3)
			sDRider.throw_at(rDest, 3, 10)
			sDRider.Knockdown(8)

/datum/action/vehicle/sDrakeAbility/proc/YeehawCheck(mob/living/carbon/human/sDRider)
	var/Yeehaw = 0
	for(var/Y in yeehawAttire)
		if(sDRider.is_wearing_item(Y))
			Yeehaw += 10
	return Yeehaw


//jelly fish//////

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
		new /obj/item/clothing/head/helmet/space/star_jelly(src.loc)
		if(eatenCores)
			convertSlimeCore()
		catchSize -= rand(5,10)
		if(catchSize < 10)
			canRegenerate = 0

/mob/living/simple_animal/hostile/fishing/star_jelly/proc/jellyChargeCheck()
	if(world.time - lastZap >= zapCooldown)
		lastZap = world.time
		return TRUE

/mob/living/simple_animal/hostile/fishing/star_jelly/CanAttack(var/atom/the_target)
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
	for(1 to timeToEat)
		if(src.loc != SF.loc || stat == 2)
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
	SF.death()
	catchSize++

/mob/living/simple_animal/hostile/fishing/star_jelly/proc/jellyFeedSPerson(mob/living/S)
	var/mob/living/carbon/human/SH = S
	visible_message("<span class='warning'>\the [src] latches onto [SH] and starts feeding on them!</span>")
	var/targetL = pick(LIMB_LEFT_ARM, LIMB_RIGHT_ARM, LIMB_LEFT_LEG, LIMB_RIGHT_LEG) //Avoid insta-kills, that's just no fun
	if(!SH.has_organ(targetL))
		targetL = LIMB_HEAD	//On the other hand, don't start fights without arms
	for(1 to 5)
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
			LoseTarget()
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
	for(0 to eatenCores)
		var/sCore = lastSlimeEaten.coretype
		new sCore(src.loc)
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
		elecMan.movement_speed_modifier *= 1.1
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
		elecMan.movement_speed_modifier /= 1.1
		to_chat(elecMan, "You feel normal again.")
		elecMan = null

/obj/item/weapon/holder/animal/star_jelly/afterattack(var/atom/target, var/mob/user)
	..()
		if(!SJ.jellyChargeCheck())
			to_chat(user, "<span class='notice'>The [src] hasn't built up enough charge.</span>")
			return
		playsound(target, 'sound/weapons/electriczap.ogg, 50, 1')
		if(istype(target, /obj/item/weapon/cell))
			var/obj/item/weapon/cell/C = target
			C.charge += min(C.maxcharge, stored_mob.catchSize*stored_mob.catchSize)
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
		H.nutrition -= max(H.nutrition - 200,0)
		spawn(2 SECONDS)
			H.drop_item(src, force_drop = 1)
			new /mob/living/simple_animal/hostile/fishing/star_jelly(src.loc)
			qdel(src)

/obj/item/clothing/head/helmet/space/star_jelly/unequipped(mob/living/carbon/human/H, var/from_slot = null)
	..()
	if(H == elecMan)
		H.flags -= ELECTRIC_HEAL


//bluespacegill//////

/mob/living/simple_animal/hostile/fishing/bluespacegill
	name = "bluespacegill"
	desc = "A small blue scaled space fish. After its unique evolutionary traits were discovered its name was taken to vote. The results were unanimous."
	icon_state = "bluespacegill"
	icon_living = "bluespacegill"
	icon_dead = "bluespacegill_dead"
	meat_type =
	size = SIZE_TINY
	minCatchSize = 3
	maxCatchSize = 6
	maxHealth = 15
	health = 15

/mob/living/simple_animal/hostile/fishing/bluespacegill/Life()
	if(timestopped)
		return 0
	blueGillJaunt()
	. = ..()

/mob/living/simple_animal/hostile/fishing/bluespacegill/proc/blueGillJaunt()
	prob(catchSize)
		do_teleport(src, get_turf(src), catchSize)

//Station Sucker///////

/mob/living/simple_animal/hostile/fishing/station_sucker
	name = "station sucker"
	desc = "Also known as 'jani-fish'. These disgusting creatures feed by crawling around with their heads to the floor, licking up filth. Fiercely territorial they'll attack other suckers, aside from their children of course."
	icon_state = "station_sucker"
	icon_living = "station_sucker"
	icon_dead = "station_sucker_dead"
	meat_type =
	size = SIZE_SMALL
	minCatchSize = 15
	maxCatchSize = 25
	maxHealth = 35
	health = 35
	faction = "station_sucker"
	attack_same = 2
	search_objects = 1
	wanted_objects = list(/obj/effect/decal/cleanable)

/mob/living/simple_animal/hostile/fishing/station_sucker/New()
	..()
	friends += src	//This probably isn't necessary but better safe than sorry
	var/obj/item/weapon/sucker_bladder/chemBladder = new /obj/item/weapon/sucker_bladder(src.loc)
	chemBladder.create_reagents(catchSize)
	chemBladder.forceMove(src)

/mob/living/simple_animal/hostile/fishing/station_sucker/AttackingTarget()
	if(istype(target, /obj/effect/decal/cleanable))
		filthSucc(target)
		return
	..()

/mob/living/simple_animal/hostile/fishing/station_sucker/proc/filthSucc(target)
	/obj/effect/decal/cleanable/F = target
	anchored = 1
	sleep(10)
	if(!F.adjacent)
		anchored = 0
		return
	if(F.reagent)
		chemBladder.reagents.add_reagent(F.reagent, F.reagents.total_volume)
	qdel(F)
	if(prob(10))
		visible_message("<span class='notice'>\The [src] licks its lips.</span>")
	health++
	if(chemBladder.reagents.is_full())
		suckerSplit()
	anchored = 0

/mob/living/simple_animal/hostile/fishing/station_sucker/proc/suckerSplit()
	playsound(src, 'sound/effects/splat.ogg', 100, 1)
	var/mob/living/simple_animal/hostile/fishing/station_sucker/janiBaby = new /mob/living/simple_animal/hostile/fishing/station_sucker(src.loc)
	janiBaby.try_move_adjacent(src)
	new /obj/effect/decal/cleanable/vomit(src.loc)
	visible_message("<span class='notice'>\The [src] has given birth!</span>")
	var/obj/item/weapon/sucker_bladder/babyShare = janiBaby.chemBladder
	reagents.trans_to(babyShare.reagents, reagents.total_volume/2)	//transfers half their filth to their kid, that's so sweet
	friends += janiBaby
	for(var/mob/living/simple_animal/hostile/fishing/station_sucker/B in friends)
		B.friends = friends.copy()


/obj/item/weapon/sucker_bladder
	name = "sucker bladder"
	desc = "The bladder of a station sucker. These act as a combination stomach, bladder, and uterus. It smells terrible."
	icon_state = "sucker_bladder"
	w_class = W_CLASS_SMALL
	throwforce = 3
	throw_range = 7
	throw_speed = 3
	force = 1

/obj/item/weapon/sucker_bladder/throw_impact(atom/hit_atom, var/speed, user)
	splash_sub(reagents, hit_atom, reagents.total_volume, user)
	qdel(src)


//Rainbow trout//////
/mob/living/simple_animal/hostile/fishing/rainbow_trout
	name = "rainbow trout"
	desc = "Named for its unique ability to synthesize almost any chemical known, or unknown, to mankind. Its meat is known to be delicious and is a popular last meal for prisoners. The prisoners have not necessarily been on death row."
	icon_state = "rainbow_trout"
	icon_living = "rainbow_trout"
	icon_dead = "rainbow_trout_dead"
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/rainbowfillet
	size = SIZE_SMALL
	faction = "hostile"
	ranged = 1
	ranged_cooldown_cap = 6 //twice that of the default
	minimum_distance = 2
	retreat_distance = 1
	ranged_message = "spits"
	ranged_cooldown = 2 //Let's not have it cyanide people instantly
	projectiletype = /obj/item/projectile/bullet/rainbow_trout
	minCatchSize = 10
	maxCatchSize = 30

/mob/living/simple_animal/hostile/fishing/rainbow_trout/New()
	..()
	projectiletype.capacity = catchSize/2
	meat_amount = catchSize/10

/obj/item/projectile/bullet/syringe/rainbow_trout
	name = "rainbow spit"
	nodamage = 0
	damage = 5
	fire_sound =
	custom_impact = FALSE
	damage_type = TOX
	decay_type = null
	projectile_speed = 1.5

/obj/item/projectile/bullet/syringe/rainbow_trout/New()
	..()
	var/spitChem = pick(rainbowChems)
	create_reagents(capacity)
	reagents.add_reagent(spitChem, capacity)

/obj/item/weapon/reagent_containers/food/snacks/meat/rainbowfillet
	name = "rainbow fillet"
	desc = "A fillet of rainbow trout meat"
	icon_state = "troutfillet"

/obj/item/weapon/reagent_containers/food/snacks/meat/rainbowfillet/New()
	..()
	eatverb = pick("bite","chew","choke down","gnaw","swallow","chomp")
	reagents.add_reagent(pick(rainbowChems), 5)
	bitesize = 5

/mob/living/simple_animal/hostile/fishing/rainbow_trout/barman

/mob/living/simple_animal/hostile/fishing/rainbow_trout/lowMed

/mob/living/simple_animal/hostile/fishing/rainbow_trout/medMed

/mob/living/simple_animal/hostile/fishing/rainbow_trout/highMed

/mob/living/simple_animal/hostile/fishing/rainbow_trout/danger

/mob/living/simple_animal/hostile/fishing/rainbow_trout/rare

/mob/living/simple_animal/hostile/fishing/rainbow_trout/weird

//Chromafin///////
	name = "chromafin"
	desc = "Many spacemen believe the chromafin was named for its literal chrome coloured fin. It was actually named for its defense mechanic of restructuring the genes of prey and predator alike."
	icon_state = "chromafin"
	icon_living = "chromafin"
	icon_dead = "chromafin_dead"
	meat_type =
	size = SIZE_SMALL

//eswordfish///////
/mob/living/simple_animal/hostile/fishing/eswordfish
	name = "eswordfish"
	desc = "While many space fish have evolved unique and interesting ways to hunt and defend themselves, the eswordfish's methods are a bit more direct."
	icon_state = "eswordfish"
	icon_living = "eswordfish"
	icon_dead = "eswordfish_dead"
	meat_type =
	butchering_drops = /obj/item/weapon/melee/energy/sword/eswordfish
	faction = "eswordfish"
	size = SIZE_NORMAL
	minCatchSize = 20
	maxCatchSize = 40 //Decides esword force. Base will always be weaker than esword, mutations + bait can make it much stronger.
	health = 80
	maxhealth = 80
	var/activatedSword = FALSE

/mob/living/simple_animal/hostile/fishing/eswordfish/Aggro()
	if(!activatedSword)
		spawn(5)
			eswordfishActivate()
	..()

/mob/living/simple_animal/hostile/fishing/eswordfish/LoseAggro()
	..()
	if(activatedSword)
		spawn(10)
			eswordfishDeactivate()

/mob/living/simple_animal/hostile/fishing/eswordfish/proc/eswordfishActivate()
	activatedSword = TRUE
	playsound(src, "sound/weapons/saberon.ogg", 100, 1)
	melee_damage_lower = catchSize
	melee_damage_upper = catchSize
	armor_modifier = 0.5
	environment_smash_flags = 1
	melee_damage_type = BURN

/mob/living/simple_animal/hostile/fishing/eswordfish/proc/eswordfishDeactivate()
	activatedSword = FALSE
	playsound(src, "sound/weapons/saberoff.ogg", 50, 1)
	melee_damage_lower = 1
	melee_damage_upper = 5
	armor_modifier = 1
	environment_smash_flags = 0
	melee_damage_type = BRUTE

/obj/item/weapon/melee/energy/sword/eswordfish
	name = "fish-e-sword"
	desc = "The organ of a eswordfish that produces its energy-snout, still attached to part of its skull for use as a handle"
	icon_state = "fishesword0"
	base_state = "fishesword"
	activeforce = 10
	origin_tech = Tc_BIOTECH + "=4", Tc_COMBAT + "=2"
	mech_flags = MECH_SCAN_FAIL
	duelsaber_type = null //maybe later
	var/mutation = null

/datum/butchering_product/fish_esword
	result = /obj/item/weapon/melee/energy/sword/eswordfish
	verb_name = "remove snout"
	verb_gerund = "removing the snout from "
	amount = 1
	butcher_time = 25

/datum/butchering_product/fish_esword/spawn_result(location, mob/parent)
	if(isliving(parent))
		var/mob/living/L = parent
		L.update_icons()
		L.mob_property_flags |= MOB_NO_LAZ

	if(amount > 0)
		amount--
		var/obj/I = new result(location)

		if(istype(parent, /mob/living/simple_animal/hostile/fishing/eswordfish))
			var/mob/living/simple_animal/hostile/fishing/eswordfish/F = parent
			I.inheritESwordFish(F)

/obj/item/weapon/melee/energy/sword/eswordfish/proc/inheritESwordFish()
	/mob/living/simple_animal/hostile/fishing/eswordfish/EF = F
	activeforce = EF.catchSize/2
	mutation = EF.mutation

/obj/item/weapon/melee/energy/sword/eswordfish/attack(mob/target, mob/living/user)
	..()
	if(mutation && active && prob(activeforce))
		switch(mutation)
			if(FISH_CLOWN)
				playsound(target, 'sound/items/bikehorn.ogg', 50, 1)
				if(prob(activeforce))
					target.Knockdown(1)
			if(FISH_POISON)
				target.reagents.add_reagent(TOXIN, 5)
			if(FISH_BLUESPACE)
				do_teleport(target, target.loc, 1)

//Dolfriend//////
/mob/living/simple_animal/hostile/fishing/dolfriend
	name = "dolfriend"
	desc = "A symbiotic organism evolved to latch onto social groups within more successful species and make itself useful in order to gain their protection. They are genetically pre-disposed to loyalty, as well as being one of the most intelligent species of space fish."
	icon_state = "dolfriend"
	icon_living = "dolfriend"
	icon_dead = "dolfriend_dead"
	meat_type =
	size = SIZE_NORMAL
	illegalMutations = list()
	melee_damage_lower = 5
	melee_damage_upper = 10
	maxHealth = 65
	health = 65
	minCatchSize = 25
	maxCatchSize = 50
	flags = HEAR_ALWAYS
	var/mob/living/carbon/human/bestFriend = null
	var/helpingFriend = FALSE
	var/stayStill = FALSE
	var/obj/effect/decal/point/currentPoint = null	//Thank you wolf code
	var/list/parrotedPhrases = list()

/mob/living/simple_animal/hostile/fishing/dolfriend/fishTame(mob/user)
	..()
	faction = "\ref[user]"
	bestFriend = user

/mob/living/simple_animal/hostile/fishing/dolfriend/Life()
	..()
	if(!bestFriend)
		return
	var/list/can_see = view(src, vision_range)
	if(!helpingFriend)
		friendPointCheck(can_see)
		parrotFriend(can_see)
		followFriend(can_see)

/mob/living/simple_animal/hostile/fishing/dolfriend/proc/followFriend(can_see)
	if((bestFriend in can_see) && (!stayStill))
		Goto(bestFriend, move_to_delay)
		if(bestFriend.isDead())
			tryToHelpFriend(can_see)

/mob/living/simple_animal/hostile/fishing/dolfriend/proc/parrotFriend(can_see)
	if(prob(catchSize/10)) //bigger fish, bigger bro
		helpingFriend = TRUE
		var/talkTargets = prune_list_to_type(can_see, mob/living)
		var/chatEmUp = pick(talkTargets)
		Goto(chatEmUp, move_to_delay)
		var/lineToSay = pick(parrotedPhrases)
		say("[lineToSay]!")
		spawn(5)
			Goto(bestFriend, move_to_delay)
		helpingFriend = FALSE

/mob/living/simple_animal/hostile/fishing/dolfriend/proc/friendPointCheck(var/list/can_see)
	for(var/obj/effect/decal/point/pointer in can_see)
		if(pointer == currentPoint)
			return
		if(pointer.pointer != bestFriend)
			return
		currentPoint = pointer
		var/atom/target = pointer.target
		friendPointDecide(target)

/mob/living/simple_animal/hostile/fishing/dolfriend/proc/friendPointDecide()
	if(target.anchored)
		return
	if(mobPoint == src)
		stayStill = TRUE
		return
	if(mobPoint == bestFriend)
		if(pulling)
			stop_pulling()
			helpingFriend = FALSE
			Goto(bestFriend, move_to_delay)
		return
	bringToFriend(target)

/mob/living/simple_animal/hostile/fishing/dolfriend/proc/bringToFriend()
	helpingFriend = TRUE
	if(mutation == BLUESPACE)
		spawn(5)
			var/targloc = get_turf(get_step(target,turn(target.dir,180)))
			do_teleport(src, targloc, 0)
	else
		Goto(target, move_to_delay)
	if(!Adjacent(target))
		helpingFriend = FALSE
		return
	if((mutation == CLOWN) && (ishuman(target)))
		var/mob/living/carbon/human/slipPoint = target
		playsound(slipPoint, 'sound/misc/slip.ogg', 50, 1)
		slipPoint.Knockdown(2)
	start_pulling(toGrab)
	var/tooHeavy = 250/catchSize
	if(isitem(target))
		var/obj/item/toGrab = target
		if(toGrab.w_class < W_CLASS_MEDIUM)
			tooHeavy = 0
	if(mutation == STRONG | GRAVITY | TELEKINETIC)
		tooHeavy = 0
	returnToBestie(tooHeavy)
	toGrab.forceMove(get_turf(src))

/mob/living/simple_animal/hostile/fishing/dolfriend/proc/returnToBestie()
	Goto(bestFriend, move_to_delay + tooHeavy)
	stop_pulling()
	helpingFriend = FALSE

/mob/living/simple_animal/hostile/fishing/dolfriend/Hear(var/datum/speech/speech, var/rendered_speech="")
	if((speech.speaker) && (speech.speaker == bestFriend))
		if((parrotedPhrases.len >= 10) && (mutation != CHATTY)) //Surely this won't be abused
			parrotedPhrases -= parrotedPhrases[1]
		parrotedPhrases += speech.message
		if(prob(catchSize/10))
			var/toSay = speech.message
			spawn(5)
				say("[toSay]!")

/mob/living/simple_animal/hostile/fishing/dolfriend/tryToHelpFriend()
	if(!pulling == bestFriend)
		Goto(bestFriend, move_to_delay)
		start_pulling(bestFriend)

//Snitch fish//////
/mob/living/simple_animal/hostile/fishing/snitchfish
	name = "snitch fish"
	desc = ""
	icon_state = "snitch_fish"
	icon_living = "snitch_fish"
	icon_dead = "snitch_fish_dead"
	size = SIZE_TINY
	search_objects = 2
	maxHealth = 10
	health = 10
	minCatchSize = 3
	maxCatchSize = 6
	var/snitchCooldown = 0

	illegalMutations = list()
	wanted_objects = list(/obj/item/weapon/paper)

/mob/living/simple_animal/hostile/fishing/snitchfish/New()
	..()
	snitchCooldown = 1200/catchSize //Two minutes at max catch size pre-mutation/bait increases
	if(mutation == TELEKINETIC)
		snitchCooldown /= 2

/mob/living/simple_animal/hostile/fishing/snitchfish/AttackingTarget()
	if(istype(target, /obj/item/weapon/paper))
		if(world.time - lastSnitch >= snitchCooldown)
			decideSnitch(target)
		else
			LoseTarget()
	..()

/mob/living/simple_animal/hostile/fishing/snitchfish/proc/decideSnitch()
	var/snitchType = pick(itemSnitch, mobSnitch, otherSnitch)
	var/theSnitch = null
	switch(snitchType)
		if(itemSnitch)
			theSnitch = snitchOnItems()
		if(mobSnitch)
			var/mob/living/mobS = pick(mob_list)
			if(mobS == src)
				visible_message("The [src] twitches violently.")
				sleep(2 SECONDS)
				explosion(get_turf(src.loc),-1,0,2)
				return
			if((ishuman(mobS) && (mobS.mind))
				theSnitch = snitchOnCrew(mobS)
			else
				theSnitch = snitchOnMobs(mobS)
		if(otherSnitch)
			theSnitch = snitchOnOther()
	if(theSnitch)
		writeSnitch(theSnitch, target)

/mob/living/simple_animal/hostile/fishing/snitchfish/proc/snitchOnItems()
	var/snitchArea = pick(area)
	var/list/sItems = list()
	for(var/obj/item/i in snitchArea)
		sItems += i
	if(!sItems.len)
		visible_message("The [src] looks disappointed.")
		return FALSE
	var/obj/item/itemS = pick(sItems)
	if(mutation == BLUESPACE)
		if(prob(catchSize))
			do_teleport(itemS, get_turf(src), 10 - catchSize)
	var/sRoll = rand(1,10)
	switch(sRoll)
		if(1)
			theSnitch = "[itemS] is at [itemS.x], [itemS.y], [itemS.z]."
		if(2)
			if(itemS.w_class > W_CLASS_MEDIUM)
				theSnitch = "[itemS] is heavy."
			else
				theSnitch = "[itemS] is light."
		if(3)
			var/itemHeldBy = itemS.loc
			if(ishuman(itemHeldBy))
				theSnitch = "[itemS] is being carried by [itemHeldBy.name]."
			if(isitem(itemHeldBy))
				theSnitch = "[itemS] is inside the [itemHeldBy.name]."
			else
				theSnitch = "[itemS] is in [itemS.area.name]."
		if(4)
			var/list/byItemS = list()
			for(var/atom/movable/A in orange(itemS, 2))
				byItemS += A
			if(!byItemS.len)
				theSnitch = "[itemS] isn't near anything at all."
			var/adjItemS = pick(byItemS)
			theSnitch = "[itemS] is near \the [adjItemS.name]"
		if(5)
			if(itemS.reagents)
				var/itemSreag = itemS.reagents[1]
				theSnitch = "[itemS] has some [itemSreag.name] in it."
			else
				theSnitch = "[itemS] doesn't have any chemicals in it."
		if(6)
			if(itemS.contents)
				var/itemInside = pick(itemS.contents)
				theSnitch = "[itemInside] is inside [itemS]."
			else
				theSnitch = "[itemS] doesn't contain anything."
		if(7)
			theSnitch = "[itemS] is in [ItemS.area.name] which is in zeta sector [ItemS.z]."
		if(8)
			var/turf/T = get_turf(itemS)
			spawn(10)
				if(get_turf(itemS != T))
					theSnitch = "[itemS] is moving."
				else
					theSnitch = "[itemS] is not moving."
		if(9)
			if(itemS.had_blood)
				theSnitch = "[itemS] has been covered in blood."
			else
				theSnitch = "[itemS] has never been covered in blood."
		if(10)
			if(itemS.damtype)
				if((itemS.damtype == "brute" || (itemS.damtype == BRUTE))
					theSnitch = "[itemS] would probably leave a bruise."
				if((itemS.damtype == "burn") || (itemS.damtype == BURN) || (itemS.damtype == "fire"))
					theSnitch = "[itemS] would probably leave a burn."
				else
					theSnitch = "[itemS] probably isn't too dangerous to swing around."
	return(theSnitch)


/mob/living/simple_animal/hostile/fishing/snitchfish/proc/snitchOnMobs()
	var/sRoll = rand(1,10)
	switch(sRoll)
		if(1)
			if(mobS.mind)
				theSnitch = "[mobS] is fully sentient."
			else
				theSnitch = "[mobS] doesn't have much of a mind to speak of."
		if(2)
			if(mobS.isDead())
				theSnitch = "[mobS] is dead."
			else
				theSnitch = "[mobS] is alive."
		if(3)
			theSnitch = "[mobS] is at [mobS.x], [mobS.y], [mobS.z]."
		if(4)
			theSnitch = "[mobS] is in [mobS.area.name]."
		if(5)
			theSnitch = "[mobS] is in [mobS.area.name], which is in zeta sector [mobS.z]."
		if(6)
			var/list/bymobS = list()
			for(var/atom/movable/A in orange(mobS, 2))
				bymobS += A
			if(!bymobS.len)
				theSnitch = "[mobS] isn't near anything at all."
			var/adjmobS = pick(bymobS)
			theSnitch = "[mobS] is near \the [adjmobS.name]"
		if(7)
			if(mobS.size > SIZE_SMALL)
				theSnitch = "[mobS] is big."
			else
				theSnitch = "[mobS] is small."
		if(8)
			theSnitch = "[mobS] could be described as [mobS.faction]." //Yes, zombie could be described as zombie, thank you snitchfish
		if(9)
			if(mobS.speak_chance)
				theSnitch = "[mobS] is a talker."
			else
				theSnitch = "[mobS] is the quiet type."
		if(10)
			if(mobS.health == mobS.maxHealth)
				theSnitch = "[mobS] is completely healthy."
			else
				theSnitch = "[mobS] is hurt."
	return(theSnitch)


/mob/living/simple_animal/hostile/fishing/snitchfish/proc/snitchOnCrew(var/mob/living/carbon/human/crewS)
	crewS = mobS
	if(mutation == FISH_HAUNTING | FISH_ILLUSIONARY)	//Spooky
		var/turf/T = get_turf(crewS)
		var/mob/living/simple_animal/hostile/fishing/fishlusion/G = new /mob/living/simple_animal/hostile/fishing/fishlusion(T)
		G.fishMimic(src)
		G.try_move_adjacent(T)
		G.alpha =/ 2
		G.wander = 0
		spawn(2 SECONDS)
			qdel(G)
	var/sRoll = rand(1, 20)
	switch(sRoll)
		if(1)
			if(crewS.assigned_role)
				theSnitch = "[crewS]'s works as [crewS.assigned_role]."
			else
				theSnitch = "[crewS] doesn't have a job."
		if(2)
			if(crewS.assigned_role)
				theSnitch = "The [crewS.assigned_role]'s name is [crewS].'"
			else
				theSnitch = "[crewS] doesn't work here."
		if(3)
			theSnitch = "[crewS]'s age is [crewS.age]."
		if(4)
			theSnitch = "[crewS]'s blood type is [crewS.dna.b_type]."
		if(5)
			var/cS = crewS.get_species()
			theSnitch = "[crewS] is a [cS]."
		if(6)
			if(crewS.mind.initial_account)
				theSnitch = "[crewS]'s account number is [crewS.mind.initial_account.account_number]."
			else
				theSnitch = "[crewS] does not have a bank account."
		if(7)
			if(crewS.mind.initial_account)
				theSnitch = "[crewS]'s account pin is [crewS.mind.initial_account.remote_access_pin]."
			else
				theSnitch = "[crewS] does not have an account pin."
		if(8)
			theSnitch = "[crewS] is a [crewS.gender]."
		if(9)
			theSnitch = "[crewS] is in [crewS.area.name]."
		if(10)
			if(crewS.dead)
				theSnitch = "[crewS] is dead."
			else
				theSnitch = "[crewS] is alive."
		if(11)
			if(!crewS.contents.len)
				theSnitch = "[crewS] isn't carrying anything."
			else
				var/ci = pick(crewS.contents)
				theSnitch = "[crewS] is carrying a [ci]."
		if(12)
			var/list/bycrewS = list()
			for(var/atom/movable/A in orange(crewS, 2))
				bycrewS += A
			if(!bycrewS.len)
				theSnitch = "[crewS] isn't near anything at all."
			var/adjcrewS = pick(bycrewS)
			theSnitch = "[crewS] is near \the [adjcrewS.name]"
		if(13)
			theSnitch = "[crewS] is at [crewS.x], [crewS.y], [crewS.z]."
		if(14)
			theSnitch = "[crewS] is in [crewS.area.name] which is zeta sector [crewS.z]."
		if(15)
			if((crewS.l_store) || (crewS.r_store))
				theSnitch = "[crewS] has something in their pockets."
			else
				theSnitch = "[crewS]'s pockets are empty."
		if(16)
			if(crewS.shoes)
				theSnitch = "[crewS] is wearing shoes." //Thank you fish
			else
				theSnitch = "[crewS] is not wearing shoes."
		if(17)
			theSnitch = "[crewS] has been cloned [crewS.times_cloned] times."
		if(18)
			var/cw = crewS.time_last_speech/10
			theSnitch = "[crewS] last spoke [cw] seconds ago."
		if(19)
			if(crewS.virus2.len)
				theSnitch = "[crewS] is sick."
			else
				theSnitch = "[crewS] is not sick."
		if(20)
			if(crewS.reagents.len)
				theSnitch = "[crewS] is metabolizing chemicals."
			else
				theSnitch = "[crewS] is not metabolizing anything."
	return(theSnitch)



/mob/living/simple_animal/hostile/fishing/snitchfish/proc/snitchOnOther()
	var/sRoll = rand(1,10)
	switch(sRoll)
		if(1)
			theSnitch = "The time is [worldtime2text()]."
		if(2)

/*****************FINISH AAAHHH***************/


/mob/living/simple_animal/hostile/fishing/snitchfish/proc/writeSnitch(var/snitchPhrase, var/target)
	if((!Adjacent(target) && (mutation != FISH_TELEKINETIC | FISH_BLUESPACE))
		Goto(target)
		sleep(2 SECONDS)
		if(!Adjacent(target))
			return
	if(!istype(target, /obj/item/weapon/paper))
		return
	var/obj/item/weapon/paper/P = target
	if(mutation == FISH_CLOWN)
		if(prob(50))
			snitchPhrase = "Honk!"
	P.info += snitchPhrase
	if(mutation == FISH_CHATTY)
		say(snitchPhrase)


//Change-ling//////

/mob/living/simple_animal/hostile/fishing/change-ling
	name = "Change-ling"
	desc = "It's commonly believed that these fish are the direct ancestor of changelings. Due to the transient nature of both changeling and change-ling genomes we may never have proof of that claim."
	icon_state = "change_ling"
	icon_living = "change_ling"
	icon_dead = "change_ling_dead"
	meat_type =
	size = SIZE_NORMAL
	maxHealth = 50
	health = 50
	minCatchSize = 25
	maxCatchSize = 40
	mutantPower = 5
	illegalMutations = list()
	tameItem = list()
	tameEase = 10
	var/shapeShifted = 0
	var/shapeJob = null
	var/firstName = null
	var/inConversation = FALSE
	var/list/responsePhrase = list()
	var/list/greetingPhrase = list()


/mob/living/simple_animal/hostile/fishing/change_ling/attackby(obj/W, mob/user)
	..()
	if(istype(W, /obj/item/weapon/photo))
		var/obj/item/weapon/photo/P = W
		if(!P.info)
			return
		var/mob/living/newForm = pick(P.info)
		icon = newForm.icon
		icon_state = newForm.icon_state
		name = newForm.name
		desc = newForm.desc
		if(ishuman(newForm))
			crewShift(newForm)
			return
	else if(istype(W, /obj/item/))
		spawn(10)
			icon = W.icon
			icon_state = W.icon_state
			name = W.name
			desc = W.desc
			wander = 0
			shapeShifted = 1

/mob/living/simple_animal/hostile/fishing/change_ling/proc/crewShift(var/mob/living/targetForm)
	var/mob/living/carbon/human/crewForm = targetForm
	shapeJob = crewForm.mind.assigned_role
	var/image/I = image('icons/effects/32x32.dmi', "blank")
	I.overlays |= crewForm.overlays
	for(var/L in name)
		if(L == " ")
			break
		firstName += L
	shapeShifted = 2

/mob/living/simple_animal/hostile/fishing/change_ling/Hear(var/datum/speech/speech, var/rendered_speech="")
	if(shapeShifted != 2)
		return
	if((!speech.speaker) && (speech.speaker == src))
		return 0
	if(is_type_in_list(speaker, friends))
		gainPersonality(speech)
	else
		fakePersonality(speaker, speech)

/mob/living/simple_animal/hostile/fishing/Change-ling/proc/gainPersonality(var/phraseLearn)
	if(findtext(phraseLearn, "?" |"Yes" | "yes" | "No" | "no" | "Maybe" | "maybe" | "I'm"))
		responsePhrase += phraseLearn
	if(findtext(phraseLearn, "Hello" | "hello" | "Howdy" | "howdy" | "Hey" | "hey"))
		greetingPhrase += phraseLearn
	var/list/forgetPhrase = list()
	forgetPhrase = responsePhrase + greetingPhrase
	if(forgetPhrase.len > catchSize)
		if(responsePhrase.len > greetingPhrase.len)
			responsePhrase -= pick(responsePhrase)
		else
			greetingPhrase -= pick(greetingPhrase)

/mob/living/simple_animal/hostile/fishing/Change-ling/proc/fakePersonality(var/mob/chatMan, var/phraseHeard)
	spawn(rand(5,15))
		dir = get_dir(src, chatMan)
	if(get_dist(src, chatMan > 4))
		return
	if(!inConversation)
		var/shortName = "[name[1]]+[name[2]]+[name[3]]+[name[4]]"
		if((findtext(phraseHeard, "[shortName]" || "[firstName]" || "[shapeJob]"))
			var/respondWith = pick(greetingPhrase)
			spawn(respondWith.len + 10)	//Longer phrase longer response time plus 1 second for realism
				say("[respondWith]")
				if((mutation == FISH_CLOWN) && (prob(20)))
					say("Honk!")
			inConversation = TRUE
	if(inConversation)
		var/replyWith = pick(responsePhrase)
		spawn(replyWith.len +10)
			say("[replyWith]")
			if((mutation == FISH_CHATTY) && (prob(20))
				var/replyAgain = pick(responsePhrase)
				say("also, [replyAgain]")
			if((mutation == FISH_CLOWN) && (prob(20)))
				say("Honk!")
		spawn(5 SECONDS)
			for(chatMan in orange(4))	//Did he leave?
				return
			inConversation = FALSE

/mob/living/simple_animal/hostile/fishing/Change-ling/attack_hand(mob/user)
	if((!shapeShifted) || (is_type_in_list(user, friends)))
		..()
		return
	if(ishuman(user))
		var/mob/living/carbon/human/theRube = user
	theRube.Knockdown(catchSize/10)
	theRube.Stun(catchSize/10)
	if(Adjacent(theRube))
		unarmedAttack(theRube)
	if(shapeShifted == 2)
		crewShift(theRube)
		wander = 1
		spawn(5)
			var/list/helpCalls = list(
			"Help! We've got a shapeshifter!",
			"Trying to replace me? Help!",
			"Ah! Clone, help! Help!",
			"Security! Help me, there's a shapeshifter!",
			"Clone! Help! Help me!",
			"Someone help, he's trying to impersonate me!",
			"We've got an identity thief, help!",
			"I got him! I got the guy shapeshifting into people!",
			)
			say(pick(helpCalls))
		if(mutation == (ILLUSIONARY | HAUNTING))
			var/list/secondMimic = list()
			for(var/mob/living/carbon/human/M in mob_list)
				secondMimic += M
			var/mob/living/simple_animal/hostile/fishing/fishlusion/F = new /mob/living/simple_animal/hostile/fishing/fishlusion(src)
			var/mob/living/backUpMimic = pick(secondMimic)
			F.fishMimic(backUpMimic)
			var/image/I = image('icons/effects/32x32.dmi', "blank")
			I.overlays |= backUpMimic.overlays
			F.try_move_adjacent(src)
			spawn(2 SECONDS)
				say("Help! We've caught a shapeshifter!")
			spawn(catchSize/2 SECONDS)
				animate(F, alpha = 0, time = 1 SECONDS)
				qdel(F)

//Meel///////
/mob/living/simple_animal/hostile/fishing/meel
	name = "meel"
	desc = "Many starving and void-stranded space anglers owe their lives to these egg laying creatures. In life their unique protein structure is in a constant state of flux, which is halted upon their death. This trait allows meel butchery to produce nearly any type of meat imaginable, and some unimaginable."
	icon_state = "meel"
	icon_living = "meel"
	icon_dead = "meel_dead"
	meat_amount = 1
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/meel
	melee_damage_lower = 5
	melee_damage_upper = 15
	maxHealth = 35
	health = 35
	minCatchSize = 15
	maxCatchSize = 25
	illegalMutations = list()
	tameItem = list()
	var/meelopause = 0		//This is a good variable name and I'm proud of it

/mob/living/simple_animal/hostile/fishing/meel/New()
	..()
	if(gender == MALE)
		meat_amount = catchSize/5
	if(gender == FEMALE)
		meelopause = catchSize
		if(mutation == FISH_ROYAL | FISH_SPLITTING)
			meelopause = catchSize*2

/mob/living/simple_animal/hostile/fishing/meel/Life()
	..()
	if(gender == FEMALE)
		if(prob(meelopause/10))
			meelEggLay()

/mob/living/simple_animal/hostile/fishing/meel/proc/meelEggLay()
	stun(3)
	spawn(10)
		playsound(src, 'sound/effects/splat.ogg', 50, 1)
		var/mob/living/simple_animal/hostile/fishing/meel/meelMate = null
		for(/mob/living/simple_animal/hostile/fishing/meel/M in orange(2))
			if(M.gender == MALE)
				meelMate = M
		if(meelMate)
			var/obj/item/weapon/reagent_containers/food/snacks/egg/meel/fertile/E = new /obj/item/weapon/reagent_containers/food/snacks/egg/meel/fertile(src.loc)
		else
			var/obj/item/weapon/reagent_containers/food/snacks/egg/meel/E = new /obj/item/weapon/reagent_containers/food/snacks/egg/meel(src.loc)
		new /obj/effect/decal/cleanable/egg_smudge(src.loc)
		meelopause--
		if(mutation)
			switch(mutation)
				if(FISH_CLOWN)
					E.mutantIngredient = HONKSERUM
				if(FISH_POISON)
					E.mutantIngredient = CARPOTOXIN
				if(FISH_GLOWING)
					E.mutantIngredient = LUMINOL
					E.ingredAmount = 1
				if(FISH_ILLUSIONARY)
					if(prob(50))
						E.remove_reagent(EGG_YOLK, 4)
						spawn(rand(30, 60))
							animate(E, alpha = 0, time = 1 SECONDS)
							qdel(E)
							meelopause++
				if(FISH_RADIOACTIVE)
					E.mutantIngredient = URANIUM
				if(FISH_EXPLODING)
					E.mutantIngredient = NITROGLYCERIN
					E.ingredAmount = 1
				if(FISH_CULT)
					E.mutantIngredient = BLOOD
					E.ingredAmount = 10
				if(FISH_ALCHEMIC)
					var/randgredient = pick(rainbowChems)
					E.mutantIngredient = randgredient
				if(FISH_GRAVITY)
					E.mutantIngredient = CORNOIL
					E.ingredAmount = 25
				if(FISH_ROYAL)
					var/royalIng = pick(ROYALJELLY, GOLD, SILVER)
					E.mutantIngredient = royalIng
				if(FISH_SPLITTING)
					if(isType(E, /obj/item/weapon/reagent_containers/food/snacks/egg/meel/fertile))
						E.babyChance = 5

/obj/item/weapon/reagent_containers/food/snacks/egg/meel
	name = "meel caviar"
	desc = "Although just as delicious as any other, meel caviar never caught on with the rich and powerful due to its abundance."
	icon_state = "meel_caviar"
	can_color = FALSE
	food_flags = FOOD_ANIMAL
	var/mutantIngredient = null
	var/ingredAmount = 5

/obj/item/weapon/reagent_containers/food/snacks/egg/meel/New()
	..()
	if(mutantIngredient)
		reagents.add_reagent(mutantIngredient, rand(0,ingredAmount))

/obj/item/weapon/reagent_containers/food/snacks/egg/meel/fertile
	var/babyChance = 1

/obj/item/weapon/reagent_containers/food/snacks/egg/meel/fertile/New()
	if(prob(babyChance))
		spawn(rand(60, 300))
			new /mob/living/simple_animal/hostile/fishing/meel(src.loc)
			qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/meat/meel/New()
	var/meelForm = null
	if(prob(1))
		meelForm = pick(existing_typesof(/obj/item/weapon/reagent_containers/food/snacks/meat))	//Roughly 0.08% chance of wendigo meat
	meelForm = pick(meelMeats)
	new meelForm(src.loc)
	qdel(src)


//Fermurtle/////////
/mob/living/simple_animal/hostile/fishing/fermurtle
	name = "keggerhead fermurtle"
	desc = ""
	icon_state = "fermurtle"
	icon_living = "fermurtle"
	icon_dead = "fermurtle"
	turns_per_move = 15	//slow boy
	size = SIZE_NORMAL
	attacktext = "bites"
	faction = "neutral"
	melee_damage_lower = 10
	melee_damage_upper = 15
	maxHealth = 100
	health = 100
	minCatchSize = 30
	maxCatchSize = 50
	tameEase = 50
	healEat = TRUE
	healMin = 10
	healMax = 20
	illegalMutations = list()
	tameItem = list(/obj/item/weapon/reagent_containers/food/drinks, /obj/item/weapon/reagent_containers/glass)
	var/datum/seed/shellPlant = null
	var/shellPlantGrowth = 0
	var/obj/item/weapon/fermurtleKeg/turtKeg = null
	var/list/datum/reagent/kegReg = null
	var/list/regAmount = null
	var/kegState = null
	var/marinateAmount = 0

	#define TURT_GROWING 1
	#define TURT_FILLING 2

/mob/living/simple_animal/hostile/fishing/fermurtle/New()
	..()
	maxHealth += catchSize	//It's a turtle
	health = maxHealth
	turtKeg = new /obj/item/weapon/reagent_containers/glass/fermurtleKeg(src.loc)
	turtKeg.volume = catchSize*5
	turtKeg.forceMove(src)

/mob/living/simple_animal/hostile/fishing/fermurtle/fishFeed(obj/F, mob/user)
	var/obj/item/weapon/reagent_containers/D = F
	if((D.reagents)
		var/healthyGulp = 0
		for(var/r in D.reagents)
			if(istype(r, /datum/reagent/ethanol)
				healthyGulp += r.volume
				D.reagents.remove(r, r.volume)
		if(healthyGulp)
			health = min(maxHealth, health + healthyGulp/2)
			if((healthyGulp >= catchSize/2) && ((prob(tameEase)) && (!beenTamed)))	//Bigger boy thirstier boy, makes it so you can't tame with 1u beer
				fishTame()

/mob/living/simple_animal/hostile/fishing/fermurtle/Life()
	..()
	if(shellPlant)
		plantKegTime()

/mob/living/simple_animal/hostile/fishing/fermurtle/proc/plantKegTime()
	var/kegChance = health*0.1
		if(mutation == (FISH_FAST | FISH_TIME))
			kegChance *= 2
		if(prob(kegChance))
			switch(kegState)	//short version is if you feed your turtle beer to heal him he'll produce faster.
				if(TURT_GROWING)
					shellPlantGrowth++
					update_icon()
					health -= maxHealth*0.20
					if(shellPlantGrowth >= 3)
						kegState = TURT_FILLING
				if(TURT_FILLING)
					if(!turtKeg.is_full())
						kegFill()
					marinateAmount++

/mob/living/simple_animal/hostile/fishing/fermurtle/proc/kegFill()
	var/halfsies = rand(0,1)	//To decide if you get 1 or 0u from low reagent amounts
	for(var/i in kegReg)
		var/space = turtKeg.reagents.maximum_volume - turtKeg.reagents.total_volume
		var/amount = round(regAmount[i]/2, halfsies)
		turtKeg.reagents.add(i, min(amount, space)	//We go through every reagent in our list, find the corresponding amount then half it. That's how much we get per keg proc
		if(mutation)
			var/mutReg = null
			var/mutAmo = 5
			switch(mutation)
				if(FISH_CLOWN)
					mutReg = pick(BANANA, HONKSERUM) //Fuck mime curse
				if(FISH_CULT)
					mutreg = BLOOD
				if(FISH_ROYAL)
					mutreg = GOLD
				if(FISH_GLOWING)
					mutreg = LUMINOL
				if(FISH_GRAVITY)
					mutreg = CHEESYGLOOP
				if(FISH_POISON)
					mutreg = TOXIN
				if(FISH_RADIOACTIVE)
					mutreg = pick(RADIUM, URANIUM)
				if(FISH_CHATTY)
					mutreg = PICCOLYN
			space = turtKeg.reagents.maximum_volume - turtKeg.reagents.total_volume
			turtKeg.reagents.add(mutReg, min(mutAmo, space)

/mob/living/simple_animal/hostile/fishing/fermurtle/attackby(var/obj/item/P, var/mob/user)
	..()
	if(istype(P, /datum/seed) && !isDead())
		var/datum/seed/tS = P
		if(shellPlant))
			to_chat(user, "The [src] is already growing something.")
			return
		if(tS.products.len != 1) || (!istype(tS.products[1], /obj/item/weapon/reagent_containers/food/snacks/grown))	//Turtle can't juice Dionas
			to_chat(user, "The products aren't compatible with [src] biology.")
			return
		plantInShell(tS)

/mob/living/simple_animal/hostile/fishing/fermurtle/proc/plantInShell(var/datum/seed/S)
	var/obj/item/weapon/reagent_containers/food/snacks/grown/G = S.products[1]
	shellPlant = S
	if(is_type_in_list(G, juice_items))
		var/jType = getJuiceType (G)	//First we simulate the fruit growing in the turtle, juice comes out.
		var/jAmount = getJuiceAmount(S)
		kegReg += jType		//Lists are for use with index to match the amount to the reagent.
		regAmount += jAmount
	for(var/sR in S.chems)
		if(sR != NUTRIMENT)	//Not trying to put the chef out of business and it would be inconvenient for the bartender. Turtle eats it or whatever.
			var/list/reagent_data = S.chems[sR]
			var/rTotal = reagent_data[1]
			if((reagent_data.len >1) && (potency > 0))
				rtotal += round(potency/reagent_data[2])
			kegReg += sR
			regAmount += rtotal		//Same equation for potency -> chems used when growing fruit in a tray.

/mob/living/simple_animal/hostile/fishing/fermurtle/proc/getJuiceType(var/obj/item/weapon/reagent_containers/food/snacks/T)
	for(var/i in juice_items)	//Stolen directly from reagent grinders
		if(istype(T, i))
			return juice_items[i]

/mob/living/simple_animal/hostile/fishing/fermurtle/proc/getJuiceAmount(var/datum/seed/J)
	if (J.potency == -1)		//Thank you reagent grinder
		return 5
	else
		if(mutation == RADIOACTIVE)
			J.potency *= 1.2
		return round(5*sqrt(O.potency))

/mob/living/simple_animal/hostile/fishing/fermurtle/update_icon()
	//*****figure out how the fuck this works***********

/mob/living/simple_animal/hostile/fishing/fermurtle/examine(mob/user)
	..()
	to_chat(user, "The [src] appears to have some [shellPlant.product[1].name] growing on its shell.")
	if(mutation == TRANSPARENT)
		to_chat(user, "You can see its shell has about [turtKeg.reagents.total_volume]u of juice stored.")

/mob/living/simple_animal/hostile/fishing/fermurtle/drop_meat(location)
	..()
	M.marinated = marinateAmount


	#undef GROWING
	#undef FILLING
	#undef FERMENTING

/obj/item/weapon/reagent_container/glass/fermurtleKeg
	name = "fermurtle shell"
	desc = "The shell of a barrelhead fermurtle. It's quite hefty. Would make a kingly mug with the right handle."
	icon_state = "fermurtle_shell"
	w_class = W_CLASS_MEDIUM
	volume = 50
	mech_flags = MECH_SCAN_FAIL
	opaque = TRUE

/obj/item/weapon/reagent_container/glass/fermurtleKeg/attackby(/obj/item/S, mob/user)
	if(istype(W, /obj/item/stack/sheet/mineral/gold || /obj/item/stack/sheet/mineral/silver || /obj/item/stack/sheet/mineral/mythril))
		var/obj/item/stack/sheet/tMat = S
		if(tMat.use(5))
			to_chat(user,"<span class='notice'>The shell has been given a handle.</span>")
			var/obj/item/weapon/reagent_container/glass/fermurtleKeg/kinglyTankard/kt = new /obj/item/weapon/reagent_container/glass/fermurtleKeg/kinglyTankard(src.loc)
			/obj/item/weapon/reagent_container/glass/kinglyTankard.volume = volume
			reagents.trans_to(kt, reagents.total_volume)
			qdel(src)
			user.put_in_hands(kt)

/obj/item/weapon/reagent_container/glass/fermurtleKeg/kinglyTankard
	name = "kingly tankard"
	desc = "Larger than a grown man's head and adorned with precious metals, this tankard created from the shell of a fermurtle is truly luxurious. Just looking at it makes you thirsty."
	icon_state = "fermurtle_kingly_tankard"
	volume = 50

/obj/item/weapon/reagent_containers/food/snacks/meat/fermurtle
	name = "fermurtle meat"
	desc = "Meat from a keggerhead fermurtle."
	icon_state = "meat"
	var/marinated = 0


/obj/item/weapon/reagent_containers/food/snacks/meat/fermurtle/New()
	..()
	if(marinated > 150) //Very roughly 15-25 minute old fermurtle
		name = "fermurtle jewel meat"
		desc = "Jewel meat from a keggerhead fermurtle. Fermurtles quite literally spend their entire lives marinating themselves. The meat of long lived fermurtles was dubbed 'jewel meat' for its gem-like glisten. Jewel meat is impossibly delicious and when prepared by a skilled chef has been known to bring grown spacemen to tears."
		icon_state = "fermurtle_jewel_meat"

/datum/organ/internal/liver/fermurtle
	name = "fermurtle liver"
	removed_type = /datum/organ/internal/liver/fermurtle

/datum/organ/internal/liver/fermurtle/process()
	..()
	for(var/datum/reagent/eth in owner.reagents.reagent_list)
		if(istype(eth, /datum/reagent/ethanol))
			owner.adjustFireLoss(-1)
			owner.adjustBruteLoss(-1)
			owner.reagents.add_reagent(NUTRIMENT, 1)

//Hermit crab////////
/mob/living/simple_animal/hostile/fishing/carry_crab
	name = "carry crab"
	desc = ""
	icon_state = "carry_crab"
	icon_living = "carry_crab"
	icon_dead = "carry_crab_dead"
	melee_damage_type = BRUTE
	size = SIZE_NORMAL
	attacktext = list("snips", "snaps", "claws", "pinches")
	faction = "neutral"
	melee_damage_lower = 20
	melee_damage_upper = 25 //Snibbity snab, these snibs and snabs are harder because it doesn't have a crate.
	search_objects = 1
	minCatchSize = 30
	maxCatchSize = 60
	tameItem = list()
	tameEase =
	healEat = TRUE
	var/obj/structure/reagent_dispensers/cauldron/barrel/crabCauldron = null
	var/obj/structure/closet/crate/crabCrate = null
	var/crabHome = FALSE

	wanted_objects = list(/obj/structure/closet/crate, /obj/structure/reagent_dispensers/cauldron/barrel)
	var/list/badCrateForCrab = list()

/datum/locking_category/carry_crab

/mob/living/simple_animal/hostile/fishing/carry_crab/New()
	..()
	if(prob(10))
		crabToWinLootCrate()

/mob/living/simple_animal/hostile/fishing/carry_crab/proc/crabToWinLootCrate()
	crabHome = TRUE
	crabCrate = /obj/structure/closet/crate/sunkenChest
	//Add things from the salvage loot table, maybe item fish too

/mob/living/simple_animal/hostile/fishing/carry_crab/attack_hand(mob/user)
	..()
	if(crabCrate)
		if((beenTamed) && (is_type_in_list(user, friends))
			if(!crabCrate.opened)
				crabCrate.open()
				return
			if(crabCrate.opened)
				crabCrate.close()
		else
			UnarmedAttack(user)
			to_chat(user, "<span class ='warning'>The [src] snaps its claw at you. It doesn't want you touching its home!</span>")


/mob/living/simple_animal/hostile/fishing/carry_crab/attackby(obj/R, mob/user)
	..()
	if(istype(R, /obj/item/weapon/reagent_containers/glass) && crabCauldron)
		var/obj/item/weapon/reagent_containers/glass/G = R
		if(G.is_empty())
			if(crabCauldron.is_empty())
				to_chat(user, "<span class ='notice'>The [crabCauldron] is empty.</span>")
			else
				crabCauldron.trans_to

/mob/living/simple_animal/hostile/fishing/carry_crab/AttackingTarget()
	if(is_type_in_list(target, wanted_objects))
		if(is_type_in_list(target, badCrateForCrab) || crabHome || !isturf(target.loc))
			loseTarget()
			return
		visible_message("The [src] scuttles excitedly and snips its claws at \the [target]!")
		crabNewHome(target)

/mob/living/simple_animal/hostile/fishing/proc/crabNewHome(target)
	if(target.anchored)
		visible_message("The [src] cannot move \the [target] and snaps its claws in frustration!")
		loseTarget()
		return
	if(istype(target, /obj/structure/closet/crate))
		if(istype(target, /obj/structure/closet/crate/secure))
			var/obj/structure/closet/crate/secure/L = target
			if(L.locked)
				visible_message("The [src], unable to pry open \the [L] begins snapping its claws in disappointment!")
				loseTarget()
				return
		crabCrate = target
		crabClaimCrate()
	if(istype(target, /obj/structure/reagent_dispensers/cauldron))
		crabCauldron = target
		crabClaimCauldron()

/mob/living/simple_animal/hostile/fishing/proc/crabClaimCrate()
	crabCrate.open(src)
	crabCrate.storage_capacity -= catchSize/3	//Bigger crab takes up more space
	lock_atom(C, /datum/locking_category/carry_crab)
	crabUpdate()

/mob/living/simple_animal/hostile/fishing/proc/crabClaimCauldron()
	for(var/atom/movable/A in crabCauldron)
		if(ismob(A))
			UnarmedAttack(A)
		A.forcemove(crabCrate.loc)
		visible_message("The [src] yanks \the [A] out of the [crabCauldron]!")
	lock_atom(C, /datum/locking_category/carry_crab)
	crabUpdate()


/mob/living/simple_animal/hostile/fishing/proc/crabUpdate
	if(crabHome)
		melee_damage_lower = 5
		melee_damage_upper = 10 //The crab has been calmed by his cozy house
		maxHealth = 100	//Crates have 100 health
		health = 100
		search_objects = 0
	if(!crabHome)
		melee_damage_lower = 20
		melee_damage_upper = 25
		health = 25
		maxhealth = 25
		faction = "hostile"


///mob/living/simple_animal/hostile/fishing/carry_crab/proc/openCrab()
//	for(var/obj/O in src)
//		O.forceMove(src.loc)

///mob/living/simple_animal/hostile/fishing/carry_crab/proc/closeCrab()
//	var/turf/T = get_turf(src)
//	for(var/obj/item/i in T)
//		if(contents.len >= crabPacity)
//			break
//		if((i.anchored) || (i.density))
//			return
//		i.forceMove(src)

/mob/living/simple_animal/hostile/fishing/carry_crab/death(var/gibbed = FALSE)
	if(crabHome)
		if(crabCrate)
			crabCrate.dump_contents()
			qdel(crabCrate)
			crabCrate = null
		if(crabCauldron)
			if(crabCauldron.reagents)
				var/cDivide = 0
				for(var/atom/A in range(1))
					cDivide += 1
				var/C = (crabCauldron.reagents.total_volume/cDivide, 1)
				for(var/atom/S in range(1))
					if(crabCauldron.reagents.total_volume < 1)
						break
					splash_sub(crabCauldron.reagents, S, C)
			crabCauldron = null
		crabHome = null
		crabUpdate()
	else
		..()





//smelt//////

//Brigmouth Bass//////

//Whale satellite//////


//Fishlusion/////
/mob/living/simple_animal/hostile/fishing/fishlusion
	name = ""
	desc = ""
	icon_state = ""
	icon_living = ""
	faction = "hostile"
	melee_damage_lower = 0
	melee_damage_upper = 0
	canMutate = FALSE


/mob/living/simple_animal/hostile/fishing/fishlusion/proc/fishMimic(var/mob/living/simple_animal/hostile/M)
	name = M.name
	icon_state = M.icon_state
	desc = M.desc
	maxHealth = M.maxHealth
	health = M.health
	faction = M.faction
	friends = M.friends
