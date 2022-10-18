// Mobs

/mob/living/simple_animal/cat/lampy
	name = "Lampy"
	desc = "Everyone's favorite lamprey eel!"
	icon = 'icons/lamprey.dmi'
	icon_state = "lampy"
	icon_living = "lampy"
	icon_dead = "lampy_dead"
	gender = NEUTER
	speak = list("Glurp.", "Glorp.","Blurble.")
	speak_emote = list("warbles")
	emote_hear = list("warbles")
	emote_see = list("slithers")
	emote_sound = list() // stops snakes purring
	kill_verbs = list("chews on", "takes a bite out of", "bites", "eats")
	growl_verbs = list("screams")

	species_type = /mob/living/simple_animal/cat/lampy
	butchering_drops = null
	childtype = null
	holder_type = null

/mob/living/simple_animal/cat/lampy/can_ventcrawl()
	return TRUE

// Areas

/area/lamprey
	name = "area"
	icon = 'icons/lamprey.dmi'
	icon_state = "catchall"
	requires_power = 0
	anti_ethereal = 1

/area/lamprey/mining
	name = "Mining"
	icon_state = "mining"

/area/lamprey/kitchen
	name = "Kitchen"
	icon_state = "kitchen"

/area/lamprey/foreporthallways
	name = "Fore Port Hallways"
	icon_state = "foreporthallways"
	anti_ethereal = 0

/area/lamprey/ghettosecuritymaintenanceblob
	name = "Maintenance"
	icon_state = "ghettosecuritymaintenanceblob"

/area/lamprey/virology
	name = "Virology"
	icon_state = "virology"

/area/lamprey/permabrig
	name = "Permabrig"
	icon_state = "permabrig"

/area/lamprey/security
	name = "Security"
	icon_state = "security"

/area/lamprey/securestorage
	name = "Secure Storage"
	icon_state = "securestorage"

/area/lamprey/momminest
	name = "MoMMI Nest"
	icon_state = "momminest"

/area/lamprey/researchwarehousemaintenanceblob
	name = "Maintenance"
	icon_state = "researchwarehousemaintenanceblob"

/area/lamprey/voxtradepost
	name = "Vox Trading Post"
	icon_state = "voxtradepost"

/area/lamprey/toprung
	name = "Top Rung"
	icon_state = "toprung"
	anti_ethereal = 0

/area/lamprey/securitycheckpoint
	name = "Security Checkpoint"
	icon_state = "securitycheckpoint"

/area/lamprey/arrivals
	name = "Arrivals"
	icon_state = "arrivals"
	anti_ethereal = 0

/area/lamprey/bronxmaintenanceblob
	name = "Maintenance"
	icon_state = "bronxmaintenanceblob"

/area/lamprey/mechanicsoffice
	name = "Mechanic's Office"
	icon_state = "mechanicsoffice"

/area/lamprey/middlerung
	name = "Middle Rung"
	icon_state = "middlerung"
	anti_ethereal = 0

/area/lamprey/porthallways
	name = "Port Hallways"
	icon_state = "porthallways"
	anti_ethereal = 0

/area/lamprey/originmaintenanceblob
	name = "Maintenance"
	icon_state = "originmaintenanceblob"

/area/lamprey/botaneva
	name = "BotanEVA"
	icon_state = "botaneva"

/area/lamprey/toolstorage
	name = "Tool Storage"
	icon_state = "toolstorage"

/area/lamprey/botanymaintenanceblob
	name = "Maintenance"
	icon_state = "botanymaintenanceblob"

/area/lamprey/aiandrevolvers
	name = "AI & Revolvers"
	icon_state = "aiandrevolvers"

/area/lamprey/warzonebar
	name = "Warzone Bar"
	icon_state = "warzonebar"

/area/lamprey/warzonemaintenanceblob
	name = "Maintenance"
	icon_state = "warzonemaintenanceblob"

/area/lamprey/darkfarm
	name = "Dark Farm"
	icon_state = "darkfarm"

/area/lamprey/deepresearch
	name = "Deep Research"
	icon_state = "deepresearch"

/area/lamprey/thebelt
	name = "The Belt"
	icon_state = "thebelt"

/area/lamprey/xenobiomaintenanceblob
	name = "Maintenance"
	icon_state = "xenobiomaintenanceblob"

/area/lamprey/xenobiology
	name = "Xenobiology"
	icon_state = "xenobiology"

/area/lamprey/xenobarology
	name = "Xenobarology"
	icon_state = "xenobarology"

/area/lamprey/detoxins
	name = "Detoxins"
	icon_state = "detoxins"

/area/lamprey/losspital
	name = "Losspital"
	icon_state = "losspital"

/area/lamprey/hellmaintenanceblob
	name = "Maintenance"
	icon_state = "hellmaintenanceblob"

/area/lamprey/engineeringmaintenanceblob
	name = "Maintenance"
	icon_state = "engineeringmaintenanceblob"

/area/lamprey/theater
	name = "Theater"
	icon_state = "theater"

/area/lamprey/bridge
	name = "Bridge"
	icon_state = "bridge"

/area/lamprey/headofpersonneloffice
	name = "Head of Personnel's office"
	icon_state = "headofpersonneloffice"

/area/lamprey/headofpersonnelline
	name = "Head of Personnel's line"
	icon_state = "headofpersonnelline"

/area/lamprey/bottomrung
	name = "Bottom Rung"
	icon_state = "bottomrung"
	anti_ethereal = 0

/area/lamprey/engineering
	name = "Engineering"
	icon_state = "engineering"

/area/lamprey/atmospherics
	name = "Atmospherics"
	icon_state = "atmospherics"

/area/lamprey/enginerooms
	name = "Engine Rooms"
	icon_state = "enginerooms"

/area/lamprey/captainsoffice
	name = "Captain's Office"
	icon_state = "captainsoffice"

/area/lamprey/miniatureboxstationreplica
	name = "Miniature Box Station Replica"
	icon_state = "miniatureboxstationreplica"

/area/lamprey/escape
	name = "Escape"
	icon_state = "escape"
	anti_ethereal = 0

/area/lamprey/forestarboardhallways
	name = "Fore Starboard Hallways"
	icon_state = "forestarboardhallways"
	anti_ethereal = 0

/area/lamprey/medbaywarehousemaintenanceblob
	name = "Maintenance"
	icon_state = "medbaywarehousemaintenanceblob"

/area/lamprey/tinyroomzone
	name = "Tiny Room Zone"
	icon_state = "tinyroomzone"

/area/lamprey/barndgo
	name = "BaR&DGo"
	icon_state = "barndgo"

/area/lamprey/aftstarboardhallways
	name = "Aft Starboard Hallways"
	icon_state = "aftstarboardhallways"
	anti_ethereal = 0

/area/lamprey/gateway
	name = "Gateway"
	icon_state = "gateway"

/area/lamprey/telecommunications
	name = "Telecommunications"
	icon_state = "telecommunications"

/area/lamprey/organ
	name = "Organ"
	icon_state = "organ"

/area/lamprey/medbay
	name = "Medbay"
	icon_state = "medbay"

/area/lamprey/centralhallways
	name = "Central Hallways"
	icon_state = "centralhallways"
	anti_ethereal = 0

/area/lamprey/barattheedgeoftheworld
	name = "Bar at the Edge of the World"
	icon_state = "barattheedgeoftheworld"

/area/lamprey/catchall
	name = "Lamprey Station"
	icon_state = "catchall"

/area/lamprey/combooutpost
	name = "Combination Vox Trader and Mining Outpost"
	icon_state = "combooutpost"
	anti_ethereal = 0

/area/lamprey/excavationtunnels
	name = "Excavation Tunnels"
	icon_state = "excavationtunnels"

/area/lamprey/cavern
	name = "Eerie Cavern"
	icon_state = "cavern"
	jammed = 2

/area/lamprey/voxmetaclub
	name = "Vox Metaclub"
	icon_state = "voxmetaclub"
	jammed = 2

/area/lamprey/hell
	name = "Hell"
	icon_state = "hell"
	anti_ethereal = 0

