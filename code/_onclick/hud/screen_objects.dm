/*
	Screen objects
	Todo: improve/re-implement

	Screen objects are only used for the hud and should not appear anywhere "in-game".
	They are used with the client/screen list and the screen_loc var.
	For more information, see the byond documentation on the screen_loc and screen vars.
*/
/obj/screen
	name = ""
	icon = 'icons/mob/screen1.dmi'
	layer = 20.0
	unacidable = 1
	var/obj/master = null	//A reference to the object in the slot. Grabs or items, generally.
	var/gun_click_time = -100 //I'm lazy.

/obj/screen/Destroy()
	master = null
	..()

/obj/screen/text
	icon = null
	icon_state = null
	mouse_opacity = 0
	screen_loc = "CENTER-7,CENTER-7"
	maptext_height = 480
	maptext_width = 480


/obj/screen/inventory
	var/slot_id	//The indentifier for the slot. It has nothing to do with ID cards.


/obj/screen/close
	name = "close"

/obj/screen/close/Click()
	if(master)
		if(istype(master, /obj/item/weapon/storage))
			var/obj/item/weapon/storage/S = master
			S.close(usr)
		else if(istype(master,/obj/item/clothing/suit/storage))
			var/obj/item/clothing/suit/storage/S = master
			S.close(usr)
	return 1


/obj/screen/item_action
	var/obj/item/owner

/obj/screen/item_action/Click()
	if(!usr || !owner)
		return 1
	if(usr.attack_delayer.blocked())
		return
	//usr.next_move = world.time + 6

	if(usr.stat || usr.restrained() || usr.stunned || usr.lying)
		return 1

	if(!(owner in usr))
		return 1

	owner.ui_action_click()
	return 1

//This is the proc used to update all the action buttons. It just returns for all mob types except humans.
/mob/proc/update_action_buttons()
	return


/obj/screen/grab
	name = "grab"

/obj/screen/grab/Click()
	var/obj/item/weapon/grab/G = master
	G.s_click(src)
	return 1

/obj/screen/grab/attack_hand()
	return

/obj/screen/grab/attackby()
	return

/obj/screen/grab/Destroy()
	if(master)
		master = null
	..()

/obj/screen/storage
	name = "storage"

/obj/screen/storage/Click()
	if(usr.attack_delayer.blocked())
		return
	if(usr.stat || usr.paralysis || usr.stunned || usr.weakened)
		return 1
	if (istype(usr.loc,/obj/mecha)) // stops inventory actions in a mech
		return 1
	if(master)
		var/obj/item/I = usr.get_active_hand()
		if(I)
			master.attackby(I, usr)
			//usr.next_move = world.time+2
	return 1

/obj/screen/gun
	name = "gun"
	icon = 'icons/mob/screen1.dmi'
	master = null
	dir = 2

	move
		name = "Allow Walking"
		icon_state = "no_walk0"
		screen_loc = ui_gun2

	run
		name = "Allow Running"
		icon_state = "no_run0"
		screen_loc = ui_gun3

	item
		name = "Allow Item Use"
		icon_state = "no_item0"
		screen_loc = ui_gun1

	mode
		name = "Toggle Gun Mode"
		icon_state = "gun0"
		screen_loc = ui_gun_select
		//dir = 1

/obj/screen/zone_sel
	name = "damage zone"
	icon_state = "zone_sel"
	screen_loc = ui_zonesel
	var/selecting = "chest"

/obj/screen/zone_sel/Click(location, control,params)
	var/list/PL = params2list(params)
	var/icon_x = text2num(PL["icon-x"])
	var/icon_y = text2num(PL["icon-y"])
	var/old_selecting = selecting //We're only going to update_icon() if there's been a change

	switch(icon_y)
		if(1 to 3) //Feet
			switch(icon_x)
				if(10 to 15)
					selecting = "r_foot"
				if(17 to 22)
					selecting = "l_foot"
				else
					return 1
		if(4 to 9) //Legs
			switch(icon_x)
				if(10 to 15)
					selecting = "r_leg"
				if(17 to 22)
					selecting = "l_leg"
				else
					return 1
		if(10 to 13) //Hands and groin
			switch(icon_x)
				if(8 to 11)
					selecting = "r_hand"
				if(12 to 20)
					selecting = "groin"
				if(21 to 24)
					selecting = "l_hand"
				else
					return 1
		if(14 to 22) //Chest and arms to shoulders
			switch(icon_x)
				if(8 to 11)
					selecting = "r_arm"
				if(12 to 20)
					selecting = "chest"
				if(21 to 24)
					selecting = "l_arm"
				else
					return 1
		if(23 to 30) //Head, but we need to check for eye or mouth
			if(icon_x in 12 to 20)
				selecting = "head"
				switch(icon_y)
					if(23 to 24)
						if(icon_x in 15 to 17)
							selecting = "mouth"
					if(26) //Eyeline, eyes are on 15 and 17
						if(icon_x in 14 to 18)
							selecting = "eyes"
					if(25 to 27)
						if(icon_x in 15 to 17)
							selecting = "eyes"

	if(old_selecting != selecting)
		update_icon()
	return 1

