/datum/component
	var/datum/owner

/datum/component/New(var/datum/O)
	owner = O

/datum/component/Destroy()
	..()

/*
	Override this (and add arguments) for component initialization logic.
*/
/datum/component/proc/InitializeComponent()
	return

/*
	If a component is able to be safely removed from an datum, override this with the logic for doing so.
	Components MUST override this if they are able to be detatched.
*/
/datum/component/proc/TryDetach()
	return FALSE

/*
	Called when the owner datum is Destroy()'d, in case we have to tell other components to do stuff before qdel()'ing them.
*/

/datum/component/proc/Deinitialize()
	return

/*
	Override this with behavior when receiving relevant signals.
*/

/datum/component/proc/ReceiveSignal(var/sigtype, var/list/args)
	return

/*
	Tells the component's owner to forward a signal to all of its components.
	sigtype: see __DEFINES/component_signals.dm for a list of valid signals
	args: assoc list of data sent with the signal
*/
/datum/component/proc/SendSignal(var/sigtype, var/list/args)
	owner.SignalComponents(sigtype, args)

/*
	Returns a value depending on what the signal and args were.
	sigtype: see __DEFINES/component_signals.dm for a list of valid signals
	args: assoc list of data sent with the signal
*/
/datum/component/proc/RecieveAndReturnSignal(var/sigtype, var/list/args)
	return 0
