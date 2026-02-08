// So we want to have compile time guarantees these methods exist on local type
// We use wrappers for this in case some part of the api ever changes, and to make their function more clear
// For the record: GLOBAL_VERB_REF would be useless as verbs can't be global.

/// Call by name proc references, checks if the proc exists on either this type () (AND ONLY THIS TYPE) or as a global proc.
#define PROC_REF(X) (nameof(.proc/##X))
/// Call by name verb references, checks if the verb exists on either this type or as a global verb.
#define VERB_REF(X) (nameof(.verb/##X))

/// Call by name proc reference, checks if the proc exists on either the given type or as a global proc
#define TYPE_PROC_REF(TYPE, X) (nameof(##TYPE.proc/##X))
/// Call by name verb reference, checks if the verb exists on either the given type or as a global verb
#define TYPE_VERB_REF(TYPE, X) (nameof(##TYPE.verb/##X))

/// Call by name proc reference, checks if the proc is an existing global proc
#define GLOBAL_PROC_REF(X) (/proc/##X)
