// Wily Coyote-style fall into background.  Done by using a matrix transformation and color.
/proc/fall_into_background(var/atom/movable/AM, var/reset_after=TRUE)
	var/matrix/fall_animation = matrix()
	fall_animation.Scale(0.1,0.1)
	fall_animation.Turn(270)
	//var/alpha_before = src.alpha
	var/color_before = list(AM.color)
	var/transform_before = matrix(AM.transform)
	var/oldcanmove=0
	if(ismob(AM))
		var/mob/M = AM
		oldcanmove = M.canmove
		M.canmove = 0
	animate(AM, transform = fall_animation, color = "#000000", time = 30, easing = QUAD_EASING)
	if(reset_after)
		spawn(30)
			//M.alpha=alpha.before
			AM.color = color_before
			AM.transform = transform_before
			if(ismob(AM))
				var/mob/M = AM
				M.canmove=oldcanmove
