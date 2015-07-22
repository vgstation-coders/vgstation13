//insert smart UI code here!
/datum/html_interface/clockslab/New()
	. = ..()

	//CSS file.
	head += "<link rel='stylesheet' type='text/css' href='slab.css'/>"
	updateLayout("")

/datum/html_interface/clockslab/updateLayout(var/nlayout)
	//Eventually the HTML code will be here.
	..({"

	"})