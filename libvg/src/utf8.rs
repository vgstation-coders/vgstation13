use byond::call::return_to_byond;
use encoding::all::WINDOWS_1252;
use encoding::label::encoding_from_windows_code_page;
use encoding::types::DecoderTrap;
use libc;
use std::cmp::{max, Ordering};
use std::ffi::CStr;
use std::slice;
use std::ptr::null;

/// Encodes a byte string to UTF-8, using the windows code page supplied.
///
/// Arguments are in the order of encoding, bytes.
#[no_mangle]
pub extern "C" fn to_utf8(n: libc::c_int, v: *const *const libc::c_char) -> *const libc::c_char {
    // We do not let the byond crate handle arguments, as we want BYTES directly.
    // Unicode decode could fail on the second argument.
    let text = unsafe {
        let slice = slice::from_raw_parts(v, n as usize);

        decode(&slice)
    };

    return_to_byond(&text).unwrap_or(null())
}

/// Encodes a byte string with a windows encoding, filters bad characters and limits message length.
///
/// Operations like message length are done on UTF-8!
/// Arguments are in the order of encoding, bytes, cap.
#[no_mangle]
pub extern "C" fn utf8_sanitize(n: libc::c_int,
                                v: *const *const libc::c_char)
                                -> *const libc::c_char {
    // Can't use the BYOND crate again because of unicode conversion failing.
    let text = unsafe {
        let slice = slice::from_raw_parts(v, n as usize);
        let cap = CStr::from_ptr(slice[2])
            .to_str()
            .map(|cap| cap.parse::<usize>().unwrap_or(1024))
            .unwrap_or(1024);

        sanitize(&decode(&slice), cap)
    };

    return_to_byond(&text).unwrap_or(null())
}

/// Returns the length of a UTF-8 string.
byond!(utf8_len: text; {
    // Count an iterator over characters.
    format!("{}", text.chars().count())
});

/// Returns the BYTE length of a UTF-8 string.
byond!(utf8_len_bytes: text; {
    // Count an iterator over characters.
    format!("{}", text.len())
});


byond!(utf8_find: haystack, needle, start, end; {
    // This happens often enough for a special case, probably.
    if start == "1" && end == "0" {
        match haystack.find(needle) {
            Some(index) => {
                // Determine true offset based on byte offset returned by find.
                return format!("{}",
                    haystack.char_indices()
                    .position(|x| x.0 == index)
                    .unwrap());
            },
            None => return "0".to_string()
        }
    }

    match byte_bounds(haystack, start, end) {
        Some((start, end)) => {
            let ref sub = haystack[start .. end];
            match sub.find(needle) {
                Some(index) => format!("{}",
                    haystack
                    .char_indices()
                    .position(|x| x.0 == index)
                    .unwrap()),
                None => "".to_string()
            }
        }
        None => "0".to_string()
    }
});

/// Function to get the byte bounds for copytext, findtext and replacetext.
/// Goes by one-indexing and correctly handles negatives.
#[allow(dead_code)]
fn byte_bounds(text: &str, start: &str, end: &str) -> Option<(usize, usize)> {
    // BYOND uses 1-indexing because of course it does...
    // I would've made sick one liners out of this if the negative index stuff weren't a thing.
    let mut start = start.parse::<isize>().unwrap_or(1);
    let mut end = end.parse::<isize>().unwrap_or(0);

    let char_count = text.chars().count() as isize;

    start += if start < 0 { char_count } else { -1 };
    let start = max(start, 0) as usize;

    match end.cmp(&0) {
        Ordering::Greater => {
            end -= 1;
        }
        Ordering::Equal => {
            end = char_count;
        }
        Ordering::Less => {
            end += char_count;
        }
    }

    let end = max(end, 0) as usize;

    if end <= start {
        // Signal "NOPE"
        return None;
    }

    let mut iter = text.char_indices();

    match (iter.nth(start), iter.nth(end - start - 1)) {
        (Some((start, _)), Some((end, _))) => Some((start, end)),
        (Some((start, _)), None) => Some((start, text.len())),
        _ => None,
    }
}

