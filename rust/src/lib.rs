use blurhash::{decode as internal_decode, encode as internal_encode};
use std::ffi::*;
// use wasm_bindgen::prelude::*;

// #[wasm_bindgen]
#[no_mangle]
pub extern "C" fn blurhash_encode(
    components_x: u32,
    components_y: u32,
    width: u32,
    height: u32,
    rgba_image: *const u8,
    rgba_image_len: usize,
) -> *mut c_char {
    let rgba_slice = unsafe { std::slice::from_raw_parts(rgba_image, rgba_image_len) };
    let encoded = internal_encode(components_x, components_y, width, height, rgba_slice).unwrap();
    let c_string = CString::new(encoded).unwrap();
    c_string.into_raw()
}

// #[wasm_bindgen]
#[no_mangle]
pub extern "C" fn blurhash_decode(
    blurhash: *const u8,
    blurhash_len: usize,
    width: u32,
    height: u32,
    punch: f32,
) -> *mut u8 {
    let blurhash_slice = unsafe { std::slice::from_raw_parts(blurhash, blurhash_len) };
    let blurhash_str = std::str::from_utf8(blurhash_slice).unwrap();
    let decoded = internal_decode(blurhash_str, width, height, punch).unwrap();
    let mut boxed_slice = decoded.into_boxed_slice();
    let ptr = boxed_slice.as_mut_ptr();
    std::mem::forget(boxed_slice);
    ptr
}

#[no_mangle]
pub extern "C" fn free_string(ptr: *mut c_char) {
    unsafe {
        if !ptr.is_null() {
            let _ = CString::from_raw(ptr);
        }
    }
}

#[no_mangle]
pub extern "C" fn free_decoded_data(ptr: *mut u8, len: usize) {
    unsafe {
        if !ptr.is_null() {
            let _ = Vec::from_raw_parts(ptr, len, len);
        }
    }
}
