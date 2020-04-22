/datum/component
	var/atom/owner

/datum/component/New(var/datum/O)
	owner = O

//Args should be an assoc list for the sake of consistency.
/datum/component/proc/InitializeComponent(var/list/args)
    return

//Override this with behavior for receiving relevant signals.
/datum/component/proc/RecieveSignal(var/sigtype, var/list/args)
	return

//Tells the component's owner to signal all of its components.
/datum/component/proc/SendSignal(var/sigtype, var/list/args)
	owner.SignalComponents(sigtype, args)

// Returns a value depending on what the signal and args were.
/datum/component/proc/RecieveAndReturnSignal(var/sigtype, var/list/args)
	return 0