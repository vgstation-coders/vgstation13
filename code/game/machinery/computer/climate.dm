var/list/climatecomps = list()

/obj/machinery/computer/climate
	name = "climate monitoring console"
	desc = "A computer designed to report on the weather conditions nearby."
	icon = 'icons/obj/computer.dmi'
	icon_state = "climate"
	moody_state = "overlay_climate-wall"
	light_color = LIGHT_COLOR_CYAN
	circuit = "/obj/item/weapon/circuitboard/labor"

/obj/machinery/computer/climate/wall
	density = FALSE
	icon_state = "climate-wall"

/obj/machinery/computer/climate/New()
	..()
	climatecomps += src

/obj/machinery/computer/climate/Destroy()
	climatecomps -= src
	..()

/obj/machinery/computer/climate/attack_hand(var/mob/user as mob)
	if(..())
		return
	user.set_machine(src)
	var/dat = list()
	dat += "<center>"
	dat += "<div class='modal'><div class='modal-content'><div class='line'><b>Weather Report</b></div><br>"
	var/datum/climate/C = SSweather.get_climate(src.z)
	if(C?.current_weather)
		var/datum/weather/W = C.current_weather
		var/reported_temp = W.temperature - 273.15
		var/remaining_time = formatTimeDuration(W.timeleft)
		dat += "<b>Current Weather:</b> <div class='line'>[W.name]</div>"
		dat += "<b>Temperature:</b> <div class='line'>[reported_temp] Celcius</div>"
		dat += W.weather_details()
		dat += "<b>Next Meteorlogical Event:</b> <div class='line'>[remaining_time]</div>"
		dat += "<b>Forecasted Weather:</b> <div class='line'>"
		for(var/datum/weather/wnext in C.forecasts)
			dat += "[wnext.name] "
		dat += "</div></div></div></center>"
	else
		dat += "<b>Panic:</b> <div class='line'>No climate detected!</div></div></div></center>"
	dat = jointext(dat,"")
	var/datum/browser/popup = new(user, "climate", "Climate Monitoring Console", 325, 375, src)
	popup.set_content(dat)
	popup.open()
	onclose(user, "climate")
