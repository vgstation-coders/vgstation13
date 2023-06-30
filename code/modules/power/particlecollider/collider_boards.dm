//why are the board req_components and the machine component_parts even separate?

/obj/item/weapon/circuitboard/particle_collider
	name = "circuitboard (parent collider)"
	desc = "Highly illegal. Contact your nearest nanotrasen administrator and inform them where you've obtained this."
	build_path = /obj/machinery/power/collider
	board_type = MACHINE
	origin_tech = Tc_ENGINEERING + "=2;" + Tc_POWERSTORAGE + "=2"
	
/obj/item/weapon/circuitboard/particle_collider/merger
	name = "Circuit Board (Particle merger)"
	desc = "A circuit board used to run a machine that merges particle streams."
	build_path = /obj/machinery/power/collider/merger
	req_components = list(
		/obj/item/weapon/stock_parts/manipulator = 1,
		/obj/item/weapon/stock_parts/micro_laser = 1,
		/obj/item/weapon/stock_parts/scanning_module = 1)
		
/obj/item/weapon/circuitboard/particle_collider/filter
	name = "Circuit Board (Particle filter)"
	desc = "A circuit board used to run a machine that routes particle streams."
	build_path = /obj/machinery/power/collider/filter
	req_components = list(
		/obj/item/weapon/stock_parts/manipulator = 1,
		/obj/item/weapon/stock_parts/micro_laser = 1,
		/obj/item/weapon/stock_parts/scanning_module = 1)
		
/obj/item/weapon/circuitboard/particle_collider/emitter
	name = "Circuit Board (Particle emitter)"
	desc = "A circuit board used to run a machine that emits particle streams."
	build_path = /obj/machinery/power/collider/emitter
	req_components = list(
		/obj/item/weapon/stock_parts/matter_bin = 1,
		/obj/item/weapon/stock_parts/micro_laser = 2)
		
/obj/item/weapon/circuitboard/particle_collider/bottler
	name = "Circuit Board (Particle bottler)"
	desc = "A circuit board used to run a machine that collects particle streams."
	build_path = /obj/machinery/power/collider/bottler
	req_components = list(
		/obj/item/weapon/stock_parts/matter_bin = 2,
		/obj/item/weapon/stock_parts/micro_laser = 1)
		
/obj/item/weapon/circuitboard/particle_collider/collider
	name = "Circuit Board (Hadron collider)"
	desc = "A circuit board used to run a machine that collides particle streams."
	build_path = /obj/machinery/power/collider/collider
	req_components = list(
		/obj/item/weapon/stock_parts/micro_laser = 3)

/obj/item/weapon/circuitboard/particle_collider/pipe
	name = "Circuit Board (Particle pipe)"
	desc = "A circuit board used to run a machine that transports and accelerates particle streams."
	build_path = /obj/machinery/power/collider/pipe
	req_components = list(
		/obj/item/weapon/stock_parts/micro_laser = 1)


