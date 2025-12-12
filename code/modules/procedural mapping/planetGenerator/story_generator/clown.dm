/datum/story_theme/clown
	name = "clown"
	theme_flag = STORY_CLOWN
	hostile_mobs = list(
		/mob/living/simple_animal/hostile/retaliate/clown
	)
	corpse_types = list(
		/obj/effect/landmark/corpse/clown
	)

/datum/story_theme/clown/generate_character_name()
	if(clown_names?.len)
		character_name = pick(clown_names)
	else
		character_name = "Sprinkles the Clown"
	return character_name

/datum/story_theme/clown/get_log_info()
	var/list/titles = list(
		"The Banana Peel Chronicles",
		"The Honkening",
		"The Great Clown Escape",
		"Circus of the Stars",
		"The Jester's Journey",
		"How I Learned to Sotp Worry and Love the HONK",
		"A Clown's Tale by [character_name]"

	)
	return list("title" = pick_n_take(titles), "subtitle" = pick_n_take(titles))

/datum/story_theme/clown/get_generic_entries()
	return list(
		"HONK! So there I was, hiding in the escape pod to surprise the Captain, when SOMEONE jettisoned it! Now I'm stuck on '[planet_name]' with nothing but my oversized shoes and a single banana peel.",
		"Found an abandoned building! It's not as funny as the station but at least there's a roof. The local wildlife keeps staring at me. I honked at them but they didn't laugh. Tough crowd.",
		"Discovered some nerdy science stuff about [tech_name]. I don't understand any of it but it looked important so I pressed all the buttons. Something beeped! Maybe it was applause?",
		"Made a new friend today! It's a rock. I drew a face on it. Named it Chuckles. Chuckles doesn't laugh at my jokes either but at least Chuckles doesn't try to eat me.",
		"Tried to make a pie from local plants. It was not a pie. It was a war crime. Even Chuckles judged me.",
		"GOOD NEWS! Found a whoopee cushion in my pocket! Bad news: nobody to use it on. Used it on Chuckles. Chuckles was not amused.",
		"The building has a computer! It keeps talking about '[tech_name]' and 'research data'. I taught it to play circus music. MUCH better.",
		"Banana peel trap caught something! It was a weird bug thing. We stared at each other for a while. Then it left. Rude.",
		"Drew a clown face on the wall with berry juice. Finally, some proper decoration around here! This place was way too serious.",
		"Found more of that [tech_name] stuff. Still don't get it. Drew honk symbols on everything. Scientists love honk symbols, right?",
		"It's been [rand(5,50)] days. I've started doing stand-up for the local wildlife. They're heckling me. WITH THEIR EYES.",
		"The creatures are getting closer every night. I've set up banana peel traps everywhere but they just... step over them. WHO STEPS OVER A BANANA PEEL?!",
		"A ship spotted my emergency disco ball signal! They're sending a shuttle. [character_name] OUT! *bike horn noise*",
		"If anyone finds this, tell the galaxy that [character_name] died as they lived: confused and wearing big shoes. HONK...",
		"Tried juggling rocks to pass the time. Dropped one on my foot. Classic [character_name] comedy! ...ow.",
		"Found a mirror in the facility! Finally someone who appreciates my makeup. We did a routine together. Standing ovation (from me).",
		"The computer keeps asking for 'credentials'. I typed in 'HONK' 47 times. It eventually gave up and let me in. Persistence!",
		"Made a balloon animal from... something I found. It's either a dog or a giraffe. Or a very confused snake. Art is subjective!",
		"Tried to teach the local creatures the art of slapstick. They just stared. Everyone's a critic these days.",
		"Found the scientists' food supplies! It's all very serious. No space Twinkies anywhere. What kind of expedition doesn't bring space Twinkies?!",
		"Built a tiny circus tent out of lab coats. Chuckles is the main attraction. Ticket price: one (1) laugh. Business is slow.",
		"The night is scariest part. No audience, no laughter, just me and Chuckles and the weird noises outside. ...HONK."
	)

