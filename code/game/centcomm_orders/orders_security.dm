/datum/centcomm_order/department/security
	acct_by_string = "Security"
	request_consoles_to_notify = list(
		"Head of Security's Desk",
		"Security"
		)

/datum/centcomm_order/department/security/criminal/New()
	..()
	must_be_in_crate = 0
	requested = list(
		/mob/living = 1
	)
	name_override = list(
		/mob/living = "Captured Enemy of the Corporation"
	)
	extra_requirements = "Dead or alive, dead paying half."
	worth = 1200

/datum/centcomm_order/department/security/criminal/ExtraChecks(var/mob/living/L)
    if(!isanyantag(L))
        return 0
    return 1