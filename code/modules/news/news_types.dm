#define DEFAULT 1

#define ADMINISTRATIVE 2
#define CLOTHING 3
#define SECURITY 4
#define SPECIAL_SECURITY 5

#define FOOD 6
#define ANIMALS 7

#define MINERALS 8

#define EMERGENCY 9
#define GAS 10
#define MAINTENANCE 11
#define ELECTRICAL 12
#define ROBOTICS 13
#define BIOMEDICAL 14

#define GEAR_EVA 15

// This system defines news that will be displayed in the course of a round.
// Uses BYOND's type system to put everything into a nice format

/datum/feed_message/news
	author = "CentComm Minister of Information"
	body = "HOLY PINGAS WHAT A SCOOP" // filler
	headline = "THIS JUST IN"
	var/channel_name = "Tau Ceti Daily"
	var/update_type // message to come after this
	var/update_delay_min
	var/update_delay_max // amount of time later it comes
	var/datum/trade_destination/affected_dest

/datum/feed_message/news/New(var/datum/trade_destination/dest)
	..()
	affected_dest = dest || pickweight(weighted_mundaneevent_locations)

// the below three were originally from revs game mode, if anyone wants to work them back into it
/datum/feed_message/news/misc/paycuts_suspicion
	headline = "Nanotrasen - Paycuts rumoured on all stations due to lack of profit"
	body = {"Reports have leaked that Nanotrasen Inc. is planning to put paycuts into
				effect on many of its Research Stations in Tau Ceti. Apparently these research
				stations haven't been able to yield the expected revenue, and thus adjustments
				have to be made."}
	author = "Unauthorized"
	update_type = /datum/feed_message/news/misc/paycuts_confirmation
	update_delay_min = 20 MINUTES
	update_delay_max = 40 MINUTES

/datum/feed_message/news/misc/paycuts_confirmation
	headline = "Nanotrasen - Paycuts confirmed, head of staff exempt"
	body = {"Earlier rumours about paycuts on Research Stations in the Tau Ceti system have
				been confirmed. Shockingly, however, the cuts will only affect lower tier
				personnel. Heads of Staff will, according to our sources, not be affected."}
	author = "Unauthorized"
	update_type = /datum/feed_message/news/misc/human_experiments
	update_delay_min = 40 MINUTES
	update_delay_max = 60 MINUTES

/datum/feed_message/news/misc/human_experiments
	headline = "Nanotrasen suspected to be experimenting on humans!"
	body = {"Unbelievable reports about human experimentation have reached our ears. According
				to a refugee from one of the Tau Ceti Research Stations, their station, in order
				to increase revenue, has refactored several of their facilities to perform experiments
				on live humans, including virology research, genetic manipulation, and \"feeding them
				to the slimes to see what happens\". Allegedly, these test subjects were neither
				humanified monkeys nor volunteers, but rather unqualified staff that were forced into
				the experiments, and reported to have died in a \"work accident\" by Nanotrasen Inc."}
	author = "Unauthorized"

/datum/feed_message/news/misc/bluespace_research
	headline = "Bluespace transportation research in full drive"
	body = {"The new field of research trying to explain several interesting spacetime oddities,
				also known as \"Bluespace Research\", has reached new heights. Of the several
				hundred space stations now orbiting in Tau Ceti, fifteen are now specially equipped
				to experiment with and research Bluespace effects. Rumours have it some of these
				stations even sport functional \"travel gates\" that can instantly move a whole research
				team to an alternate reality."}

/datum/feed_message/news/misc/found_ssd
	channel_name = "Tau Ceti Daily"
	author = "Doctor Eric Hanfield"
	headline = "Crew consciousness issues - A root cause?"
	body = {"Several people have been found unconscious at their terminals. It is thought that it was due
				to a lack of sleep or of simply migraines from staring at the screen too long. Camera footage
				reveals that many of them were playing games instead of working and their pay has been docked
				accordingly."}

/datum/feed_message/news/misc/explosions
	channel_name = "Tau Ceti Daily"
	author = "Reporter Leland H. Howards"
	headline = "Explosions on Lotus Tree - 50 dead at least"
	body = {"The newly-christened civillian transport Lotus Tree suffered two very large explosions near the
				bridge today, and there are unconfirmed reports that the death toll has passed 50. The cause of
				the explosions remain unknown, but there is speculation that it might have something to do with
				the recent change of regulation in the Moore-Lee Corporation, a major funder of the ship, when M-L
				announced that they were officially acknowledging inter-species marriage and providing couples
				with marriage tax-benefits."}

/datum/feed_message/news/misc/food_riots
	channel_name = "Tau Ceti Daily"
	author = "Reporter Ro'kii Ar-Raqis"
	headline = "Food riots engulf Tenebrae"
	body = {"Breaking news: Food riots have broken out throughout the Refuge asteroid colony in the Tenebrae
				Lupus system. This comes only hours after Nanotrasen officials announced they will no longer trade with the
				colony, citing the increased presence of \"hostile factions\" on the colony has made trade too dangerous to
				continue. Nanotrasen officials have not given any details about said factions. More on that at the top of
				the hour."}
	update_type = /datum/feed_message/news/misc/more_food_riots
	update_delay_min = 40 MINUTES
	update_delay_max = 60 MINUTES

/datum/feed_message/news/misc/more_food_riots
	channel_name = "Tau Ceti Daily"
	author = "Reporter Ro'kii Ar-Raqis"
	headline = "Food riots on Tenebrae intensify"
	body = {"More on the Refuge food riots: The Refuge Council has condemned Nanotrasen's withdrawal from
	the colony, claiming \"there has been no increase in anti-Nanotrasen activity\", and \"\[the only] reason
	Nanotrasen withdrew was because the \[Tenebrae Lupus] system's Plasma deposits have been completely mined out.
	We have little to trade with them now\". Nanotrasen officials have denied these allegations, calling them
	\"further proof\" of the colony's anti-Nanotrasen stance. Meanwhile, Refuge Security has been unable to quell
	the riots. More on this at 6."}

/datum/feed_message/news/event
	is_admin_message = 1
	var/list/cheaper_goods = list()
	var/list/dearer_goods = list()

/datum/feed_message/news/event/riots
	dearer_goods = list(SECURITY)
	cheaper_goods = list(MINERALS, FOOD)

/datum/feed_message/news/event/riots/New(var/datum/trade_destination/dest)
	..()
	headline = "[pick("Unrest","Riots")] on [affected_dest.name] affect stock supply"
	body = "[pick("Riots have","Unrest has")] broken out on planet [affected_dest.name]. Authorities call for calm, as [pick("various parties","rebellious elements","peacekeeping forces","\'REDACTED\'")] begin stockpiling weaponry and armour. Meanwhile, food and mineral prices are dropping as local industries attempt empty their stocks in expectation of looting."

/datum/feed_message/news/event/animal_attack
	cheaper_goods = list(ANIMALS)
	dearer_goods = list(FOOD, BIOMEDICAL)

/datum/feed_message/news/event/animal_attack/New(var/datum/trade_destination/dest)
	..()
	headline = "Feral wildlife on [affected_dest.name] attacks food stockpiles"
	body = "Local [pick("wildlife","animal life","fauna")] on planet [affected_dest.name] has been increasing in agression and raiding outlying settlements for food. Big game hunters have been called in to help alleviate the problem, but numerous injuries have already occurred."

/datum/feed_message/news/event/accident
	dearer_goods = list(EMERGENCY, BIOMEDICAL, ROBOTICS)

/datum/feed_message/news/event/accident/New(var/datum/trade_destination/dest)
	..()
	body = "[pick("Industrial accident","Malfunction")] at [affected_dest.name] site causes [pick("large disaster","mass damage","mass destruction")]"
	body = "[pick("An industrial accident","A smelting accident","A malfunction","A malfunctioning piece of machinery","Negligent maintenance","A cooleant leak","A ruptured conduit")] at a [pick("factory","installation","power plant","dockyards")] on [affected_dest.name] resulted in severe structural damage and numerous injuries. Repairs are ongoing."

/datum/feed_message/news/event/biohazard
	dearer_goods = list(BIOMEDICAL, GAS)

/datum/feed_message/news/event/biohazard/New(var/datum/trade_destination/dest)
	..()
	headline = "Viral outbreak on [affected_dest.name] infects many"
	body = "[pick("A \'REDACTED\'","A biohazard","An outbreak","A virus")] on [affected_dest.name] has resulted in quarantine, stopping much shipping in the area. Although the quarantine is now lifted, authorities are calling for deliveries of medical supplies to treat the infected, and gas to replace contaminated stocks."

/datum/feed_message/news/event/pirates
	dearer_goods = list(SECURITY, MINERALS)

/datum/feed_message/news/event/pirates/New(var/datum/trade_destination/dest)
	..()
	headline = "[affected_dest.name] [pick("raided","ambushed","attacked")] by criminal elements"
	body = "[pick("Pirates","Criminal elements","A [pick("Syndicate","Donk Co.","Waffle Co.","\'REDACTED\'")] strike force")] have [pick("raided","blockaded","attempted to blackmail","attacked")] [affected_dest.name] today. Security has been tightened, but many valuable minerals were taken."

/datum/feed_message/news/event/corporate
	dearer_goods = list(SECURITY, MAINTENANCE)

/datum/feed_message/news/event/corporate/New(var/datum/trade_destination/dest)
	..()
	headline = "[affected_dest.name] [pick("raided","sieged","attacked")] by large scale rogue entities"
	body = "A small [pick("pirate","Cybersun Industries","Gorlex Marauders","Syndicate")] fleet has precise-jumped into proximity with [affected_dest.name], [pick("for a smash-and-grab operation","in a hit and run attack","in an overt display of hostilities")]. Much damage was done, and security has been tightened since the incident."

/datum/feed_message/news/event/alien_raiders
	dearer_goods = list(BIOMEDICAL, ANIMALS)
	cheaper_goods = list(GAS, MINERALS)

/datum/feed_message/news/event/alien_raiders/New(var/datum/trade_destination/dest)
	..()
	headline = "Alien raid, theft and kidnappings on [affected_dest.name]"
	if(prob(20))
		body = "The Tiger Co-operative have raided [affected_dest.name] today, no doubt on orders from their enigmatic masters. Stealing wildlife, farm animals, medical research materials and kidnapping civilians. Nanotrasen authorities are standing by to counter attempts at bio-terrorism."
	else
		body = "[pick("The alien species designated \'United Exolitics\'","The alien species designated \'REDACTED\'","An unknown alien species")] have raided [affected_dest.name] today, stealing wildlife, farm animals, medical research materials and kidnapping civilians. It seems they desire to learn more about us, so the Navy will be standing by to accomodate them next time they try."

/datum/feed_message/news/event/ai_liberation
	dearer_goods = list(EMERGENCY, GAS, MAINTENANCE)

/datum/feed_message/news/event/ai_liberation/New(var/datum/trade_destination/dest)
	..()
	headline = "[pick("Slicer","Hacker")] [pick("infests","infiltrates","compromises")] [pick("on-board A.I","defence systems")] on [affected_dest.name] causing mass death"
	body = "A [pick("\'REDACTED\' was detected on","S.E.L.F operative infiltrated","malignant computer virus was detected on","rogue [pick("slicer","hacker")] was apprehended on")] [affected_dest.name] today, and managed to infect [pick("\'REDACTED\'","a sentient sub-system","a class one AI","a sentient defence installation")] before it could be stopped. Many lives were lost as it systematically begin murdering civilians, and considerable work must be done to repair the affected areas."

/datum/feed_message/news/event/mourning
	cheaper_goods = list(MINERALS, MAINTENANCE)

/datum/feed_message/news/event/mourning/New(var/datum/trade_destination/dest)
	..()
	var/name = capitalize(pick(random_name(pick(MALE,FEMALE)), 40; "\'REDACTED\'"))
	headline = "Famous figure [name] dead at [rand(25,100)]"
	body = "[pick("The popular","The well-liked","The eminent","The well-known")] [pick("professor","entertainer","singer","researcher","public servant","administrator","ship captain","\'REDACTED\'")], [name] has [pick("passed away","committed suicide","been murdered","died in a freakish accident")] on [affected_dest.name] today. The entire planet is in mourning, and prices have dropped for industrial goods as worker morale drops."

/datum/feed_message/news/event/cult_cell
	dearer_goods = list(SECURITY, BIOMEDICAL, MAINTENANCE)

/datum/feed_message/news/event/cult_cell/New(var/datum/trade_destination/dest)
	..()
	headline = "[pick("Blood c","C","Apocalyptic c")]ult cell [pick("discovered","revealed","exposed")] on [affected_dest.name]"
	body = "A [pick("dastardly","blood-thirsty","villanous","crazed")] cult of [pick("The Elder Gods","Nar'sie","an apocalyptic sect","\'REDACTED\'")] has [pick("been discovered","been revealed","revealed themselves","gone public")] on [affected_dest.name] earlier today. Public morale has been shaken due to [pick("certain","several","one or two")] [pick("high-profile","well known","popular")] individuals [pick("performing \'REDACTED\' acts","claiming allegiance to the cult","swearing loyalty to the cult leader","promising to aid to the cult")] before those involved could be brought to justice. The editor reminds all personnel that supernatural myths will not be tolerated on Nanotrasen facilities."

/datum/feed_message/news/event/breach
	dearer_goods = list(SECURITY)

/datum/feed_message/news/event/breach/New(var/datum/trade_destination/dest)
	..()
	headline = "[pick("Security breach","Prison break")] on [affected_dest.name] [pick("restricted","sensitive")] [pick("zone","area")]"
	body = "There was [pick("a security breach in","an unauthorised access in","an attempted theft in","an anarchist attack in","violent sabotage of")] a [pick("high-security","restricted access","classified","\'REDACTED\'")] [pick("\'REDACTED\'","section","zone","area")] this morning. Security was tightened on [affected_dest.name] after the incident, and the editor reassures all Nanotrasen personnel that such lapses are rare."

/datum/feed_message/news/event/animal_rights
	dearer_goods = list(ANIMALS)

/datum/feed_message/news/event/animal_rights/New(var/datum/trade_destination/dest)
	..()
	headline = "[pick("Animal","Animal rights")] breakout on [affected_dest.name]"
	body = "[pick("Militant animal rights activists","Members of the terrorist group Animal Rights Consortium","Members of the terrorist group \'REDACTED\'")] have [pick("launched a campaign of terror","unleashed a swathe of destruction","raided farms and pastures","forced entry to \'REDACTED\'")] on [affected_dest.name] earlier today, freeing numerous [pick("farm animals","animals","\'REDACTED\'")]. Prices for tame and breeding animals have spiked as a result."

/datum/feed_message/news/event/festival
	dearer_goods = list(FOOD, ANIMALS)

/datum/feed_message/news/event/festival/New(var/datum/trade_destination/dest)
	..()
	headline = "Festivities begin on [affected_dest.name]"
	body = "A [pick("festival","week long celebration","day of revelry","planet-wide holiday")] has been declared on [affected_dest.name] by [pick("Governor","Commissioner","General","Commandant","Administrator")] [random_name(pick(MALE,FEMALE))] to celebrate [pick("the birth of their [pick("son","daughter")]","coming of age of their [pick("son","daughter")]","the pacification of rogue military cell","the apprehension of a violent criminal who had been terrorising the planet")]. Massive stocks of food and meat have been bought driving up prices across the planet."

/datum/feed_message/news/mundane
	is_admin_message = 1

/datum/feed_message/news/mundane/research/New(var/datum/trade_destination/dest)
	..()
	headline = "Major [pick("science","research")] [pick("breakthrough","find","discovery")] on [affected_dest.name]"
	body = "A major breakthough in the field of [pick("plasma research","super-compressed materials","nano-augmentation","bluespace research","volatile power manipulation")] \
				was announced [pick("yesterday","a few days ago","last week","earlier this month")] by a private firm on [affected_dest.name]. \
				Nanotrasen declined to comment as to whether this could impinge on profits."

/datum/feed_message/news/mundane/bargains/New(var/datum/trade_destination/dest)
	..()
	headline = "[pick("BIG SALE NOW ON","BARGAINS DOWN","PRICES GALORE")] at [affected_dest.name]!"
	body = "BARGAINS! BARGAINS! BARGAINS! Commerce Control on [affected_dest.name] wants you to know that everything must go! Across all retail centres, \
				all goods are being slashed, and all retailors are onboard - so come on over for the \[shopping\] time of your life."

/datum/feed_message/news/mundane/song/New(var/datum/trade_destination/dest)
	..()
	var/name = random_name(pick(MALE,FEMALE))
	var/title = "[pick("single","album","EP","label")] '[pick("Everyone's","Look at the","Baby don't eye those","All of those","Dirty nasty")] \
				[pick("roses","three stars","starships","nanobots","cyborgs","Skrell","Sren'darr")] \
				[pick("on Venus","on Reade","on Moghes","in my hand","slip through my fingers","die for you","sing your heart out","fly away")]'"
	headline = "Musician [name] to release new [title] in [rand(5,20)] days"
	body = "[pick("Singer","Singer/songwriter","Saxophonist","Pianist","Guitarist","TV personality","Star")] [name] \
				announced the debut of their new [title] \
				with [pick("pre-puchases available","a release tour","cover signings","a launch concert")] on [affected_dest.name]."

/datum/feed_message/news/mundane/movie/New(var/datum/trade_destination/dest)
	..()
	var/name = random_name(pick(MALE,FEMALE))
	var/title = "[pick("Deadly","The last","Lost","Dead")] [pick("Starships","Warriors","outcasts","Tajarans","Unathi","Skrell")] \
				[pick("of","from","raid","go hunting on","visit","ravage","pillage","destroy")] \
				[pick("Moghes","Earth","Biesel","Ahdomai","S'randarr","the Void","the Edge of Space")]"
	headline = "[name] to be involved in new movie `[title]` soon"
	body = "From the [pick("desk","home town","homeworld","mind")] of [pick("acclaimed","award-winning","popular","stellar")] \
				[pick("playwright","author","director","actor","TV star")] [name] comes the latest sensation: '[title]'.\
				. Own it on webcast today, or visit the galactic premier on [affected_dest.name]!"

/datum/feed_message/news/mundane/hunt/New(var/datum/trade_destination/dest)
	..()
	body = "Game hunters on [affected_dest.name] "
	if(prob(33))
		headline = "[pick("Animal","Game",affected_dest.name)] hunters [pick("make big discovery","bag trophy prize","win big")]"
		body += "were surprised when an unusual species experts have since identified as \
		[pick("a subclass of mammal","a divergent abhuman species","an intelligent species of lemur","organic/cyborg hybrids")] turned up. Believed to have been brought in by \
		[pick("alien smugglers","early colonists","syndicate raiders","unwitting tourists")], this is the first such specimen discovered in the wild."
	else if(prob(50))
		var/adversary = pick("nas'r","diyaab","samak","predator which has not yet been identified")
		headline = "[pick("Brave","Game",affected_dest.name)] hunters [pick("attacked","mauled","ambushed")] by [adversary]"
		body += "were attacked by a vicious [adversary]\
		. Officials urge caution, and locals are advised to stock up on armaments."
	else
		headline = "[pick("Animal","Game",affected_dest.name)] hunters [pick("break new record","find large specimen","get their big break")]"
		body += "brought in an unusually [pick("valuable","rare","large","vicious","intelligent")] [pick("mammal","predator","farwa","samak")] for inspection \
		[pick("today","yesterday","last week")]. Speculators suggest they may be tipped to break several records."

/datum/feed_message/news/mundane/election/New(var/datum/trade_destination/dest)
	..()
	headline = "[pick("Election night","Fear and loathing","Locals go to the polls","Big vote")] on the [affected_dest.name] campaign trail"
	body = "The pre-selection of an additional candidates was announced for the upcoming [pick("supervisors council","advisory board","governership","board of inquisitors")] \
				election on [affected_dest.name] was announced earlier today, \
				[pick("media mogul","web celebrity", "industry titan", "superstar", "famed chef", "popular gardener", "ex-army officer", "multi-billionaire")] \
				[random_name(pick(MALE,FEMALE))]. In a statement to the media they said '[pick("My only goal is to help the [pick("sick","poor","children")]",\
				"I will maintain Nanotrasen's record profits","I believe in our future","We must return to our moral core","Just like... chill out dudes")]'."

/datum/feed_message/news/mundane/gossip/New(var/datum/trade_destination/dest)
	..()
	var/name = random_name(pick(MALE,FEMALE))
	headline = "[pick("The latest scoop on [name]!","[name]'s dirty little [pick("secret","affair")]","Quasi-legal intel on [name]'s private life","We wiretapped [name]'s PDA message and found this. What you gonna do about it?","New very super seriously important news on [name]")]"
	body = "[pick("TV host","Webcast personality","Superstar","Model","Actor","Singer")] [name] "
	if(prob(33))
		body += "and their partner announced the birth of their [pick("first","second","third")] child on [affected_dest.name] early this morning. \
		Doctors say the child is well, and the parents are considering "
		if(prob(50))
			body += capitalize(pick(first_names_female))
		else
			body += capitalize(pick(first_names_male))
		body += " for the name."
	else if(prob(50))
		body += "announced their [pick("split","break up","marriage","engagement")] with [pick("TV host","webcast personality","superstar","model","actor","singer")] \
		[random_name(pick(MALE,FEMALE))] at [pick("a society ball","a new opening","a launch","a club")] on [affected_dest.name] yesterday, pundits are shocked."
	else

		body += {"is recovering from plastic surgery in a clinic on [affected_dest.name] for the [pick("second","third","fourth")] time, reportedly having made the decision in response to
			[pick("unkind comments by an ex","rumours started by jealous friends","the decision to be dropped by a major sponsor","a disasterous interview on Tau Ceti Tonight")]."}


/datum/feed_message/news/mundane/tourism/New(var/datum/trade_destination/dest)
	..()
	headline = "[pick("Come see","A trip to","Tours now available for new event on","Why to visit")] [affected_dest.name]"
	body = "Tourists are flocking to [affected_dest.name] after the surprise announcement of [pick("major shopping bargains by a wily retailer",\
				"a huge new ARG by a popular entertainment company","a secret tour by popular artiste [random_name(pick(MALE,FEMALE))]")]. \
				Tau Ceti Daily is offering discount tickets for two to see [random_name(pick(MALE,FEMALE))] live in return for eyewitness reports and up to the minute coverage."

/datum/feed_message/news/mundane/celeb_death/New(var/datum/trade_destination/dest)
	..()
	var/name = "[random_name(pick(MALE,FEMALE))]"
	headline = "[name] has [pick("passed","died","been found dead")]"
	body = "It is with regret today that we announce the sudden passing of the "
	if(prob(33))
		body += "[pick("distinguished","decorated","veteran","highly respected")] \
		[pick("Ship's Captain","Vice Admiral","Colonel","Lieutenant Colonel")] "
	else if(prob(50))
		body += "[pick("award-winning","popular","highly respected","trend-setting")] \
		[pick("comedian","singer/songwright","artist","playwright","TV personality","model")] "
	else
		body += "[pick("successful","highly respected","ingenious","esteemed")] \
		[pick("academic","Professor","Doctor","Scientist")] "

	body += "[name] on [affected_dest.name] [pick("last week","yesterday","this morning","two days ago","three days ago")]\
	[pick(". Assassination is suspected, but the perpetrators have not yet been brought to justice",\
	" due to Syndicate infiltrators (since captured)",\
	" during an industrial accident",\
	" due to [pick("heart failure","kidney failure","liver failure","brain hemorrhage")]")]"

/datum/feed_message/news/mundane/resignation/New(var/datum/trade_destination/dest)
	..()
	var/name = "[random_name(pick(MALE,FEMALE))]"
	headline = "Nanotrasen Admiral [name] [pick("resigns","calls it quits","retires")]"
	body = "Nanotrasen regretfully announces the resignation of [pick("Sector","Division","Ship","Vice")] Admiral [name]."
	if(prob(25))
		var/locstring = pick("Segunda","Salusa","Cepheus","Andromeda","Gruis","Corona","Aquila","Asellus") + " " + pick("I","II","III","IV","V","VI","VII","VIII")
		body += " In a ceremony on [affected_dest.name] this afternoon, they will be awarded the \
		[pick("Red Star of Sacrifice","Purple Heart of Heroism","Blue Eagle of Loyalty","Green Lion of Ingenuity")] for "
		if(prob(33))
			body += "their actions at the Battle of [pick(locstring,"REDACTED")]."
		else if(prob(50))
			body += "their contribution to the colony of [locstring]."
		else
			body += "their loyal service over the years."
	else if(prob(33))
		body += " They are expected to settle down in [affected_dest.name], where they have been granted a handsome pension."
	else if(prob(50))
		body += " The news was broken on [affected_dest.name] earlier today, where they cited reasons of '[pick("health","family","REDACTED")]'"
	else
		body += " Administration Aerospace wishes them the best of luck in their retirement ceremony on [affected_dest.name]."

/datum/feed_message/news/trivial
	channel_name = "The Gibson Gazette"
	//is_admin_message = 1

/datum/feed_message/news/trivial/New(var/datum/trade_destination/dest)
	..()
	author = pick("Editor Mike Hammers","Assistant Editor Carl Ritz")
	headline = "[pick("The [pick("daily","weekly")] round-up","The latest run-down","The current events","BREAKING NEWS PLEASE SELECT THIS STORY ON ALL CASTERS...","The update","Stories you can't read anywhere else...","The news they didn't want you to know","This [pick("day","week")] in [pick("science","information","the news","the happenings","the headlines","the story","stupid","insanity","boredom","shame","confusion","hilarity","the vast nothingness of space")]")] on [affected_dest.name]!"
	body = ""
	var/list/thenews = file2list("config/news/trivial.txt")
	for(var/i in 1 to rand(3,5))
		body += "/ [pick_n_take(thenews)] /" // because newlines don't work, this will have to do
	body = replacetext(body,"{{AFFECTED}}",affected_dest.name)
