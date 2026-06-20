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

//how many mobs we want to exist on junga
var/alist/spawn_targets=alist(
	/mob/living/simple_animal/complex/dinosaur=35,
	/mob/living/simple_animal/complex/panther=35,
	/mob/living/simple_animal/complex/bear=40,
	/mob/living/simple_animal/complex/crocodile=15,
	/mob/living/simple_animal/complex/frog=10,
	/mob/living/simple_animal/complex/frog/poison=10,
	/mob/living/simple_animal/complex/parrot=15,
	/mob/living/simple_animal/complex/capybara_wild=6,
)

//any wildlife, be it fren-shaped or not.
/obj/abstract/map/spawner/jungle_any
	icon_state="jungle_mob_random"
	var/spawn_periodically=TRUE
	var/ticker=0

/obj/abstract/map/spawner/jungle_any/New()
	if(spawn_periodically)
		processing_objects+=src
	var/rng=rand()
	if(rng < 0.65) //65% chance of friendly mobs
		amount=rand(3,4)
		if(prob(20)) //20% chance for rare (13% overall)
			amount = rand(1,2)
			to_spawn = pick(junglemobs_passive_rare)
		else
			to_spawn = pick(junglemobs_passive)
	else
		amount=rand(3,4)
		to_spawn = pick(junglemobs_hostile)
	..()

/obj/abstract/map/spawner/jungle_any/process()
	ticker++
	if(ticker%10!=0 || prob(75) ) //25% chance to fire every 10 ticks. ensures it won't happen a whole lot, and will randomize locations a bit
		return
	for(var/mob/M in range(7)) //do not spawn if we're being observed
		if(M.client)
			return
	var/alist/current_mob_counts=alist()
	for(var/mob/M in mob_list) //count all mobs
		current_mob_counts[M.type]=(current_mob_counts[M.type] || 0) +1
	for(var/path,target in spawn_targets) //check if they're under our target
		if (current_mob_counts[path]<target)
			var/tospawn=target - current_mob_counts[path] //how many behind the target we are
			tospawn = max(3,min(5,floor(tospawn/2) )) //do some scaling to try to spawn them with a group with an acceptable size. this will result in some over and undershoots, but that's ok.
			while(tospawn--)
				new path(src.loc)
			return
		
//random peaceful wildlife. :)
/obj/abstract/map/spawner/jungle_fren
	icon_state="jungle_mob_fren"
	
/obj/abstract/map/spawner/jungle_fren/New()
	amount=rand(3,5)
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
	amount=rand(3,5)
	to_spawn = pick(junglemobs_hostile)
	..()