unsafe fn decode(args: &[*const libc::c_char]) -> String {
    let encoding = CStr::from_ptr(args[0])
        .to_str()
        .map(|encoding| {
            encoding_from_windows_code_page(encoding.parse::<usize>().unwrap_or(1252))
                .unwrap_or(WINDOWS_1252)
        })
        .unwrap_or(WINDOWS_1252);
    let bytes = CStr::from_ptr(args[1]).to_bytes();
    encoding.decode(bytes, DecoderTrap::Replace).unwrap()
}

fn sanitize(text: &str, cap: usize) -> String {
    let mut out = String::with_capacity(text.len());
    let mut count = 0;
    for character in text.chars() {
        match character {
            '\u{0000}'...'\u{001F}' |
            '\u{0080}'...'\u{00A0}' => continue,
            '<' => out.push_str("&lt;"),
            '>' => out.push_str("&gt;"),
            _ => out.push(character),
        };
        count += 1;
        if count >= cap {
            break;
        };
    }
    out
}

#[test]
fn test_sanitize() {
    assert_eq!(sanitize("testing!", 1024), "testing!");
    assert_eq!(sanitize("testing<>!", 1024), "testing&lt;&gt;!");
    assert_eq!(sanitize("testing\n\n\n<>!", 1024), "testing&lt;&gt;!");
    assert_eq!(sanitize("testing\n\u{0088}\n<>!", 1024), "testing&lt;&gt;!");
    assert_eq!(sanitize("<script src='hacked.js'></script>icky ocky!\n<>!", 1024),
               "&lt;script src='hacked.js'&gt;&lt;/script&gt;icky ocky!&lt;&gt;!");
    assert_eq!(sanitize("test", 3), "tes");
    assert_eq!(sanitize("\n\n\ntest", 3), "tes");
    assert_eq!(sanitize("\n\n\n>test", 3), "&gt;te");
}

#[test]
fn test_utf8() {
    use std::ffi::CString;
    let encoding = CString::new(b"1252".as_ref()).unwrap();
    let test = CString::new(b"Hi there!".as_ref()).unwrap();
    let both = [encoding.as_ptr(), test.as_ptr()];

    unsafe { assert_eq!(decode(&both), "Hi there!") };


    let encoding = CString::new(b"1252".as_ref()).unwrap();
    let test = CString::new(b"H\xed th\xe9r\xe9!".as_ref()).unwrap();
    let both = [encoding.as_ptr(), test.as_ptr()];

    unsafe { assert_eq!(decode(&both), "Hí théré!") };


    let encoding = CString::new(b"1251".as_ref()).unwrap();
    let both = [encoding.as_ptr(), test.as_ptr()];

    unsafe { assert_eq!(decode(&both), "Hн thйrй!") };
}

#[test]
fn test_byte_bounds() {
    assert_eq!(byte_bounds("abcdefgh", "1", "0"), Some((0, 8)));
    assert_eq!(byte_bounds("abcdefgh", "0", "0"), Some((0, 8)));
    assert_eq!(byte_bounds("abcdefgh", "-2", "0"), Some((6, 8)));
    assert_eq!(byte_bounds("abcdefgh", "-4", "-2"), Some((4, 6)));
    assert_eq!(byte_bounds("abcdefghijklmnopwrstuvwxyz", "-4", "-2"),
               Some((22, 24)));
    assert_eq!(byte_bounds("abcdefgh", "-20", "-2"), Some((0, 6)));
    assert_eq!(byte_bounds("abcdefgh", "2", "1"), None);
    assert_eq!(byte_bounds("àbçdéfgh", "1", "0"), Some((0, 11)));
    assert_eq!(byte_bounds("àbç👏défgh", "2", "0"), Some((2, 15)));
    assert_eq!(byte_bounds("👏àbç👏défgh", "2", "0"), Some((4, 19)));
    assert_eq!(byte_bounds("abcdefgh", "20", "40"), None);
    assert_eq!(byte_bounds("abcdefgh", "3", "40"), Some((2, 8)));
}

#[test]
fn test_utf8_find() {
    panic!("For fucks sake write the damn test already and stop fucking with RPDs.")
}
