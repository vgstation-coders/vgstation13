// PRESETS

// EMP

/obj/machinery/camera/emp_proof/New()
	..()
	upgradeEmpProof()

// X-RAY

/obj/machinery/camera/xray/New()
	..()
	upgradeXRay()
	update_icon()

// MOTION

/obj/machinery/camera/motion/New()
	..()
	upgradeMotion()

// HEARING

/obj/machinery/camera/hearing/New()
	..()
	upgradeHearing()

// ALL UPGRADES

/obj/machinery/camera/all/New()
	..()
	upgradeEmpProof()
	upgradeXRay()
	upgradeMotion()
	upgradeHearing()
	update_icon()

// AUTONAME

/obj/machinery/camera/autoname
	var/number = 0 //camera number in area

//This camera type automatically sets it's name to whatever the area that it's in is called.
/obj/machinery/camera/autoname/New()
	..()
	spawn(10)
		number = 1
		var/area/A = get_area(src)
		if(A)
			for(var/obj/machinery/camera/autoname/C in cameranet.cameras)
				if(C == src)
					continue
				var/area/CA = get_area(C)
				if(CA.type == A.type)
					if(C.number)
						number = max(number, C.number+1)
			c_tag = "[A.name] #[number]"


// CHECKS

/obj/machinery/camera/proc/isEmpProof()
	var/O = locate(/obj/item/stack/sheet/mineral/phoron) in assembly.upgrades
	return O

/obj/machinery/camera/proc/isXRay()
	var/O = locate(/obj/item/weapon/reagent_containers/food/snacks/grown/carrot) in assembly.upgrades
	return O

/obj/machinery/camera/proc/isMotion()
	var/O = locate(/obj/item/device/assembly/prox_sensor) in assembly.upgrades
	return O

/obj/machinery/camera/proc/isHearing()
	var/O = locate(/obj/item/device/assembly/voice) in assembly.upgrades
	return O

// UPGRADE PROCS

/obj/machinery/camera/proc/upgradeEmpProof()
	assembly.upgrades.Add(new /obj/item/stack/sheet/mineral/phoron(assembly))
	update_upgrades()

/obj/machinery/camera/proc/upgradeXRay()
	assembly.upgrades.Add(new /obj/item/weapon/reagent_containers/food/snacks/grown/carrot(assembly))
	update_upgrades()

// If you are upgrading Motion, and it isn't in the camera's New(), add it to the machines list.
/obj/machinery/camera/proc/upgradeMotion()
	assembly.upgrades.Add(new /obj/item/device/assembly/prox_sensor(assembly))
	update_upgrades()

/obj/machinery/camera/proc/upgradeHearing()
	assembly.upgrades.Add(new /obj/item/device/assembly/voice(assembly))
	update_upgrades()
	update_hear()
