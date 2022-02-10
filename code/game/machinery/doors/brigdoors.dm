//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

///////////////////////////////////////////////////////////////////////////////////////////////
// Brig Door control displays.
//  Description: This is a controls the timer for the brig doors, displays the timer on itself and
//               has a popup window when used, allowing to set the timer.
//  Code Notes: Combination of old brigdoor.dm code from rev4407 and the status_display.dm code
//  Date: 01/september/2010
//  Programmer: Veryinky
/////////////////////////////////////////////////////////////////////////////////////////////////
/obj/machinery/door_timer
	name = "Door Timer"
	icon = 'icons/obj/status_display.dmi'
	icon_state = "frame"
	desc = "A remote control for a door."
	req_access = list(access_brig)
	anchored = TRUE
	density = FALSE
	var/timeleft = 0		// in seconds
	var/timing = FALSE
	var/picture_state		// icon_state of alert picture, if not displaying text/numbers
	var/list/obj/machinery/targets = list()
	var/last_call = 0
	layer = ABOVE_WINDOW_LAYER

/obj/machinery/door_timer/New()
	..()
	machines -= src
	fast_objects += src //process every 0.5 instead of every 2

/obj/machinery/door_timer/Destroy()
	fast_objects -= src
	..()

/obj/machinery/door_timer/initialize()
	..()

	pixel_x = ((src.dir & 3)? (0) : (src.dir == 4 ? WORLD_ICON_SIZE : -WORLD_ICON_SIZE))
	pixel_y = ((src.dir & 3)? (src.dir ==1 ? WORLD_ICON_SIZE : -WORLD_ICON_SIZE) : (0))

	for(var/obj/machinery/door/window/brigdoor/M in all_doors)
		if (M.id_tag == src.id_tag)
			targets += M
			M.open() //these start the shift open

	for(var/obj/machinery/flasher/F in flashers)
		if(F.id_tag == src.id_tag)
			targets += F

	for(var/obj/structure/closet/secure_closet/brig/C in brig_lockers)
		if(C.id_tag == src.id_tag)
			targets += C

	if(targets.len==0)
		stat |= BROKEN
	update_icon()

//Main door timer loop, if it's timing and time is >0 reduce time by 1.
// if it's less than 0, open door, reset timer
// update the door_timer window and the icon
/obj/machinery/door_timer/process()
	if((stat & (FORCEDISABLE|NOPOWER|BROKEN)) || !timing)
		return
	if(timeleft <= 0)
		timer_end() // open doors, reset timer, clear status screen
		timing = FALSE
		return
	timeleft -= (SS_WAIT_FAST_OBJECTS/(1 SECONDS)) //this is a fast object
	updateUsrDialog()
	update_icon()


// has the door power sitatuation changed, if so update icon.
/obj/machinery/door_timer/power_change()
	..()
	update_icon()

// open/closedoor checks if door_timer has power, if so it checks if the
// linked door is open/closed (by density) then opens it/closes it.
/obj/machinery/door_timer/proc/timer_start()
	if(stat & (FORCEDISABLE|NOPOWER|BROKEN))
		return 0

	for(var/obj/machinery/door/window/brigdoor/door in targets)
		if(door.density)
			continue
		spawn(0)
			door.close()

	for(var/obj/structure/closet/secure_closet/brig/C in targets)
		if(C.broken)
			continue
		if(C.opened && !C.close())
			continue
		C.locked = 1
		C.icon_state = C.icon_locked
	return 1


/obj/machinery/door_timer/proc/timer_end()
	if(stat & (FORCEDISABLE|NOPOWER|BROKEN))
		return 0

	for(var/obj/machinery/door/window/brigdoor/door in targets)
		if(!door.density)
			continue
		spawn(0)
			door.open()

	for(var/obj/structure/closet/secure_closet/brig/C in targets)
		if(C.broken)
			continue
		if(C.opened)
			continue
		C.locked = 0
		C.icon_state = C.icon_closed

	timeleft = 0

	update_icon()

	return 1

/obj/machinery/door_timer/proc/timeset(var/seconds)
	timeleft = seconds


