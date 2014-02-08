/obj/machinery/door/airlock/plasma
	name = "Plasma Airlock"
	desc = "No way this can end badly."
	icon = 'icons/obj/doors/Doorplasma.dmi'
	mineral = "plasma"

/obj/machinery/door/airlock/plasma/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)

/obj/machinery/door/airlock/plasma/proc/ignite(exposed_temperature)
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)

/obj/machinery/door/airlock/plasma/proc/PlasmaBurn(temperature)
	for(var/turf/simulated/floor/target_tile in range(2,loc))
//		if(target_tile.parent && target_tile.parent.group_processing) // THESE PROBABLY DO SOMETHING IMPORTANT BUT I DON'T KNOW HOW TO FIX IT - Erthilo
//			target_tile.parent.suspend_group_processing()
		var/datum/gas_mixture/napalm = new
		var/toxinsToDeduce = 35
		napalm.toxins = toxinsToDeduce
		napalm.temperature = 400+T0C
		target_tile.assume_air(napalm)
		spawn (0) target_tile.hotspot_expose(temperature, 400)
	for(var/obj/structure/falsewall/plasma/F in range(3,src))//Hackish as fuck, but until temperature_expose works, there is nothing I can do -Sieve
		var/turf/T = get_turf(F)
		T.ChangeTurf(/turf/simulated/wall/mineral/plasma/)
		del (F)
	for(var/turf/simulated/wall/mineral/plasma/W in range(3,src))
		W.ignite((temperature/4))//Added so that you can't set off a massive chain reaction with a small flame
	for(var/obj/machinery/door/airlock/plasma/D in range(3,src))
		D.ignite(temperature/4)
	new/obj/structure/door_assembly( src.loc )
	del (src)