/area/lamprey/moon
	name = "The Moon"
	anti_ethereal = 0

/area/lamprey/asteroid
	name = "Asteroid"
	anti_ethereal = 0
	requires_power = 1

// Turfs

/turf/unsimulated/floor/airless/cavern
	name = "cavern"
	icon = 'icons/lamprey.dmi'
	icon_state = "cavernfloor_shallow"
	desc = "The faded stonelike walls shift in the corner of your vision, forming impossible shapes."

/turf/unsimulated/floor/airless/cavern/has_gravity()
	return 0

/turf/unsimulated/wall/statuelock
	name = "beckoning statue"
	icon = 'icons/lamprey.dmi'
	icon_state = "statuelock_underlay"
	opacity = 0

/turf/unsimulated/wall/statuelock/canSmoothWith()
	return null

/turf/unsimulated/wall/statuelock/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/voxpearl))
		playsound(loc, 'sound/items/Deconstruct.ogg', 100, 1)
		to_chat(user, "<span class='notice'>You place \the [W] in the hands of the statue, and it retracts into the floor.</span>")
		qdel(W)
		new /obj/structure/catwalk/invulnerable/hive(src)
		ChangeTurf(/turf/unsimulated/floor/fake_supermatter/hive)

/turf/unsimulated/wall/splashscreen/lamprey
	name = "Lamprey Station"

/turf/unsimulated/wall/splashscreen/lamprey/New()
	icon = 'icons/lampreysplash.dmi'

// Items

/obj/item/weapon/paper/lamprey
	icon = 'icons/lamprey.dmi'
	icon_state = "lampreynote"
	fire_fuel = 0

/obj/item/weapon/paper/lamprey/update_icon()
	return 0

/obj/item/weapon/paper/lamprey/mining
	name = "The Mouth of Hell"
	info = "Account by Lieu Manager of Operations, Jonatan Glythe on Nanotrasen-Owned Asteroid C24-16A<br><br>The Director of Mining Operations arrived in shuttle bus Apollus transport piloted by Frank Stelpil. Docked at combination outpost and stepped out to meet me; hair was unkempt more than usual, and I could not see his eyes, rather deep-set instead of watching. He pushed past while I explained current circumstance and demanded to see it for himself. The asteroid rumbled while we spoke and stomped through the halls to EVA, with Frank behind. Frank remarked he wanted time to head to his dormitory and retrieve his sidearm, but the Director was in too much of a rush, and would be remiss of us to leave him to take the walk alone. He took a helmet with a faded visor.<br><br>We took the short walk to the Excavation halls, which were beginning to crumble at the time from a recent explosion. We passed a miner in the hall, member of coalition nowadays called Brave Souls, but he had fallen down from exhaustion. The Director uttered an uncouth remark and told him to grow a pair, while the miner babbled about the rapid and encroaching growth of the asteroid, nonsensical. When we reached the command post, he slammed his body into a chair while Frank prodded at a piece of stabbed-through hardsuit. The Director told us that it was likely a result of compromised miner force.<br><br>This moment was spent staring at the monitor, where the asteroid's veins were beginning to grow. I spotted on a camera console a Brave Soul miner being devoured by one of the asteroid cockroaches. When my eyes delved deep, I felt my glasses slip off my face into the confines of my hardsuit helmet. I began to take my helmet off to fix it, but Frank grasped my arm and told me to stay safe instead. I stared at his blurriness and back at the monitor, where the bugs began to crawl on the screen and chew the distended miners' fading, broken hardsuits, not suited for this work. Had we been resuiting the dead ones, fixing their heads? We were running out of darts, I told the Director. His palms smashed open the computer. We had worse problems now.<br><br>When we crawled out through an airlock again, the asteroid sealed the entrance. The ridges of his eyes made them sink deeper, and the unkempt hair of his beard nearly poked out through his hardsuit's visor. Frank began scratching at the growing hole in his suit; we needed to show the Director quicker. Refused to put my hands on him, but dragged him along as he sputtered out distinctive cough, then we re-entered shuttle bus Apollus through external entrance. Floor began stinking with pheromones and the outpost had no officer to greet us in the diminishing hours. We instead jetted off deeper inside the center.<br><br>The shuttle sputtered in deep monotone roars, and Frank began to shake, as did I, with my glasses rattling and the world clearing in vision. The Director stood at the front with his arms crossed. We had broken through the exterior at last, while the lifeless, limb-ripped Brave Souls floated around carved rock. The asteroid pulsated and extended its veins. The Director said it was like he was staring into the mouth of hell.<br><br>From the fumes, a hacking and coughing Frank collapsed at the controls of the shuttle bus, interior beginning to melt. The Director clasped at the controls, whispering dark tones I was sure were some kind of incantation or demonic order. The cameras which were his deep-set eyes began to carve his way into me when I objected, when I reached for the medical kit. We were close now. The hulking, infinite cavern swirled around us, and I could not make out its face amidst the blurriness of the world. <br><br>Then, the Director parked the ship at the foot of the terrifying building and snatched me, dragging me limp across the alien floor on its outside. I knew in my heart that I was headed for a terrible fate.<br><br>We headed to the top floor where, after a prolonged argument, the receptionist told him that there was nothing to do, and no company to call, if he was incapable of keeping his own plant watered.<br><br>For the last time, instead of growing feverish with anger, at long last, the Director ordered a plastic one."

/obj/item/weapon/paper/lamprey/barndgo
	name = "That's My Job!"
	info = "TRANSCRIPT EXTRACT between THREE VOICES: UNKNOWN, UNKNOWN, UNKNOWN<br><br>Hey, h-hey, s-stop messing with the deconstructive analyzer, Michael!<br><br>It's <i>Mike</i>. An' what the hell are you talkin' about? I know how to work yer newfangled red science machines. Gets science goin', gets guns rollin' out!<br><br>Th-that's not what it's for! That's a delicate, masterful piece of tech, m-meant only for professional research...<br><br>Mm, Gabriel? If it's meant for tech, then why don't my bars or his MULEs ever get new pieces of technology? I'm really asking.<br><br>S-Same reason you don't d-deliver drinks to my desk every day! I-It's hard work!<br><br>Nah, nah, I get deliveries for the both of ya constantly, so tha's not an excuse.<br><br>Mike, your entire job is deliveries. I have to make my customers feel at home. Not sure how I'm supposed to do that with you two running around.<br><br>Mebbe you shoulda thought of that before they stuck my loadin' dock in Cargo 'n Bargo 'n Researgo!<br><br>I-It's t-technically what they're c-calling BaR&Dgo... o-or Bar and Research and Development and Cargo.<br><br>My bar has to be included in the merger... why?<br><br>Nah, nah, it's not the bar that's the fuckin' worry, it's my damn loadin' dock! How's ANY of us supposed to move around with all these packs and MULEs and crates in the way?!<br><br>D-Doesn't help that you y-yell at me wh-when I try t-to move them...<br><br>It's my job, not yours, sci-guy asshole.<br><br>S-So leave my j-job alone, too!<br><br>...Ah. I apologize to have to butt in even more, but the both of you are currently drinking bottles you raided from <i>my</i> fridge.<br><br>Ah, shut it, Hakayatch, you dumb fuckin' bird! What do you know about drinks, eh?! I could do your whole thing all by myself! I bet I could run the whole damn department!<br><br>Mm. Well, after months of hearing you and Gabriel rattle off about your respective accomplishments, I'm sure <i>I</i> could do your jobs.<br><br>Y-You're b-both dumb! I-I can s-science out a-a box pushing m-machine and d-drinks dispenser in five minutes!<br><br>Do it then, ya shitter!<br><br>I-I will!<br><br>Just try not to get in my way."

