/obj/structure/crystal
	name = "large crystal"
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "crystal"
	density = 1

/obj/structure/crystal/New()
	..()

	icon_state = pick("ano70","ano80")

	desc = pick(\
	"It shines faintly as it catches the light.",\
	"It appears to have a faint inner glow.",\
	"It seems to draw you inward as you look it at.",\
	"Something twinkles faintly as you look at it.",\
	"It's mesmerizing to behold.")

/obj/structure/crystal/Destroy()
	new /datum/artifact_postmortem_data(src)
	src.visible_message("<span class='danger'>[src] shatters!</span>")
	src.investigation_log(I_ARTIFACT, "|| shattered by [key_name(usr)].")
	if(prob(75))
		new /obj/item/weapon/shard/plasma(loc)
	if(prob(50))
		new /obj/item/weapon/shard/plasma(loc)
	if(prob(25))
		new /obj/item/weapon/shard/plasma(loc)
	if(prob(75))
		new /obj/item/weapon/shard(loc)
	if(prob(50))
		new /obj/item/weapon/shard(loc)
	if(prob(25))
		new /obj/item/weapon/shard(loc)
	..()

//todo: laser_act
