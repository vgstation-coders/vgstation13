/mob/living/carbon/complex
	var/icon_state_standing
	var/icon_state_lying
	var/icon_state_dead
	var/flag = 0
	var/oxygen_alert = 0
	var/toxins_alert = 0
	var/fire_alert = 0
	var/pressure_alert = 0
	base_insulation = 0.5
	var/temperature_alert = 0
	var/safe_oxygen_min = 16 // Minimum safe partial pressure of O2, in kPa
	var/co2overloadtime = null

/mob/living/carbon/complex/New()
	create_reagents(200)
	..()