/mob/living/simple_animal/hostile/fishing
	name = ""
	desc = ""
	icon =
	icon_state = ""
	icon_living = ""
	icon_dead = ""
	speak_emote = list("glubs", "bubbles", "chirps") //I guess?
	speak_chance = 0
	turns_per_move = 5
	speed = 1
	environment_smash_flags = 0
	melee_damage_type = BRUTE
	size = SIZE_SMALL
	attacktext = "bites"
	faction = "neutral"
	melee_damage_lower = 1
	melee_damage_upper = 5
	maxHealth = 50
	health = 50


	var/catchSize = 0 //Decides different mechanics for different fish, bigger is usually stronger. Can be thought of similar to botany potency.

	var/datum/angler_mutation/mutation = null
	var/mutantPower = 5 //Used for deciding probability of some mutations triggering and their power/range. Should be kept lower than 10ish or things get stupid.
	var/mutateCooldown = 600	//Generic cooldown for mutations like EMP and illusion. 60 second default. Changed by mutation type.
	var/lastMutActivate = 0
	var/specMutateTrigger = FALSE //Use on New() with specific mutations to turn off the normal mutation triggers like death or aggro and give them special ones.
	var/isLiar = FALSE	//For the liar mutation when scanning mutations
	var/canMutate = TRUE //Ability to mutate at all. Can turn off for things like special spawns.
	var/list/illegalMutations = list() //What mutations will break the mob, prevents them from being rolled

	var/list/tameItem = list() //What items they'll accept to tame them.
	var/tameEase = 0 //Percentage. Lower is harder.
	var/beenTamed = FALSE
	var/healEat = FALSE //If giving them their tame item heals them
	var/healMin = 5
	var/healMax = 15

	//var/datum/angler_analyzer_data/mobFish/analyzerData = null	//The associated datum for use with the angler analyzer.

/mob/living/simple_animal/hostile/fishing/New()
	..()
	catchSize = rand(minCatchSize, maxCatchSize)
	genderPick()

/mob/living/simple_animal/hostile/fishing/proc/updateFish()
	return

/mob/living/simple_animal/hostile/fishing/proc/genderPick()
	gender = pick(MALE, FEMALE)

/mob/living/simple_animal/hostile/fishing/attackby(obj/W, mob/user)
	..()
	if(tameItem.len)
		if(!stat && is_type_in_list(W, tameItem))
			fishFeed(W, user)

/mob/living/simple_animal/hostile/fishing/proc/fishFeed(var/obj/F, var/mob/user)
	if(user.drop_item(F))
		if(healEat)
			health = min(maxHealth, health + rand(healMin, healMax))
			to_chat(user, "<span class='info'>\The [src] looks a bit healthier.</span>")
		qdel(F)
		if(!beenTamed && prob(tameEase))
			fishTame(user)

/mob/living/simple_animal/hostile/fishing/fishTame(mob/user)
	beenTamed = TRUE
	friends += user
	to_chat(user, "<span class='info'>\The [src] seems to like you.</span>")
	var/image/heart = image('icons/mob/animal.dmi',src,"heart-ani2")
	heart.plane = ABOVE_HUMAN_PLANE
	flick_overlay(heart, list(user.client), 20)

/mob/living/simple_animal/hostile/fishing/Process_Spacemove(var/check_drift = 0)
	return TRUE
