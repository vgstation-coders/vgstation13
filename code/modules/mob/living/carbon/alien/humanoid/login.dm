/mob/living/carbon/alien/humanoid/Login()
	..()
	update_hud()
	updatePhoronHUD()
	if(!isturf(loc))
		client.eye = loc
		client.perspective = EYE_PERSPECTIVE
	return
