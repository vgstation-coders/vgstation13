#define SEND_SIGNAL(target, sigtype, arguments...) ( !target.comp_lookup || !target.comp_lookup[sigtype] ? NONE : target._SendSignal(sigtype, list(##arguments)) )
#define SEND_GLOBAL_SIGNAL(sigtype, arguments...) ( SEND_SIGNAL(global.signal_handler, sigtype, ##arguments) )

// Return this from `/datum/component/Initialize` or `datum/component/OnTransfer`
// to have the component be deleted if it's applied to an incorrect type.
// `parent` must not be modified if this is to be returned.
//This will be noted in the runtime logs
#define COMPONENT_INCOMPATIBLE 1

// How multiple components of the exact same type are handled in the same datum
#define COMPONENT_DUPE_UNIQUE_PASSARGS 1 // (default) old component is given the initialization args of the new
#define COMPONENT_DUPE_ALLOWED         2 // duplicates allowed