/datum/story_theme/clown/get_weather_entries()
	var/list/entries = list()
	switch(planet_style)
		if("lava planet")
			entries += "It's SO HOT my rubber nose is melting! This isn't funny! Wait, actually, my nose IS kind of funny looking now. HONK!"
			entries += "The ground keeps catching fire. My shoes are singed. Do you know how hard it is to find size 47 shoes?!"
		if("frozen planet")
			entries += "My tears are literally freezing on my face. Comedy through tragedy! That's art! ...I want to go home."
			entries += "Made a snowman! Named him Chuckles Jr. He laughed at my jokes! Then I realized it was just the wind. Sad HONK."
		if("desert planet")
			entries += "Sand. Everywhere. In my shoes, in my nose, probably in places I don't want to think about. NOT FUNNY."
			entries += "Found an oasis! It was a mirage. Classic desert joke. I'm not laughing though. Very thirsty."
		if("jungle planet")
			entries += "The humidity is making my wig droop! A clown's hair is their PRIDE. This planet has no respect for the art form."
			entries += "Got hit in the face by a vine. Then another vine. Then ANOTHER vine. Okay, that one was actually kind of funny. HONK!"
		if("wasteland planet")
			entries += "This place looks like the aftermath of the worst pie fight in history. Actually, that sounds amazing."
			entries += "Everything is dead here. The real tragedy is there's no one to appreciate my comedy. Waste of talent!"
		if("beach planet")
			entries += "Built a sand castle! Then the tide ate it. Just like my hopes and dreams. But funnier!"
			entries += "A crab stole my shoe! We had a standoff for three hours. The crab won. Honk of defeat."
		if("grass planet")
			entries += "Nice planet, actually. Good grass for pratfalls. Tested it extensively. Soft landing! HONK!"
			entries += "Found some flowers. Made a crown. I am now the Clown King of this meadow. My subjects are bugs. They seem unimpressed."
		if("unknown planet")
			entries += "This planet is WEIRD. Even for me. And I once juggled antimatter. (I don't recommend it.)"
			entries += "The sky is the wrong color. Or maybe my eyes are broken? Honked at it. No response. Rude planet."
	return entries

/datum/story_theme/clown/get_ruin_entries()
	var/list/entries = list()
	switch(ruin_name)
		if("bunker")
			entries += "This bunker is WAY too serious. I've been drawing smiley faces on all the guns. Much better! :)"
			entries += "Found a weapons locker. Turned it into a costume closet. Priorities!"
		if("cabin")
			entries += "Cozy cabin! Needs more color though. I've been redecorating with anything I can find. Abstract expressionism!"
			entries += "The fireplace is nice for roasting... I don't actually know how to cook. Burned water somehow."
		if("shrine")
			entries += "Found a shrine! Made an offering. It was my last pie. WORTH IT. Honkmother will be pleased."
			entries += "This place feels spiritual. I've been praying for a rescue ship with a good sense of humor."
		if("camp")
			entries += "Camping is fun! Said no one ever. Where's the room service? Where's the AUDIENCE?"
			entries += "Set up the tent wrong three times. Classic [character_name]! Fourth time's the charm. Or fifth. Lost count."
		if("greenhouse")
			entries += "So many plants! Tried talking to them. They're better listeners than most humans, honestly."
			entries += "Attempted to grow funny plants. They're just regular plants. Disappointing. No whoopee cushion seeds."
		if("workshop")
			entries += "TOOLS! I can make PROPS! Built a rubber chicken from scratch. Well, from metal scraps. It's... crunchy."
			entries += "Made a horn from spare parts. It doesn't HONK right but it does make a sound. A scary sound. Oops."
	return entries

/datum/story_theme/clown/get_fauna_entries()
	var/list/entries = list()
	switch(planet_style)
		if("beach planet")
			entries += "The crabs here walk sideways. I tried walking sideways too. We bonded. Then they pinched me. Friendship over!"
			entries += "Met a capybara! It just... sat there. Best audience I've had in weeks. 5 stars, would perform for again."
		if("desert planet")
			entries += "Lizards everywhere! Tried to put tiny hats on them. They were NOT cooperative. No appreciation for fashion."
			entries += "A big bug thing chased me for an hour. When I finally stopped running, it just... left. Was it playing? Do bugs play?!"
		if("frozen planet")
			entries += "Saw a big fluffy thing in the distance. Waved at it. It waved back! ...with its claws. Running now. HONK!"
			entries += "The animals here have SO much fur. I'm jealous. My costume is NOT rated for this temperature."
		if("grass planet")
			entries += "Found a cow thing! Tried to milk it. It was not a cow. It was VERY angry. Worth it for the comedy though."
			entries += "Birds here sing weird songs. Tried to teach them honking. Partial success? They make a 'SKRONK' noise now."
		if("jungle planet")
			entries += "MONKEYS! They understand comedy! One of them threw something at me. Beautiful slapstick! Proud of them."
			entries += "A big cat has been following me. Either it wants to eat me or it wants tickets to my show. Either way, scary!"
		if("lava planet")
			entries += "How do these things LIVE here? I can barely survive and I'm wearing protective (clown) gear!"
			entries += "Saw a creature literally swimming in lava. I can't even take a hot shower. Show-off."
		if("wasteland planet")
			entries += "Zombie things? ZOMBIE THINGS?! HONK HONK HONK! Not funny! NOT FUNNY!"
			entries += "Okay, the zombies can't catch me because my shoes make me run funny. So... silver lining?"
		if("unknown planet")
			entries += "I don't know WHAT these things are. They honk back at me though. Communication! Sort of!"
			entries += "Strange creature followed me home. It's purple. I named it Grape. Grape doesn't laugh but Grape doesn't try to eat me. Good enough!"
	return entries

