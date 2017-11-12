extern crate clap;
#[macro_use]
extern crate lazy_static;
#[macro_use]
extern crate serde_derive;
extern crate serde;
extern crate serde_json;
extern crate regex;

use std::cmp::Ordering;
use std::collections::HashMap;
use std::fs::File;
use std::io::prelude::*;
use std::io::BufReader;
use clap::{App, Arg};
use regex::Regex;

const DEFAULT_INPUT_FILE: &str = "input.txt";
const DEFAULT_OUTPUT_FILE: &str = "output.txt";

lazy_static! {
	static ref STACK_FORMATTING_REGEX: Regex = {
		Regex::new(r"^(?:\.\.\.|(?:.+? \(.+?\): )?.+\(.*?\))$").unwrap()
	};
}

type Runtimes = HashMap<String, RuntimeData>;

#[derive(Serialize, Eq, PartialEq, Debug)]
struct RuntimeData {
    pub details: String,
    pub counter: usize,
    pub kind: RuntimeKind,
}

impl std::fmt::Display for RuntimeData {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> Result<(), std::fmt::Error> {
        write!(f, "{}", self.details)?;
        writeln!(f, "Occurred {} times.", self.counter)?;
        Ok(())
    }
}

#[derive(Hash, Eq, PartialEq, Copy, Clone, Debug, Serialize)]
enum RuntimeKind {
    RuntimeError,
    InfiniteLoop,
    RecursionLimit,
}

impl RuntimeKind {
    pub fn has_poor_formatting(&self) -> bool {
        *self == RuntimeKind::InfiniteLoop || *self == RuntimeKind::RecursionLimit
    }
}

fn line_kind(line: &str) -> LineKind {
    if line == "Infinite loop suspected--switching proc to background." {
        return LineKind::InfiniteLoop;
    }
    if line ==
       "runtime error: Maximum recursion level reached (perhaps there is an infinite loop)" {
        return LineKind::RecursionLimit;
    }
    if line.len() > 22 && line[9..].starts_with("] Runtime in ") {
        return LineKind::Runtime;
    }
    if line.len() > 22 && line[9..].starts_with("] Skipped ") {
        return LineKind::Skipped;
    }
    LineKind::Junk
}

enum LineKind {
    InfiniteLoop,
    RecursionLimit,
    Runtime,
    Skipped,
    Junk,
}

fn parse_from_file<W: Read>(file: W, mut runtimes: &mut Runtimes) {
    let reader = BufReader::new(file);
    let mut lines = reader.lines().map(std::result::Result::unwrap);

    // Manually iterate so we maintain control over the iterator
    //   and can pass it down mid-loop.
    // A regular for loop borrows it mutably until the loop is done.
    while let Some(mut line) = lines.next() {
        while let Some(newline) = parse_line(&mut lines, &mut runtimes, &line) {
            // If the parsing ate the next line and gave it back we do that one instead.
            line = newline;
        }
    }
}

fn parse_line<L: Iterator<Item = String>>(mut lines: &mut L,
                                          mut runtimes: &mut Runtimes,
                                          currentline: &str)
                                          -> Option<String> {
    match line_kind(currentline) {
        LineKind::InfiniteLoop => {
            // Skip next 1 line so we arrive at the "proc name:"
            lines.next();
            if let Some(line) = lines.next() {
                parse_runtime(&mut lines,
                              &mut runtimes,
                              &line[11..],
                              RuntimeKind::InfiniteLoop)
            } else {
                None
            }
        }
        LineKind::RecursionLimit => {
            // Skip next 1 line so we arrive at the "proc name:"
            lines.next();
            if let Some(line) = lines.next() {
                parse_runtime(&mut lines,
                              &mut runtimes,
                              &line[11..],
                              RuntimeKind::RecursionLimit)
            } else {
                None
            }
        }
        LineKind::Runtime => {
            parse_runtime(&mut lines,
                          &mut runtimes,
                          &currentline[22..],
                          RuntimeKind::RuntimeError)
        }
        LineKind::Skipped => {
            // Read amount of runtimes skipped
            let countstart = &currentline[19..];
            let endindex =
                countstart.char_indices().take_while(|&(_, c)| c.is_digit(10)).last().unwrap().0;
            let count = countstart[..endindex + 1].parse::<usize>().unwrap();

            // Now to get the key.
            let key = &countstart[endindex + 14..];

            if let Some(runtime) = runtimes.get_mut(key) {
                runtime.counter += count;
            } else {
                println!("Found skip, but we have no runtime with said key. If this is an older \
                          log file: ignore this. {}",
                         key);
            }

            None
        }
        LineKind::Junk => None,
    }
}