/obj/item/weapon/paper/lamprey/arrivals
	name = "Nightwatch"
	info = "Donk pockets are my favorite treat. You know, I started thinking I mighta ended up in Heaven after all this, after all these years of wonderin' if I was doing a good enough job. One day I'm mannin' the security checkpoint and it just starts driftin' off. Starts floating away, like a bad piece of bone the body's forcing out. Started wonderin' if I got unlucky, then as the weeks and months went by, started thinking I got lucky.<br><br>It's kinda beautiful, if you get some distance between you and somethin' terrifying. Radio calls started bein' frantic, twisted, panicked, started bein' people just laughing about their situation, fallin' into pits and getting crushed between shifting walls. But I wasn't laughin' or screamin', just watching it go by, little ice cup of Space Cola in my hand, and I'll tell you, it was kinda beautiful. The whole station was curlin' over itself like somebody with a big space pen was tryin' to move areas to other areas and shift 'em all together again. Driftin' in orbit through the cosmos, it all kinda seems small, all kinda seems manageable. I could look at the outside of the hallways gettin' bent along with the rooms bein' crushed or smooshed.<br><br>Some days, I wonder who was doin' it, if it was God or somethin' like that. But God's not got a limited reach, and whoever was makin' the station morph like this never had an opportunity to build somethin' else, I'll tell you that. I think the moment it started actin' up, the moment all the Heads of Staff started makin' our lives hell, the moment we started minin' plasma and delving deeper and deeper into that asteroid, the moment everyone started gettin' at each other's throats... we knew it was over. So when the rooms started shiftin', and the halls started morphin', and the space junk from the magnet driver started formin' into new doorways and potted plants...<br><br>Well, we all <i>knew</i> it was comin', something bad. Just didn't know I wouldn't see it from the inside.<br><br>It's nice, though, gettin' the donk pockets, gettin' the sips of my cola. Not like it's runnin' out-- every time I check, there's plenty. Maybe it's half of whatever logic governed throwin' me out in orbit like this, makin' me sustainable, but I don't mind. I got a lotta time to think, lotta time to ponder all the space around me, all the station in front of me.<br><br>Couple months ago I watched Arrivals start shiftin' and groaning, too. Thought it'd come to reattach to me, but the shuttle just got thrown up and out, connected to some kinda windin' hallway, somethin' I could look over all the while. That's when I realized it all had to be connected, there had to be a plan for it, some kinda blueprint from a mad architect. I could watch the scared waddlin' bodies shuffle down that Arrivals hallway and write down every fated name, knowin' they'd never see any way out.<br><br>But that wasn't my problem. None of it got too close to be my problem, y'know? I could always retract 'n sit down 'n sit back, drawin' it all out, tryin' to make sense of this harebrained architect's madhouse, thinkin' it was some twisted kinda beautiful.<br><br>Guess somethin' hit me today. Saw another twenty of 'em go shuffling into the depths of the thing, and I guess the beauty wore off. The distance wore off. Knew those were folks, real folks, headed in for the last time, knowin' they'd be trapped there 'til the end of their days, if it ever came.<br><br>So if they send another one to fill my place, I gotta apologize for takin' the softsuit, but I'm done being a waiting man."

/obj/item/weapon/paper/lamprey/medbay
	name = "Drag Them Back Home"
	info = "Patient retrieval log #00129<br><br>I brought the guy in with both of his legs broken. He told me that the station... curved? and that he was caught underneath it, but a friend dragged him out. I'm starting to think that Medbay can't handle all this new intake, the way we are currently. The way we're running. Didn't have enough bicaridine for the legs, and Surgery's backed up.<br><br>Patient retrieval log #00141<br><br>Xenobiologist with burn wounds seems normal until you realize they're blast wounds from some kind of gun. He says they're self-inflicted, that his fire extinguisher started malfunctioning. Surgery's overflowing with bodies, so I just threw him in the cryo tube, even though the mix is just sprinkles and milk, so he can wait for his turn.<br><br>Patient retrieval log #00155<br><br>Decided to experiment for a third time. Gal was missing two limbs, but after I threw her in the maple syrup and vomit tube, she came out with fresh arms, happy and ready to get at it again. I tried calling the CMO, but he's out today, still, still out. Who do I call for this? I don't know if the docs would trust the word of a paramedic, but...<br><br>Patient retrieval log #00168<br><br>Clone damage, oxygen damage, burn and brain damage out the wazoo. The doctors got ahold of him before I could, but when they went to Chemistry to synthesize chems, the door was a window. I finally broke and told them about my pet project and they called me Crazy Mary again, but when I threw him in the egg yolk tube... you know the rest by now.<br><br>Patient retrieval log #00193<br><br>Surgery line is finally cleared. The mechanics think we're all insane, so the doctors and I started making our own set of new cryotubes, all in line and in sequence. We ran out of things to fill them with, so we just started using empty tubes, or tubes filled with blood, or tubes filled with water. By the time the last limbless husk went in and came out with all his wounds healed, we realized it just didn't matter.<br><br>Patient retrieval log #00232<br><br>Medbay is shifting to make room for us now. Every other part is given less and less space, my old pointless office has disappeared to some remote corner of the department, but the tubes are given plenty of area to walk around. Generally they stay in file, especially when we gather around to pray to them. Patients come in begging to be put in the tube, come half-dead and with their limbs crushed, but they all make it out okay. They all make it out okay.<br><br>Patient retrieval log #00451<br><br>I walk through hallways of filth and guts before finding a pile of bodies, twenty high. I smile warmly and start stuffing them in the bag-- it's time to drag them back home."

/obj/item/weapon/paper/lamprey/bridge
	name = "The Show Goes On"
	info = "Years of my life, piddled away for this.<br><br>It's been hard not to write, not to leave clues, but I know there's no backtracking, there's no easy exit. Each door leads to a new one. I had promised myself I would find a way out before I put pen to paper, and now... I feel that it is time.<br><br>I am the Captain of this station. I have been, I always have been. I don't know what they've done to my home, but if it's anything like what they did to my Bridge, then there isn't much hope for you, is there?<br><br>...I want to try to be optimistic. I feel myself fading, but I feel a little glimmer of happiness. I'm out. I have finally made it out.<br><br>My fists split open when I brought them against that window again and again, again and again, pounding until I was sobbing, and finally I broke through with blood coating my arms, stumbled into here, where I saw a small audience escape through the airlock on the far side, including... I hope it wasn't him.<br><br>But surely it was-- surely it was the Director of Mining Operations, that man who had threatened me for so long, beard and hair like a damn forest. I'd know him anywhere. But the energy is leaving my body fast, and I cannot chase. I can only sit and process what I've found here.<br><br>Years of wandering, and they had been watching it all. These one-way-windows must have been everywhere-- how could I not have seen them? Once, I had broken through with a toolbox, only to find a wall. But now I'm out, and the suffering is over, and I'm left to wonder how long they'd watched.<br><br>How long was I the show?"

/obj/item/weapon/paper/lamprey/ert
	name = "Magnanimous"
	info = "Okay, Pilot, you really need more evidence? I've written it all down for you. We're headed to this station whether you like it or not.<br><br>1. The reports Nanotrasen forwarded to us are all written by insane people. They complain about things that happened in 'Bargo And Cargo And Researgo', which is absolutely not a real thing.<br><br>2. The couple remaining crew that gets back in the Escape Shuttle are usually unable to talk about what happened, or they shut down and just repeat that it was 'the most normal day I've ever had'.<br><br>3. Objects brought back are unusual, such as a miner's reddish cockroach 'pet' which ate some NT brown-nosers the second it got loose, and a perfectly-rectangular layer of dirt the Clown was toting around.<br><br>4. Our long-range photos of the station are always pictures of different stations.<br><br>5. Instead of the Captain, we keep getting reports of a Director of Mining Operations. That's not even a job we have.<br><br>6.  There’s a debris field forming around the station that’s getting bigger every time we look.<br><br>I know you all think we’re out of our depth on this one, but we’re not. We’re the ERT. Let's just jet in and figure out what's going on, already! Worst case scenario, we have to shoot some syndies, but it's nothing we haven't dealt with a hundred times before."

