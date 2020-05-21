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
	anti_ethereal = 0

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

/obj/item/weapon/voxpearl
	name = "vox pearl"
	desc = "It glimmers with untold energy."
	icon = 'icons/lamprey.dmi'
	icon_state = "voxpearl"
	w_class = W_CLASS_TINY