fn parse_runtime<L: Iterator<Item = String>>(lines: &mut L,
                                             runtimes: &mut Runtimes,
                                             key: &str,
                                             kind: RuntimeKind)
                                             -> Option<String> {
    if runtimes.contains_key(key) {
        let runtime = runtimes.get_mut(key).unwrap();
        runtime.counter += 1;
        // Skip lines starting with two spaces since those are the trace and other details.
        // Skipping these here is faster than letting the main loop do it
        //   as the main loop has to do multiple equality checks,
        //   but here it's just checking two spaces.
        for line in lines {
            if !line.starts_with("  ") {
                return Some(line);
            }
        }
        // We don't have to handle poorly-formatted errors (infinite loops, recursion) here:
        //   the trace gets treated as junk and ignored.
        // Theoretically it would be an improvement but infinite loops and stack overflows
        //   are too rare to care about for me to bother optimizing it.
        None
    } else {
        let mut details = String::new();
        let mut outstring = None;
        for line in lines.by_ref() {
            if !line.starts_with("  ") {
                outstring = Some(line);
                break;
            }
            details.push_str(&line);
            details.push('\n');
        }
        // TODO: Maybe merge this with the above loop?
        if kind.has_poor_formatting() && outstring.is_some() &&
           STACK_FORMATTING_REGEX.is_match(outstring.as_ref().unwrap()) {
            // RIGHT we have to handle the stack trace with special behavior
            //   because we can't intercept infinite loops/stack overflows in /world/Error,
            //   meaning they're still too poorly formatted to parse easily like a runtime.
            // Thanks, Lummox.
            details.push_str(outstring.as_ref().unwrap());
            details.push('\n');
            // We read the first line and a trace maxes out at 20 lines so
            //   take a MAX of 19 lines.
            for line in lines.by_ref().take(19) {
                // The [ is the start of a regular runtime.
                // Other infinite loops or recursion limits can't match against the stack regex.
                // This should prevent us missing other runtimes due to erroneous stack parsing.
                if line.starts_with('[') || !STACK_FORMATTING_REGEX.is_match(&line) {
                    outstring = Some(line);
                    break;
                }

                details.push_str(&line);
                details.push('\n');
            }
        }
        let new_entry = RuntimeData {
            details: details,
            counter: 1,
            kind: kind,
        };
        runtimes.insert(key.to_owned(), new_entry);
        runtimes.get_mut(key).unwrap();
        outstring
    }
}

fn total_runtimes(runtimes: &Runtimes) -> usize {
    runtimes.values().map(|data| data.counter).sum()
}

fn total_unique_runtimes(runtimes: &Runtimes) -> usize {
    runtimes.len()
}

// Small struct to make sorting easier.
#[derive(Eq, PartialEq)]
struct KeyRuntimePair<'a>(&'a str, &'a RuntimeData);

impl<'a> PartialOrd for KeyRuntimePair<'a> {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

impl<'a> Ord for KeyRuntimePair<'a> {
    fn cmp(&self, other: &Self) -> Ordering {
        match self.1.counter.cmp(&other.1.counter) {
            // Same count, compare keys to alphabetically sort those instead.
            Ordering::Equal => self.0.cmp(other.0).reverse(),
            x => x,
        }
    }
}

fn write_to_file<W: Write>(runtimes: &Runtimes, mut file: W) -> std::io::Result<()> {
    writeln!(file,
             "Total errors: {}. Total unique errors: {}.
--------------------------------------
\
              Runtime errors:",
             total_runtimes(runtimes),
             total_unique_runtimes(runtimes))?;
    let highest_count = runtimes.values().map(|r| r.counter).max().unwrap_or(0);
    let width = format!("{}", highest_count).len();

    // Runtimes are the most common so we pre-allocate the vector for them.
    let mut all_runtimes = Vec::with_capacity(total_unique_runtimes(runtimes));
    let mut all_infinite_loops = Vec::new();
    let mut all_recursion_limits = Vec::new();

    for pair in runtimes.iter().map(|(a, b)| KeyRuntimePair(a, b)) {
        match pair.1.kind {
            RuntimeKind::RuntimeError => all_runtimes.push(pair),
            RuntimeKind::InfiniteLoop => all_infinite_loops.push(pair),
            RuntimeKind::RecursionLimit => all_recursion_limits.push(pair),
        }
    }

    all_runtimes.sort_unstable();
    all_infinite_loops.sort_unstable();
    all_recursion_limits.sort_unstable();

    for KeyRuntimePair(ident, runtime) in all_runtimes.into_iter().rev() {
        writeln!(file,
                 "x{:<width$} {}",
                 runtime.counter,
                 ident,
                 width = width)?;
    }
    writeln!(file,
             "--------------------------------------
Infinite loops:")?;

    for KeyRuntimePair(ident, runtime) in all_infinite_loops.into_iter().rev() {
        writeln!(file,
                 "x{:<width$} {}",
                 runtime.counter,
                 ident,
                 width = width)?;
    }

    writeln!(file,
             "--------------------------------------
Recursion limits reached:")?;

    for KeyRuntimePair(ident, runtime) in all_recursion_limits.into_iter().rev() {
        writeln!(file,
                 "x{:<width$} {}",
                 runtime.counter,
                 ident,
                 width = width)?;
    }

    Ok(())
}

fn main() {
    let matches = App::new("/vg/station 13 Runtime Condenser")
        .version("0.1")
        .author("/vg/station 13 Developers")
        .about("Compresses and filters runtime errors output by Dream Daemon, showing a more \
                readable summary.")
        .arg(Arg::with_name("json")
            .long("json")
            .short("j")
            .help("Output in JSON."))
        .arg(Arg::with_name("input")
            .long("input")
            .short("i")
            .help("Specifies the input file to read from.")
            .default_value(DEFAULT_INPUT_FILE)
            .takes_value(true)
            .multiple(true))
        .arg(Arg::with_name("output")
            .long("output")
            .short("o")
            .help("Specifies the output file to write to.")
            .default_value(DEFAULT_OUTPUT_FILE)
            .takes_value(true))
        .get_matches();

    let json = matches.is_present("json");
    let input = matches.values_of("input").unwrap();
    let output = matches.value_of("output").unwrap();

    let mut runtimes = Runtimes::new();
    for filename in input {
        let input_file = File::open(filename).expect("Error opening input file.");
        parse_from_file(input_file, &mut runtimes);
    }
    let mut output_file = File::create(output).expect("Error creating output file.");
    if json {
            output_file.write_all(serde_json::to_string(&runtimes)
                .expect("Unable to format output as JSON")
                .as_bytes())
        } else {
            write_to_file(&runtimes, output_file)
        }
        .expect("Error outputting to file.");
}
