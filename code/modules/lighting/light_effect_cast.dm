#define BASE_PIXEL_OFFSET 224
#define BASE_TURF_OFFSET 2
#define WIDE_SHADOW_THRESHOLD 80
#define OFFSET_MULTIPLIER_SIZE 32
#define CORNER_OFFSET_MULTIPLIER_SIZE 16

var/light_power_multiplier = 5

// Casts shadows from occluding objects for a given light.

/obj/light/proc/cast_light()
	light_color = null

	temp_appearance = list()

	//cap light range to 5
	light_range = min(5, light_range)

	alpha = min(255,max(0,round(light_power*light_power_multiplier*25)))

	if(light_type == LIGHT_SOFT_FLICKER)
		alpha = initial(alpha)
		animate(src, alpha = initial(alpha) - rand(30, 60), time = 2, loop = -1, easing = SINE_EASING)

	for(var/turf/T in range(light_range, src))
		affecting_turfs |= T

	if(!isturf(loc))
		for(var/turf/T in affecting_turfs)
			T.lumcount = -1
			T.affecting_lights -= src
		affecting_turfs.Cut()
		return

	for(var/turf/T in affecting_turfs)
		T.affecting_lights |= src


	if(light_type == LIGHT_DIRECTIONAL)
		icon = 'icons/lighting/directional_overlays.dmi'
		light_range = 2.5
	else
		pixel_x = pixel_y = -(world.icon_size * light_range)
		switch(light_range)
			if(1)
				icon = 'icons/lighting/light_range_1.dmi'
			if(2)
				icon = 'icons/lighting/light_range_2.dmi'
			if(3)
				icon = 'icons/lighting/light_range_3.dmi'
			if(4)
				icon = 'icons/lighting/light_range_4.dmi'
			if(5)
				icon = 'icons/lighting/light_range_5.dmi'
			else
				qdel(src)
				return

	icon_state = "white"

	var/image/I = image(icon)
	I.layer = HIGHEST_LIGHTING_LAYER
	I.icon_state = "overlay"
	if(light_type == LIGHT_DIRECTIONAL)
		var/turf/next_turf = get_step(src, dir)
		for(var/i = 1 to 3)
			if(CheckOcclusion(next_turf))
				I.icon_state = "[I.icon_state]_[i]"
				break
			next_turf = get_step(next_turf, dir)

	temp_appearance += I

	if(light_type == LIGHT_DIRECTIONAL)
		follow_holder_dir()

	//no shadows
	if(light_range < 2 || light_type == LIGHT_DIRECTIONAL)
		overlays = temp_appearance
		temp_appearance = null
		return

	var/list/visible_turfs = list()

	for(var/turf/T in view(light_range, src))
		visible_turfs += T

	for(var/turf/T in visible_turfs)
		if(CheckOcclusion(T))
			CastShadow(T)

	overlays = temp_appearance
	temp_appearance = null

