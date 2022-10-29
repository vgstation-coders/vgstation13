/obj/item/tool/suture/ //parent type, should never appear ingame
	name = "Suture"
	desc = "Some sort of simple surgical tool. This one doesn't seem to do anything."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "fixovein_old"
	
	w_class = SIZE_SMALL
	force = 0
	throwforce = 1
	
	var/heal_brute = 0
	var/heal_burn = 0
	//use time is in suturing.dm
	

// copied from CM-ss13
//a simple surgical tool, used to heal heavily damaged limbs
//doesn't fix bones, IB, or bleeding, just lowers damage
/obj/item/tool/suture/surgical_line
	name = "\improper surgical line"
	desc = "A roll of military-grade surgical line, able to seamlessly sew up any wound. Also works as a robust fishing line for maritime deployments."
	icon_state = "line"

	heal_brute = 10
	heal_burn = 0


//copied from CM-ss13
//a simple surgical tool, used to repair heavy burns
//TODO make it actually change your skin color
/obj/item/tool/suture/synthgraft
	name = "\improper Synth-Graft"
	desc = "An applicator for synthetic skin field grafts. The stuff reeks, itches like the dickens, hurts going on, and the colour is a perfectly averaged multiethnic tone that doesn't blend with <i>anyone's</i> complexion. But at least you don't have to stay in sickbay."
	icon_state = "graft" 
	
	heal_burn = 10
	heal_brute = 0
