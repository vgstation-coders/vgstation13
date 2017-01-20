use byond::call::return_to_byond;
use encoding::all::WINDOWS_1252;
use encoding::label::encoding_from_windows_code_page;
use encoding::types::DecoderTrap;
use libc;
use std::ffi::CStr;
use std::slice;
use std::ptr::null;

fn decode(decoder: &str, bytes: &[u8]) -> String {
    let encoder = encoding_from_windows_code_page(decoder.parse::<usize>().unwrap_or(1252)).unwrap_or(WINDOWS_1252);
    encoder.decode(&bytes, DecoderTrap::Replace).unwrap_or("fuck".into())
}

/// Encodes a byte string to UTF-8, using the windows code page supplied.
#[no_mangle]
pub extern "C" fn to_utf8(n: libc::c_int, v: *const *const libc::c_char) -> *const libc::c_char {
    // We do not let the byond crate handle arguments, as we want BYTES directly.
    // Unicode decode could fail on the second argument.
    let (encoding, bytes) = unsafe {
        let slice = slice::from_raw_parts(v, n as usize);
        let encoding = String::from_utf8_lossy(CStr::from_ptr(slice[0]).to_bytes()).into_owned();
        let bytes = CStr::from_ptr(slice[1]).to_bytes().to_owned();

        (encoding, bytes)
    };

    return_to_byond(&decode(&encoding, &bytes)).unwrap_or(null())
}

/// Encodes a byte string with a windows encoding, filters bad characters and limits message length.
///
/// Operations like message length are done on UTF-8!
#[no_mangle]
pub extern "C" fn utf8_sanitize(n: libc::c_int, v: *const *const libc::c_char) -> *const libc::c_char {
    // Can't use the BYOND crate again because of unicode conversion failing.
    let (encoding, bytes, cap) = unsafe {
        let slice = slice::from_raw_parts(v, n as usize);
        let encoding = String::from_utf8_lossy(CStr::from_ptr(slice[0]).to_bytes()).into_owned();
        let bytes = CStr::from_ptr(slice[1]).to_bytes().to_owned();
        let cap = match CStr::from_ptr(slice[2]).to_str() {
            Ok(ref length) => match length.parse::<usize>() {
                Ok(x) => x,
                _ => 1024
            },
            _ => 1024
        };

        (encoding, bytes, cap)
    };

    let text = decode(&encoding, &bytes);
    let text = {
        let mut out = String::with_capacity(text.len());
        let mut count = 0;
        for character in text.chars() {
            match character {
                '\u{0000}' ... '\u{001F}' | '\u{0080}' ... '\u{00A0}' => continue,
                '<' => out.push_str("&lt;"),
                '>' => out.push_str("&gt;"),
                _ => out.push(character)
            };
            count += 1;
            if count >= cap {
                break;
            };
        };
        out
    };

    return_to_byond(&text).unwrap_or(null())
}
