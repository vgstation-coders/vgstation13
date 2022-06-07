/datum/role/grue
	name = GRUE
	id = GRUE
	special_role = GRUE
	required_pref = ROLE_GRUE
	wikiroute = ROLE_GRUE
	logo_state = "grue-logo"
	default_admin_voice = "Your Grue Instincts"
	admin_voice_style = "grue"
	var/eatencount=0
	var/spawncount=0

/datum/role/grue/Greet()
	to_chat(antag.current, "<span class='warning'>You are a grue.</span>")
	to_chat(antag.current, "<span class='warning'>Darkness is your ally; bright light is harmful to your kind. You hunger... specifically for sentient beings, but you are still young and cannot eat until you are more mature.</span>")
	to_chat(antag.current, "<span class='warning'>Bask in shadows to prepare to moult. The more sentient beings you eat, the more powerful you will become.</span>")

/datum/role/grue/ForgeObjectives(var/hatched) //Check if they hatched from an egg or spawned in
	if(hatched) //Assign it grue_basic objectives if its a hatched grue
		AppendObjective(/datum/objective/grue/grue_basic)
	else
		AppendObjective(/datum/objective/grue/eat_sentients)
		if(prob(50) && config.grue_egglaying)
			AppendObjective(/datum/objective/grue/spawn_offspring)

/datum/role/grue/GetScoreboard()
	. = ..()
	. += "The grue ate [eatencount] sentient being[eatencount==1 ? "" : "s"]"
	if(config.grue_egglaying)
		. += " and spawned [spawncount] offspring"
	. += ".<BR>"