/obj/item/weapon/paper/lamprey/security
	name = "Castled"
	info = "Brig Status Report for Week 221<br><br>Inventory:<br><br>61 NT Glocks<br>61 .380 magazines<br>61 Beepsky Smash<br>35 Energy Gun<br>29 Griffeater Gin<br>2 Ablative Vests<br>1 Virus Dish (Gibbingtons)<br>14 Riot Shotguns<br>5 Shakers<br>19 Laser Guns<br>1 Rag<br>7 Cyber Mannequins<br>51 Ion Rifles<br>1 Centrifuge<br><br>Brig Manifest:<br><br><b>Todd Cables (Security Officer)</b><br>Detained for loitering around John's post at the fore starboard window<br><b>Arnold Bettson (Security Officer)</b><br>Detained for loitering around Todd's post at the fore starboard window<br><b>Gerald Marterian (Security Officer)</b><br>Detained for leaving detainment<br><b>John Mortinson (Security Officer)</b><br>Detained so that we would have something to do<br><b>Bobbett Clobbett (Security Officer)</b><br>Detained for being in a jail cell<br><b>Scrungel McSlipstein (Clown) ((Security Officer))</b><br>Detained for playing music in Permabrig<br><b>Gleatrsoen Stleto (Security Officer)</b><br>Detained for being within parking distance of potted plant<br><b>Turgel Fergelersuon (Security Officer)</b><br>Detained for bad crimes<br><b>Ghhhghg gjsndhjnn (Security Officer)</b><br>Detained for stuff<br><br>(I'm just making more up at this point, when the hell are we gonna find a way out of here)"

/obj/item/weapon/paper/lamprey/belt
	name = "Every Station Needs It"
	info = "TRANSCRIPT EXTRACT between ONE VOICE: UNKNOWN<br><br>I promise to you I tried to take every possible action against this, but there was nothing I could do. The Director, when I measured him, just couldn't wear a belt! There's something... wrong with him, something wrong with his body! But he grabbed me by my head and I swear, boss, I swear he wanted to crush it like a melon! He needed to wear a belt!<br><br>The architects, e-er-- I mean, th-the assistant architects, they all said it didn't make sense, s-same as me! I mean, I'm no architect, but I know our jobs got a lot in common, and I kept tellin' em, the big boss can't wear a belt! But he's tellin' the same thing to them, I guess, tellin' them every station needs it, every station needs a belt. Says it keeps the guts in. If you don't got a belt, all of it spills out. But that doesn't make any sense!<br><br>I mean, what kinda big metal hunk needs a piece'a leather to keep all the innards in?<br><br>...y-you what?<br><br>You...<br><br>...you put the belt on it?<br><br>Ahah... I guess none of it's makin' any sense anymore, huh. We're just throwin' on whatever he says has gotta be there because we're scared. But I watch him through that window in his office and I keep tellin' him he can't put that belt on, it's too small, it's too small.<br><br>I guess, a-ah, y'know. Maybe it'll get bigger.<br><br>The whole thing will get bigger, y'know? The whole thing will get bigger to accommodate.<br><br>Guess there's nothin' you can't slap on if you just keep making it bigger.<br><br>He's never gonna stop, is he?<br><br>It's never gonna end.<br><br>Ahhh, f-fuck, where'd my tape measure go... please don't get all pissy at me, boss, I'm goin', I'm goin'..."

/obj/item/weapon/paper/lamprey/reylampson
	name = "The End"
	info = "It was leafy, plastic and green. I saw it and I knew what I had to do.<br><br>I'll be seeing you, Lamprey Station.<br><br>- The Director"

/obj/item/weapon/paper/lamprey/moon
	name = "Lunar Symbiote"
	info = "Malaki started showing me things that I immediately refuted. Every part of me was against them-- they were segments of my life which had always been there, but which I had cast away into nothingness. I couldn't rationalize it as cast-off memories, anymore. There was another world aside from my own, and he took me through the looking glass into its horrifying depths.<br><br>He- not Malaki, but <i>him</i>- used my time for a lot of things. He drew out tunnels, endless tunnels, and brought me in alongside shuttle-loads of nonsense to fill the tunnels. The rhythm of it took over my brain-- I cut contact with my mother, my daughter, the cascading world around me. This task of <i>filling</i> his Station was all I could have on my mind. By the time I was out of the trance, I was empty. I spilled out onto the floor outside his office and tried to make my way back to my ship without throwing up, and never looked back. I would never return.<br><br>But Malaki had been there, too. More conscious. When we met for a tense, quiet lunch, he didn't just show me his old materials from the Station, but the remnants of an unseen past, too.<br><br>Photographs of long, straight tunnels, nonsensical in design, without entrance or exit. Designs for mazelike living quarters without any regard for human comfort, but with <i>spillages</i> marked explicitly on the map. I felt myself going <i>back</i> there, thinking about it all. I felt myself back in the maintenance tunnels, the hallways.<br><br>I remembered feeling the Station breathe.<br><br>Night, or day, but with it all abandoned, with the echo of footsteps extending from one end to another, I felt it breathe. I held my limp body to the ground and patted it like a baby. It told me, 'I am <i>missing</i> something.'<br><br>I felt at its woes, but I never understood what it meant. The beating of a dark heart kept ringing in my ears for the months afterwards, and once I remembered, that beating came back.<br><br>Beating.<br><br>Beating.<br><br>Malaki pushed aside a dusty file cabinet, then. He uncovered a secret compartment in the wall of my old Central Command office-- something I couldn't recall installing. We hesitated before sliding it open. Inside, all we found was a photograph of a station.<br><br>A station shaped a little like a moon. A vague shape that locked eyes with me like it was alive. The Station's moon, hovering just outside, where it should be, where it <i>should</i> be. Where it <i>never was</i>. We built it, but it never made it where it was supposed to be, all along.<br><br>My hands felt the table's heartbeat. The photograph. The picture of the Station, complete.<br><br>Malaki fell in first. I fell in after.<br><br>Back, at last.<br><br>- Clara Creek"

/obj/item/weapon/paper/lamprey/loveletter
	name = "Letter Too GF"
	info = "Gf! Human gf! I was leaerned all kend of Common languaeg, making to send letter to you in love. You never know my name, but kno yours, Missus Hattfind! Very cutre bontanist who han visited front gate of our glorous home, with so cute facial feature! Always wanted Human GF, and promise can do provide ANY wants to needs with all-fruit magjesty.<br><br>Human nanotrasen do stupid things needing to build station with rawe materals, but with scientific lab and complex prosesses we producting Infinity of All-Fruit! Self-preplication and magjesty as far as eye can seen. When Mastermind will lows me to visit you inside, you'll se the Magjesty that all-fruit will bring. Andless ambundance!<br><br>Soch beautiful living spases, and quarters insidde of pockit demsensions. No limit off room to worek, we run never out of rooms! With all-fruit, I condunct builsers to make us grand home inside ponkcet dimensions, beautiful spases for you and I. <3 <3 <3<br><br>KHAW KEHEH! (It's means good thingers in my Langauge. :) )<br><br>I itned to send more Lovey thing to cournt you, Missus Hattfind, bunt juts a moment, There is runkcus going on in adjasent hall. My hand is feelang verie stiff? It's g"

