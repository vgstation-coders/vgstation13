// -- Borrowed from various authors from TGStation - https://github.com/tgstation/tgstation

// rust_g.dm - DM API for rust_g extension library
//
// To configure, create a `rust_g.config.dm` and set what you care about from
// the following options:
//
// #define RUST_G "path/to/rust_g"
// Override the .dll/.so detection logic with a fixed path or with detection
// logic of your own.
//
// #define RUSTG_OVERRIDE_BUILTINS
// Enable replacement rust-g functions for certain builtins. Off by default.

#ifndef RUST_G
// Default automatic RUST_G detection.
// On Windows, looks in the standard places for `rust_g.dll`.
// On Linux, looks in `.`, `$LD_LIBRARY_PATH`, and `~/.byond/bin` for either of
// `librust_g.so` (preferred) or `rust_g` (old).

/* This comment bypasses grep checks */ /var/__rust_g

/proc/__detect_rust_g()
	if (world.system_type == UNIX)
		if (fexists("./librust_g.so"))
			// No need for LD_LIBRARY_PATH badness.
			return __rust_g = "./librust_g.so"
		else if (fexists("./rust_g"))
			// Old dumb filename.
			return __rust_g = "./rust_g"
		else if (fexists("[world.GetConfig("env", "HOME")]/.byond/bin/rust_g"))
			// Old dumb filename in `~/.byond/bin`.
			return __rust_g = "rust_g"
		else
			// It's not in the current directory, so try others
			return __rust_g = "librust_g.so"
	else
		return __rust_g = "rust_g"

#define RUST_G (__rust_g || __detect_rust_g())
#endif

#define RUSTG_JOB_NO_RESULTS_YET "NO RESULTS YET"
#define RUSTG_JOB_NO_SUCH_JOB "NO SUCH JOB"
#define RUSTG_JOB_ERROR "JOB PANICKED"

#define rustg_git_revparse(rev) call_ext(RUST_G, "rg_git_revparse")(rev)
#define rustg_git_commit_date(rev) call_ext(RUST_G, "rg_git_commit_date")(rev)

#define rustg_log_write(fname, text, format) call_ext(RUST_G, "log_write")(fname, text, format)
/proc/rustg_log_close_all() return call_ext(RUST_G, "log_close_all")()

#define RUSTG_HTTP_METHOD_GET "get"
#define RUSTG_HTTP_METHOD_PUT "put"
#define RUSTG_HTTP_METHOD_DELETE "delete"
#define RUSTG_HTTP_METHOD_PATCH "patch"
#define RUSTG_HTTP_METHOD_HEAD "head"
#define RUSTG_HTTP_METHOD_POST "post"
#define rustg_http_request_blocking(method, url, body, headers) call_ext(RUST_G, "http_request_blocking")(method, url, body, headers)
#define rustg_http_request_async(method, url, body, headers) call_ext(RUST_G, "http_request_async")(method, url, body, headers)
#define rustg_http_check_request(req_id) call_ext(RUST_G, "http_check_request")(req_id)

#define rustg_sql_connect_pool(options) call_ext(RUST_G, "sql_connect_pool")(options)
#define rustg_sql_query_async(handle, query, params) call_ext(RUST_G, "sql_query_async")(handle, query, params)
#define rustg_sql_query_blocking(handle, query, params) call_ext(RUST_G, "sql_query_blocking")(handle, query, params)
#define rustg_sql_connected(handle) call_ext(RUST_G, "sql_connected")(handle)
#define rustg_sql_disconnect_pool(handle) call_ext(RUST_G, "sql_disconnect_pool")(handle)
#define rustg_sql_check_query(job_id) call_ext(RUST_G, "sql_check_query")("[job_id]")

/**
 * Sets up the Aho-Corasick automaton with its default options.
 *
 * The search patterns list and the replacements must be of the same length when replace is run, but an empty replacements list is allowed if replacements are supplied with the replace call
 * Arguments:
 * * key - The key for the automaton, to be used with subsequent rustg_acreplace/rustg_acreplace_with_replacements calls
 * * patterns - A non-associative list of strings to search for
 * * replacements - Default replacements for this automaton, used with rustg_acreplace
 */