/datum/story_theme/clown/get_loot_entries()
	var/list/entries = list()
	switch(planet_style)
		if("beach planet")
			entries += "Found beach balls! FINALLY something fun! Juggling practice has resumed. Chuckles is impressed. (Probably.)"
			entries += "Discovered a stash of tropical drinks. They've gone bad. Drank one anyway. Regrets."
		if("desert planet")
			entries += "Found tools! Made a shovel into a unicycle. Well, tried to. It's more of a... sharp wheel."
			entries += "Medical supplies! Bandaged Chuckles. He didn't need bandages but he looks cuter now."
		if("frozen planet")
			entries += "BLANKETS! So many blankets! Built a blanket fort. Best day since I got stranded. HONK!"
			entries += "Found frozen food. Don't need a freezer here! Planet IS the freezer! Modern problems require modern solutions."
		if("grass planet")
			entries += "Regular supplies. Boring. Drew funny faces on all the containers. Much better."
			entries += "Found games! Board games! I play against Chuckles. Chuckles keeps on winning somehow. Showoff."
		if("jungle planet")
			entries += "Everything is wet and moldy. Even my enthusiasm. Especially my enthusiasm."
			entries += "Found instruments! A little damp but functional! Formed a one-clown band. Audience: zero. Dreams: crushed."
		if("lava planet")
			entries += "Heat-proof stuff! My rubber nose no longer melts as fast. UPGRADE!"
			entries += "Found fancy tech. Don't know what it does but it lights up. Made it into a disco ball. PARTY!"
		if("wasteland planet")
			entries += "Found weapons. Turned them into juggling equipment. More fun this way!"
			entries += "Old vending machine! Kicked it until something came out. It was just dust. Sad HONK."
		if("unknown planet")
			entries += "Found weird glowing things. Attached them to my shoes. Now I have light-up clown shoes! AMAZING!"
			entries += "Strange objects everywhere. I don't know what any of them do. Neither did the scientists, apparently."
	return entries

