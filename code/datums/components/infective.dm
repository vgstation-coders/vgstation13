/datum/component/infective
	dupe_mode = COMPONENT_DUPE_ALLOWED
	var/list/datum/disease/diseases //make sure these are the static, non-processing versions!
	var/expire_time
	var/min_clean_strength = CLEAN_WEAK

/datum/component/infective/Initialize(list/datum/disease/_diseases, expire_in)
	if(islist(_diseases))
		diseases = diseases
	else
		diseases = list(_diseases)
	if(expire_in)
		expire_time = world.time + expire_in
		QDEL_IN(src, expire_in)
	RegisterSignal(COMSIG_MOVABLE_BUCKLE, .proc/try_infect_buckle)
	RegisterSignal(COMSIG_MOVABLE_COLLIDE, .proc/try_infect_collide)
	RegisterSignal(COMSIG_MOVABLE_CROSSED, .proc/try_infect_crossed)
	RegisterSignal(COMSIG_ITEM_ATTACK_ZONE, .proc/try_infect_attack_zone)
	RegisterSignal(COMSIG_ITEM_ATTACK, .proc/try_infect_attack)
	RegisterSignal(COMSIG_ITEM_EQUIPPED, .proc/try_infect_equipped)
	RegisterSignal(COMSIG_MOVABLE_IMPACT_ZONE, .proc/try_infect_impact_zone)
	RegisterSignal(COMSIG_FOOD_EATEN, .proc/try_infect_eat)
	RegisterSignal(COMSIG_COMPONENT_CLEAN_ACT, .proc/clean)

/datum/component/infective/proc/try_infect_eat(mob/living/eater, mob/living/feeder)
	for(var/V in diseases)
		eater.ForceContractDisease(V)
	try_infect(feeder, BODY_ZONE_L_ARM)

/datum/component/infective/proc/clean(clean_strength)
	if(clean_strength >= min_clean_strength)
		qdel(src)

/datum/component/infective/proc/try_infect_buckle(mob/M, force)
	if(isliving(M))
		try_infect(M)

/datum/component/infective/proc/try_infect_collide(atom/A)
	var/atom/movable/P = parent
	if(P.throwing)
		//this will be handled by try_infect_impact_zone()
		return
	if(isliving(A))
		try_infect(A)

/datum/component/infective/proc/try_infect_impact_zone(mob/living/target, hit_zone)
	try_infect(target, hit_zone)

/datum/component/infective/proc/try_infect_attack_zone(mob/living/carbon/target, mob/living/user, hit_zone)
	try_infect(user, BODY_ZONE_L_ARM)
	try_infect(target, hit_zone)

/datum/component/infective/proc/try_infect_attack(mob/living/target, mob/living/user)
	if(!iscarbon(target)) //this case will be handled by try_infect_attack_zone
		try_infect(target)
	try_infect(user, BODY_ZONE_L_ARM)

/datum/component/infective/proc/try_infect_equipped(mob/living/L, slot)
	var/old_permeability
	if(isitem(parent))
		//if you are putting an infective item on, it obviously will not protect you, so set its permeability high enough that it will never block ContactContractDisease()
		var/obj/item/I = parent
		old_permeability = I.permeability_coefficient
		I.permeability_coefficient = 1.01

	try_infect(L, slot2body_zone(slot))

	if(isitem(parent))
		var/obj/item/I = parent
		I.permeability_coefficient = old_permeability

/datum/component/infective/proc/try_infect_crossed(atom/movable/M)
	if(isliving(M))
		try_infect(M, BODY_ZONE_PRECISE_L_FOOT)

/datum/component/infective/proc/try_infect(mob/living/L, target_zone)
	for(var/V in diseases)
		L.ContactContractDisease(V, target_zone)
