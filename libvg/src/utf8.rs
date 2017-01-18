use byond::call::return_to_byond;
use encoding::all::WINDOWS_1252;
use encoding::label::encoding_from_windows_code_page;
use encoding::types::DecoderTrap;
use libc;
use std::ffi::CStr;
use std::slice;
use std::ptr::null;

#[no_mangle]
pub extern "C" fn to_utf8(n: libc::c_int, v: *const *const libc::c_char) -> *const libc::c_char {
    if n != 2 {
        return return_to_byond("Somebody tell whoever did a call to to_utf8 to get their shit together, thanks.").unwrap_or(null());
    }

    // We do not let the byond crate handle arguments, as we want BYTES directly.
    // Unicode decode could fail on the second argument.
    let (encoding, bytes) = unsafe {
        let slice = slice::from_raw_parts(v, n as usize);
        let encoding = String::from_utf8_lossy(CStr::from_ptr(slice[0]).to_bytes()).into_owned();
        let bytes = CStr::from_ptr(slice[1]).to_bytes().to_owned();

        (encoding, bytes)
    };

    let encoder = encoding_from_windows_code_page(encoding.parse::<usize>().unwrap_or(1252)).unwrap_or(WINDOWS_1252);

    return_to_byond(&encoder.decode(&bytes, DecoderTrap::Replace).unwrap_or("fuck".into())).unwrap_or(null())
}
