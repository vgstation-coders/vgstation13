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
	if(map.climate)
		var/datum/climate/C = map.climate
		if(istype(C.current_weather,/datum/weather/snow)) //This is a snowmap!
			var/datum/weather/snow/S = C.current_weather
			var/reported_temp = S.temperature - 273.15
			var/reported_snow = S.snow_fluff_estimate
			var/remaining_time = formatTimeDuration(C.current_weather.timeleft)
			dat += "<b>Temperature:</b> <div class='line'>[reported_temp] Celcius</div>"
			dat += "<b>Snowfall:</b> <div class='line'>[reported_snow] </div>"
			dat += "<b>Next Meteorlogical Event:</b> <div class='line'>[remaining_time]</div>"
			dat += "<b>Forecasted Snowfall:</b> <div class='line'>"
			for(var/datum/weather/W in C.forecasts)
				dat += "[W.name] "
			dat += "</div></div></div></center>"
		else
			dat += "<b>Unknown Climate:</b> <div class='line'>Not configured for climate.</div></div></div></center>"
	else
		dat += "<b>Panic:</b> <div class='line'>No climate detected!</div></div></div></center>"
	dat = jointext(dat,"")
	var/datum/browser/popup = new(user, "climate", "Climate Monitoring Console", 325, 375, src)
	popup.set_content(dat)
	popup.open()
	onclose(user, "climate")