/obj/screen/zone_sel/update_icon()
	overlays.len = 0
	overlays += image('icons/mob/zone_sel.dmi', "[selecting]")


/obj/screen/Click(location, control, params)
	if(!usr)	return 1

	switch(name)
		if("toggle")
			if(usr.hud_used.inventory_shown)
				usr.hud_used.inventory_shown = 0
				usr.client.screen -= usr.hud_used.other
			else
				usr.hud_used.inventory_shown = 1
				usr.client.screen += usr.hud_used.other

			usr.hud_used.hidden_inventory_update()

		if("equip")
			if (istype(usr.loc,/obj/mecha)) // stops inventory actions in a mech
				return 1
			if(ishuman(usr))
				var/mob/living/carbon/human/H = usr
				H.quick_equip()

		if("resist")
			if(isliving(usr))
				var/mob/living/L = usr
				L.resist()

		if("mov_intent")
			if(iscarbon(usr))
				var/mob/living/carbon/C = usr
				if(C.legcuffed)
					C << "<span class='notice'>You are legcuffed! You cannot run until you get [C.legcuffed] removed!</span>"
					C.m_intent = "walk"	//Just incase
					C.hud_used.move_intent.icon_state = "walking"
					return 1
				switch(usr.m_intent)
					if("run")
						usr.m_intent = "walk"
						usr.hud_used.move_intent.icon_state = "walking"
					if("walk")
						usr.m_intent = "run"
						usr.hud_used.move_intent.icon_state = "running"
				if(istype(usr,/mob/living/carbon/alien/humanoid))
					usr.update_icons()
		if("m_intent")
			if(!usr.m_int)
				switch(usr.m_intent)
					if("run")
						usr.m_int = "13,14"
					if("walk")
						usr.m_int = "14,14"
					if("face")
						usr.m_int = "15,14"
			else
				usr.m_int = null
		if("walk")
			usr.m_intent = "walk"
			usr.m_int = "14,14"
		if("face")
			usr.m_intent = "face"
			usr.m_int = "15,14"
		if("run")
			usr.m_intent = "run"
			usr.m_int = "13,14"
		if("Reset Machine")
			usr.unset_machine()
		if("internal")
			if(iscarbon(usr))
				var/mob/living/carbon/C = usr
				if(!C.stat && !C.stunned && !C.paralysis && !C.restrained())
					if(C.internal)
						C.internal = null
						C << "<span class='notice'>No longer running on internals.</span>"
						if(C.internals)
							C.internals.icon_state = "internal0"
					else
						if(!istype(C.wear_mask, /obj/item/clothing/mask))
							C << "<span class='notice'>You are not wearing a mask.</span>"
							return 1
						else
							var/list/nicename = null
							var/list/tankcheck = null
							var/breathes = "oxygen"    //default, we'll check later
							var/list/contents = list()

							if(ishuman(C))
								var/mob/living/carbon/human/H = C
								breathes = H.species.breath_type
								nicename = list ("suit", "back", "belt", "right hand", "left hand", "left pocket", "right pocket")
								tankcheck = list (H.s_store, C.back, H.belt, C.r_hand, C.l_hand, H.l_store, H.r_store)

							else

								nicename = list("Right Hand", "Left Hand", "Back")
								tankcheck = list(C.r_hand, C.l_hand, C.back)

							for(var/i=1, i<tankcheck.len+1, ++i)
								if(istype(tankcheck[i], /obj/item/weapon/tank))
									var/obj/item/weapon/tank/t = tankcheck[i]
									if (!isnull(t.manipulated_by) && t.manipulated_by != C.real_name && findtext(t.desc,breathes))
										contents.Add(t.air_contents.total_moles)	//Someone messed with the tank and put unknown gasses
										continue					//in it, so we're going to believe the tank is what it says it is
									switch(breathes)
																		//These tanks we're sure of their contents
										if("nitrogen") 							//So we're a bit more picky about them.

											if(t.air_contents.nitrogen && !t.air_contents.oxygen)
												contents.Add(t.air_contents.nitrogen)
											else
												contents.Add(0)

										if ("oxygen")
											if(t.air_contents.oxygen && !t.air_contents.toxins)
												contents.Add(t.air_contents.oxygen)
											else
												contents.Add(0)

										// No races breath this, but never know about downstream servers.
										if ("carbon dioxide")
											if(t.air_contents.carbon_dioxide && !t.air_contents.toxins)
												contents.Add(t.air_contents.carbon_dioxide)
											else
												contents.Add(0)

										// ACK ACK ACK Plasmen
										if ("plasma")
											if(t.air_contents.toxins)
												contents.Add(t.air_contents.toxins)
											else
												contents.Add(0)


								else
									//no tank so we set contents to 0
									contents.Add(0)

							//Alright now we know the contents of the tanks so we have to pick the best one.

							var/best = 0
							var/bestcontents = 0
							for(var/i=1, i <  contents.len + 1 , ++i)
								if(!contents[i])
									continue
								if(contents[i] > bestcontents)
									best = i
									bestcontents = contents[i]


							//We've determined the best container now we set it as our internals

							if(best)
								C << "<span class='notice'>You are now running on internals from [tankcheck[best]] on your [nicename[best]].</span>"
								C.internal = tankcheck[best]


							if(C.internal)
								if(C.internals)
									C.internals.icon_state = "internal1"
							else
								C << "<span class='notice'>You don't have a[breathes=="oxygen" ? "n oxygen" : addtext(" ",breathes)] tank.</span>"
		if("act_intent")
			usr.a_intent_change("right")
		if("help")
			usr.a_intent = I_HELP
			usr.hud_used.action_intent.icon_state = "intent_help"
		if("harm")
			usr.a_intent = I_HURT
			usr.hud_used.action_intent.icon_state = "intent_hurt"
		if("grab")
			usr.a_intent = I_GRAB
			usr.hud_used.action_intent.icon_state = "intent_grab"
		if("disarm")
			usr.a_intent = I_DISARM
			usr.hud_used.action_intent.icon_state = "intent_disarm"

		if("pull")
			usr.stop_pulling()
		if("throw")
			if(!usr.stat && isturf(usr.loc) && !usr.restrained())
				usr:toggle_throw_mode()
		if("drop")
			usr.drop_item_v()

		if("module")
			if(isrobot(usr))
				var/mob/living/silicon/robot/R = usr
				if(R.module)
					R.hud_used.toggle_show_robot_modules()
					return 1
				R:pick_module()

		if("radio")
			if(issilicon(usr))
				usr:radio_menu()
		if("panel")
			if(issilicon(usr))
				usr:installed_modules()

		if("store")
			if(isrobot(usr))
				var/mob/living/silicon/robot/R = usr
				R.uneq_active()

		if(INV_SLOT_TOOL)
			if(istype(usr, /mob/living/silicon/robot/mommi))
				usr:toggle_module(INV_SLOT_TOOL)

		if(INV_SLOT_SIGHT)
			if(istype(usr, /mob/living/silicon/robot/mommi))
				usr:toggle_module(INV_SLOT_SIGHT)

		if("module1")
			if(istype(usr, /mob/living/silicon/robot))
				usr:toggle_module(1)

		if("module2")
			if(istype(usr, /mob/living/silicon/robot))
				usr:toggle_module(2)

		if("module3")
			if(istype(usr, /mob/living/silicon/robot))
				usr:toggle_module(3)

		if("AI Core")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				AI.view_core()

		if("Show Camera List")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				var/camera = input(AI, "Choose which camera you want to view", "Cameras") as null|anything in AI.get_camera_list()
				AI.ai_camera_list(camera)

		if("Track With Camera")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				var/target_name = input(AI, "Choose who you want to track", "Tracking") as null|anything in AI.trackable_mobs()
				AI.ai_camera_track(target_name)

		if("Toggle Camera Light")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				AI.toggle_camera_light()

		if("Show Crew Manifest")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				AI.ai_roster()

		if("Show Alerts")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				AI.ai_alerts()

		if("Announcement")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				AI.announcement()

		if("Call Emergency Shuttle")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				AI.ai_call_shuttle()

		if("State Laws")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				AI.checklaws()

		if("PDA - Send Message")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				AI.cmd_send_pdamesg()

		if("PDA - Show Message Log")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				AI.cmd_show_message_log()

		if("Take Image")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				AI.aicamera.toggle_camera_mode()

		if("View Images")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				AI.aicamera.viewpictures()

		if("Allow Walking")
			if(gun_click_time > world.time - 30)	//give them 3 seconds between mode changes.
				return
			if(!istype(usr.get_active_hand(),/obj/item/weapon/gun))
				usr << "You need your gun in your active hand to do that!"
				return
			usr.client.AllowTargetMove()
			gun_click_time = world.time

		if("Disallow Walking")
			if(gun_click_time > world.time - 30)	//give them 3 seconds between mode changes.
				return
			if(!istype(usr.get_active_hand(),/obj/item/weapon/gun))
				usr << "You need your gun in your active hand to do that!"
				return
			usr.client.AllowTargetMove()
			gun_click_time = world.time

		if("Allow Running")
			if(gun_click_time > world.time - 30)	//give them 3 seconds between mode changes.
				return
			if(!istype(usr.get_active_hand(),/obj/item/weapon/gun))
				usr << "You need your gun in your active hand to do that!"
				return
			usr.client.AllowTargetRun()
			gun_click_time = world.time

		if("Disallow Running")
			if(gun_click_time > world.time - 30)	//give them 3 seconds between mode changes.
				return
			if(!istype(usr.get_active_hand(),/obj/item/weapon/gun))
				usr << "You need your gun in your active hand to do that!"
				return
			usr.client.AllowTargetRun()
			gun_click_time = world.time

		if("Allow Item Use")
			if(gun_click_time > world.time - 30)	//give them 3 seconds between mode changes.
				return
			if(!istype(usr.get_active_hand(),/obj/item/weapon/gun))
				usr << "You need your gun in your active hand to do that!"
				return
			usr.client.AllowTargetClick()
			gun_click_time = world.time


		if("Disallow Item Use")
			if(gun_click_time > world.time - 30)	//give them 3 seconds between mode changes.
				return
			if(!istype(usr.get_active_hand(),/obj/item/weapon/gun))
				usr << "You need your gun in your active hand to do that!"
				return
			usr.client.AllowTargetClick()
			gun_click_time = world.time

		if("Toggle Gun Mode")
			usr.client.ToggleGunMode()

		if("uniform")
			if(ismonkey(usr))
				var/mob/living/carbon/monkey/M = usr
				if(M.canWearClothes)
					if (!M.get_active_hand())
						M.wearclothes(null)
					else if (istype(M.get_active_hand(), /obj/item/clothing/monkeyclothes))
						M.wearclothes(M.get_active_hand())

		if("hat")
			if(ismonkey(usr))
				var/mob/living/carbon/monkey/M = usr
				if(M.canWearHats)
					if (!M.get_active_hand())
						M.wearhat(null)
					else if (istype(M.get_active_hand(), /obj/item/clothing/head))
						M.wearhat(M.get_active_hand())
		if("wall")
			if(isconstruct(usr))
				var/mob/living/simple_animal/construct/builder/C = usr
				var/spell/S = null
				for(var/datum/D in C.spell_list)
					if(istype(D, /spell/aoe_turf/conjure/wall))
						S = D
						break
				if(S)
					S.perform()
		if("floor")
			if(isconstruct(usr))
				var/mob/living/simple_animal/construct/builder/C = usr
				var/spell/S = null
				for(var/datum/D in C.spell_list)
					if(istype(D, /spell/aoe_turf/conjure/floor ))
						S = D
						break
				if(S)
					S.perform()
		if("soulstone")
			if(isconstruct(usr))
				var/mob/living/simple_animal/construct/builder/C = usr
				var/spell/S = null
				for(var/datum/D in C.spell_list)
					if(istype(D, /spell/aoe_turf/conjure/soulstone ))
						S = D
						break
				if(S)
					S.perform()
		if("shell")
			if(isconstruct(usr))
				var/mob/living/simple_animal/construct/builder/C = usr
				var/spell/S = null
				for(var/datum/D in C.spell_list)
					if(istype(D, /spell/aoe_turf/conjure/construct/lesser  ))
						S = D
						break
				if(S)
					S.perform()
		if("pylon")
			if(isconstruct(usr))
				var/mob/living/simple_animal/construct/builder/C = usr
				var/spell/S = null
				for(var/datum/D in C.spell_list)
					if(istype(D, /spell/aoe_turf/conjure/pylon ))
						S = D
						break
				if(S)
					S.perform()
		if("shift")
			if(isconstruct(usr))
				var/mob/living/simple_animal/construct/wraith/C = usr
				var/spell/S = null
				for(var/datum/D in C.spell_list)
					if(istype(D, /spell/targeted/ethereal_jaunt/shift ))
						S = D
						break
				if(S)
					S.perform()
		if("juggerwall")
			if(isconstruct(usr))
				var/mob/living/simple_animal/construct/armoured/C = usr
				var/spell/S = null
				for(var/datum/D in C.spell_list)
					if(istype(D, /spell/aoe_turf/conjure/forcewall/lesser ))
						S = D
						break
				if(S)
					S.perform()
		if("rune")
			if(isconstruct(usr))
				var/mob/living/simple_animal/construct/harvester/C = usr
				if(!C.purge)
					C.harvesterune()
				else
					C << "<span class='warning'>The nullrod's power interferes with your own!</span>"

		if("breakdoor")
			if(isconstruct(usr))
				var/mob/living/simple_animal/construct/harvester/C = usr
				if(!C.purge)
					C.harvesterknock()
				else
					C << "<span class='warning'>The nullrod's power interferes with your own!</span>"

		if("harvest")
			if(isconstruct(usr))
				var/mob/living/simple_animal/construct/harvester/C = usr
				if(!C.purge)
					C.harvesterharvest()
				else
					C << "<span class='warning'>The nullrod's power interferes with your own!</span>"

