/mob/living/simple_animal/hostile/fishing/star_drake
	name = "star drake"
	desc = "These crystalline skinned creatures begin life only a few inches tall but quickly grow to be larger than an adult spaceman. Their ability to grow so quickly is almost certainly due to their unique diet of live space carp."
	icon_state = "star_drake"
	icon_living = "star_drake"
	icon_dead = "star_drake_dead"
	meat_type =
	size = SIZE_BIG
	treadmill_speed = 5 //Something something horsepower
	melee_damage_lower = 15
	melee_damage_upper = 25
	minCatchSize = 75
	maxCatchSize = 130
	tameEase = 20
	possibleMutations = list()
	tameItem = list(/obj/item/weapon/holder/animal/carp)
	var/obj/structure/bed/chair/vehicle/star_drake/vehicleForm = null
	var/drakeBreed = null

/mob/living/simple_animal/hostile/fishing/star_drake/New()
	..()
	vehicleForm = new /obj/structure/bed/chair/vehicle/star_drake(src)
	vehicleForm.mobForm = src
	health = catchSize
	maxHealth = catchSize
	pickDrakeBreed()
	modifyDrakeBreed()

/mob/living/simple_animal/hostile/fishing/star_drake/proc/pickDrakeBreed()
	var/list/drakeBreeds = list(
		ruby = 20,
		emerald = 20,
		topaz = 20,
		amethyst = 20,
		redEyes = 5,
		blueEyes = 5,
	)
	drakeBreed = pickweight(drakeBreeds)

/mob/living/simple_animal/hostile/fishing/star_drake/proc/modifyDrakeBreed()
	switch(drakeBreed)
		if(ruby)
			icon_state = "star_drake_ruby"
		if(emerald)
			icon_state = "star_drake_emerald"
		if(topaz)
			icon_state = "star_drake_topaz"
		if(amethyst)
			icon_state = "star_drake_amethyst"
		if(redEyes)
			icon_state = "star_drake_redeyes"
			speed -= 0.1	//FAST
		if(blueEyes)
			icon_state = "star_drake_blueeyes"
			speed -= 0.1

/mob/living/simple_animal/hostile/fishing/star_drake/fishTame(mob/user)
	..()
	var/sDrakeNick = sanitize((input(user, "Give your star drake a nickname?", "Star drake nickname", 1, MAX_NAME_LEN)))
	vehicleForm.inheritSDrake()
	vehicleForm.gainMobFormTrait()
	if(sDrakeNick.len)
		vehicleForm.nick = sDrakeNick
	else if(prob(1))
		vehicleForm.nick = pick("Mystery", "Majesty", "Grace", "Debbie")
	else
		vehicleForm.nick = "Star Drake"
	mobForm.name = vehicleForm.nick

/mob/living/simple_animal/hostile/fishing/star_drake/fishFeed(var/obj/F, var/mob/user)
	..()
	vehicleForm.inheritSDrake()
	vehicleForm.carpFuel++	//Greedy mutation star drakes being paid for their services is intentional

/mob/living/simple_animal/hostile/fishing/star_drake/attack_hand(mob/user)
	..()
	if(beenTamed)
		if(!is_type_in_list(user, friends))
			to_chat(user, "<span class='warning'>\The [src] bucks as you try to mount it. It doesn't want you riding it.</span>")
			unarmed_attack(user)
			user.Knockdown(3)
			return
		sDrakeMount(user)

/mob/living/simple_animal/hostile/fishing/star_drake/proc/sDrakeMount(mob/user)
	vehicleForm.forceMove(loc)
	forceMove(vehicleForm)
	vehicleForm.buckle_mob(user, user)

/mob/living/simple_animal/hostile/fishing/star_drake/proc/inheritSDrake()
	maxHealth = vehicleForm.max_health
	health = vehicleForm.health

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
	max_health = mobForm.maxHealth
	health = mobForm.health

/obj/structure/bed/chair/vehicle/star_drake/proc/gainMobFormTrait()
	icon_state = mobForm.icon_state
	movement_delay = mobForm.speed
	sDrakeGainAbility()

/obj/structure/bed/chair/vehicle/star_drake/proc/sDrakeGainAbility()
	if(mobForm.catchSize > 100)
		vehicle_actions += /datum/action/vehicle/sDrakeAbility/gallop
	if(mobForm.mutation)
		switch(mobForm.mutation)
			if(FISH_ROUDY)
				vehicle_actions += /datum/action/vehicle/sDrakeAbility/sDrakeRoudyRide
	switch(mobForm.drakeBreed)
		if(redEyes)
			vehicle_actions += /datum/action/vehicle/sDrakeAbility/infernoFireBlast	//Time to d-d-d-d-d-d-duel
		if(blueEyes)
			vehicle_actions += /datum/action/vehicle/sDrakeAbility/burstStreamOfDestruction

