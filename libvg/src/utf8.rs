use byond::call::return_to_byond;
use encoding::all::WINDOWS_1252;
use encoding::label::encoding_from_windows_code_page;
use encoding::types::DecoderTrap;
use libc;
use std::ffi::CStr;
use std::slice;
use std::ptr::null;

unsafe fn decode(args: &[*const libc::c_char]) -> String {
    let encoding = CStr::from_ptr(args[0])
        .to_str()
        .map(|encoding| {
            encoding_from_windows_code_page(encoding.parse::<usize>().unwrap_or(1252))
                .unwrap_or(WINDOWS_1252)
        })
        .unwrap_or(WINDOWS_1252);
    let bytes = CStr::from_ptr(args[1]).to_bytes();
    encoding.decode(bytes, DecoderTrap::Replace).unwrap_or("fuck".into())
}

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
