/datum/reagent/silicate
	name = "Silicate"
	id = "silicate"
	description = "A compound that can be used to reinforce glass."
	reagent_state = LIQUID
	color = "#C7FFFF" // rgb: 199, 255, 255

	reaction_obj(var/obj/O, var/volume)
		src = null
		if(istype(O,/obj/structure/window))
			if(O:silicate <= 200)

				O:silicate += volume
				O:health += volume * 3

				if(!O:silicateIcon)
					var/icon/I = icon(O.icon,O.icon_state,O.dir)

					var/r = (volume / 100) + 1
					var/g = (volume / 70) + 1
					var/b = (volume / 50) + 1
					I.SetIntensity(r,g,b)
					O.icon = I
					O:silicateIcon = I
				else
					var/icon/I = O:silicateIcon

					var/r = (volume / 100) + 1
					var/g = (volume / 70) + 1
					var/b = (volume / 50) + 1
					I.SetIntensity(r,g,b)
					O.icon = I
					O:silicateIcon = I

		return