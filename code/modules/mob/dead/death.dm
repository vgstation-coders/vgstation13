/mob/dead/dust()	//ghosts can't be vaporised.
	return

/mob/dead/gib()		//ghosts can't be gibbed.
	return

/mob/dead/cultify()
	if(icon_state != "ghost-narsie")
		icon = 'icons/mob/mob.dmi'
		icon_state = "ghost-narsie"
		overlays = 0
		if(mind && mind.current)
			if(istype(mind.current, /mob/living/carbon/human/))	//dressing our ghost with a few items that he was wearing just before dying
				var/mob/living/carbon/human/H = mind.current	//note that ghosts of players that died more than a few seconds before meeting nar-sie won't have any of these overlays
				/*overlays += H.overlays_standing[6]//ID
				overlays += H.overlays_standing[9]//Ears
				overlays += H.overlays_standing[10]//Suit
				overlays += H.overlays_standing[11]//Glasses
				overlays += H.overlays_standing[12]//Belt
				overlays += H.overlays_standing[14]//Back
				overlays += H.overlays_standing[18]//Head
				overlays += H.overlays_standing[19]//Handcuffs
				*/
				overlays += H.obj_overlays[ID_LAYER]
				overlays += H.obj_overlays[EARS_LAYER]
				overlays += H.obj_overlays[SUIT_LAYER]
				overlays += H.obj_overlays[GLASSES_LAYER]
				overlays += H.obj_overlays[GLASSES_OVER_HAIR_LAYER]
				overlays += H.obj_overlays[BELT_LAYER]
				overlays += H.obj_overlays[BACK_LAYER]
				overlays += H.obj_overlays[HEAD_LAYER]
				overlays += H.obj_overlays[HANDCUFF_LAYER]
		invisibility = 0
		to_chat(src, "<span class='sinister'>Even as a non-corporal being, you can feel Nar-Sie's presence altering you. You are now visible to everyone.</span>")
		flick("rune_seer",src)

/mob/dead/update_canmove()
	return

/mob/dead/blob_act()
	return