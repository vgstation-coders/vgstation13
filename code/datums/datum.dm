/datum
	var/datum/weakref/weak_reference
	/// Lazy associated list of type -> component/list of components.
	var/list/datum_components
	/// (private) Lazy associated list of signal -> registree/list of registrees
	var/list/comp_lookup
	/// (private) Associated lazy list of signals -> `/datum/callback`s that will be run when the parent datum receives that signal
	var/list/signal_procs
	/// (protected, boolean) If the component is enabled. If not, it will not react to signals.
	/// `FALSE` by default, set to `TRUE` when a signal is registered
	var/signal_enabled = FALSE