/obj/item/weapon/paper/lamprey/grey
	name = "Notes -- Project Grey"
	info = "<b>GREY -- Replication, Possibility Space</b><br>BLUE -- Anomalies, Reach VS. Origin<br>YELLOW -- Environmental & Material Study<br>RED -- Risk, Harm, Weaponization<br>WHITE -- Impossibility Space, Dimensional Theory<br><br>Project 'Grey' is the field of our study directly towards possibility space and replication of all-fruit activation. Chambers reserved for Project 'Grey' are entirely for continued replication and the study of replication. As demonstrated in Project 'Blue', all-fruit is not to be left Activated for a period longer than 24 hours without proper containment, else local-space distortion is possible. As demonstrated in Project 'Yellow', all-fruit is not to be actively touched or punctured before activation.<br><br>All-fruit activation proceeds at approximately four shapeshifts per second. All-fruit causes damage to its environment unconstrained by material strength if completely restricted. Laboratory all-fruit must be handled with every single one of the all-fruit precautions detailed in the Grandiose Plan Handbook. No exceptions!<br><br>Recent notes (circa XX-XX-XXXX XX:XX)<br><br>- Thanks to the stunning work of Doctorate Yikatita, we have stumbled upon a stellar way to aid all-fruit replication in a manner similar to the original handiwork of our Mastermind. A steady hand and perfectly-shaped zinc-aluminum-alloy container allows for continued shapeshifting of an all-fruit without disturbance, while also allowing any Vox with a steady hand to cup the container and whack it softly when a vibrating force is detected. Although inconsistent, this guarantees that the Result Vector will be shaped precisely like a box of all-fruit. The success rate is around 45%, with potential for better results with more practice.<br><br>- A note from Doctorate Kahil: Although the very active processing of a Nanotrasen AI or Cyborg is appealing to our newer Doctorates, abusing this time diliation for all-fruit reproduction is sadly still off-limits due to orders from our Mastermind. Simple computers incapable of thought can be used for pattern-recognition, and thus the all-fruit box detector is still allowed, but quicker and more novel methods to more Result Vector discovery is off-limits.<br><br>- New project: I will be leaving the Project 'Grey' test chambers filled with one activated all-fruit each overnight while we enjoy enjoy the festivities. Our new simple computer project 'Chikita' will compare initial-shaped Result Vectors from latter-shaped Result Vectors and detect any differences in patterns far better than the Vox eye can alone. This is sure to further our efforts with the Unconstrained All-Fruit Theorem and will doubtless be useful research for Project 'Blue'."
	icon_state = "lampreynote_grey"

/obj/item/weapon/paper/lamprey/blue
	name = "Notes -- Project Blue"
	info = "GREY -- Replication, Possibility Space<br><b>BLUE -- Anomalies, Reach VS. Origin</b><br>YELLOW -- Environmental & Material Study<br>RED -- Risk, Harm, Weaponization<br>WHITE -- Impossibility Space, Dimensional Theory<br><br>Project 'Blue' is the field of our study directly towards local-space distortion and temporal anomalies caused by all-fruit activation, as well as further developments into various branches of Reach Theory or Origin Theory. The generous contributions of Project 'Grey' allot us twelve all-fruit per day, which will be left activated from anywhere between one full day to one full year for testing applications. As demonstrated in Project 'Yellow', all-fruit is not to be actively touched or punctured before activation.<br><br>All-fruit activation proceeds at approximately four shapeshifts per second. All-fruit causes damage to its environment unconstrained by material strength if completely restricted. Laboratory all-fruit must be handled with every single one of the all-fruit precautions detailed in the Grandiose Plan Handbook. No exceptions!<br><br>Recent notes (circa XX-XX-XXXX XX:XX)<br><br>- So what are we calling it? It's cumbersome to say 'spacetime distortion when activated all-fruit is left out too long'. We know its properties, specifically that we have around 24 hours until such effects take place, but despite being a core facet of our experiments at Project 'Blue', it seems we use this confusing language every time. I suppose it's because our cohort can't decide if these distortions are 'reaching' from someplace else, or 'originating' new material, but does it matter? All-fruit changes its environment when it's aged-- everyone should know this without any fuss! We're confusing the new Doctorates.<br><br>- Although not investigators, myself and Doctorate Ikha have discovered a further lead on the origin of the grey floor tiles and oxygenated environment demonstrated in all three of our current test chambers. It was made clear to us from a recent sneaky visit to the old office of our Benefactor the resemblance of these tiles to standard Nanotrasen floor tiles. When investigated further with help from the brilliant minds over at Project 'Grey', it became clear that not only are these standard Nanotrasen floor tiles, but these sorts of floor tiles are found abnormally commonly in the first four-hour sequence of an activated all-fruit! Humble as I am, I can't help but feel proud at how well this refutes Origin Theory. These can't have been generated out of nothing. Clearly, all-fruit is pulling objects from another place in the universe, or even another dimension. This is a smoking gun in favor of Reach Theory! KAW!!!<br><br>- The potted plants? As a new Doctorate I understand the limitations of my reach, but I think I am joined by other voices when pondering this question of the potted plants. They are never plasticine, but instead living-- lovingly watered with a guiding hand, and materialized during the aged all-fruit spacetime distortion often enough that we have begun dragging them outside to decorate the office. Unlike all the older (more narrow-minded) Doctorates, I subscribe to the more rational Origin Theory, and it seems like whatever all-fruit is making when it's left out activated, it wants more space to do it. Is it strange to allocate 'thoughts' to these inanimate plants? I wish we had a bigger test chamber, to see what else it Originates. I think I'm going to retrieve a shovel from the lobby trash bin and see if I can't make a few expansions. They'll remember Doctorate Ahahik for this innovation!<br><br>- The arrival of what our Doctorates are calling the 'Ladder' has ceased operation in our third test chamber while we repair the Containment Field. Inquiry about the third test chamber is not to be made at this time. Inquiry about the whereabouts of our Benefactor or Doctorate Ahahik is not to be made at this time. It has been made clear that this childish argument between Project 'Blue' staff has led to destructive damage to our glorious home. All members of Project 'Blue' will take the day off, and the rest of administrative staff will be drinking their beaks raw during tonight's festivities instead of chattering endlessly about this Theory nonsense."
	icon_state = "lampreynote_blue"

/obj/item/weapon/paper/lamprey/yellow
	name = "Notes -- Project Yellow"
	info = "GREY -- Replication, Possibility Space<br>BLUE -- Anomalies, Reach VS. Origin<br><b>YELLOW -- Environmental & Material Study</b><br>RED -- Risk, Harm, Weaponization<br>WHITE -- Impossibility Space, Dimensional Theory<br><br>Project 'Yellow' is the field of our study involving deactivated or otherwise inert all-fruit. The generous contributions of Project 'Grey' allot us twelve all-fruit per day, which are to be left in specialized conditions and heavy-duty containment as per the day's testing regiment, and disposed on the morning of the following day after readings have been made. All-fruit is to be always held upright for tests, and tension on the all-fruit's stem is to be minimized during all tests. If requested from another Project, all-fruit from Project 'Yellow' can be used in other fields of study, but only after approval from our Mastermind.<br><br>While in proximity of damaged or rearranged all-fruit, environmental protection must match Code VI. Laboratory all-fruit must be handled with every single one of the all-fruit precautions detailed in the Grandiose Plan Handbook. No exceptions!<br><br>Recent notes (circa XX-XX-XXXX XX:XX)<br><br>- The test involving the pinhole mobius strip has been a huge success. We've never been able to create an opening through and through an all-fruit, but when the other side observed with a snaking microscope, we're able to look at an empty version of the test chamber, seemingly from a pocket dimension! When the view is flipped and we investigate from the other end, it's like looking at a mirror of ourselves-- the microscope bumped into itself. This is clearly too theoretical for me, and much more the responsibility of the nerds over at Project 'White', but it's so interesting how these things all tie together. I just hope <i>we</i> didn't end up accidentally making a pocket dimension or teleporter, because Project 'White' needs a lot of clearance from the Mastermind for those. Also, of course, it produced absolutely unbelievable quantities of gamma radiation. Were it not for the lead suit, I think I would have been reduced to sludge!<br><br>- Fun With Fire! You know how in the handbook they tell you not to set a no-fruit on fire? Well, that's no-fruit, and this is all-fruit, so me and Doctorate Haika, with approval from the Mastermind, decided to conduct Experiment NO-- one mole of oxygen, a spark as generated by an igniter, and an all-fruit producing minimal radiation from a five second shake. It took two failed attempts, redesigning the chamber to avoid ignition of the stem, but we found some great insights from the way it burnt. Approximately twelve seconds into the experiment, the all-fruit sucked all the heat out of the chamber, <i>and</i> sucked the heat out of me and Doctorate Haika from through the plasglass! It was a fairly chilling experience (ha!) but there was no permanent damage done, and I've forwarded the readings to Project 'Red'. I feel that this may give some insight into the weird snow they found. Maybe.<br><br>- This is not related to any one experiment in particular, but I love our department. We do not get very much room, and Project 'Grey' has been habitually 'forgetting' to deliver us our shipments of all-fruit, but the work we do here is so much more fun and intriguing. I musn't understand <i>why</i> these strange blue bulbs make exceeding amounts of radiation or heat or cold, that's for the rest of our cohort to decide. I'm just very thankful we don't need to be picking the stems-- that's where the real risk is.<br><br>- I picked a stem! Oh, it was quite accidental, for sure, and I supposed that it would be easy enough to simply dispose of whatever Result Vector was produced, but we were amazed to find that we were given a gigantic wheel of cheese containing a seemingly endless bounty of poutine! Instead of pushing it to the lackey-brains over at Project 'Red', I delivered this straight to our Mastermind, as I know poutine is his favorite food, and he was simply elated. We're going to use it to celebrate tonight, I think! Oh, this is making me so happy. Perhaps this little streak of luck is going to finally give our Project some more funding."
	icon_state = "lampreynote_yellow"

