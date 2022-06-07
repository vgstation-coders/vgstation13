/obj/item/weapon/gun/procgun
    desc = "Oh no..."
    name = "proc gun"
    icon = 'icons/obj/device.dmi'
    icon_state = "eftpos" // We gmod now (looks like toolgun)
    w_class = W_CLASS_SMALL
    recoil = 0
    fire_delay = 0
    fire_sound = "procgun_sound"
    var/procname
    var/list/procargs = list()

var/static/list/bad_procs = list(
	"gib",
	"ex_act",
	"singularity_act",
	"shuttle_act",
	"death",
)

/obj/item/weapon/gun/procgun/attack_self(mob/user)
    if(!user.check_rights(R_DEBUG))
        to_chat(user,"<span class='warning'>You do not have the divine authority to modify what this gun does.</span>")
        return

    procname = input("Proc path to call on target hit, eg: /proc/fake_blood","Path:", null) as text|null
    if(!procname)
        return

    var/argnum = input("Number of arguments","Number:",0) as num|null
    if(!argnum && (argnum!=0))
        return

    procargs.len = argnum // Expand to right length

    var/i
    for(i = 1, i < argnum + 1, i++) // Lists indexed from 1 forwards in byond
        procargs[i] = variable_set(user.client)

    if(procname in bad_procs)
        desc = "RUN!!!"
    else
        desc = "Oh no..."

    process_chambered()

/obj/item/weapon/gun/procgun/process_chambered()
    if(!in_chamber)
        in_chamber = new/obj/item/projectile/beam/procjectile(src)
    var/obj/item/projectile/beam/procjectile/P = in_chamber
    P.procname = procname
    P.procargs = procargs.Copy()
    return 1

/obj/item/projectile/beam/procjectile
    name = "proc beam"
    icon = 'icons/obj/projectiles_experimental.dmi'
    icon_state = "procg"
    damage = 0
    nodamage = TRUE
    fire_sound = "procgun_sound"
    var/procname
    var/list/procargs = list()

/obj/item/projectile/beam/procjectile/to_bump(atom/A)
    if(procname && hascall(A, procname))
        spawn(1)
            call(A,procname)(arglist(procargs))
    return ..()
