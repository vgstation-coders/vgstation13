/datum/clockcult_power/vitality_matrix
	name				= "Vitality Matrix"
	desc				= "Places a blue sigil at the initiator's feet, and magenta circles at the helpers' feet. The blue sigil drains life from any body on the circles, and completely restores a single body on top of it after receiving enough essence. Can be used to raise the dead. Overused bodies will be reduced to piles of bones, unable to be used further."
	category			= CLOCK_APPLICATIONS

	invocation			= "TODO"
	participants_min	= 2
	participants_max	= 5
	cast_time			= 5 SECONDS
	req_components		= list(CLOCK_VANGUARD = 3, CLOCK_HIEROPHANT = 1, CLOCK_GEIS = 1)