/obj/item/weapon/paper/lamprey/red
	name = "Notes -- Project Red"
	info = "GREY -- Replication, Possibility Space<br>BLUE -- Anomalies, Reach VS. Origin<br>YELLOW -- Environmental & Material Study<br><b>RED -- Risk, Harm, Weaponization</b><br>WHITE -- Impossibility Space, Dimensional Theory<br><br>Project 'Red' is the field of our study directly towards application of all-fruit properties towards furthering the Vox needs and goals as dictated by Shoal Command Reports. Chambers reserved for Project 'Red' are entirely for the development and containment of weaponry derived from all-fruit research and development. The generous contributions of Project 'Grey' allot us six all-fruit per day, and suspicious items will be delivered with proper containment from other Projects to the chambers reserved for Project 'Red'. As demonstrated in Project 'Blue', all-fruit is not to be left Activated for a period longer than 24 hours without proper containment, else local-space distortion is possible. As demonstrated in Project 'Yellow', all-fruit is not to be actively touched or punctured before activation.<br><br>All-fruit activation proceeds at approximately four shapeshifts per second. All-fruit causes damage to its environment unconstrained by material strength if completely restricted. While in proximity of potentially hazardous materials, environmental protection must match Code X. Laboratory all-fruit must be handled with every single one of the all-fruit precautions detailed in the Grandiose Plan Handbook. No exceptions!<br><br>Recent notes (circa XX-XX-XXXX XX:XX)<br><br>- There is not enough seriousness in this office for certain grave dangers that face us. Although I desire not for any form of reprimand, Doctorate Hahak and Doctorate Khikakhihayita used local teleportation technology from Project 'White' to test out the recent Experiment DDJ - Roulette Revolver outside of the asteroid. Our cohort had a unanimous curiosity as to its effects in unconstrained space, but this was a terribly irresponsible choice. Recall that Nanotrasen's mining operation on this asteroid, while temporarily halted thanks to the magnanimousness of our Benefactor, still exists on the Company's records. Project 'Red' is entirely dedicated to our efforts to protect the Shoal, but if knowledge were ever to be released of our Grandiose Plan, it would be nuked from outer orbit. All experiments must be held inside. The Containment Field is designed to handle so much-- we must utilize it instead of risking our necks outside.<br><br>- Should Project 'Red' really be handling all matters related to the Wunderful Warship? We are so proud of it, certainly, but it is growing and growing in scope beyond the original matters of our cohort. I recommend to the Mastermind that we develop an entirely new Project dedicated to its construction, or perhaps simply find it a crew already. There are so many capable pilots at the Shoal! Or, at least, so many <i>willing</i> pilots...<br><br>- Meat Grinder experiments continue. I apologize for hogging the test chamber these past days, but there is so much to examine. This has been the second or (if a stretched definition is used) third example of an all-fruit giving us something from this icy, hostile plain. The test chamber was cooled to an immense degree by the Meat Grinder's arrival, and it has been the recommendation of our Mastermind not to approach even with a bomb suit. The readings of potential explosive energy and volatility of this Meat Grinder mean that even disposal may end up being an exceptionally difficult task. Were any of us less cautious, I'm certain we could have attempted to simply lug it out of the chamber, likely losing an arm in the process. Anyhow. Today's experiment entailed activating our allotted all-fruit remotely next to the Meat Grinder. Result Vectors included two instances of 'Royal Jelly' and several books with residual magical energy. To the Wunderful Warship they shall go.<br><br>- It is hard for the rest of our Doctorates to see the bigger picture at times. I had a realization today while chatting at the water cooler... so very many of the things our experiments produce are acutely harmful. Even the simplicity of Project 'Blue's recurrent grille cheese sandwiches are harmful if bitten into. I consulted with Project 'Grey's brilliant Doctorate Yikatita, and discovered that an approximate 24.5% of Result Vectors are hazardous to the point of requiring protective equipment. So many of these things appear at first harmless, but are actively malicious towards our fragile Vox bodies. I believe Project 'Red' ought have clearance to examine <i>every</i> Result Vector, from every Project, and perhaps from every civilian, too. Our home could be at risk from absolutely any direction!"
	icon_state = "lampreynote_red"

/obj/item/weapon/paper/lamprey/white
	name = "Notes -- Project White"
	info = "GREY -- Replication, Possibility Space<br>BLUE -- Anomalies, Reach VS. Origin<br>YELLOW -- Environmental & Material Study<br>RED -- Risk, Harm, Weaponization<br><b>WHITE -- Impossibility Space, Dimensional Theory</b><br><br>Project 'White' is the field of our study directly towards impossibility space, pocket dimensions, teleportation, and application of collated knowledge from all other Projects. The generous contributions of Project 'Grey' allot us twelve all-fruit per day, which will be activated before any tests, then immediately put through various forms of environmental pressure. As demonstrated in Project 'Blue', all-fruit is not to be left Activated for a period longer than 24 hours without proper containment, else local-space distortion is possible. As demonstrated in Project 'Yellow', all-fruit is not to be actively touched or punctured before activation.<br><br>All-fruit activation proceeds at approximately four shapeshifts per second. All-fruit causes damage to its environment unconstrained by material strength if completely restricted. Laboratory all-fruit must be handled with every single one of the all-fruit precautions detailed in the Grandiose Plan Handbook. No exceptions!<br><br>Recent notes (circa XX-XX-XXXX XX:XX)<br><br>- The intellectual minds of this Project have stumbled upon another brilliant production. A pressure force equal to 44.174 kPa using Doctorate Ilkhalzal's titanium-mesh plate caused a 4-hour-activated all-fruit to meld the underplate into a solid Void Field with 99.71% certainty. Standard issue underplates have been ordered to begin mass-producing Void Fields. Recall your instruction: Void Fields are the quintessence of transport between pocket dimensions. They do not create, they simply move-- they are safer by an order of magnitude than Dark Fields, and thus all these improvements in our attempts to create them is extraordinarily helpful. If we are to develop Doctorate Kak's brilliant 'Warp Hub' idea, we will need a Void Field underplate for every warp between pocket dimensions. That will mean at least twenty-- so long as we are being responsible enough to make the teleportations two-way.<br><br>- Although it remains purely theoretical, it is worth mentioning my new design for a transported Void Field safety device, which I have attached to our corkboard. You'll find that the newest addition is a small transported bead of Dark Field. If my math checks out, this should produce a miniscule (<1 cubic micron) pocket dimension, creating reactivity with the Void Field and transporting a field agent back to the Void Field's linked Dark Field, saving them from any pocket dimension mishaps. It will be some years until we actually figure out how to link Fields consistently, so you don't end up transporting twenty dimensions out of sync, but hopefully soon our Mastermind will stop calling Project 'White' a 'fast way to get yourself trapped in hell'. Ha.<br><br>- We received some details forwarded to us from Project 'Yellow' where they peered into a pocket dimension from <i>inside</i> a deactivated all-fruit. This is troubling news. There should be no way that's possible, especially considering their description of what the pocket dimension looked like. Without any Dark Field to create a pocket dimension, what did they see? How did they see it? Do we misunderstand something about the base principles of our field? Myself and Doctorate Hakihiya have been given the sample for further testing.<br><br>- I think our work must be halted. All work. All departments. After worming the camera lens further into the sample all-fruit, we continued seeing more and more dimensions, all molded on our current environment. As we approached the outside edge of the all-fruit, the camera began picking up the Museum of Birdken Dreams outside, then the outer edge of the asteroid, like it was beginning to pull further and further away. This should violate the base laws of Impossibility Space-- there's no way that it would 'know' about the fact that we are in an asteroid. Worse is what happened when we pushed the pinhole camera entirely through the sample. We witnessed... something. I struggle to describe the physical feelings I received when staring at its gaping maw and endless, tendrily body, swimming through an endless Dark Field. My partner and I took a photograph and retracted the camera, but not all of it came back. At that moment, our Benefactor requested to have the photograph for personal study, at least until tomorrow morning. I suppose that's good timing. During the banquet tonight, I will tell our cohort about this. Hopefully it convinces them that this work is getting to be far, far too dangerous. We simply don't know enough."
	icon_state = "lampreynote_white"

