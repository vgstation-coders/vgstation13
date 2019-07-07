/obj/effect/hole
	name = "hole in the floor"
	desc = "looks deep"
	icon = 'icons/effects/effects.dmi'
	icon_state = "blank_base"
	var/target_loc

/obj/effect/hole/Crossed(mob/living/O)
	if(target_loc)
		O.visible_message("<span class = 'warning'>\the [O] falls down \the [src]!</span>")
		O.forceMove(target_loc)