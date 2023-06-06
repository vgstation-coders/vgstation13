// Still WIP for now...

/datum/lighting_system/europa_classic
	name = "Europa Classic"
	desc = "A dynamic lighting system featuring soft shadows, special effects and bright colours. It aims to be reasonably bright and exude an atmosphere of a well-maintained station."
	enabled = 1

/datum/lighting_system/europa_classic/choose_light_range_icon(var/two_bordering_walls, var/light_range, var/num)
	var/shadowicon
	if (!two_bordering_walls && (num == FRONT_SHADOW))
		switch(light_range)
			if(2)
				shadowicon = 'icons/lighting/light_range_2_shadows2_soft.dmi'
			if(3)
				shadowicon = 'icons/lighting/light_range_3_shadows2_soft.dmi'
			if(4)
				shadowicon = 'icons/lighting/light_range_4_shadows2_soft.dmi'
			if(5)
				shadowicon = 'icons/lighting/light_range_5_shadows2_soft.dmi'
			if(6)
				shadowicon = 'icons/lighting/light_range_6_shadows2_soft.dmi'
			if(7)
				shadowicon = 'icons/lighting/light_range_7_shadows2_soft.dmi'
			if(8)
				shadowicon = 'icons/lighting/light_range_8_shadows2_soft.dmi'
			if(9)
				shadowicon = 'icons/lighting/light_range_9_shadows2_soft.dmi'

	else
		switch(light_range)
			if(2)
				if(num == CORNER_SHADOW)
					shadowicon = 'icons/lighting/light_range_2_shadows1.dmi'
				else
					shadowicon = 'icons/lighting/light_range_2_shadows2.dmi'
			if(3)
				if(num == CORNER_SHADOW)
					shadowicon = 'icons/lighting/light_range_3_shadows1.dmi'
				else
					shadowicon = 'icons/lighting/light_range_3_shadows2.dmi'
			if(4)
				if(num == CORNER_SHADOW)
					shadowicon = 'icons/lighting/light_range_4_shadows1.dmi'
				else
					shadowicon = 'icons/lighting/light_range_4_shadows2.dmi'
			if(5)
				if(num == CORNER_SHADOW)
					shadowicon = 'icons/lighting/light_range_5_shadows1.dmi'
				else
					shadowicon = 'icons/lighting/light_range_5_shadows2.dmi'
			if(6)
				if(num == CORNER_SHADOW)
					shadowicon = 'icons/lighting/light_range_6_shadows1.dmi'
				else
					shadowicon = 'icons/lighting/light_range_6_shadows2.dmi'
			if(7)
				if(num == CORNER_SHADOW)
					shadowicon = 'icons/lighting/light_range_7_shadows1.dmi'
				else
					shadowicon = 'icons/lighting/light_range_7_shadows2.dmi'
			if(8)
				if(num == CORNER_SHADOW)
					shadowicon = 'icons/lighting/light_range_8_shadows1.dmi'
				else
					shadowicon = 'icons/lighting/light_range_8_shadows2.dmi'
			if(9)
				if(num == CORNER_SHADOW)
					shadowicon = 'icons/lighting/light_range_9_shadows1.dmi'
				else
					shadowicon = 'icons/lighting/light_range_9_shadows2.dmi'
	return shadowicon
