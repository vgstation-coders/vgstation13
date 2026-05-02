//things that try to kill you.
var/list/junglemobs_hostile=list(
	/mob/living/simple_animal/complex/dinosaur,
	/mob/living/simple_animal/complex/panther,
	/mob/living/simple_animal/complex/bear,
)


//things that won't attack you
var/list/junglemobs_passive=list(
/mob/living/simple_animal/complex/frog,
/mob/living/simple_animal/complex/frog/poison,
/mob/living/simple_animal/complex/parrot,
/mob/living/carbon/monkey,
)
//they don't kill you, but also are less frequent. capy bappies are here because the pacify aura is quite strong and funny. so we limit that, because we HATE fun.
var/list/junglemobs_passive_rare=list(
/mob/living/simple_animal/complex/capybara_wild,
)

//any wildlife, be it fren-shaped or not.
/obj/abstract/map/spawner/jungle_any
	icon_state="jungle_mob_random"

/obj/abstract/map/spawner/jungle_any/New()
	var/rng=rand()
	if(rng < 0.65) //65% chance of friendly mobs
		amount=rand(3,6)
		if(prob(20)) //20% chance for rare (13% overall)
			amount = rand(1,2)
			to_spawn = pick(junglemobs_passive_rare)
		else
			to_spawn = pick(junglemobs_passive)
	else
		amount=rand(2,5)
		to_spawn = pick(junglemobs_hostile)
		if(to_spawn==/mob/living/simple_animal/complex/panther) //being carnivores only, they need a bit of help to get the population ball rolling. also they spread out a lot.
			amount+=2
	..()


//random peaceful wildlife. :)
/obj/abstract/map/spawner/jungle_fren
	icon_state="jungle_mob_fren"
	
/obj/abstract/map/spawner/jungle_fren/New()
	amount=rand(3,6)
	if(prob(20))
		to_spawn = pick(junglemobs_passive_rare)
		amount = rand(1,2)
	else
		to_spawn = pick(junglemobs_passive)
	..()


//random hostile wildlife. >:(
/obj/abstract/map/spawner/jungle_hostile
	icon_state="jungle_mob_hostile"
	
/obj/abstract/map/spawner/jungle_hostile/New()
	amount=rand(3,6)
	to_spawn = pick(junglemobs_hostile)
	..()
