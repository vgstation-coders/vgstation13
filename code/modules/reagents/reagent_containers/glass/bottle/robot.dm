
/obj/item/weapon/reagent_containers/glass/bottle/robot
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25,30,50,100)
	flags = FPRINT  | OPENCONTAINER
	volume = 60
	var/reagent = ""

/obj/item/weapon/reagent_containers/glass/bottle/robot/restock()
	if(reagent && (reagents.get_reagent_amount(reagent) < volume))
		reagents.add_reagent(reagent, 2)

/obj/item/weapon/reagent_containers/glass/bottle/robot/inaprovaline
	name = "internal inaprovaline bottle"
	desc = "A small bottle. Contains inaprovaline - used to stabilize patients."
	//icon_state = "bottle16"
	reagent = INAPROVALINE
	reagents_to_add = INAPROVALINE

/obj/item/weapon/reagent_containers/glass/bottle/robot/antitoxin
	name = "internal anti-toxin bottle"
	desc = "A small bottle of Anti-toxins. Counters poisons, and repairs damage, a wonder drug."
	//icon_state = "bottle17"
	reagent = ANTI_TOXIN
	reagents_to_add = ANTI_TOXIN
