/*
 * LOOK G-MA, I'VE JOINED CARBON PROCS THAT ARE IDENTICAL IN ALL CASES INTO ONE PROC, I'M BETTER THAN LIFE()
 * I thought about mob/living but silicons and simple_animals don't want this just yet.
 * Handles lying down and shrinking from DNA and viruses
 * IMPORTANT: Multiple animate() calls do not stack well, so try to do them all at once if you can.
 */

#define SHRINK_SCALE_FACTOR 0.7

/mob/living/carbon/update_transform()
	var/matrix/final_transform = transform
	var/final_pixel_y = pixel_y
	var/final_dir = dir
	var/animate = FALSE
	if(lying != lying_prev)
		animate = TRUE

		if(!lying) // lying to standing
			final_pixel_y += 6 * PIXEL_MULTIPLIER
			final_transform.Turn(-90)
		else //if(lying)
			if(!lying_prev) // standing to lying
				final_pixel_y -= 6 * PIXEL_MULTIPLIER
				final_transform.Turn(90)

		if(dir & (EAST | WEST)) // facing east or west
			final_dir = pick(NORTH, SOUTH) // so you fall on your side rather than your face or ass

		lying_prev = lying // so we don't try to animate until there's been another change.


	if(shrunken != shrunken_prev)
		animate = TRUE

		if(!shrunken)
			final_pixel_y += 4 * PIXEL_MULTIPLIER
			if(!lying)
				final_transform *= matrix().Scale(1, 1 / SHRINK_SCALE_FACTOR)
			else
				final_transform *= matrix().Scale(1 / SHRINK_SCALE_FACTOR, 1)
		else
			if(!shrunken_prev)
				final_pixel_y -= 4 * PIXEL_MULTIPLIER
				if(!lying)
					final_transform *= matrix().Scale(1, SHRINK_SCALE_FACTOR)
				else
					final_transform *= matrix().Scale(SHRINK_SCALE_FACTOR, 1)
					

		shrunken_prev = shrunken // so we don't try to animate until there's been another change.
	
	if(animate)
		animate(src, transform = final_transform, pixel_y = final_pixel_y, dir = final_dir, time = 2, easing = EASE_IN | EASE_OUT)
