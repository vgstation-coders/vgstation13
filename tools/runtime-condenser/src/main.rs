use std::fs::File;
use std::io::prelude::*;
use std::io::BufReader;
use std::collections::HashMap;

const INPUT_FILE: &str = "input.txt";
const OUTPUT_FILE: &str = "output.txt";

type Runtimes = HashMap<String, RuntimeData>;

struct RuntimeData {
	pub details: String,
	pub counter: usize,
	pub kind: RuntimeKind,
}

#[derive(Hash, Eq, PartialEq, Copy, Clone, Debug)]
enum RuntimeKind {
	RuntimeError,
	InfiniteLoop,
	//RecursionLimit,
}

impl std::fmt::Display for RuntimeData {
	fn fmt(&self, f: &mut std::fmt::Formatter) -> Result<(), std::fmt::Error> {
		write!(f, "{}", self.details)?;
		writeln!(f, "Occurred {} times.", self.counter)?;
		Ok(())
	}
}

fn line_kind(line: &str) -> LineKind {
	if line.starts_with("proc name: ") {
		return LineKind::InfiniteLoop;
	}
	if line == "Infinite loop suspected--switching proc to background." {
		return LineKind::InfiniteLoopHeader;
	}
	if line.len() > 22 && line[9..].starts_with("] Runtime in ") {
		return LineKind::Runtime;
	}
	LineKind::Junk
}

enum LineKind {
	InfiniteLoopHeader,
	InfiniteLoop,
	Runtime,
	Junk,
}

fn parse_from_file(path: &str) -> Runtimes {
	let input_file = File::open(path).expect("Error opening file.");
	let reader = BufReader::new(input_file);
	let mut lines = reader.lines().map(std::result::Result::unwrap);

	let mut runtimes = Runtimes::new();

	while let Some(mut line) = lines.next() {
		while let Some(newline) = parse_line(&mut lines, &mut runtimes, &line) {
			line = newline;
		}
	}
	runtimes
}

fn parse_line(
	mut lines: &mut Iterator<Item = String>,
	mut runtimes: &mut Runtimes,
	currentline: &str,
) -> Option<String> {
	match line_kind(currentline) {
		LineKind::InfiniteLoopHeader => {
			// Skip NEXT line since the header is two lines long.
   // Next line that will be read by main loop will be the infinite loop itself.
			lines.next();
			None
		}
		LineKind::InfiniteLoop => parse_runtime(
			&mut lines,
			&mut runtimes,
			currentline,
			RuntimeKind::InfiniteLoop,
		),
		LineKind::Runtime => parse_runtime(
			&mut lines,
			&mut runtimes,
			&currentline[22..],
			RuntimeKind::RuntimeError,
		),
		LineKind::Junk => None,
	}
}

fn parse_runtime(
	lines: &mut Iterator<Item = String>,
	runtimes: &mut Runtimes,
	key: &str,
	kind: RuntimeKind,
) -> Option<String> {
	if runtimes.contains_key(key) {
		let runtime = runtimes.get_mut(key).unwrap();
		runtime.counter += 1;
		// Skip lines starting with two spaces since those are the trace and other details.
		while let Some(line) = lines.next() {
			if !line.starts_with("  ") {
				return Some(line);
			}
		}
		None
	} else {
		let mut details = String::new();
		let mut outstring = None;
		while let Some(line) = lines.next() {
			if !line.starts_with("  ") {
				outstring = Some(line);
				break;
			}
			details.push_str(&line);
			details.push('\n');
		}
		let new_entry = RuntimeData {
			details: String::new(),
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
	writeln!(
		output_file,
		"Total runtimes: {}. Total unique_runtimes: {}.
--------------------------------------
Runtime errors:",
		total_runtimes(runtimes),
		total_unique_runtimes(runtimes)
	).unwrap();
	for (ident, _) in runtimes.iter().filter(is_runtime_error) {
		writeln!(output_file, "{}", ident).unwrap();
	}
	writeln!(
		output_file,
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
