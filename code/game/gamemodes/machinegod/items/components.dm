/obj/item/clock_component
	name = "Clockwork Component"
	desc = "lol this item shouldn't exist"
	icon = 'icons/obj/clockwork/components.dmi'
	throwforce = 0
	w_class = 1.0
	throw_speed = 7
	throw_range = 15
	var/list/godtext = list("This item really shouldn't exist, y'know.")
	var/godbanter = "Your shit sucks and this item shouldn't exist."

	var/component_type = "well then..." //Type of this component

/obj/item/clock_component/examine(mob/user)
	..()
	//add a check to see if the revenant in question isn't summoned, if false, no response
	if(prob(15) && isclockcult(user))
		user << "<span class='clockwork'>[pick(godtext)]</span>"
	if(iscultist(user) || user.mind.assigned_role == "Chaplain")
		if(prob(45))
			user << "<span class='danger'>[godbanter]</span>"

/obj/item/clock_component/belligerent
	name = "belligerent eye"
	desc = "<span class='danger'>It's as if it's looking for something to hurt.</span>"
	icon_state = "eye"
	godtext = list("\"...\"", \
	"For a brief moment, your mind is flooded with extremely violent thoughts.")
	godbanter = "The eye gives you an intensely hateful glare."

	component_type = CLOCK_BELLIGERENT

/obj/item/clock_component/vanguard
	name = "vanguard cogwheel"
	desc = "<span class='info'>It's as if it's trying to comfort you with its glow.</span>"
	icon_state = "cogwheel"
	godtext = list("\"Be safe, child.\"", \
	"You feel comforted, inexplicably.", \
	"\"Never hesitate to make sacrifices for your brothers and sisters.\"", \
	"\"Never forget; pain is temporary, His glory is eternal.\"")
	godbanter = "\"Pray to your god that we never meet.\""

	component_type = CLOCK_VANGUARD

/obj/item/clock_component/replicant
	name = "replicant alloy"
	desc = "<b>It's as if it's calling to be moulded into something greater.</b>"
	icon_state = "alloy"
	godtext = list("\"There's always something to be done. Get to it.\"", \
	"\"Spend more time making these and less time gazing into them.\"", \
	"\"Idle hands are worse than broken hands. Get to work.\"", \
	"A detailed image of Ratvar appears in the alloy for a split second.")
	godbanter = "The alloy takes an ugly, grotesque shape for a moment."

	component_type = CLOCK_REPLICANT

/obj/item/clock_component/hierophant
	name = "hierophant ansible"
	desc = "<span style='color:#ffc000'><b>It's as if it's trying to say something...</b></span>"
	icon_state = "ansible"
	godtext = list("\"NYEHEHEHEHEH!\"", \
	"\"Rkvyr vf fhpu n'ober. Gurer'f abguvat v'pna uhag va urer.\"", \
	"\"Jung'f xrrcvat lbh? V'jnag gb tb xvyy fbzrguvat.\"", \
	"\"V'zvff gur fzryy bs oheavat syrfu fb onqyl...\"")
	godbanter = "\"Fbba, jr funyy erghea, naq lbh funyy crevfu. Hahahaha...\""

	component_type = CLOCK_HIEROPHANT

/obj/item/clock_component/geis
	name = "geis capacitor"
	desc = "<span style='color:magenta'><i>It's as if it really doesn't doesn't appreciate being held.</i></span>"
	icon_state = "capacitor"
	godtext = list("\"Disgusting.\"", \
	"\"Well, aren't you an inquisitive fellow?\"", \
	"A foul presence pervades your mind, and suddenly vanishes.", \
	"\"The fact that Ratvar has to depend on simpletons like you is appalling.\"")
	godbanter = "\"Try not lose your head. I need that, you know. Ha ha ha...\""

	component_type = CLOCK_GEIS
