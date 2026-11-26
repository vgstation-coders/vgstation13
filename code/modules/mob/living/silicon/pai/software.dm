// TODO:


/mob/living/silicon/pai/var/list/available_software = list(
															SOFT_FL = 10,
															SOFT_RT = 10,
															SOFT_RS = 10,
															SOFT_VE = 10,

															SOFT_WJ = 30,
															SOFT_CS = 30,
															SOFT_FS = 30,
															SOFT_UT = 30,
															SOFT_MS = 30, //records + HUD
															SOFT_SS = 30, //records + HUD
															SOFT_AS = 5,
															SOFT_ME = 10,
															SOFT_PS = 10,
															SOFT_XS = 10,
															SOFT_HM = 25

															)


/mob/living/silicon/pai/verb/paiInterface()
	set category = "pAI Commands"
	set name = "Software Interface"
	tgui_interact(usr)

/mob/living/silicon/pai/proc/uninstall_loop(var/cost)
	var/duration = cost*2 //2 seconds per unit RAM
	while(uninstallprogress < 100)
		if(uninstallprogress<0) //if canceled by the PAI, this becomes negative and the loop returns false here
			return 0
		uninstallprogress += round((1/duration)*100,1)  //store and calculate the value in percentages. easier to display.
		uninstallprogress = min(100,uninstallprogress) //Never go above 100
		if(uninstallprogress >= 100)
			to_chat(src, "<span class='notice'>Software uninstallation complete!</span>")
			return 1
		if(screen == SOFT_UN) // Update our view, if appropriate
			SStgui.update_uis(src)
		sleep(1 SECONDS)

/mob/living/silicon/pai/proc/CheckDNA(var/mob/M, var/mob/living/silicon/pai/P)
	if(M.stat == DEAD)
		to_chat(P, "<span class='warning'>DNA is denaturing due to the body's death, aborting operation.</span>")
		return
	var/answer = input(M, "[P] is requesting a DNA sample from you. Will you allow it to confirm your identity?", "[P] Check DNA", "No") in list("Yes", "No")
	if(answer == "Yes")
		var/turf/T = get_turf(P.loc)
		for (var/mob/v in viewers(T))
			v.show_message("<span class='notice'>[M] presses \his thumb against [P].</span>", 1, "<span class='notice'>[P] makes a sharp clicking sound as it extracts DNA material from [M].</span>", 2)
		var/datum/dna/test_dna = M.dna
		to_chat(P, "<font color = red><h3>[M]'s UE string : [dna.unique_enzymes]</h3></font>")
		if(test_dna.unique_enzymes == P.dna.unique_enzymes)
			to_chat(P, "<b>DNA is a match to stored Master DNA.</b>")
		else
			to_chat(P, "<b>DNA does not match stored Master DNA.</b>")
	else
		to_chat(P, "[M] does not seem like \he is going to provide a DNA sample willingly.")

// -=-=-=-= Software =-=-=-=-=- //

/mob/living/silicon/pai/proc/hackloop(var/obj/machinery/M)
	if(M)
		hacktarget = M
	while(hackprogress < 100)
		if(hacktarget && get_dist(src, hacktarget) <= 1)
			hackprogress += rand(10, 20)
		else
			temp = "Process aborted."
			hackprogress = 0
			hacktarget = null
			return 0
		hackprogress = min(100,hackprogress) //Never go above 100
		if(screen == "wirejack") // Update our view, if appropriate
			SStgui.update_uis(src)
		else
			hackprogress = 0
			hacktarget = null
			return 0
		if(hackprogress >= 100)
			hackprogress = 0
			hacktarget = null
			playsound(loc, 'sound/machines/ding.ogg', 50, 1)
			return 1
		sleep(1 SECONDS)			// Update every 1 second

/mob/living/silicon/pai/proc/chargeloop(var/mode)
	if(!mode)
		return
	while(charge < 15)
		charge++
		if(charge >= 15)
			charge = 0
			return 1
		if(screen == mode) // Update our view or cancel charge
			SStgui.update_uis(src)
		else
			charge = 0
			return 0
		sleep(1 SECONDS)

// EMP Shielding, just a description
