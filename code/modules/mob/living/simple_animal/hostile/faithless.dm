/mob/living/simple_animal/hostile/faithless
	name = "The Faithless"
	desc = "A being of shadow. It posesses a menacing gaze and a tortured voice."
	icon_state = "faithless"
	icon_living = "faithless"
	icon_dead = "faithless_dead"
	speak_chance = 0
	turns_per_move = 5
	response_help = "passes through"
	response_disarm = "shoves"
	response_harm = "hits"
	speed = 1
	maxHealth = 80
	health = 80
	can_butcher = 0

	mob_property_flags = MOB_SUPERNATURAL
	harm_intent_damage = 10
	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "grips"
	attack_sound = 'sound/hallucinations/growl1.ogg'

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	speed = 5

	supernatural = TRUE

	faction = "faithless"

	blooded = FALSE

/mob/living/simple_animal/hostile/faithless/Process_Spacemove(var/check_drift = 0)
	return 1

/mob/living/simple_animal/hostile/faithless/ai_target_acquired(atom/target)
	if(target)
		emote("me",,"wails at [target]!")

/mob/living/simple_animal/hostile/faithless/AttackingTarget()
	. =..()
	var/mob/living/L = .
	if(istype(L))
		if(prob(12))
			L.Knockdown(3)
			L.Stun(3)
			L.visible_message("<span class='danger'>\The [src] knocks down \the [L]!</span>")

/mob/living/simple_animal/hostile/faithless/cult
	faction = "cult"

/mob/living/simple_animal/hostile/faithless/cult/CanAttack(var/atom/the_target)
	//IF WE ARE CULT MONSTERS (those who spawn after Nar-Sie has risen) THEN WE DON'T ATTACK CULTISTS
	if(ismob(the_target))
		var/mob/M = the_target
		if(isanycultist(M))
			return 0
	return ..(the_target)

/mob/living/simple_animal/hostile/faithless/cult/cultify()
	return


