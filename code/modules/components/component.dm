/datum/component
	var/datum/component_container/container

	// Enables or disables the components
	var/enabled=1

/datum/component/New(var/datum/component_container/CC)
	container=CC

// Override to receive signals.
/datum/component/proc/RecieveSignal(var/sigtype, var/list/args)
	return

// Send a signal to all other components in the container.
/datum/component/proc/SendSignal(var/sigtype, var/list/args)
	container.SendSignal(sigtype, args)

// Return first /datum/component that is subtype of c_type.
/datum/component/proc/GetComponent(var/c_type)
	return container.GetComponent(c_type)

// Returns ALL /datum/components in parent container that are subtypes of c_type.
/datum/component/proc/GetComponents(var/c_type)
	return container.GetComponents(c_type)

// Returns a value depending on what the signal and args were.
/datum/component/proc/RecieveAndReturnSignal(var/sigtype, var/list/args)
	return 0
