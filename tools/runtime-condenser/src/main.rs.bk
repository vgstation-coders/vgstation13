use std::fs::File;
use std::io::prelude::*;
use std::io::BufReader;
use std::collections::hash_map::{HashMap, Entry};

const INPUT_FILE: &str = "input.txt";
const OUTPUT_FILE: &str = "output.txt";

type Runtimes = HashMap<String, RuntimeData>;

struct RuntimeData {
	pub details: String,
	pub counter: usize,
	pub kind: RuntimeKind
}

enum RuntimeKind {
	RuntimeError,
	InfiniteLoop,
	RecursionLimit
}

enum State {
	Runtime(String),
	Skip(usize),
	Scanning
}

impl std::fmt::Display for RuntimeData {
	fn fmt(&self, f: &mut std::fmt::Formatter) -> Result<(), std::fmt::Error> {
		write!(f, "{}", self.details)?;
		writeln!(f, "Occurred {} times.", self.counter)?;
		Ok(())
	}
}

fn insert_runtime(runtimes: &mut Runtimes, identifier: String, kind: RuntimeKind) {
	match runtimes.entry(identifier) {
		Entry::Vacant(entry) => {
			entry.insert(RuntimeData {
				details: String::new(),
				counter: 1,
				kind: kind
			});
		}
		Entry::Occupied(mut entry) => {
			let data = entry.get_mut();
			data.counter += 1;
		}
	};
}

fn line_kind(line: &str) -> LineKind {
	if line.find("Infinite loop suspected--switching proc to background.").is_some() {
		return LineKind::InfiniteLoopHeader;
	}
	if line.starts_with("proc name") {
		return LineKind::InfiniteLoop;
	}
	if line.find("Runtime in ").is_some() {
		return LineKind::Runtime;
	}
	if line.starts_with("  ") {
		return LineKind::Details;
	}
	LineKind::Junk
}

enum LineKind {
	InfiniteLoopHeader,
	InfiniteLoop,
	Runtime,
	Details,
	Junk
}

fn parse_from_file(path: &str) -> Runtimes {
	let input_file = File::open(path).expect("Error opening file.");
	let reader = BufReader::new(input_file);
	let lines = reader.lines().map(std::result::Result::unwrap);
	
	let mut runtimes = Runtimes::new();
	let mut current_state = State::Scanning;

	for line in lines {
		if let State::Skip(mut count) = current_state {
			count = count - 1;
			if count < 1 {
				current_state = State::Scanning
			}
			continue;
		}
		match line_kind(&line) {
			LineKind::InfiniteLoopHeader => {
				current_state = State::Skip(1);
			}
			LineKind::InfiniteLoop => {
				if let State::Scanning = current_state {
					current_state = State::Runtime(line.clone());
					insert_runtime(&mut runtimes, line, RuntimeKind::InfiniteLoop);
				}
			}
			LineKind::Details => {
				if let State::Runtime(ref ident) = current_state {
					let data = runtimes.get_mut(ident).unwrap();
					if data.counter != 1 {
						continue;
					}
					data.details.push_str(&line);
					data.details.push('\n');
				}
			}
			LineKind::Runtime => {
				let runtime_identifier = line[22..].to_owned();
				current_state = State::Runtime(runtime_identifier.clone());
				insert_runtime(&mut runtimes, runtime_identifier, RuntimeKind::RuntimeError);
			}
			LineKind::Junk => ()
		}
	}
	runtimes
}

fn total_runtimes(runtimes: &Runtimes) -> usize {
	runtimes.iter()
		.fold(0, |count, (_ident, data)| count + data.counter)
}

fn total_unique_runtimes(runtimes: &Runtimes) -> usize {
	runtimes.iter()
		.count()
}

fn is_runtime_error(runtime: &(&String, &RuntimeData)) -> bool {
	if let RuntimeKind::RuntimeError = runtime.1.kind {
		return true;
	}
	false
}

fn is_infinite_loop(runtime: &(&String, &RuntimeData)) -> bool {
	!is_runtime_error(runtime)
}

fn write_to_file<P: AsRef<std::path::Path>>(runtimes: &Runtimes, file_path: P) {
	let mut output_file = File::create(file_path).expect("Error creating output file.");
	writeln!(output_file, 
"Total runtimes: {}. Total unique_runtimes: {}.
--------------------------------------
Runtime errors:",
		total_runtimes(runtimes), total_unique_runtimes(runtimes)).unwrap();
	for (ident, _) in runtimes.iter().filter(is_runtime_error) {
		writeln!(output_file, "{}", ident).unwrap();
	}
	writeln!(output_file,
"--------------------------------------
Infinite loops:"
	).unwrap();
	for (ident, _) in runtimes.iter().filter(is_infinite_loop) {
		writeln!(output_file, "{}", ident).unwrap();
	}
	writeln!(output_file, "--------------------------------------").unwrap();
	for (ident, data) in runtimes {
		writeln!(output_file, "{}\n{}", ident, data).unwrap();
	}
}

fn main() {
	let runtimes = parse_from_file(INPUT_FILE);
	write_to_file(&runtimes, OUTPUT_FILE);
}
