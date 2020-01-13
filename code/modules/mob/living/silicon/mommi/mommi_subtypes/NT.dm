//Nanotrasen MoMMI subtype because we don't give mommis a choice of choosing their module.
/mob/living/silicon/robot/mommi/nt/New()
	pick_module(NANOTRASEN_MOMMI)
	..()
	camera.network = list(CAMERANET_ENGI)
	cyborg_cams[CAMERANET_ENGI] += camera