/obj/light/proc/CastShadow(var/turf/target_turf)
	//get the x and y offsets for how far the target turf is from the light
	var/x_offset = target_turf.x - x
	var/y_offset = target_turf.y - y

	var/num = 1
	if((abs(x_offset) > 0 && !y_offset) || (abs(y_offset) > 0 && !x_offset))
		num = 2


	//due to only having one set of shadow templates, we need to rotate and flip them for up to 8 different directions
	//first check is to see if we will need to "rotate" the shadow template
	var/xy_swap = 0
	if(abs(x_offset) > abs(y_offset))
		xy_swap = 1

	var/shadowoffset = 16 + 32 * light_range


	//due to the way the offsets are named, we can just swap the x and y offsets to "rotate" the icon state

	var/shadowicon
	switch(light_range)
		if(2)
			if(num == 1)
				shadowicon = 'icons/lighting/light_range_2_shadows1.dmi'
			else
				shadowicon = 'icons/lighting/light_range_2_shadows2.dmi'
		if(3)
			if(num == 1)
				shadowicon = 'icons/lighting/light_range_3_shadows1.dmi'
			else
				shadowicon = 'icons/lighting/light_range_3_shadows2.dmi'
		if(4)
			if(num == 1)
				shadowicon = 'icons/lighting/light_range_4_shadows1.dmi'
			else
				shadowicon = 'icons/lighting/light_range_4_shadows2.dmi'
		if(5)
			if(num == 1)
				shadowicon = 'icons/lighting/light_range_5_shadows1.dmi'
			else
				shadowicon = 'icons/lighting/light_range_5_shadows2.dmi'

	var/image/I = image(shadowicon)

	if(xy_swap)
		I.icon_state = "[abs(y_offset)]_[abs(x_offset)]"
	else
		I.icon_state = "[abs(x_offset)]_[abs(y_offset)]"


	var/matrix/M = matrix()

	//TODO: rewrite this comment:
	//using scale to flip the shadow template if needed
	//horizontal (x) flip is easy, we just check if the offset is negative
	//vertical (y) flip is a little harder, if the shadow will be rotated we need to flip if the offset is positive,
	// but if it wont be rotated then we just check if its negative to flip (like the x flip)
	var/x_flip
	var/y_flip
	if(xy_swap)
		x_flip = y_offset > 0 ? -1 : 1
		y_flip = x_offset < 0 ? -1 : 1
	else
		x_flip = x_offset < 0 ? -1 : 1
		y_flip = y_offset < 0 ? -1 : 1

	M.Scale(x_flip, y_flip)

	//here we do the actual rotate if needed
	if(xy_swap)
		M.Turn(90)

	//warning: you are approaching shitcode (this is where we move the shadow to the correct quadrant based on its rotation and flipping)
	//shadows are only as big as a quarter or half of the light for optimization

	//please for the love of god change this if there's a better way

	if(num == 1)
		if((x_flip == 1 && y_flip == 1 && xy_swap == 0) || (x_flip == -1 && y_flip == 1 && xy_swap == 1))
			M.Translate(shadowoffset, shadowoffset)
		else if((x_flip == 1 && y_flip == -1 && xy_swap == 0) || (x_flip == 1 && y_flip == 1 && xy_swap == 1))
			M.Translate(shadowoffset, 0)
		else if((xy_swap == 0 && x_flip == -y_flip) || (xy_swap == 1 && x_flip == -1 && y_flip == -1))
			M.Translate(0, shadowoffset)
	else
		if(x_flip == 1 && y_flip == 1 && xy_swap == 0)
			M.Translate(0, shadowoffset)
		else if(x_flip == 1 && y_flip == 1 && xy_swap == 1)
			M.Translate(shadowoffset / 2, shadowoffset / 2)
		else if(x_flip == 1 && y_flip == -1 && xy_swap == 1)
			M.Translate(-shadowoffset / 2, shadowoffset / 2)

	//apply the transform matrix
	I.transform = M
	I.layer = LIGHTING_LAYER

	//and add it to the lights overlays
	temp_appearance += I

	var/targ_dir = get_dir(target_turf, src)

	var/blocking_dirs = 0
	for(var/d in cardinal)
		var/turf/T = get_step(target_turf, d)
		if(CheckOcclusion(T))
			blocking_dirs |= d

	I = image('icons/lighting/wall_lighting.dmi')
	I.icon_state = "[blocking_dirs]-[targ_dir]"
	I.pixel_x = (world.icon_size * light_range) + (x_offset * world.icon_size)
	I.pixel_y = (world.icon_size * light_range) + (y_offset * world.icon_size)
	I.layer = ABOVE_LIGHTING_LAYER

	temp_appearance += I

/obj/light/proc/CheckOcclusion(var/turf/T)
	if(!istype(T))
		return 0

	if(T.opacity)
		return 1

	for(var/obj/machinery/door/D in T)
		if(D.opacity)
			return 1

	return 0

#undef BASE_PIXEL_OFFSET
#undef BASE_TURF_OFFSET
#undef WIDE_SHADOW_THRESHOLD
#undef OFFSET_MULTIPLIER_SIZE
#undef CORNER_OFFSET_MULTIPLIER_SIZE
