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
/// Operations like message length are done on Unicode code points!
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
        return match haystack.find(needle) {
            Some(index) => {
                // Determine true offset based on byte offset returned by find.
                format!("{}",
                    haystack.char_indices()
                    .position(|x| x.0 == index)
                    .unwrap() + 1)
            },
            None => "0".to_string()
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
                    .unwrap() + 1),
                None => "0".to_string()
            }
        }
        None => "0".to_string()
    }
});

byond!(utf8_index: text, index; {
    let index = index.parse::<isize>().unwrap_or(1);

    // 0-indexed index for the string, by code points.
    let index = match index.cmp(&0) {
        Ordering::Greater => index - 1,
        // Invalid index.
        Ordering::Equal => return "",
        Ordering::Less => {
            let char_count = text.chars().count() as isize;
            char_count + index
        }
    } as usize;

    // Get the byte bound.
    let byte = match text.char_indices().nth(index) {
        Some((i, _)) => i,
        None => return ""
    };

    &text[byte .. byte+1]
});

/// Function to get the byte bounds for copytext, findtext and replacetext.
/// Goes by one-indexing and correctly handles negatives.
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
    use byond::call::test_byond_call_args;
    assert_eq!(test_byond_call_args(utf8_find, &["abcdefgh", "c", "1", "0"]), "3");
    assert_eq!(test_byond_call_args(utf8_find, &["abcdefgh", "g", "1", "3"]), "0");
    assert_eq!(test_byond_call_args(utf8_find, &["abcdefgh", "z", "1", "3"]), "0");
}

#[test]
fn test_utf8_len() {
    use byond::call::test_byond_call_args;
    assert_eq!(test_byond_call_args(utf8_len, &["abc"]), "3");
    assert_eq!(test_byond_call_args(utf8_len, &[""]), "0");
    assert_eq!(test_byond_call_args(utf8_len, &["👏àbç👏défgh"]), "10");
}

#[test]
fn test_utf8_byte_len() {
    use byond::call::test_byond_call_args;
    assert_eq!(test_byond_call_args(utf8_len_bytes, &["abc"]), "3");
    assert_eq!(test_byond_call_args(utf8_len_bytes, &[""]), "0");
    assert_eq!(test_byond_call_args(utf8_len_bytes, &["👏àbç👏défgh"]), "19");
}

#[test]
fn test_utf8_index() {
    use byond::call::test_byond_call_args;
    assert_eq!(test_byond_call_args(utf8_index, &["abc", "1"]), "a");
    assert_eq!(test_byond_call_args(utf8_index, &["abc", "3"]), "c");
    assert_eq!(test_byond_call_args(utf8_index, &["abc", "-2"]), "b");
    assert_eq!(test_byond_call_args(utf8_index, &["abc", "-1"]), "c");
    assert_eq!(test_byond_call_args(utf8_index, &["abc", "5"]), "");
    assert_eq!(test_byond_call_args(utf8_index, &["abc", "0"]), "");
    assert_eq!(test_byond_call_args(utf8_index, &["abc", "-10"]), "");
}
