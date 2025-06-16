//things that try to kill you.
var/list/junglemobs_hostile=list(
	/mob/living/simple_animal/hostile/giant_spider/jungle,
	/mob/living/simple_animal/hostile/bear/dinosaur,
	/mob/living/simple_animal/hostile/bear/panther,
	/mob/living/simple_animal/hostile/bear/brownbear/jungle,
)

//things that could kill you
var/list/junglemobs_dangerous=list(
/mob/living/simple_animal/hostile/lizard/frog/poison,
)

//things that won't kill you
var/list/junglemobs_safe=list(
/mob/living/simple_animal/hostile/lizard/frog,
/mob/living/simple_animal/parrot,
/mob/living/simple_animal/capybara/jungle,
)



//any wildlife, be it fren-shaped or not.
/obj/abstract/map/spawner/jungle_any
	icon_state="jungle_mob_random"

/obj/abstract/map/spawner/jungle_any/New()
	var/list/pickfrom=list()
	
	pickfrom+=junglemobs_hostile
	pickfrom+=junglemobs_dangerous
	pickfrom+=junglemobs_safe
	
	to_spawn = pick(pickfrom)
	..()


/obj/abstract/map/spawner/jungle_any/multi
	icon_state="jungle_mob_randomany"

/obj/abstract/map/spawner/jungle_any/multi/New()	
	amount=rand(1,9)
	..()


//random peaceful wildlife. :)
/obj/abstract/map/spawner/jungle_fren
	icon_state="jungle_mob_fren"
	
/obj/abstract/map/spawner/jungle_fren/New()
	to_spawn = pick(junglemobs_safe)
	..()

/obj/abstract/map/spawner/jungle_fren/multi
	icon_state="jungle_mob_frenmany"

/obj/abstract/map/spawner/jungle_fren/multi/New()	
	amount=rand(1,9)
	..()


//random hostile wildlife. >:(
/obj/abstract/map/spawner/jungle_hostile
	icon_state="jungle_mob_hostile"
	
/obj/abstract/map/spawner/jungle_hostile/New()
	to_spawn = pick(junglemobs_hostile)
	..()

/obj/abstract/map/spawner/jungle_hostile/multi
	icon_state="jungle_mob_hostilemany"

/obj/abstract/map/spawner/jungle_hostile/multi/New()	
	amount=rand(1,9)
	..()	


//random dangerous wildlife. <:O
/obj/abstract/map/spawner/jungle_danger
	icon_state="jungle_mob_danger"
	
/obj/abstract/map/spawner/jungle_danger/New()
	to_spawn = pick(junglemobs_dangerous)
	..()

/obj/abstract/map/spawner/jungle_danger/multi
	icon_state="jungle_mob_dangermany"

/obj/abstract/map/spawner/jungle_danger/multi/New()	
	amount=rand(1,9)
	..()		