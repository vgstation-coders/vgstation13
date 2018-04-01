/obj/item/device/assembly/signaler
	name = "remote signaling device"
	desc = "Used to remotely activate devices. Allows for syncing when using a secure signaler on another."
	icon_state = "signaller"
	item_state = "signaler"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	materials = list(MAT_METAL=400, MAT_GLASS=120)
	wires = WIRE_RECEIVE | WIRE_PULSE | WIRE_RADIO_PULSE | WIRE_RADIO_RECEIVE
	attachable = 1

	var/code = DEFAULT_SIGNALER_CODE
	var/frequency = FREQ_SIGNALER
	var/delay = 0
	var/datum/radio_frequency/radio_connection
	var/suicider = null

/obj/item/device/assembly/signaler/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] eats \the [src]! If it is signaled, [user.p_they()] will die!</span>")
	playsound(src, 'sound/items/eatfood.ogg', 50, 1)
	user.transferItemToLoc(src, user, TRUE)
	suicider = user
	return MANUAL_SUICIDE

/obj/item/device/assembly/signaler/proc/manual_suicide(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user]'s \the [src] recieves a signal, killing them instantly!</span>")
	user.adjustOxyLoss(200)//it sends an electrical pulse to their heart, killing them. or something.
	user.death(0)

/obj/item/device/assembly/signaler/New()
	..()
	spawn(40)
		set_frequency(frequency)


/obj/item/device/assembly/signaler/Destroy()
	SSradio.remove_object(src,frequency)
	return ..()

/obj/item/device/assembly/signaler/activate()
	if(!..())//cooldown processing
		return FALSE
	signal()
	return TRUE

/obj/item/device/assembly/signaler/update_icon()
	if(holder)
		holder.update_icon()
	return

/obj/item/device/assembly/signaler/ui_interact(mob/user, flag1)
	. = ..()
	if(is_secured(user))
		var/t1 = "-------"
		var/dat = {"
<TT>

<A href='byond://?src=[REF(src)];send=1'>Send Signal</A><BR>
<B>Frequency/Code</B> for signaler:<BR>
Frequency:
<A href='byond://?src=[REF(src)];freq=-10'>-</A>
<A href='byond://?src=[REF(src)];freq=-2'>-</A>
[format_frequency(src.frequency)]
<A href='byond://?src=[REF(src)];freq=2'>+</A>
<A href='byond://?src=[REF(src)];freq=10'>+</A><BR>

Code:
<A href='byond://?src=[REF(src)];code=-5'>-</A>
<A href='byond://?src=[REF(src)];code=-1'>-</A>
[src.code]
<A href='byond://?src=[REF(src)];code=1'>+</A>
<A href='byond://?src=[REF(src)];code=5'>+</A><BR>
[t1]
</TT>"}
		user << browse(dat, "window=radio")
		onclose(user, "radio")
		return


/obj/item/device/assembly/signaler/Topic(href, href_list)
	..()

	if(!usr.canmove || usr.stat || usr.restrained() || !in_range(loc, usr))
		usr << browse(null, "window=radio")
		onclose(usr, "radio")
		return

	if (href_list["freq"])
		var/new_frequency = (frequency + text2num(href_list["freq"]))
		if(new_frequency < MIN_FREE_FREQ || new_frequency > MAX_FREE_FREQ)
			new_frequency = sanitize_frequency(new_frequency)
		set_frequency(new_frequency)

	if(href_list["code"])
		src.code += text2num(href_list["code"])
		src.code = round(src.code)
		src.code = min(100, src.code)
		src.code = max(1, src.code)

	if(href_list["send"])
		spawn( 0 )
			signal()

	if(usr)
		attack_self(usr)

	return

/obj/item/device/assembly/signaler/attackby(obj/item/W, mob/user, params)
	if(issignaler(W))
		var/obj/item/device/assembly/signaler/signaler2 = W
		if(secured && signaler2.secured)
			code = signaler2.code
			frequency = signaler2.frequency
			to_chat(user, "You transfer the frequency and code of \the [signaler2.name] to \the [name]")
	..()

/obj/item/device/assembly/signaler/proc/signal()
	if(!radio_connection)
		return

	var/datum/signal/signal = new(list("code" = code))
	radio_connection.post_signal(src, signal)

	var/time = time2text(world.realtime,"hh:mm:ss")
	var/turf/T = get_turf(src)
	if(usr)
		GLOB.lastsignalers.Add("[time] <B>:</B> [usr.key] used [src] @ location ([T.x],[T.y],[T.z]) <B>:</B> [format_frequency(frequency)]/[code]")


	return

/obj/item/device/assembly/signaler/receive_signal(datum/signal/signal)
	if(!signal)
		return 0
	if(signal.data["code"] != code)
		return 0
	if(!(src.wires & WIRE_RADIO_RECEIVE))
		return 0
	if(suicider)
		manual_suicide(suicider)
	pulse(1)
	audible_message("[icon2html(src, hearers(src))] *beep* *beep*", null, 1)
	return


/obj/item/device/assembly/signaler/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, RADIO_SIGNALER)
	return

// Embedded signaller used in grenade construction.
// It's necessary because the signaler doens't have an off state.
// Generated during grenade construction.  -Sayu
/obj/item/device/assembly/signaler/reciever
	var/on = FALSE

/obj/item/device/assembly/signaler/reciever/proc/toggle_safety()
	on = !on

/obj/item/device/assembly/signaler/reciever/activate()
	toggle_safety()
	return 1

/obj/item/device/assembly/signaler/reciever/describe()
	return "The radio receiver is [on?"on":"off"]."

/obj/item/device/assembly/signaler/reciever/receive_signal(datum/signal/signal)
	if(!on)
		return
	return ..(signal)


// Embedded signaller used in anomalies.
/obj/item/device/assembly/signaler/anomaly
	name = "anomaly core"
	desc = "The neutralized core of an anomaly. It'd probably be valuable for research."
	icon_state = "anomaly core"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'

/obj/item/device/assembly/signaler/anomaly/receive_signal(datum/signal/signal)
	if(!signal)
		return 0
	if(signal.data["code"] != code)
		return 0
	for(var/obj/effect/anomaly/A in get_turf(src))
		A.anomalyNeutralize()

/obj/item/device/assembly/signaler/anomaly/attack_self()
	return

/obj/item/device/assembly/signaler/cyborg

/obj/item/device/assembly/signaler/cyborg/attackby(obj/item/W, mob/user, params)
	return
