// Wily Coyote-style fall into background.  Done by using a matrix transformation and color.
/proc/fall_into_background(var/atom/movable/M, var/reset_after=TRUE)
	var/matrix/scale_transform = matrix()
	scale_transform.Scale(0.1,0.1)
	var/matrix/rotate_transform = matrix()
	rotate_transform.Turn(270)
	//var/alpha_before = src.alpha
	var/color_before = list(M.color)
	var/transform_before = matrix(M.transform)
	animate(M, transform = scale_transform * rotate_transform, color = "#000000", time = 30, easing = QUAD_EASING)
	if(reset_after)
		//M.alpha=alpha.before
		M.color = color_before
		M.transform = transform_before
