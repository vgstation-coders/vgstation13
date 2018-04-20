/mob/living/carbon/complex/equip_to_slot(obj/item/W, slot, redraw_mob = 1)
	if(!istype(W))
		return

	if(src.is_holding_item(W))
		src.u_equip(W)

	W.hud_layerise()
	W.equipped(src, slot)
	W.forceMove(src)
	if(client)
		client.screen |= W