/datum/story_theme/clown/get_main_ruin_entries()
	var/list/entries = list()
	switch(ruin_name)
		if("Geode")
			entries += "Found a GIANT SPARKLY ROCK! It's like a disco ball from space! Chuckles is JEALOUS. Not as pretty as Chuckles though. Don't tell the space rock I said that."
			entries += "The crystal cave is beautiful! I did a stand-up routine inside. The acoustics were AMAZING. The crystals didn't laugh but they sparkled. Close enough!"
			entries += "Tried to juggle some crystals from the geode. They're sharp. Hands are bleeding. Classic slapstick! HONK of pain!"
		if("Crashed Tradeship")
			entries += "Found a crashed ship! Cargo everywhere! Searched for rubber chickens - NONE. What kind of traders don't carry rubber chickens?! IRRESPONSIBLE."
			entries += "The crashed tradeship is sad. All that merchandise, no customers. I gave it a proper funeral. By which I mean I honked the ship's horn for an hour."
			entries += "Explored the tradeship wreck. Found a captain's hat! I am now CAPTAIN HONKBEARD. My crew is Chuckles. Chuckles is not impressed."
		if("Crashed Pod")
			entries += "Tiny crashed spaceship! Like a clown car but sadder! Only room for one person. How do you fit 27 clowns in THAT?!"
			entries += "The escape pod is dented in a funny shape! Looks like a sad face! Wait, that IS sad. Someone crashed. Hope they're okay. HONK of concern."
			entries += "Found an escape pod! No survivors. Just a single shoe. ONE SHOE. Even in tragedy, comedy. That's my philosophy."
		if("Abandoned Digsite")
			entries += "Someone was digging here! For WHAT? Buried treasure? Buried pies? Buried FUNNY? I must investigate! After my nap."
			entries += "The digsite is full of holes! Perfect for pratfalls! I fell in three of them! Comedy GOLDMINE! My ankle hurts."
			entries += "Archaeologists were here! Looking for OLD JOKES probably! Ancient humor! I could teach them SO MUCH! If they weren't gone."
		if("Alien Hive")
			entries += "NOPE. NOPE NOPE NOPE. Found an alien hive. You know what's NOT funny? Aliens. NOT. FUNNY. Running away now.  I had enough alien births in one lifetime thank you very much!"
			entries += "The alien nest thing is TERRIFYING. Tried to do a comedy routine to calm down. The aliens did NOT appreciate it. Still running."
			entries += "I have named the alien hive 'The No-Fun Zone.' Chuckles and I are NEVER going there. Not even for a pie. Well... maybe for a pie."
		if("The Buried Bar")
			entries += "A BAR! Underground! Best discovery EVER! Went to check for seltzer bottles. Found MANY! [character_name] is ARMED now! *maniacal honking*"
			entries += "The buried bar is my new favorite place! Someone left joke books! The jokes are OLD but classics never die! Like 'why did the clown go to the doctor'!"
			entries += "Spent three hours at the bar practicing my routine for the bottles. They were a GREAT audience. Very supportive. Very glass. HONK!"
		if("Cult Base")
			entries += "Found a spooky cult place! Drew clown faces on all their scary symbols! Much better! HONK of defiance! They worshipped wrong - should've worshipped comedy!"
			entries += "The cult base is CREEPY. But you know what scares away evil? LAUGHTER! I honked at every corner. Place is 100% clown-blessed now."
			entries += "Cult people have NO sense of humor. Found their robes. Tried them on. Made a GREAT cape. Chuckles says I look 'edgy.' Is that good?"
	return entries

/datum/story_theme/clown/get_stashed_loot_entries()
	var/list/entries = list()
	switch(stashed_loot_type)
		if(/datum/loot_table/weighted/bureaucracy)
			entries += "Found papers and pens! Drew honk symbols on EVERYTHING. Then stashed them. For later honks."
			entries += "Organized paperwork into a fort. Chuckles lives there now. It's administrative housing!"
		if(/datum/loot_table/weighted/combat)
			entries += "Weapons?! SELTZER BOTTLE UPGRADE TIME! ...oh these are real weapons. Less funny. Still stashed them though!"
			entries += "Made a pile of scary things near the wall. If something attacks, I'll throw them and RUN. HONK!"
		if(/datum/loot_table/decoration)
			entries += "PRETTY THINGS! Made this place look like a proper circus! Well... circusER. Stashed the extras!"
			entries += "Decorations! Finally some COLOR around here! Hid the best ones for special occasions."
		if(/datum/loot_table/engineering)
			entries += "Tools! I can fix my horn! I can make a NEW horn! I can make TEN HORNS! (stashed for horn emergencies)"
			entries += "Engineering stuff! Made a unicycle! It doesn't work! Stashed the parts for Attempt Two!"
		if(/datum/loot_table/entertainment)
			entries += "TOYS! GAMES! ACTUAL FUN THINGS! THIS IS THE BEST DAY! *carefully stashes everything* Mine now."
			entries += "Entertainment supplies! Chuckles and I can finally play cards! Chuckles keeps on winning somehow, I DON'T GET IT!"
		if(/datum/loot_table/weighted/exotic)
			entries += "Weird glowing stuff! Is it magic? Is it science? Is it a new comedy prop? STASHED FOR INVESTIGATION!"
			entries += "Found mysterious items! They might be valuable! They might explode! Either way, ENTERTAINING!"
		if(/datum/loot_table/weighted/medical)
			entries += "Bandages and medicine! For when the slapstick goes too far! (stashed near my sleeping spot)"
			entries += "Medical stuff! Can patch up Chuckles if he chips! ...can rocks chip? STASHED JUST IN CASE!"
		if(/datum/loot_table/module)
			entries += "Robot brain things! Maybe I can make a robot friend! A robot that APPRECIATES COMEDY! (stashed for later)"
			entries += "AI modules! Could teach an AI to tell jokes! ROBOT COMEDIAN! ...stashed until I figure out how computers work."
		if(/datum/loot_table/weighted/structure)
			entries += "Building stuff! I can make a BIGGER tent! A FUNNIER tent! Chuckles gets his own room!"
			entries += "Construction materials stashed! Planning to build a proper stage. Every clown needs a stage!"
		if(/datum/loot_table/trash)
			entries += "Garbage is just comedy props in disguise! Stashed the good trash. Threw away the bad trash. HONK!"
			entries += "One person's trash is another clown's treasure! Found THREE rubber bands! Jackpot!"
	return entries

