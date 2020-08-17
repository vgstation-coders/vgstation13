
var/bees_count = 0

/datum/bee
	var/mob/living/simple_animal/bee/mob = null
	var/obj/machinery/apiary/home = null
	var/damage = 1//the brute damage dealt by a sting. Set when leaving the hive (spawning).
	var/toxic = 0//the extra toxic damage dealt by a sting. Set when leaving the hive (spawning).
	var/health = 10
	var/maxHealth = 10
	var/list/pollens = list()//flowers (seed_datums) that were pollinated by that bee
	var/state = BEE_ROAMING
	var/fatigue = 0//increases after a successful pollination or when searching for flowers in vain
	var/bored = 0//increases when searching for enemies in vain
	var/exhaustion = 0//increases when roaming without a queen
	var/corpse = /obj/effect/decal/cleanable/bee
	var/toxins = 0
	var/datum/bee_species/species = null

//When a bee leaves the hive, it takes on the hive's damage and toxic values
/datum/bee/New(var/obj/machinery/apiary/spawner = null)
	..()
	if(!bees_species[BEESPECIES_NORMAL])
		initialize_beespecies()
	bees_count++
	species = bees_species[BEESPECIES_NORMAL]
	if (spawner)
		home = spawner
		damage = spawner.damage
		toxic = spawner.toxic

//call to make bees go look out for plants
/datum/bee/proc/goPollinate()
	state = BEE_OUT_FOR_PLANTS
	mob.updateState = 1

//call to make bees go look out for kills. angry bees are red-eyed.
/datum/bee/proc/angerAt(var/mob/M = null)
	if (state == BEE_SWARM)
		return
	state = BEE_OUT_FOR_ENEMIES
	mob.target = M
	mob.updateState = 1

//call to make bees go home. Hive-less bees never calm down
/datum/bee/proc/homeCall()
	if (home)
		state = BEE_HEADING_HOME
		mob.updateState = 1
	else
		fatigue = 0
		bored = 0
		state = BEE_ROAMING
		mob.updateState = 1

/datum/bee/proc/death(var/gibbed = FALSE)
	if (mob)
		new corpse(get_turf(mob))
	qdel(src)

/datum/bee/Destroy()
	bees_count--
	if (mob)
		mob.bees.Remove(src)
		mob = null
	if (home)
		home.bees_outside_hive -= src
		home = null
	..()

//QUEEN BEE
/datum/bee/queen_bee
	health = 15
	maxHealth = 15
	corpse = /obj/effect/decal/cleanable/bee/queen_bee
	var/colonizing = 0
	var/searching = 0//only attempt building our own hive once we've searched for a while already.

/datum/bee/queen_bee/proc/setHome(var/obj/machinery/apiary/A)
	state = BEE_SWARM
	colonizing = 1
	mob.destination = A
	mob.updateState = 1

/proc/initialize_beespecies()
	for(var/x in typesof(/datum/bee_species))
		var/datum/bee_species/species = new x
		bees_species[species.common_name] = species
