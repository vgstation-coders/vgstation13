#define SEND_SIGNAL(target, sigtype, arguments...) ( !target.comp_lookup || !target.comp_lookup[sigtype] ? NONE : target._SendSignal(sigtype, list(##arguments)) )
#define SEND_GLOBAL_SIGNAL(sigtype, arguments...) ( SEND_SIGNAL(global.signal_handler, sigtype, ##arguments) )

#define COMPONENT_INCOMPATIBLE 1

// How multiple components of the exact same type are handled in the same datum
#define COMPONENT_DUPE_HIGHLANDER      0 //old component is deleted (default)
#define COMPONENT_DUPE_ALLOWED         1 //duplicates allowed
#define COMPONENT_DUPE_UNIQUE          2 //new component is deleted
#define COMPONENT_DUPE_UNIQUE_PASSARGS 4 //old component is given the initialization args of the new
