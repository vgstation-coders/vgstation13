/obj/structure/particle_accelerator/power_box
	name = "Particle Focusing EM Lens"
	desc_holder = "This uses electromagnetic waves to focus the Alpha-Particles."
	icon = 'icons/obj/machines/particle_accelerator2.dmi'
	icon_state = "power_box"
	reference = "power_box"

/obj/structure/particle_accelerator/power_box/update_icon()
	..()
	if(construction_state == 3)
		if(powered)
			update_moody_light('icons/lighting/moody_lights.dmi', "[reference]p[strength]")
		else
			update_moody_light('icons/lighting/moody_lights.dmi', "[reference]c")
	else
		kill_moody_light()