//Allows humans to use door_timer
//Opens dialog window when someone clicks on door timer
// Allows altering timer and the timing boolean.
// Flasher activation limited to 15 seconds
/obj/machinery/door_timer/attack_hand(var/mob/user as mob)
	if(..())
		return
	user.set_machine(src)
	var/dat = "<HTML><BODY><TT>"

	dat += {"<HR>Timer System:</hr>
		<b>Door [src.id_tag] controls</b><br/>"}
	if (src.timing)
		dat += "<a href='?src=\ref[src];timing=0'>Stop Timer and open door</a><br/>"
	else
		dat += "<a href='?src=\ref[src];timing=1'>Activate Timer and close door</a><br/>"


	dat += {"Time Left: [timeleft / 60 % 60]:[add_zero(num2text(timeleft % 60), 2)] <br/>
			<a href='?src=\ref[src];tp=-60'>-</a> <a href='?src=\ref[src];tp=-1'>-</a> <a href='?src=\ref[src];tp=1'>+</a> <A href='?src=\ref[src];tp=60'>+</a><br/>"}
	for(var/obj/machinery/flasher/F in targets)
		if(F.last_flash && (F.last_flash + 15 SECONDS) > world.timeofday)
			dat += "<br/><A href='?src=\ref[src];fc=1'>Flash Charging</A>"
		else
			dat += "<br/><A href='?src=\ref[src];fc=1'>Activate Flash</A>"


	dat += {"<br/><br/><a href='?src=\ref[user];mach_close=computer'>Close</a>
			</TT></BODY></HTML>"}
	user << browse(dat, "window=computer;size=400x500")
	onclose(user, "computer")


//Function for using door_timer dialog input, checks if user has permission
// href_list to
//  "timing" turns on timer
//  "tp" value to modify timer
//  "fc" activates flasher
// Also updates dialog window and timer icon
/obj/machinery/door_timer/Topic(href, href_list)
	if(..())
		return
	if(!src.allowed(usr))
		to_chat(usr, "<span class='warning'>Access denied.</span>")
		return

	usr.set_machine(src)
	if(href_list["timing"])
		timing = text2num(href_list["timing"])
	else if(href_list["tp"])
		timeleft += text2num(href_list["tp"])
		timeleft = clamp(round(timeleft), 0, 3600)
	else if(href_list["fc"])
		for(var/obj/machinery/flasher/F in targets)
			F.flash()
	add_fingerprint(usr)
	updateUsrDialog()
	update_icon()
	if(timing)
		timer_start()

//icon update function
// if NOPOWER, display blank
// if BROKEN, display blue screen of death icon AI uses
// if timing=true, run update display function
/obj/machinery/door_timer/update_icon()
	if(stat & (FORCEDISABLE|NOPOWER))
		icon_state = "frame"
		return
	if(stat & (BROKEN))
		set_picture("ai_bsod")
		return
	if(timing)
		var/disp1 = uppertext(id_tag)
		var/disp2 = "[add_zero(num2text((timeleft / 60) % 60),2)]~[add_zero(num2text(timeleft % 60), 2)]"
		spawn(0.5 SECONDS)
			update_display(disp1, disp2)
	else
		update_display("SET","TIME")


// Adds an icon in case the screen is broken/off, stolen from status_display.dm
/obj/machinery/door_timer/proc/set_picture(var/state)
	picture_state = state
	overlays.len = 0
	overlays += image('icons/obj/status_display.dmi', icon_state=picture_state)


//Checks to see if there's 1 line or 2, adds text-icons-numbers/letters over display
// Stolen from status_display
/obj/machinery/door_timer/proc/update_display(var/line1, var/line2)
	if(line2 == null)		// single line display
		overlays.len = 0
		overlays += texticon(line1, 23, -13)
	else					// dual line display
		overlays.len = 0
		overlays += texticon(line1, 23, -9)
		overlays += texticon(line2, 23, -17)
	// return an icon of a time text string (tn)
	// valid characters are 0-9 and :
	// px, py are pixel offsets


//Actual string input to icon display for loop, with 5 pixel x offsets for each letter.
//Stolen from status_display
/obj/machinery/door_timer/proc/texticon(var/tn, var/px = 0, var/py = 0)
	var/image/I = image('icons/obj/status_display.dmi', "blank")
	var/len = length(tn)

	for(var/d = 1 to len)
		var/char = copytext(tn, len-d+1, len-d+2)
		if(char == " ")
			continue
		var/image/ID = image('icons/obj/status_display.dmi', icon_state=char)
		ID.pixel_x = (-(d-1)*5 + px) * PIXEL_MULTIPLIER
		ID.pixel_y = py * PIXEL_MULTIPLIER
		I.overlays += ID
	return I


/obj/machinery/door_timer/cell_1
	name = "Cell 1"
	id_tag = "Cell 1"
	dir = 2
	pixel_y = -WORLD_ICON_SIZE


/obj/machinery/door_timer/cell_2
	name = "Cell 2"
	id_tag = "Cell 2"
	dir = 2
	pixel_y = -WORLD_ICON_SIZE


/obj/machinery/door_timer/cell_3
	name = "Cell 3"
	id_tag = "Cell 3"
	dir = 2
	pixel_y = -WORLD_ICON_SIZE


/obj/machinery/door_timer/cell_4
	name = "Cell 4"
	id_tag = "Cell 4"
	dir = 2
	pixel_y = -WORLD_ICON_SIZE


/obj/machinery/door_timer/cell_5
	name = "Cell 5"
	id_tag = "Cell 5"
	dir = 2
	pixel_y = -WORLD_ICON_SIZE


/obj/machinery/door_timer/cell_6
	name = "Cell 6"
	id_tag = "Cell 6"
	dir = 4
	pixel_x = WORLD_ICON_SIZE


/obj/machinery/door_timer/npc_tamper_act(mob/living/L)
	//Increase or decrease the release time by a random number
	timeleft = max(0, timeleft + rand(-60, 60)) //From -1 minute to 1 minute. Can't go below 0
	timer_start()

	if(prob(10)) //Flash the flashers
		for(var/obj/machinery/flasher/F in targets)
			F.flash()