#define rustg_setup_acreplace(key, patterns, replacements) call_ext(RUST_G, "setup_acreplace")(key, json_encode(patterns), json_encode(replacements))

/**
 * Sets up the Aho-Corasick automaton using supplied options.
 *
 * The search patterns list and the replacements must be of the same length when replace is run, but an empty replacements list is allowed if replacements are supplied with the replace call
 * Arguments:
 * * key - The key for the automaton, to be used with subsequent rustg_acreplace/rustg_acreplace_with_replacements calls
 * * options - An associative list like list("anchored" = 0, "ascii_case_insensitive" = 0, "match_kind" = "Standard"). The values shown on the example are the defaults, and default values may be omitted. See the identically named methods at https://docs.rs/aho-corasick/latest/aho_corasick/struct.AhoCorasickBuilder.html to see what the options do.
 * * patterns - A non-associative list of strings to search for
 * * replacements - Default replacements for this automaton, used with rustg_acreplace
 */
#define rustg_setup_acreplace_with_options(key, options, patterns, replacements) call_ext(RUST_G, "setup_acreplace")(key, json_encode(options), json_encode(patterns), json_encode(replacements))

/**
 * Run the specified replacement engine with the provided haystack text to replace, returning replaced text.
 *
 * Arguments:
 * * key - The key for the automaton
 * * text - Text to run replacements on
 */
#define rustg_acreplace(key, text) call_ext(RUST_G, "acreplace")(key, text)

/**
 * Run the specified replacement engine with the provided haystack text to replace, returning replaced text.
 *
 * Arguments:
 * * key - The key for the automaton
 * * text - Text to run replacements on
 * * replacements - Replacements for this call. Must be the same length as the set-up patterns
 */
#define rustg_acreplace_with_replacements(key, text, replacements) call_ext(RUST_G, "acreplace_with_replacements")(key, text, json_encode(replacements))

/**
 * This proc generates a cellular automata noise grid which can be used in procedural generation methods.
 *
 * Returns a single string that goes row by row, with values of 1 representing an alive cell, and a value of 0 representing a dead cell.
 *
 * Arguments:
 * * percentage: The chance of a turf starting closed
 * * smoothing_iterations: The amount of iterations the cellular automata simulates before returning the results
 * * birth_limit: If the number of neighboring cells is higher than this amount, a cell is born
 * * death_limit: If the number of neighboring cells is lower than this amount, a cell dies
 * * width: The width of the grid.
 * * height: The height of the grid.
 */
#define rustg_cnoise_generate(percentage, smoothing_iterations, birth_limit, death_limit, width, height) call_ext(RUST_G, "cnoise_generate")(percentage, smoothing_iterations, birth_limit, death_limit, width, height)

/**
 * This proc generates a grid of perlin-like noise
 *
 * Returns a single string that goes row by row, with values of 1 representing an turned on cell, and a value of 0 representing a turned off cell.
 *
 * Arguments:
 * * seed: seed for the function
 * * accuracy: how close this is to the original perlin noise, as accuracy approaches infinity, the noise becomes more and more perlin-like
 * * stamp_size: Size of a singular stamp used by the algorithm, think of this as the same stuff as frequency in perlin noise
 * * world_size: size of the returned grid.
 * * lower_range: lower bound of values selected for. (inclusive)
 * * upper_range: upper bound of values selected for. (exclusive)
 */
#define rustg_dbp_generate(seed, accuracy, stamp_size, world_size, lower_range, upper_range) call_ext(RUST_G, "dbp_generate")(seed, accuracy, stamp_size, world_size, lower_range, upper_range)

#define rustg_dmi_strip_metadata(fname) call_ext(RUST_G, "dmi_strip_metadata")(fname)
#define rustg_dmi_create_png(path, width, height, data) call_ext(RUST_G, "dmi_create_png")(path, width, height, data)
#define rustg_dmi_resize_png(path, width, height, resizetype) call_ext(RUST_G, "dmi_resize_png")(path, width, height, resizetype)
/**
 * input: must be a path, not an /icon; you have to do your own handling if it is one, as icon objects can't be directly passed to rustg.
 *
 * output: json_encode'd list. json_decode to get a flat list with icon states in the order they're in inside the .dmi
 */
