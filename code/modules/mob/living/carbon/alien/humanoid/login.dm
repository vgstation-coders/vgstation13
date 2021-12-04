/mob/living/carbon/alien/humanoid/Login()
	..()
	AddInfectionImages()
	update_hud()
	updatePlasmaHUD()
	if(!isturf(loc))
		client.eye = loc
		client.perspective = EYE_PERSPECTIVE
	return