/datum/story_theme/clown/get_disease_entry(var/disease_form)
	var/list/entries = list()
	switch(disease_form)
		if("Virus")
			entries = list(
				"ACHOO! Got the sniffles. My red nose is even REDDER now! ...wait, is that bad? HONK of concern!",
				"Feeling woozy. The room is spinning! Actually, that's kind of fun! Wheee! ...ow, fell over.",
				"This virus is NO JOKE! And I know jokes! My whole BODY is the punchline now and it's NOT FUNNY!",
				"Chuckles says I look pale. I told Chuckles I'm a CLOWN, we're SUPPOSED to look pale! ...but yeah, I feel terrible."
			)
		if("Bacteria")
			entries = list(
				"Something's infected! Probably from juggling questionable objects. Worth it? ...maybe not this time.",
				"Bacteria are like tiny unfunny clowns living inside me. EVICTION NOTICE! ...they're not listening.",
				"The infection is spreading. Drew a frowny face on the bandage. At least SOMETHING should express how I feel!",
				"Chuckles is worried about my wound. I told him it's just a flesh wound! He didn't laugh. Neither did I. Ow."
			)
		if("Parasite")
			entries = list(
				"Something's living in my tummy and it's NOT the butterflies from stage fright! UNINVITED GUEST! HONK!",
				"The parasite is making me hungry ALL the time. Ate my emergency pie. This is SERIOUS now.",
				"I can feel it wiggling! That's MY bit! Only I'M supposed to wiggle! COPYRIGHT INFRINGEMENT!",
				"Chuckles thinks I should see a doctor. I think doctors should see ME! ...performing. Once I'm better. If I get better."
			)
		if("Prion")
			entries = list(
				"Forgot my best joke today. THE BEST ONE. It had a punchline about... about... what was it about?",
				"My brain feels fuzzy. Fuzzier than my backup wig. That's VERY fuzzy. This isn't funny anymore.",
				"Can't remember if I fed Chuckles. Can't remember if Chuckles needs feeding. Can't remember what Chuckles is. ...rock?",
				"The thoughts come and go. Like an audience! Except the audience leaves and comes back. My thoughts just... leave. HONK?"
			)
		if("Fungus")
			entries = list(
				"Found mushrooms growing on my costume! Tried to make them into a hat. They're on my SKIN. Less fun now.",
				"The fungus is spreading! I'm becoming a fun-GUY! Get it? FUN-GUY? ...I'm scared, Chuckles.",
				"Itchy itchy ITCHY! Worse than that time I used poison ivy for a bouquet gag! MUCH worse!",
				"The mushrooms are pretty colors at least. Silver linings! ...the silver lining is I'm becoming a garden. HONK of existential crisis!"
			)
		else
			entries = list(
				"Don't feel so good. The show must go on though! *weak honk* ...okay maybe a short intermission.",
				"Sick as a dog! Wait, dogs are cute. Sick as a... mime? Yeah. Sick as a MIME. *shudders*",
				"Whatever this is, it's NOT funny. And I'm an EXPERT on what's funny! This is the opposite!",
				"Chuckles is being a good nurse. He just sits there, supportively. Because he's a rock. I love you, Chuckles."
			)
	return pick(entries)

/datum/story_theme/clown/on_ruin_placed(var/turf/ruin_turf)
	var/area/ruin_area = get_area(ruin_turf)
	if(!ruin_area)
		return

	var/list/valid_turfs = list()
	for(var/turf/simulated/floor/F in ruin_area)
		var/blocked = FALSE
		for(var/atom/A in F)
			if(A.density)
				blocked = TRUE
				break
		if(!blocked)
			valid_turfs += F

	var/num_peels = rand(3, 8)
	for(var/i in 1 to min(num_peels, valid_turfs.len))
		var/turf/spawn_turf = pick_n_take(valid_turfs)
		new /obj/item/weapon/bananapeel(spawn_turf)