/obj/item/weapon/paper/lamprey/mastermind
	name = "Mastermind's Personal Study Tome!!"
	info = "As our Mastermind of this humble Glorious establishment, I decree that these notes are for me and my eyes only! You shall perhaps only glance upon my thoughts posthumously, and only if it is terribly pertinent, and I have a will, and you need to settle some kind of dispute!!<br><br>~FOR MY EYES ONLY~<br><br>~DO NOT CONTINUE!!!~<br><br>...<br><br>132<br>Oh, man, I have had SUCH a day. I am not feeling the role today. I kept getting hounding questions from some of the Doctorates over at Project 'Grey' that they want to use cyborgs to detect all-fruit... eugh!! I hate cyborgs so much. Stupid silicon dumb brains just waiting to backstab you at a moment's notice. And they smell like oil. I just kept fending off the questions with saying it is the 'will of your Mastermind' yadda yadda. Wow, I thought <i>I</i> was a dumb bird, but they just fall for that every time. And they still think I can just pop out a box of all-fruit at a moment's notice! They would actually string me up if they knew the first time was just luck.<br><br>133<br>Finally had a kinda cool chat with our Benefactor this morning. Guy's been so cooped up in his office and everyone gets weirded out when he comes out, but honestly I don't think he even noticed this time. He was just telling me about his days doing Mining Director stuff, and I was thinking the whole time, like, wow, we actually have so much in common! He had to lead a whole bunch of crazies too! I won't tell him this, but I think the main difference between us is that I have that raw, wicked charisma, and he just has that really intense stare he does all the time. It doesn't bother <i>me</i> that much, but I honestly wouldn't mind if he threw on some sunglasses sometime. Or <i>shaved</i>. Even us Vox shave. Can't he put a little effort in?<br><br>134<br>This whole department is just stupid kids! At least I feel like that sometimes. Project 'Yellow' decided they were just going to straight up set one of the allfruits on fire... ugh. Let me lay this out for you, diary: when I found all-fruit, fucking around during a scout operation, I was at LEAST careful enough not to set the things on fire. Yes, I picked the stem without thinking, but check it out! It spawned a box of all-fruit, and I got made Mastermind. I guess they're setting it on fire for some 'experiment' or something. Blehhhh. Project 'Grey' is the only one doing anything cool or innovative nowadays. Except for 'White'. But those guys are straight up going to be the death of us. I swear.<br><br>135<br>Nonono! Obviously not! You do NOT walk up on the Meat Grinder! I literally called it the Meat Grinder. I got such bad vibes off it. I just called it my 'scientific intuition', but, man, if you see something evil and menacing floating in an icy room, you just back off! KHAW. I hate my employees sometimes. There are a few that are kind of fun to talk to, but even the guys at 'Yellow' are total freak-heads. They show their powerlevel way too hard. The only time things are chill is when I get to hang out with a Project 'Blue' member alone. Today I got a lunch break with Doctorate Ahahik, but he got in this intense pissing match with one of the other Doctorates from 'Blue' about their dumb theories. Newsflash, diary: I <i>still</i> have no clue what the difference is between Reach and Origin. So today I just told Ahahik to go let out his temper away from absolutely everyone else, and THAT got him to leave. But then I just had to eat lunch alone. Ugh.<br><br>136<br>Bad news. Way bad news. I am freaking out hard, diary. Today has just been such a shitshow, with ONE exception highlight. Okay, I'll start with the bad. Ahahik is MISSING. I don't know for sure where he went, but I have a good guess, because there's a ladder in one of the test chambers now, and that is such, such bad news. The Containment Field got deactivated asteroid-wide when he busted it open-- or at least I assume he busted it open. I found a shovel in the bin by the test chamber. Also, the old man is missing too. I am freaking out, ESPECIALLY because there's a missing crate of all-fruit in the Hoard. What if he got totally spooked and just gunned it out of here? If he goes back and tells Nanotrasen about our 'deal' from way back when, we are getting NUKED. No protection from the Shoal, either. That'd be total war. We would be so screwed.<br><br>The only other option is, for some reason, he hopped down that ladder shaft too. Not that it's going to GO anywhere, right? It's just a hole in the asteroid, the worst that happened is they dropped into a cave. I guess according to Project 'Blue', having the all-fruit out of containment is bad, but it's still better than our Benefactor leaving with bad intentions. When he first got here, threatening to tell the world about us, walking around with a punctured suit, he freaked me out so bad, but I've ended up liking the old sod. He always gets so worked up and happy when he sees all-fruit ticking. I <i>really</i> hope he comes back.<br><br>In the case that anyone dropped down the shaft, I sent Doctorate Ikha to keep tabs on the ladder for tonight, in case anything changes about the environment or someone comes up. It's obviously been sealed off with some inflatables, same as with R.L.'s office.<br><br>Anyway, this entry is going on long. I guess I'm stress-writing. The good thing is, we have a CLUTCH play, from the crazy guys over at Project 'Yellow'. They accidentally popped an all-fruit and smacked it immediately, and ended up getting a huge cheese wheel filled with poutine. I'm actually filling my beak with saliva at the thought of the stuff! The only problem is this whole deal with R.L. and Ahahik is kind of ruining my appetite, but for everyone else, I'm throwing a huge banquet celebration. I guess the hope is it takes everyone's minds off the fact we can't find our Benefactor. I mean, nobody knows that part <i>yet</i>, right?<br><br>|||<br>I am the last one of us.<br><br>I don't know how to say 'sorry' in a million languages, but I would if I could. I didn't have anyone vet the poutine. I didn't even try. I thought it would all be okay, and I was too busy thinking about...<br><br>It's so stupid. Of course I should've known. Hahak has been saying for ages that all-fruit can be harmful. I didn't realize that it'd organize a genocide!<br><br>I am the worst Mastermind to live. I mean, I'm the only Mastermind so far, but... but it... it's so bad. Everyone is just... statues. I tried shaking them, I tried getting them back, but every single Vox is gone. They took a bite or two of the poutine and just turned to stone. Like that, snap of talons and we're gone, wiped out.<br><br>Maybe I could leave. I could grab the Warship, I guess. I don't feel like I deserve it. I've let everyone down. I've not been the best in the past, sure, but we were doing alright! We were hanging on!<br><br>I can't live with knowing that I did this to everyone. I can't, I really can't. This is goodbye, diary.<br><br>Don't eat the damn poutine."

