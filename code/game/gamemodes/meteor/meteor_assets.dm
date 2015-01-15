//This little beauty is where all the fun stuff that is mostly related to the Meteors gamemode happens. Welcome, take a seat and enjoy yourself

//Sometimes, you just want to sit in an armchair and still be useful. I'm sure those people will like this one !

var/list/meteormonitorlist = list() //Used to send ALL the information to the computers easily

/obj/machinery/computer/meteormonitor
	name = "meteor monitoring computer"
	desc = "Original design of Space Weather Incorportated. Allows you to use the station's arrays, radars and bluespace systems to keep a track of any meteor within 7 mUAs. Great for slumber parties"
	icon_state = "forensic" //Sprite used by the Bhangmeter. Feel free to make a new one
	circuit = "/obj/item/weapon/circuitboard/meteormonitor"

	//This is where we prepare all the data we're going to use in here. These are dumped from meteors.dm during meteor waves
	var/meteor_storm = 0 //IS EVERYTHING METEORS ? Set by Meteor Universal State
	var/emergency_warning = 0 //Set to 1 (True) if SOMETHING EVEN MORE SERIOUS THAN METEORS IS HAPPENING HOLY SHIT
	var/emergency_warning_type = 0 //WHAT IS IMPORTANT. 0 is nothing, 1 is stray meteor, 2 is supply drop
	var/meteor_wave_inbound = 0 //Self-explanatory. If meteors are inbound, then that's when most of the data is dumping
	var/meteor_wave_live = 0 //Small key to know if the wave we are dumping data about IS ACTUALLY STRIKING RIGHT NOW
	var/meteor_wave_dirinfo = "/unknown direction/" //Will directly output an usable string. How modern !
	var/meteor_wave_sizeinfo = 0 //How much meteors are we expecting ?
	var/meteor_wave_tod = "/ERROR/" //Real, english value for when we detect the wave. This is for fluff
	var/meteor_wave_strikedelay = 0 //How much time is left ? Uses the info above to generate a delay from time of detection (static)
	var/meteor_wave_name = "Database Error" //Because the most important thing is knowing the denomination what's just about to hit you !
	var/meteor_supplydrop_tag = "Illegal Tag Name" //What GPS you'll be looking for, duh

/obj/machinery/computer/meteormonitor/New()
	..()
	meteormonitorlist += src

/obj/machinery/computer/meteormonitor/Destroy()
	meteormonitorlist -= src
	..()

/obj/machinery/computer/meteormonitor/process()
	return PROCESS_KILL

/obj/machinery/computer/meteormonitor/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/meteormonitor/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/computer/meteormonitor/attack_hand(mob/user as mob)
	user.set_machine(src)
	interact(user)

/obj/machinery/computer/meteormonitor/interact(mob/user as mob)
	var/dat = "<title>Space Weather Inc. Meteor Monitor Prototype Mk.II</title><BR>"
	if(meteor_storm) //Are we on the Meteors gamemode ?
		dat += "<font color='red'>A meteor storm has been detected in this sector. Space Weather Inc. will do its best to guide you through this event if you are affected. Here are some basic instructions :<BR>"
		dat += "* Supplies have been deployed, or should deploy in an open, publicly reachable area of your station/outpost/ship. Please secure them as soon as possible, odds are you already have if you are reading this.<BR>"
		dat += "* Use the provided building materials to build barricades (reinforced plasma glass insulates from blasts and wood can be used to construct barricade kits, refer to engineering manuals)<BR>"
		dat += "* Use all other supplies to protect and save crewmen and keep morale up. Meteor storms are no breeze even for a veteran crew !<BR>"
		dat += "* A backup shuttle will be dispatched from our nearest sector outpost to pick the crew of your station/outpost/ship up. Stay firm, and good luck !.</font><BR>"
		dat += "_______________________________________________________<BR><BR>"
/* //Non-functional for the time being, because the related events aren't
	if(emergency_warning == 1)
		dat += "<font color='red'><B>Warning ! Please take immediate notice :"
		if(emergency_warning_type) //You can't be too safe
			switch(emergency_warning_type)
				//If staircases yeah !
				if(1)
					//Last indent I swear
					dat += "A large meteor has strayed off the main cluster's path. Direct impact expected at ([m_eventx], [m_eventy], [picked_meteor_area]) in [stray_meteor_delay/10] seconds. Clear the area immediately !</font><BR><BR>"
				if(2)
					dat += "Space Weather supplies have been beamed onto the station. A GPS beacon, tagged '[meteor_supplydrop_tag]', will lead you to the crate.</font><BR><BR>"
*/
	if(meteor_wave_inbound == 1) //Shit shit shit do we have meteors ?
		dat += "<font color='red'>[meteor_wave_tod] : Meteor wave (ID : [meteor_wave_name]) detected on collision course with the station. Outstanding information :</font><BR>"
		dat += "Three-dimensional triangulation and ballistic analysis show that the meteor wave will hit from the [meteor_wave_dirinfo] of this position.<BR>"
		dat += "Arrays detect [meteor_wave_sizeinfo] objects in [meteor_wave_name].<BR>"
		dat += "Registered delay to impact : [meteor_wave_live ? "<font color='red'>Live</font>":"[meteor_wave_strikedelay/10] seconds"].<BR>"
	else
		dat += "No major meteor wave detected. All is clear, for now !"

	user << browse(dat, "window=meteor monitor")
	onclose(user, "meteor monitor")
	return