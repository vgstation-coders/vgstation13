/datum/bait_recipe


/obj/item/weapon/bait/hook
	name = "fishing hook"
	desc = "A simple metal hook meant for attaching objects not normally suited for a fishing rod to the rod. Results may vary."
	var/list/hookableItems = list(
		/obj/item/clothing/gloves/yellow = 101
	)

/obj/item/weapon/bait/hook/attack(obj/item/baitToBe, mob/user)
	if(!user.a_intent == I_HELP)
		..()

/obj/item/weapon/bait/hook/proc/baitCheck(baitToBe)
	var/bTypeTag = 0
	for(baitToBe in hookableItems)
		bTypeTag = hookableItems[baitToBe]
	var/theBait = bTypeDecide()

/obj/item/weapon/bait/hook/proc/bTypeDecide(baitToBe)
	switch(bTypeTag)
		if(0)
			return

/obj/item/weapon/bait/hook/proc/makeBait(baitToBe)
	var/theBait = bTypeDecide(baitToBe)
