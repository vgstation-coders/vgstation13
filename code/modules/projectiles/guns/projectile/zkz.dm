/obj/item/weapon/gun/projectile/zkz
    name = "\improper ZKZ transactional rifle"
    desc = "Primordial weapon attuned to the beating heart of the financial system."
    fire_sound = 'sound/weapons/vag.ogg'
    icon = 'icons/obj/biggun.dmi'
    icon_state = "mosinlarge"
    item_state = null
    inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
    max_shells = 30
    w_class = W_CLASS_LARGE
    force = 10
    flags = FPRINT
    siemens_coefficient = 1
    slot_flags = SLOT_BACK
    origin_tech = Tc_COMBAT + "=5;" + Tc_MATERIALS + "=2;" + Tc_SYNDICATE + "=5"
    gun_flags = 0
    mech_flags = MECH_SCAN_FAIL
    var/sheens = FALSE //white glow for millionaires on firing
    var/shotsleft = 30 //thirty fixed amount of shots, no extra ammo

/obj/item/weapon/gun/projectile/zkz/getAmmo()
    return shotsleft

/obj/item/weapon/gun/projectile/zkz/getSpent()
    return max_shells - shotsleft

/obj/item/weapon/gun/projectile/zkz/process_chambered()
    if(in_chamber)
        return 1
    else if(shotsleft)
        in_chamber = new /obj/item/projectile/bullet/a76239mm_financial(src)
        var/mob/M = loc
        var/totalvalue = 0
        if(istype(M))
            for(var/obj/item/weapon/card/id/C1 in get_contents_in_object(M, /obj/item/weapon/card/id))
                totalvalue += C1.GetBalance() //From bank account
                if(istype(C1.virtual_wallet))
                    totalvalue += C1.virtual_wallet.money
            for(var/obj/item/weapon/spacecash/C2 in get_contents_in_object(M, /obj/item/weapon/spacecash))
                totalvalue += C2.get_total()
            switch(totalvalue)
                if(0 to 99)
                    in_chamber.damage = 1
                if(100 to 999)
                    in_chamber.damage = 10
                if(1000 to 9999)
                    in_chamber.damage = 25
                if(10000 to 99999)
                    in_chamber.damage = 50
                if(100000 to 999999)
                    in_chamber.damage = 75
                if(1000000 to INFINITY)
                    in_chamber.damage = 10000
        fire_sound = totalvalue >= 1000000 ? 'sound/weapons/vag2.ogg' : 'sound/weapons/vag.ogg'
        sheens = totalvalue >= 1000000
        shotsleft--
        return 1
    return 0

/obj/item/weapon/gun/projectile/zkz/Fire(atom/target, mob/living/user, params, reflex = 0, struggle = 0, var/use_shooter_turf = FALSE)
    . = ..()
    if(. && sheens)
        var/PixelX = 0
        var/PixelY = 0
        switch(loc.dir)
            if(NORTH)
                PixelY = 16
            if(SOUTH)
                PixelY = -16
            if(EAST)
                PixelX = 16
            if(WEST)
                PixelX = -16
        var/image/impact = image('icons/obj/projectiles_impacts.dmi',loc,"spur_1")
        impact.pixel_x = PixelX
        impact.pixel_y = PixelY
        impact.layer = PROJECTILE_LAYER
        loc.overlays += impact
        spawn(3)
            loc.overlays -= impact