////////////ADMINBUS HUD ICONS////////////
		if("Delete Bus")
			if(usr.buckled && istype(usr.buckled, /obj/structure/stool/bed/chair/vehicle/adminbus))
				var/obj/structure/stool/bed/chair/vehicle/adminbus/A = usr.buckled
				A.Adminbus_Deletion(usr)
		if("Delete Mobs")
			if(usr.buckled && istype(usr.buckled, /obj/structure/stool/bed/chair/vehicle/adminbus))
				var/obj/structure/stool/bed/chair/vehicle/adminbus/A = usr.buckled
				A.remove_mobs(usr)
		if("Spawn Clowns")
			if(usr.buckled && istype(usr.buckled, /obj/structure/stool/bed/chair/vehicle/adminbus))
				var/obj/structure/stool/bed/chair/vehicle/adminbus/A = usr.buckled
				A.spawn_mob(usr,1,5)
		if("Spawn Carps")
			if(usr.buckled && istype(usr.buckled, /obj/structure/stool/bed/chair/vehicle/adminbus))
				var/obj/structure/stool/bed/chair/vehicle/adminbus/A = usr.buckled
				A.spawn_mob(usr,2,5)
		if("Spawn Bears")
			if(usr.buckled && istype(usr.buckled, /obj/structure/stool/bed/chair/vehicle/adminbus))
				var/obj/structure/stool/bed/chair/vehicle/adminbus/A = usr.buckled
				A.spawn_mob(usr,3,5)
		if("Spawn Trees")
			if(usr.buckled && istype(usr.buckled, /obj/structure/stool/bed/chair/vehicle/adminbus))
				var/obj/structure/stool/bed/chair/vehicle/adminbus/A = usr.buckled
				A.spawn_mob(usr,4,5)
		if("Spawn Spiders")
			if(usr.buckled && istype(usr.buckled, /obj/structure/stool/bed/chair/vehicle/adminbus))
				var/obj/structure/stool/bed/chair/vehicle/adminbus/A = usr.buckled
				A.spawn_mob(usr,5,5)
		if("Spawn Large Alien Queen")
			if(usr.buckled && istype(usr.buckled, /obj/structure/stool/bed/chair/vehicle/adminbus))
				var/obj/structure/stool/bed/chair/vehicle/adminbus/A = usr.buckled
				A.spawn_mob(usr,6,1)
		if("Spawn Loads of Captain Spare IDs")
			if(usr.buckled && istype(usr.buckled, /obj/structure/stool/bed/chair/vehicle/adminbus))
				var/obj/structure/stool/bed/chair/vehicle/adminbus/A = usr.buckled
				A.loadsa_goodies(usr,1)
		if("Spawn Loads of Money")
			if(usr.buckled && istype(usr.buckled, /obj/structure/stool/bed/chair/vehicle/adminbus))
				var/obj/structure/stool/bed/chair/vehicle/adminbus/A = usr.buckled
				A.loadsa_goodies(usr,2)
		if("Repair Surroundings")
			if(usr.buckled && istype(usr.buckled, /obj/structure/stool/bed/chair/vehicle/adminbus))
				var/obj/structure/stool/bed/chair/vehicle/adminbus/A = usr.buckled
				A.Mass_Repair(usr)
		if("Mass Rejuvination")
			if(usr.buckled && istype(usr.buckled, /obj/structure/stool/bed/chair/vehicle/adminbus))
				var/obj/structure/stool/bed/chair/vehicle/adminbus/A = usr.buckled
				A.mass_rejuvinate(usr)
		if("Singularity Hook")
			if(usr.buckled && istype(usr.buckled, /obj/structure/stool/bed/chair/vehicle/adminbus))
				var/obj/structure/stool/bed/chair/vehicle/adminbus/A = usr.buckled
				A.throw_hookshot(usr)
		if("Adminbus-mounted Jukebox")
			if(usr.buckled && istype(usr.buckled, /obj/structure/stool/bed/chair/vehicle/adminbus))
				var/obj/structure/stool/bed/chair/vehicle/adminbus/A = usr.buckled
				A.Mounted_Jukebox(usr)
		if("Teleportation")
			if(usr.buckled && istype(usr.buckled, /obj/structure/stool/bed/chair/vehicle/adminbus))
				var/obj/structure/stool/bed/chair/vehicle/adminbus/A = usr.buckled
				A.Teleportation(usr)
		if("Release Passengers")
			if(usr.buckled && istype(usr.buckled, /obj/structure/stool/bed/chair/vehicle/adminbus))
				var/obj/structure/stool/bed/chair/vehicle/adminbus/A = usr.buckled
				A.release_passengers(usr)
		if("Send Passengers Back Home")
			if(usr.buckled && istype(usr.buckled, /obj/structure/stool/bed/chair/vehicle/adminbus))
				var/obj/structure/stool/bed/chair/vehicle/adminbus/A = usr.buckled
				A.Send_Home(usr)
		if("Antag Madness!")
			if(usr.buckled && istype(usr.buckled, /obj/structure/stool/bed/chair/vehicle/adminbus))
				var/obj/structure/stool/bed/chair/vehicle/adminbus/A = usr.buckled
				A.Make_Antag(usr)
		if("Give Infinite Laser Guns to the Passengers")
			if(usr.buckled && istype(usr.buckled, /obj/structure/stool/bed/chair/vehicle/adminbus))
				var/obj/structure/stool/bed/chair/vehicle/adminbus/A = usr.buckled
				A.give_lasers(usr)
		if("Delete the given Infinite Laser Guns")
			if(usr.buckled && istype(usr.buckled, /obj/structure/stool/bed/chair/vehicle/adminbus))
				var/obj/structure/stool/bed/chair/vehicle/adminbus/A = usr.buckled
				A.delete_lasers(usr)
		if("Give Fuse-Bombs to the Passengers")
			if(usr.buckled && istype(usr.buckled, /obj/structure/stool/bed/chair/vehicle/adminbus))
				var/obj/structure/stool/bed/chair/vehicle/adminbus/A = usr.buckled
				A.give_bombs(usr)
		if("Delete the given Fuse-Bombs")
			if(usr.buckled && istype(usr.buckled, /obj/structure/stool/bed/chair/vehicle/adminbus))
				var/obj/structure/stool/bed/chair/vehicle/adminbus/A = usr.buckled
				A.delete_bombs(usr)
		if("Send Passengers to the Thunderdome's Red Team")
			if(usr.buckled && istype(usr.buckled, /obj/structure/stool/bed/chair/vehicle/adminbus))
				var/obj/structure/stool/bed/chair/vehicle/adminbus/A = usr.buckled
				A.Sendto_Thunderdome_Arena_Red(usr)
		if("Split the Passengers between the two Thunderdome Teams")
			if(usr.buckled && istype(usr.buckled, /obj/structure/stool/bed/chair/vehicle/adminbus))
				var/obj/structure/stool/bed/chair/vehicle/adminbus/A = usr.buckled
				A.Sendto_Thunderdome_Arena(usr)
		if("Send Passengers to the Thunderdome's Green Team")
			if(usr.buckled && istype(usr.buckled, /obj/structure/stool/bed/chair/vehicle/adminbus))
				var/obj/structure/stool/bed/chair/vehicle/adminbus/A = usr.buckled
				A.Sendto_Thunderdome_Arena_Green(usr)
		if("Send Passengers to the Thunderdome's Observers' Lodge")
			if(usr.buckled && istype(usr.buckled, /obj/structure/stool/bed/chair/vehicle/adminbus))
				var/obj/structure/stool/bed/chair/vehicle/adminbus/A = usr.buckled
				A.Sendto_Thunderdome_Obs(usr)
		if("Capture Mobs")
			if(usr.buckled && istype(usr.buckled, /obj/structure/stool/bed/chair/vehicle/adminbus))
				var/obj/structure/stool/bed/chair/vehicle/adminbus/A = usr.buckled
				A.toggle_bumpers(usr,1)
		if("Hit Mobs")
			if(usr.buckled && istype(usr.buckled, /obj/structure/stool/bed/chair/vehicle/adminbus))
				var/obj/structure/stool/bed/chair/vehicle/adminbus/A = usr.buckled
				A.toggle_bumpers(usr,2)
		if("Gib Mobs")
			if(usr.buckled && istype(usr.buckled, /obj/structure/stool/bed/chair/vehicle/adminbus))
				var/obj/structure/stool/bed/chair/vehicle/adminbus/A = usr.buckled
				A.toggle_bumpers(usr,3)
		if("Close Door")
			if(usr.buckled && istype(usr.buckled, /obj/structure/stool/bed/chair/vehicle/adminbus))
				var/obj/structure/stool/bed/chair/vehicle/adminbus/A = usr.buckled
				A.toggle_door(usr,0)
		if("Open Door")
			if(usr.buckled && istype(usr.buckled, /obj/structure/stool/bed/chair/vehicle/adminbus))
				var/obj/structure/stool/bed/chair/vehicle/adminbus/A = usr.buckled
				A.toggle_door(usr,1)
		if("Turn Off Headlights")
			if(usr.buckled && istype(usr.buckled, /obj/structure/stool/bed/chair/vehicle/adminbus))
				var/obj/structure/stool/bed/chair/vehicle/adminbus/A = usr.buckled
				A.toggle_lights(usr,0)
		if("Dipped Headlights")
			if(usr.buckled && istype(usr.buckled, /obj/structure/stool/bed/chair/vehicle/adminbus))
				var/obj/structure/stool/bed/chair/vehicle/adminbus/A = usr.buckled
				A.toggle_lights(usr,1)
		if("Main Headlights")
			if(usr.buckled && istype(usr.buckled, /obj/structure/stool/bed/chair/vehicle/adminbus))
				var/obj/structure/stool/bed/chair/vehicle/adminbus/A = usr.buckled
				A.toggle_lights(usr,2)
		else
			return 0
	return 1

/obj/screen/inventory/Click()
	// At this point in client Click() code we have passed the 1/10 sec check and little else
	// We don't even know if it's a middle click
	if(usr.attack_delayer.blocked())
		return
	if(usr.stat || usr.paralysis || usr.stunned || usr.weakened)
		return 1
	if (istype(usr.loc,/obj/mecha)) // stops inventory actions in a mech
		return 1
	switch(name)
		if("r_hand")
			if(iscarbon(usr))
				var/mob/living/carbon/C = usr
				C.activate_hand("r")
				//usr.next_move = world.time+2
		if("l_hand")
			if(iscarbon(usr))
				var/mob/living/carbon/C = usr
				C.activate_hand("l")
				//usr.next_move = world.time+2
		if("swap")
			usr:swap_hand()
		if("hand")
			usr:swap_hand()
		else
			if(usr.attack_ui(slot_id))
				usr.update_inv_l_hand(0)
				usr.update_inv_r_hand(0)
				usr.delayNextAttack(6)
	return 1