#define rustg_dmi_icon_states(fname) call_ext(RUST_G, "dmi_icon_states")(fname)

#define rustg_file_read(fname) call_ext(RUST_G, "file_read")(fname)
#define rustg_file_exists(fname) (call_ext(RUST_G, "file_exists")(fname) == "true")
#define rustg_file_write(text, fname) call_ext(RUST_G, "file_write")(text, fname)
#define rustg_file_append(text, fname) call_ext(RUST_G, "file_append")(text, fname)
#define rustg_file_get_line_count(fname) text2num(call_ext(RUST_G, "file_get_line_count")(fname))
#define rustg_file_seek_line(fname, line) call_ext(RUST_G, "file_seek_line")(fname, "[line]")

#ifdef RUSTG_OVERRIDE_BUILTINS
	#define file2text(fname) rustg_file_read("[fname]")
	#define text2file(text, fname) rustg_file_append(text, "[fname]")
#endif

/**
 * Returns the formatted datetime string of HEAD using the provided format.
 * Defaults to returning %F which is YYYY-MM-DD.
 * This is different to rustg_git_commit_date because it only needs the logs directory.
 */
/proc/rustg_git_commit_date_head(format = "%F")
	return call_ext(RUST_G, "rg_git_commit_date_head")(format)

#define rustg_json_is_valid(text) (call_ext(RUST_G, "json_is_valid")(text) == "true")

#define rustg_noise_get_at_coordinates(seed, x, y) call_ext(RUST_G, "noise_get_at_coordinates")(seed, x, y)

/**
 * Generates a 2D poisson disk distribution ('blue noise'), which is relatively uniform.
 *
 * params:
 * 	`seed`: str
 * 	`width`: int, width of the noisemap (see world.maxx)
 * 	`length`: int, height of the noisemap (see world.maxy)
 * 	`radius`: int, distance between points on the noisemap
 *
 * returns:
 * 	a width*length length string of 1s and 0s representing a 2D poisson sample collapsed into a 1D string
 */
#define rustg_noise_poisson_map(seed, width, length, radius) call_ext(RUST_G, "noise_poisson_map")(seed, width, length, radius)

/*
 * Takes in a string and json_encode()"d lists to produce a sanitized string.
 * This function operates on whitelists, there is currently no way to blacklist.
 * Args:
 * * text: the string to sanitize.
 * * attribute_whitelist_json: a json_encode()'d list of HTML attributes to allow in the final string.
 * * tag_whitelist_json: a json_encode()'d list of HTML tags to allow in the final string.
 */
#define rustg_sanitize_html(text, attribute_whitelist_json, tag_whitelist_json) call_ext(RUST_G, "sanitize_html")(text, attribute_whitelist_json, tag_whitelist_json)

#define rustg_time_microseconds(id) text2num(call_ext(RUST_G, "time_microseconds")(id))
#define rustg_time_milliseconds(id) text2num(call_ext(RUST_G, "time_milliseconds")(id))
#define rustg_time_reset(id) call_ext(RUST_G, "time_reset")(id)

/// Returns the timestamp as a string
/proc/rustg_unix_timestamp()
	return call_ext(RUST_G, "unix_timestamp")()

#define rustg_raw_read_toml_file(path) json_decode(call_ext(RUST_G, "toml_file_to_json")(path) || "null")

/proc/rustg_read_toml_file(path)
	var/list/output = rustg_raw_read_toml_file(path)
	if (output["success"])
		return json_decode(output["content"])
	else
		CRASH(output["content"])

#define rustg_raw_toml_encode(value) json_decode(call_ext(RUST_G, "toml_encode")(json_encode(value)))

/proc/rustg_toml_encode(value)
	var/list/output = rustg_raw_toml_encode(value)
	if (output["success"])
		return output["content"]
	else
		CRASH(output["content"])

#define rustg_url_encode(text) call_ext(RUST_G, "url_encode")("[text]")
#define rustg_url_decode(text) call_ext(RUST_G, "url_decode")(text)

#ifdef RUSTG_OVERRIDE_BUILTINS
	#define url_encode(text) rustg_url_encode(text)
	#define url_decode(text) rustg_url_decode(text)
#endif
