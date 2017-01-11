// SO HERE'S THE PROBLEM.
// There's tons of SHITCODE that assumes that if the ticker exists during /New(), the thing got created after object init.
// This is both naive and flat out wrong.
// So we can't make the ticker be initialized at its global variable, because then New() fucks up.
// But the ticker needs to exist during object init, but it can't start before init.
// SO we have a separate subsystem just to create the ticker.
// Thanks, oldcoders.
var/datum/subsystem/create_ticker/SScreate_ticker

/datum/subsystem/create_ticker
	name       = "Create Ticker"
	init_order = SS_INIT_TICKER_SPAWN
	flags      = SS_NO_FIRE

/datum/subsystem/create_ticker/Initialize(timeofday)
	ticker = new
	// Fuck announcing this, no ..().

// Yes that's it.
// Just fuck my shit up.
