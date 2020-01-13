/datum/disease/jungle_fever
	name = "Jungle Fever"
	max_stages = 1
	cure = "None"
	spread = "Bites"
	spread_type = SPECIAL
	affected_species = list("Monkey", "Human")
	curable = 0
	desc = "monkeys with this disease will bite humans, causing humans to spontaneously mutate into a monkey."
	severity = "Medium"
	//stage_prob = 100
	agent = "Kongey Vibrion M-909"

/datum/disease/jungle_fever/stage_act()
	..()
	if(!affected_mob || !affected_mob.mind || affected_mob.mind.GetRole(MADMONKEY))
		return
	var/datum/role/madmonkey/MM = new
	MM.AssignToRole(affected_mob.mind,1)
	MM.Greet(GREET_DEFAULT)
	MM.OnPostSetup()
	MM.AnnounceObjectives()

/*============
*             *
*  ROLE BEGIN *
*             *
============*/

/datum/role/madmonkey
	name = MADMONKEY
	id = MADMONKEY
	special_role = MADMONKEY
	logo_state = "monkey-logo"
	greets = list(GREET_MASTER,GREET_DEFAULT,GREET_CUSTOM)
	var/countdown = 60

datum/role/madmonkey/Greet(var/greeting,var/custom)
	if(!greeting)
		return

	var/icon/logo = icon('icons/logos.dmi', logo_state)
	switch(greeting)
		if (GREET_CUSTOM)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <B>[custom]</B>")
		else if(GREET_MASTER)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='warning'><B>You are the Jungle Fever patient zero!</B><BR>Find somewhere safe, you will transform in one minute. At that time, start biting!</span>")
		else //default
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='warning'><B>You are a [name]!</B><BR>Bite crewmembers to add to your ranks!</span>")

/datum/role/madmonkey/OnPostSetup()
	if(faction)
		return
	var/datum/faction/F = find_active_faction_by_type(/datum/faction/junglefever)
	if(!F)
		F = ticker.mode.CreateFaction(/datum/faction/junglefever, null, 1)
		F.forgeObjectives()
		F.HandleRecruitedRole(src)
	else
		F.HandleRecruitedRole(src)

/datum/role/madmonkey/process()
	..()
	if(!antag || !antag.current || isobserver(antag.current) || ismonkey(antag.current))
		return
	if (countdown > 0)
		countdown--
		if (countdown == 50)
			to_chat(antag.current, "<span class='alert'>You feel hungry for bananas.</span>")
		else if (countdown == 30)
			to_chat(antag.current, "<span class='alert'>You feel like you're about to go ape.</span>")
		else if (countdown <= 0)
			var/mob/living/carbon/monkey/M = antag.current.monkeyize()
			M.contract_disease(new /datum/disease/jungle_fever, 1)
	if (antag && antag.current.hud_used)
		if(antag.current.hud_used.countdown_display)
			antag.current.hud_used.countdown_display.overlays.len = 0
			var/first = round(countdown/10)
			var/second = countdown%10
			var/image/I1 = new('icons/obj/centcomm_stuff.dmi',src,"[first]",30)
			var/image/I2 = new('icons/obj/centcomm_stuff.dmi',src,"[second]",30)
			I1.pixel_x += 10 * PIXEL_MULTIPLIER
			I2.pixel_x += 17 * PIXEL_MULTIPLIER
			I1.pixel_y -= 11 * PIXEL_MULTIPLIER
			I2.pixel_y -= 11 * PIXEL_MULTIPLIER
			antag.current.hud_used.countdown_display.overlays += I1
			antag.current.hud_used.countdown_display.overlays += I2
		else
			antag.current.hud_used.countdown_hud()