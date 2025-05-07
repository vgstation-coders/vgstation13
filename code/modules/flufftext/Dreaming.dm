/mob/living/carbon/proc/dream()
	dreaming = 1
	var/list/dreams = list(
		"an ID card","a bottle","a familiar face","a crewmember","a toolbox","a security officer","the captain",
		"deep space","a doctor","the engine","a traitor","an ally","darkness","light","a scientist","a monkey",
		"a loved one","warmth","the sun","a hat","the Luna","a planet","plasma","air","the medical bay","the bridge",
		"blinking lights","a blue light","Nanotrasen","healing","power","respect","riches","space","happiness","pride",
		"water","melons","flying","the eggs","money","the head of personnel","the head of security","a chief engineer",
		"a research director","a chief medical officer","the detective","the warden","a member of the internal affairs",
		"a station engineer","the janitor","atmospheric technician","the quartermaster","a cargo technician","the botanist",
		"a shaft miner","a psychologist","the chemist","the geneticist","the virologist","the roboticist","the chef","the bartender",
		"the chaplain","the librarian","a mouse","an ert member","a beach","the holodeck","a smokey room","a mouse","the bar",
		"the rain","the ai core","the mining station","the research station","a beaker of strange liquid","a team","a man with a bad haircut",
		"the moons of jupiter","an old malfunctioning AI","a ship full of spiders","bork","a chicken","a supernova","lockers","ninjas",
		"chickens","the oven","euphoria","space god","farting","bones burning","flesh evaporating","distant worlds","skeletons",
		"voices everywhere","death","a traitor","dark allyways","darkness","a catastrophe","a gun","freezing","a ruined station","plasma fires",
		"an abandoned laboratory","The Syndicate","blood","falling","flames","ice","the cold","an operating table","a war","red men","malfunctioning robots",
		"valids","hardcore","your mom","lewd","explosions","broken bones","clowns everywhere","features","a crash","a skrell","a unathi","a tajaran",
		"a vox","a plasmaman","a skellington","a diona","the derelict","the end of the world","the thunderdome","a ship full of dead clowns","a chicken with godlike powers",
		"a red bus that drives through space","an alien artifact","the mechanic","a newspaper","an insectoid","a slime","a slime person","a mushroom person",
		"the Cult of Nar-Sie","the Wizard Federation","an impossibly gigantic lamprey floating through space, bending reality as it goes","a sword that talks",
		"an eclipse","a sandwich so tall that it pierces the heavens","things you people wouldn't believe","attack ships on fire off the shoulder of Orion","C-beams glittering in the dark near the Tannhäuser Gate",
		"the xenoarchaeologist", "the xenobiologist", "getting reincarnated in another world","a hat pile so tall that it pierces the heavens","a wheelchair ride pile so tall that it pierces the heavens",
		"bees","a cryptographic sequencer","the singularity","mr. clean","a dual sword made of pure energy","a welding tool being held to a fuel tank","a cascading supermatter sea",
		"a rat of incredible muscular mass","a cuban mariachi wearing a green mask",
		)
	spawn(0)
		for(var/i = rand(1,4),i > 0, i--)
			var/dream_image = pick(dreams)
			dreams -= dream_image
			to_chat(src, "<span class='notice'><i>... [dream_image] ...</i></span>")
			sleep(rand(40,70))
			if(paralysis <= 0)
				break
		dreaming = 0

/mob/living/carbon/proc/handle_dreams()
	if(prob(5) && !dreaming)
		dream()

/mob/living/carbon/var/dreaming = 0
