/obj/effect/gravestone
	name = "gravestone"
	desc = "Whoever lies here must sure be confused as to how they were buried in a space station."
	icon = 'icons/obj/halloween.dmi'
	icon_state = "gravestone_wood"
	anchored = 1

/obj/effect/gravestone/New()
	gravestone_flick()
	..()

/obj/effect/gravestone/proc/gravestone_flick()
	return

/obj/effect/gravestone/stone
	icon_state = "gravestone_stone"

var/list/halloween_spawns = list(
	"default" = list(/mob/living/simple_animal/hostile/humanoid/skellington),

	"cargo" = list(/mob/living/simple_animal/hostile/humanoid/mummy, /mob/living/simple_animal/hostile/mimic/crate/chest,\
	/mob/living/simple_animal/hostile/mimic/crate/item) + typesof(/mob/living/simple_animal/hostile/humanoid/jackal),

	"kitchen" = list(/mob/living/simple_animal/hostile/humanoid/kitchen/poutine, /mob/living/simple_animal/hostile/humanoid/kitchen/meatballer),

	"library" = list(/mob/living/simple_animal/hostile/scarybat/book, /mob/living/simple_animal/hostile/mannequin/cult),

	"medical" = list(/mob/living/simple_animal/hostile/blood_splot, /obj/structure/skele_stand, /mob/living/simple_animal/hostile/monster/cyber_horror)\
	 + typesof(/mob/living/simple_animal/hostile/necro/zombie),

	"maintenance" = list(/mob/living/simple_animal/hostile/humanoid/vampire, /mob/living/simple_animal/hostile/gremlin/greytide,\
	/mob/living/simple_animal/hostile/gremlin, /mob/living/simple_animal/hostile/necro/zombie/putrid),

	"engineering" = list(/mob/living/simple_animal/hostile/humanoid/supermatter, /mob/living/simple_animal/hostile/syphoner),

)

/obj/effect/gravestone/halloween
	name = "strange gravestone"

/obj/effect/gravestone/halloween/New()
	icon_state = pick("gravestone_wood","gravestone_stone")
	..()
	spawn_enemies()

/obj/effect/gravestone/halloween/gravestone_flick()
	flick("[icon_state]_new", src)

/obj/effect/gravestone/halloween/proc/spawn_enemies()
	set waitfor = 0
	var/our_area = get_area_string()

	if(our_area == "space" || our_area == "chapel")
		animate(src, alpha = 0, time = 1 SECONDS)
		sleep(1 SECONDS)
		qdel(src)
		return

	var/list/possible_spawns = halloween_spawns["default"] + halloween_spawns[our_area]

	spawn(rand(15 SECONDS, 30 SECONDS))
		var/to_spawn = pick(possible_spawns)
		if(to_spawn)
			new to_spawn(get_turf(src))
		animate(src, alpha = 0, time = 3 SECONDS)
		spawn(3 SECONDS)
			qdel(src)

/obj/effect/gravestone/halloween/proc/get_area_string()
	. = "default"

	var/area/A = get_area(src)
	if(isspace(A))
		. = "space"
	else if(istype(A,/area/engine) || istype(A,/area/engineering) || istype(A,/area/construction))
		. = "engineering"
	else if(istype(A,/area/medical))
		. = "medical"
	else if(istype(A,/area/chapel))
		. = "chapel"
	else if(istype(A,/area/library))
		. = "library"
	else if(istype(A, /area/maintenance))
		. = "maintenance"
	else if(istype(A, /area/supply))
		. = "cargo"
	else if(istype(A,/area/crew_quarters/kitchen) || istype(A,/area/hydroponics))
		. = "kitchen"