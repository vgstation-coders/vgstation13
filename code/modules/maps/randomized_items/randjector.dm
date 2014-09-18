
//**************************************************************
//
// Randomized Injectors
// -------------------------
// For the glorious fools who'd use them
//
//**************************************************************

/obj/item/randjector
	desc = "It's filled with a murky liquid, and appears to be spring-loaded."
	var/list/reagentsToAdd = list()
	var/messagePre
	var/messagePost

/obj/item/randjector
	icon = 'icons/obj/map/randjectors.dmi'

/obj/item/randjector/New()
	src.create_reagents(1000)
	var/adj1 = pick("dirty","ancient","grimy","filthy","greasy","oily","moist")
	var/adj2 = pick("wicked","used","dangerous","shitty","mysterious","odd")
	var/label = pick(
		"Don't tell Hippocrates!",
		"Good medicine!",
		"Sweet brown sugar!",
		"Inject me!",
		"Enjoy!",
		"Are you man enough?!",
		)
	src.messagePre = pick(
		"Whispering a silent prayer",
		"Suspecting there's something very wrong with you",
		"Questioning your life choices",
		"Repressing your doubts",
		"Steeling your resolve",
		)
	src.messagePost = pick(
		"and hope you wore clean underwear today",
		"and start having second thoughts",
		"and immediately begin to regret it",
		"and wonder why",
		"and doubt your sanity",
		"and your life flashes before your eyes",
		)
	src.name = "[adj1], [adj2]-looking injector"
	if(prob(50)) src.desc = "The label says: \"<I>[label]</I>\""
	src.pickReagents()
	if(prob(50)) src.icon_state = "single"
	else
		if(prob(50)) src.icon_state = "fat"
		else
			src.icon_state = "double"
			src.pickReagents()
		for(. in src.reagentsToAdd)
			src.reagents.add_reagent(.,src.reagentsToAdd[.])
	for(. in src.reagentsToAdd)
		src.reagents.add_reagent(.,src.reagentsToAdd[.])
	var/image/I = image(src.icon,,"[src.icon_state]_overlay")
	I.color = pick("#FF0000","#FF9900","#00FF00","#00CCFF","#FF00FF")
	I.alpha = 192
	src.overlays += I
	src.pixel_x += rand(-3,3)
	src.pixel_y += rand(-3,3)
	return ..()

/obj/item/randjector/proc/pickReagents() //honk if you love RNG
	if(prob(5)) src.reagentsToAdd["adminordrazine"] = rand(20,100)
	if(prob(5)) src.reagentsToAdd["cyanide"] = rand(1,10)
	if(prob(5)) src.reagentsToAdd["chloralhydrate"] = rand(1,10)
	if(prob(5)) src.reagentsToAdd["creatine"] = rand(30,70)
	if(prob(5)) src.reagentsToAdd["capsaicin"] = rand(10,30)
	if(prob(5)) src.reagentsToAdd["bustanut"] = rand(10,30)
	if(prob(5)) src.reagentsToAdd["frostoil"] = rand(10,30)
	if(prob(5)) src.reagentsToAdd["nutriment"] = rand(40,120)
	if(prob(5)) src.reagentsToAdd["nanites"] = rand(50,100)
	if(prob(5)) src.reagentsToAdd["xenomicrobes"] = rand(50,100)
	if(prob(5)) src.reagentsToAdd["mutationtoxin"] = rand(1,10)
	if(prob(5)) src.reagentsToAdd["ryetalyn"] = rand(1,10)
	if(prob(5)) src.reagentsToAdd["mutagen"] = rand(5,20)
	if(prob(5)) src.reagentsToAdd["amutationtoxin"] = rand(1,10)
	if(prob(5)) src.reagentsToAdd["space_drugs"] = rand(50,150)
	if(prob(5)) src.reagentsToAdd["pacid"] = rand(5,20)
	if(prob(5)) src.reagentsToAdd["radium"] = rand(10,50)
	if(prob(5)) src.reagentsToAdd["fuel"] = rand(10,50)
	if(prob(5)) src.reagentsToAdd["plasma"] = rand(10,50)
	if(prob(5)) src.reagentsToAdd["anti_toxin"] = rand(20,100)
	if(prob(5)) src.reagentsToAdd["leporazine"] = rand(10,50)
	if(prob(5)) src.reagentsToAdd["tricordrazine"] = rand(10,50)
	if(prob(5)) src.reagentsToAdd["dexalinp"] = rand(1,10)
	if(prob(5)) src.reagentsToAdd["impedrezene"] = rand(5,20)
	if(prob(5)) src.reagentsToAdd["imidazoline"] = rand(5,20)
	if(prob(5)) src.reagentsToAdd["inacusiate"] = rand(5,20)
	if(prob(5)) src.reagentsToAdd["alkysine"] = rand(10,30)
	if(prob(5)) src.reagentsToAdd["bicaridine"] = rand(20,70)
	if(prob(5)) src.reagentsToAdd["hyperzine"] = rand(20,70)
	if(prob(5)) src.reagentsToAdd["rezadone"] = rand(10,50)
	if(prob(5)) src.reagentsToAdd["zombiepowder"] = rand(5,20)
	if(prob(5)) src.reagentsToAdd["mindbreaker"] = rand(50,150)
	if(prob(5)) src.reagentsToAdd["spiritbreaker"] = rand(5,20)
	if(prob(5)) src.reagentsToAdd["doctorsdelight"] = rand(20,70)
	if(prob(5)) src.reagentsToAdd["amasec"] = rand(1,10)
	if(prob(5)) src.reagentsToAdd["neurotoxin"] = rand(5,20)
	if(prob(5)) src.reagentsToAdd["ethanol"] = rand(20,100)
	if(src.reagentsToAdd.len < 4) .()
	return

/obj/item/randjector/attack(mob/M,mob/user)
	if(istype(M,/mob) && M.reagents)
		src.reagents.trans_to(M,src.reagents.total_volume)
		. = "<font color='red'>[user.name] ([user.ckey]) injected [M.name] ([M.ckey]) with the [src] (reagents: [list2params(src.reagentsToAdd)]).</font>"
		user.attack_log += text("\[[time_stamp()]\] [.]")
		if(M != user) //We only need this if they stab someone else
			M.attack_log += text("\[[time_stamp()]\] [.]")
			msg_admin_attack("[.] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
			log_attack(.)
			M << "<span class='danger'>You feel a huge prick!</span>"
			user << "<span class='notice'>You jab [src] into [M], slamming the plunger all the way in.</span>"
		else user << "<B>[src.messagePre], you jab [src] into your [pick("arm","leg","torso","neck")], [src.messagePost].</B>"
	new/obj/item/weapon/reagent_containers/syringe(user.loc)
	del(src)
	return