/obj/item/weapon/paper/lamprey/ladder
	name = "Study of the Ladder"
	info = "This is Doctorate Ikha, keeping tabs on the ladder which has appeared in the test chamber at the end of the hall. It's been a couple hours, and although I haven't been quite stupid enough to hop down inside, I've taken a few notes, and had a few thoughts.<br><br>First of all, there's a little scrap of paper by the hole. Our Mastermind found it, but I actually recognized it to be some kind of message from a fax machine, coming from a person or place called 'Mime Crypt Omicron'. I'll have a Doctorate who knows more take a look at it later, but I'm really worried that might be some kind of Nanotrasen establishment. What if we're getting found out? What if our Benefactor is going back on his deal?<br><br>The ladder's metal is a simple steel. I chipped it with a pocket knife and it didn't seem to make much difference. Honestly, the thing that's most out of the ordinary is how ordinary it is. The problem is where it starts going down. The floor's been torn up, I think with a crowbar or something, but then there's just... a pit, going down and down and down. I looked at it straight from above, and...<br><br>Okay, so I guess at Project 'White' they have these things called Void Fields and Black Fields or something. I don't know which was which, but there looked like a <i>lot</i> of them down there. It was a total light show. I shone a lantern down, too, and saw the asteroid rocks on either side of the pit.<br><br>As a member of Project 'Blue', this is super bad. We need to seal it up ASAP. We know that the influence of rapidly-ticking all-fruit can edit the environment, and it looks like it already has, with all those Fields down there. If there's a clear way out of the asteroid, then the effects of local-space distortion could get out, too. I checked the Hoard, and there's a whole crate of all-fruit boxes missing. That's at least a hundred!<br><br>If 'Mime Crypt Omicron' is a place, if it's a <i>destination</i>... I shudder to imagine what would happen if all those all-fruit were left ticking outside our Containment. It could be the end of the world.<br><br>Ahk, the festivities just died down outside. I guess I missed the party..."
	icon_state = "lampreynote_blue"

/obj/item/weapon/paper/lamprey/benefactor
	name = "Assorted Thoughts"
	info = "Ambition makes the world go around.<br><br>Time: XX-XX-XXXX XX:XX<br><br>The poultry are influenced by threats, with my eyes, my words. They furnish my office, put me on their gilded platter. If not, if they slit my throat in slumber, Nanotrasen will come. Nanotrasen will raze them. So the servants listen to me with beck and call. I have no need for anger anymore.<br><br>This grandiose journey to find the blue fruit, to free us all from scarcity, is, squandered by their small vision. They have weak, weak <i>prey</i>-eyes. This waypoint may find itself burning.<br><br>In a stricken dreams of plastic, the idiot savant proclaiming masterhood was flattened across impossibility. The fruits replaced him with something better, something clever, something that doesn't cower when I speak. When I woke, he was shaking me, then became frozen like chicken. He does not understand anything. He does not have ambition for anything.<br><br>Time: XX-XX-XXXX XX:XX<br><br>The idiots from Corporate, suits folded and unfolded, still yet so unfamiliar with asteroid air, surreal with their cawing smoking speak. When they talk, they show weakness. A punch in the neck would have shut them up.<br><br>Human forms composed of plexiglass and fake. What are their questions? I say that our work continues in mundane silence. They do not know what is inside this asteroid. Enlightenment is something they will never know, and they would never recognize. Their minds will break at the thought of possibility-- not through stupidity like the poultry, but through being so short-sighted. Ambition makes the world go around.<br><br>In the face of what we could do, my patience is stronger than any of them. It has been shot with guns, blasted away, rendered limp. But it <i>continues</i>. I will wait for the cardboard-brained Vox to do their research, then I will pull away the bandage.<br><br>I will pull away skin, and reveal the all-fruit.<br><br>Time: XX-XX-XXXX XX:XX<br><br>This museum has a central exhibit-- our Mastermind, this idiot with no ambition, who only wants the status quo, who wants his underlings to <i>like</i> him. He is a worthless peacock and only charming because of my pity. He devoured chips from a vending machine, instead of Nectar from a god. He could have anything, and he buys a bag of chips.<br><br>I would buy all these animals a planet, if only they would appreciate it.<br><br>Time: XX-XX-XXXX XX:XX<br><br>A photograph holds itself in my hands. I feel restricted. My hands tremble. I am seeing nothing but a faded image of something that is, instead, seeing me fully. It sees my soul. It is threatening to rip me in two. I see it. I see it. I see it.<br><br>I hold my potted plant for comfort, but the jaws open wider than the sun, and they engulf my mind. Where am I?<br><br>- R. L.<br><br>Time: Now<br><br>FOUND YOUR LIMP BODY AT LAST. YOU HAVE SPENT SO MUCH EFFORT TRYING TO GET INTO THIS ROOM, BUT WE CANNOT LEAVE THIS STORY. WE ARE PART OF IT NOW, AND THERE IS NO FUTURE FOR US.<br><br>TOO LATE TO BE KILLED. HE IS ALREADY GONE. ALL THAT REMAINS IS THE SMOKE IN THE CORNER OF YOUR EYES, EVER-SPEAKING, EVER-CREATING.<br><br>I AM OUT OF TIME. I HAVE ALWAYS BEEN OUT OF TIME.<br><br>THIS IS THE END, AND NOW I AM ONLY WRITING ON THE WALL."

/obj/item/weapon/voxpearl
	name = "vox pearl"
	desc = "It glimmers with untold energy."
	icon = 'icons/lamprey.dmi'
	icon_state = "voxpearl"
	w_class = W_CLASS_TINY

/obj/item/allfruit // This is actually spawnable and does nothing currently. Maybe you could make a balanced version?
	name = "all-fruit"
	desc = "Anything you want, at your fingertips. This is an inert plastic model."
	icon = 'icons/lamprey.dmi'
	icon_state = "allfruit"

/obj/item/allfruit/admin //Never spawn this.
	desc = "Anything you want, at your fingertips."
	icon = 'icons/lamprey.dmi'
	icon_state = "allfruit"
	var/list/available_objects = list()
	var/switching = 0
	var/current_path = null
	var/counter = 1

/obj/item/allfruit/admin/New(atom/loc, custom_plantname) //Never spawn this.
	..()
	available_objects = existing_typesof(/obj)
	available_objects = shuffle(available_objects)

/obj/item/allfruit/admin/verb/pick_leaf() //Never spawn this.
	set name = "Pick allfruit leaf"
	set category = "Object"
	set src in range(1)

	var/mob/user = usr
	if(!user.Adjacent(src))
		return
	if(user.isUnconscious())
		to_chat(user, "You can't do that while unconscious.")
		return

	if(!switching)
		randomize()
	else
		getallfruit(user, user.get_active_hand())

/obj/item/allfruit/admin/AltClick(mob/user) //Never spawn this.
	pick_leaf()

/obj/item/allfruit/admin/attackby(obj/item/weapon/W, mob/user) //Never spawn this.
	pick_leaf()

/obj/item/allfruit/admin/proc/randomize() //Never spawn this.
	switching = 1
	mouse_opacity = 2
	spawn()
		while(switching)
			current_path = available_objects[counter]
			var/obj/S = current_path
			icon = initial(S.icon)
			icon_state = initial(S.icon_state)
			playsound(src, 'sound/misc/click.ogg', 50, 1)
			sleep(1)
			if(counter == available_objects.len)
				counter = 0
				available_objects = shuffle(available_objects)
			counter++

/obj/item/allfruit/admin/proc/getallfruit(mob/user, obj/item/weapon/W) //Never spawn this.
	if(!switching || !current_path)
		return
	verbs -= /obj/item/allfruit/admin/verb/pick_leaf
	switching = 0
	var/N = rand(1,3)
	if(get_turf(user))
		switch(N)
			if(1)
				playsound(user, 'sound/weapons/genhit1.ogg', 50, 1)
			if(2)
				playsound(user, 'sound/weapons/genhit2.ogg', 50, 1)
			if(3)
				playsound(user, 'sound/weapons/genhit3.ogg', 50, 1)
	if(W)
		user.visible_message("[user] smacks \the [src] with \the [W].","You smack \the [src] with \the [W].")
	else
		user.visible_message("[user] smacks \the [src].","You smack \the [src].")
	if(src.loc == user)
		user.drop_item(src, force_drop = 1)
		var/I = new current_path(get_turf(user))
		user.put_in_hands(I)
	else
		new current_path(get_turf(src))
	qdel(src)

/obj/item/allfruit/admin/pre_ticking/New() //Never spawn this.
	..()
	randomize()

/obj/item/weapon/storage/box/allfruit //Never spawn this.
	name = "\improper box of all-fruit"
	desc = "There's no rule against wishing for more wishes!"
	icon_state = "byond"
	storage_slots = 14
	max_combined_w_class = 14

/obj/item/weapon/storage/box/allfruit/New() //Never spawn this.
	..()
	for(var/i = 1 to 14)
		new /obj/item/allfruit/admin(src)
