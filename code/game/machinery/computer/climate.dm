/obj/machinery/computer/climate
	name = "climate monitoring console"
	desc = "A computer designed to report on the weather conditions nearby."
	icon = 'icons/obj/computer.dmi'
	icon_state = "climate"
	light_color = LIGHT_COLOR_CYAN
	circuit = "/obj/item/weapon/circuitboard/labor"
	var/reported_temp = T_ARCTIC
	var/reported_snow = "minimal"

/obj/machinery/computer/climate/New()
	..()
	climatecomps += src

/obj/machinery/computer/climate/Destroy()
	climatecomps -= src
	..()

/obj/machinery/computer/climate/attack_ai(var/mob/user as mob)
	add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/computer/climate/attack_hand(var/mob/user as mob)
	if(..())
		return
	user.set_machine(src)
	var/dat = list()
	dat += "<center>"
	dat += "<div class='modal'><div class='modal-content'><div class='line'><b>Weather Report</b></div><br>"
	dat += "<b>Temperature:</b> <div class='line'>[reported_temp-273.15] Celcius</div>"
	dat += "<b>Snowfall:</b> <div class='line'>[reported_snow] </div></div></div></center>"
	dat = jointext(dat,"")
	var/datum/browser/popup = new(user, "climate", "Climate Monitoring Console", 325, 350, src)
	popup.set_content(dat)
	popup.open()
	onclose(user, "climate")

/obj/machinery/computer/climate/proc/update_weather(var/intensity = SNOW_CALM)
	switch(intensity)
		if(SNOW_CALM)
			reported_temp = T_ARCTIC
			reported_snow = "minimal"

		if(SNOW_AVERAGE)
			reported_temp = T_ARCTIC-5
			reported_snow = "about 1.5cm/minute (light)"

		if(SNOW_HARD)
			reported_temp = T_ARCTIC-10
			reported_snow = "<span class='blob'>about 4.8cm/minute (heavy)</span>"

		if(SNOW_BLIZZARD)
			reported_temp = T_ARCTIC-20
			reported_snow = "<span class='danger'>about 10.8cm/minute (ALERT)</span>"