/obj/machinery/turret/angry
    name = "Angry Turret"

/obj/machinery/turret/angry/update_gun()
    if(!installed)
        installed = /obj/item/weapon/gun/energy/laser