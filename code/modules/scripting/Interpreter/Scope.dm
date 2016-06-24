/*
	Class: scope
	A runtime instance of a block. Used internally by the interpreter.
*/
/datum/scope
	var/datum/scope/parent = null
	var/datum/node/BlockDefinition/block
	var/list/functions
	var/list/variables

/datum/scope/New(var/datum/node/BlockDefinition/B, var/datum/scope/parent)
	block = B
	parent = parent
	variables = B.initial_variables.Copy()
	functions = B.functions.Copy()
	. = ..()