/obj/structure/bed/chair/vehicle/star_drake/attackby(obj/item/W, mob/living/user)
	..()
	if(is_type_in_list(W, mobForm.tameItem)
		mobForm.fishFeed(W, user)
		mobForm.inheritSDrake()

/obj/structure/bed/chair/vehicle/star_drake/manual_unbuckle(user)
	..()
	mobForm.forceMove(loc)
	forceMove(mobForm)
	mobForm.inheritSDrake()

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
	var/mob/living/carbon/sDRider = Target.occupant
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


/datum/action/vehicle/sDrakeAbility/gallop
	name = "star drake gallop"
	desc = "Spur your star drake to gallop forward."
	sDrakeCD = 300
	cFuelUse = 1

/datum/action/vehicle/sDrakeAbility/gallop/Trigger()
	if(..())
		var/gDest = get_ranged_target_turf(get_turf(Target), Target.dir, 5)
		Target.throw_at(gDest, 5, 2)


/datum/action/vehicle/sDrakeAbility/sDrakeMutationActiv
	name = "Activate Mutation"
	desc = "Coax your star drake to activate its mutation."
	cFuelUse = 5

/datum/action/vehicle/sDrakeMutationActiv/Trigger()
	if(..())
		mobForm.mutation.mutateActivate()

/datum/action/vehicle/sDrakeAbility/sDrakeRoudyRide
	name = "Roudy Bronco"
	desc = "Spur your star drake to buck wildly, YeeHaw!"
	sDrakeCD = 15
	cFuelUse = 0

/datum/action/vehicle/sDrakeAbility/sDrakeRoudyRide/Trigger()
	if(..())
		spawn for(var/i=1, i<=8, i++)
			Target.dir = turn(Target.dir, 45)
		if(prob(40 - YeehawCheck()))
			Target.manual_unbuckle(sDRider)
			var/rDest = get_distant_turf(get_turf(Target), Target.dir, 3)
			sDRider.throw_at(rDest, 3, 10)
			sDRider.Knockdown(8)
		else
			visible_message("<span class='notice'>YeeHaw!</span>")


/datum/action/vehicle/sDrakeAbility/proc/YeehawCheck()
	var/Yeehaw = 0
	for(var/Y in yeehawAttire)
		if(sDRider.is_wearing_item(Y))
			Yeehaw += 10
	return Yeehaw

/datum/action/vehicle/sDrakeAbility/infernoFireBlast
	name = "inferno fire blast"
	desc = "Inflict damage to your opponent equal to your red eyes black drake's original attack. Red Eyes Black Drake cannot attack the turn you activate this ability."
	sDrakeCD = 150
	cFuelUse = 3

/datum/action/vehicle/sDrakeAbility/infernoFireBlast/Trigger()
	if(..())
		var//obj/item/weapon/gun/sDrake/energy/infernoFireBlast/IFBgun = new /obj/item/weapon/gun/sDrake/energy/infernoFireBlast(src)
		var/turf/T = get_ranged_target_turf(get_turf(target), target.dir, 10)
		IFBgun.Fire(T, sDRider)	//We make a gun, the mob inside the vehicle "fires" the gun. We delete the gun.	It seemed reasonable at the time.
		qdel(IFBgun)

/datum/action/vehicle/sDrakeAbility/burstStreamOfDestruction
	name = "burst stream of destruction"
	desc = "If you control a blue eyes white drake: destroy a wall your opponent controls. Blue eyes white drake cannot attack the turn you activate this ability."
	sDrakeCD = 300
	cFuelUse = 5

/datum/action/vehicle/sDrakeAbility/burstStreamOfDestruction/Trigger()
	if(..())
		var//obj/item/weapon/gun/sDrake/energy/burstStreamOfDestruction/BSODgun = new /obj/item/weapon/gun/sDrake/energy/burstStreamOfDestruction(src)
		var/turf/T = get_ranged_target_turf(get_turf(target), target.dir, 10)
		BSODgun.Fire(T, sDRider)
		qdel(IFBgun)

/obj/item/weapon/gun/energy/sDrake
	name = "sDrakeGunOrgan"
	desc = "You shouldn't see this"
	fire_sound = 'sound/weapons/lasercannonfire.ogg'
	charge_cost = 0
	ejectshell = 0
	clumsy_check = 0
	honor_check = 0
	advanced_tool_user_check = 0
	MoMMI_check = 0
	nymph_check = 0
	hulk_check = 0
	golem_check = 0

/obj/item/weapon/gun/sDrake/energy/infernoFireBlast
	projectile_type = "/obj/item/projectile/energy/infernoFireBlastProj"

/obj/item/weapon/gun/sDrake/energy/burstStreamOfDestruction
	projectile_type = "/obj/item/projectile/energy/burstStreamOfDestructionProj"

/obj/item/projectile/energy/infernoFireBlastProj
	name = "inferno fire blast"
	damage = 20		//Average of lower and upper drake attack. Good enough.

/obj/item/projectile/energy/infernoFireBlastProj/on_hit(var/atom/target, var/blocked = 0)
	if(isliving(target))
		var/mob/living/M = target
		M.adjust_fire_stacks(0.5)
		M.on_fire = 1
		M.update_icon = 1

/obj/item/projectile/burstStreamOfDestruction
	name = "burst stream of destruction"
	damage = 35

/obj/item/projectile/energy/burstStreamOfDestruction/on_hit(var/atom/target, var/blocked = 0)
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		C.Knockdown(2)
		C.Stun(2)
	if(istype(target, /turf/simulated/wall))
		var/turf/simulated/wall/W = target
		W.melt()
