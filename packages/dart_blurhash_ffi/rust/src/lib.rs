use blurhash::{decode_image, encode_image};
use image::ImageReader;
use std::ffi::*;
use std::io::Cursor;
#[cfg(target_arch = "wasm32")]
use wasm_bindgen::prelude::*;

mod base83;

#[repr(C)]
pub struct WrappedEncodeResult {
    success: bool,
    data: *mut c_char,
    error_message: *mut c_char,
}

#[repr(C)]
pub struct WrappedDecodeResult {
    success: bool,
    data: *mut u8,
    error_message: *mut c_char,
}

const VALID_CHARS: &str =
    "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz#$%*+,-.:;=?@[]^_{|}~";

#[cfg_attr(target_arch = "wasm32", wasm_bindgen)]
#[no_mangle]
pub extern "C" fn blurhash_encode(
    components_x: u32,
    components_y: u32,
    rgba_image: *const u8,
    rgba_image_len: usize,
) -> WrappedEncodeResult {
    let bytes_slice = unsafe { std::slice::from_raw_parts(rgba_image, rgba_image_len) };
    let reader = ImageReader::new(Cursor::new(bytes_slice))
        .with_guessed_format()
        .unwrap();

    let img = match reader.decode() {
        Ok(img) => img,
        Err(e) => {
            let c_string =
                CString::new(format!("Failed to decode input image bytes: {:?}", e)).unwrap();
            return WrappedEncodeResult {
                success: false,
                data: std::ptr::null_mut(),
                error_message: c_string.into_raw(),
            };
        }
    };

    let encoded = encode_image(components_x, components_y, &img.to_rgba8()).unwrap();
    let c_string = CString::new(encoded).unwrap();

    WrappedEncodeResult {
        data: c_string.into_raw(),
        error_message: std::ptr::null_mut(),
        success: true,
    }
}

#[cfg_attr(target_arch = "wasm32", wasm_bindgen)]
#[no_mangle]
pub extern "C" fn blurhash_decode(
    blurhash: *const u8,
    blurhash_len: usize,
    width: u32,
    height: u32,
    punch: f32,
) -> WrappedDecodeResult {
    let blurhash_slice = unsafe { std::slice::from_raw_parts(blurhash, blurhash_len) };
    let blurhash_str = match std::str::from_utf8(blurhash_slice) {
        Ok(value) => value,
        Err(e) => {
            let c_string = CString::new(format!("Invalid UTF-8 sequence: {:?}", e)).unwrap();
            return WrappedDecodeResult {
                success: false,
                data: std::ptr::null_mut(),
                error_message: c_string.into_raw(),
            };
        }
    };

    let decoded_result = decode_image(blurhash_str, width, height, punch);
    match decoded_result {
        Ok(pixels) => {
            // Create copy of pixel data
            let mut vec = pixels.into_vec();
            // Getting pointer to data
            let ptr = vec.as_mut_ptr();
            // Warning: do not free memory, as the pointer will be used in Flutter
            std::mem::forget(vec);

            WrappedDecodeResult {
                success: true,
                data: ptr,
                error_message: std::ptr::null_mut(),
            }
        }
        Err(e) => {
            let c_string = CString::new(format!("Failed to decode blurhash: {:?}", e)).unwrap();
            WrappedDecodeResult {
                success: false,
                data: std::ptr::null_mut(),
                error_message: c_string.into_raw(),
            }
        }
    }
}

#[cfg_attr(target_arch = "wasm32", wasm_bindgen)]
#[no_mangle]
pub extern "C" fn is_valid_blurhash(blurhash: *const u8, blurhash_len: usize) -> bool {
    let blurhash_slice = unsafe { std::slice::from_raw_parts(blurhash, blurhash_len) };
    let blurhash_str = std::str::from_utf8(blurhash_slice).unwrap();

    // Length checking
    if blurhash_str.len() < 6 || blurhash_str.len() > 87 {
        return false;
    }

    // All chars exists in Base83
    if !blurhash_str.chars().all(|c| VALID_CHARS.contains(c)) {
        return false;
    }

    // Getting sizes
    let size_flag = match base83::decode83(blurhash_str.chars().next().unwrap()) {
        Some(size) => size,
        None => return false,
    };

    let num_y = (size_flag / 9) + 1;
    let num_x = (size_flag % 9) + 1;

    // expected hash size
    let expected_length = 4 + 2 * num_x * num_y;

    blurhash_len == expected_length
}

#[cfg_attr(target_arch = "wasm32", wasm_bindgen)]
#[no_mangle]
pub extern "C" fn free_string(ptr: *mut c_char) {
    unsafe {
        if !ptr.is_null() {
            let _ = CString::from_raw(ptr);
        }
    }
}

#[cfg_attr(target_arch = "wasm32", wasm_bindgen)]
#[no_mangle]
pub extern "C" fn free_bytes(ptr: *mut u8, len: usize) {
    unsafe {
        if !ptr.is_null() {
            let _ = Vec::from_raw_parts(ptr, len, len);
        }
    }
}
