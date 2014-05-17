/*
Tickity tock
*/

/obj/item/watch
	icon = 'icons/obj/watch.dmi' 
	var/watchtype = 0 //Controls the visible message for checking time. 
	var/fake = 0 //Hey kid, want a watch?

/obj/item/watch/attack_self(mob/living/user as mob)
	switch(watchtype)
		if(watchtype = 1)
			usr.visible_message("<span class='rose'>[usr] swiftly raises the watch to his hand, and checks the time. So cool.</span>") 
		if(watchtype = 2)
			usr.visible_message("<span class='rose'>[usr] flicks open the pocket watch, glances at the watch face, and closes the watch again. Classy.</span>") 
		else
			usr.visible_message("<span class='rose'>[usr] checks the time.</span>")

	if(fake = 1)
		usr << "The time is [rand(1,24)]:[rand(1,60)]."
	else
		usr << "The time is [worldtime2text()]."

//This is for wristwatches, but I figure you can use it for the rest of them too.
/obj/item/watch/verb/checktime()
	set category = "Object"
	set name = "Check the time"
	set desc = "Check the time on a watch."

	switch(watchtype)
		if(watchtype = 1)
			usr.visible_message("<span class='rose'>[usr] swiftly raises the watch to his hand, and checks the time. So cool.</span>") 
		if(watchtype = 2)
			usr.visible_message("<span class='rose'>[usr] flicks open the pocket watch, glances at the watch face, and closes the watch again. Classy.</span>") 
		else
			usr.visible_message("<span class='rose'>[usr] checks the time.</span>")

	if(fake = 1)
		usr << "The time is [rand(1,24)]:[rand(1,60)]."
	else
		usr << "The time is [worldtime2text()]."
		
		
//Base for the wrist watch.	
/obj/item/watch/wrist
	name = "wrist watch"
	desc = "A watch? On your wrist? What will they think of next?"
	icon_state = "wristwatch"
	item_state = "wristwatch"
	w_class = 1.0
	flags = FPRINT | TABLEPASS | CONDUCT
	
	watchtype = 1
	
//Job related watches	
/obj/item/watch/wrist/rolex
	name = "rolex"
	desc = "Easy to say, nice to look at."
	icon_state = "rolex"
	item_state = "wristwatch"
	w_class = 1.0
	flags = FPRINT | TABLEPASS | CONDUCT



/obj/item/watch/wrist/cargo
	name = "brown watch"
	desc = "A wrist watch. This particular one is painted brown."
	icon_state = "cargowatch"
	item_state = "wristwatch"
	w_class = 1.0
	flags = FPRINT | TABLEPASS | CONDUCT




/obj/item/watch/wrist/science
	name = "purple watch"
	desc = "A wrist watch. This particular one is painted purple."
	icon_state = "sciencewatch"
	item_state = "wristwatch"
	w_class = 1.0
	flags = FPRINT | TABLEPASS | CONDUCT




/obj/item/watch/wrist/security
	name = "red watch"
	desc = "A wrist watch. This particular one is painted red."
	icon_state = "securitywatch"
	item_state = "wristwatch"
	w_class = 1.0
	flags = FPRINT | TABLEPASS | CONDUCT




/obj/item/watch/wrist/medical
	name = "blue watch"
	desc = "A wrist watch. This particular one is painted blue."
	icon_state = "medicalwatch"
	item_state = "wristwatch"
	w_class = 1.0
	flags = FPRINT | TABLEPASS | CONDUCT




/obj/item/watch/wrist/engineer
	name = "yellow watch"
	desc = "A wrist watch. This particular one is painted yellow."
	icon_state = "engineerwatch"
	item_state = "wristwatch"
	w_class = 1.0
	flags = FPRINT | TABLEPASS | CONDUCT



/obj/item/watch/wrist/syndie
	name = "black watch"
	desc = "A wrist watch. This particular one is painted black. It has writing on the back that says 'FUK NT!!1!'"
	icon_state = "syndiewatch"
	item_state = "wristwatch"
	w_class = 1.0
	flags = FPRINT | TABLEPASS | CONDUCT




/obj/item/watch/wrist/centcomm
	name = "grey watch"
	desc = "A wrist watch. This particular one is painted grey, with blue trim."
	icon_state = "centcommwatch"
	item_state = "wristwatch"
	w_class = 1.0
	flags = FPRINT | TABLEPASS | CONDUCT


//Pocket watches.
/obj/item/watch/pocketwatch
	name = "Pocket Watch"
	desc = "Fancy."
	icon_state = "pocket"
	item_state = "watch"
	w_class = 1.0
	flags = FPRINT | TABLEPASS | CONDUCT

	watchtype = 2 
	
/obj/item/watch/old
	name = "Old Pocket Watch"
	desc = "Classy."
	icon_state = "oldpocket"
	item_state = "watch"
	w_class = 1.0
	flags = FPRINT | TABLEPASS | CONDUCT


/obj/item/watch/fakepocket
	name = "Damaged Pocket Watch"
	desc = "Something seems off.."
	icon_state = "fakepocket"
	item_state = "watch"
	w_class = 1.0
	flags = FPRINT | TABLEPASS | CONDUCT

	fake = 1


/obj/item/watch/syndie
	name = "Strange Pocket Watch"
	desc = "Strangly Fancy."
	icon_state = "cloaking" //Old name. Felt I should leave it incase I ever get the urge to figure cloaking watches out.
	item_state = "watch"
	w_class = 1.0
	flags = FPRINT | TABLEPASS | CONDUCT

