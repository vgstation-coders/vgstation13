/datum/html_interface_client
	// The /client object represented by this model.
	var/client/client

	// The layout currently visible to the client.
	var/layout

	// The content elements (mirrored from /datum/html_interface) currently visible to the client.
	var/list/content_elements = new/list()

	// The current title for this client
	var/title

	// TRUE if the browser control has loaded and will accept input, FALSE if not.
	var/is_loaded = FALSE

	// TRUE if this client should receive updates, FALSE if not.
	var/active = TRUE

	// A list of extra variables, for use by extensions.
	var/list/extra_vars

/datum/html_interface_client/New(client/client)
	. = ..()

	client = client

/datum/html_interface_client/proc/putExtraVar(key, value)
	if (!extra_vars) extra_vars = new/list()
	extra_vars[key] = value

/datum/html_interface_client/proc/removeExtraVar(key)
	if (extra_vars)
		. = extra_vars[key]

		extra_vars.Remove(key)

		if (!extra_vars.len) extra_vars = null

	return .

/datum/html_interface_client/proc/getExtraVar(key)
	if (extra_vars) return extra_vars[key]
