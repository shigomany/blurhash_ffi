use image::{DynamicImage, GenericImageView, ImageBuffer, Rgb};
use std::f32::consts::PI;


#[flutter_rust_bridge::frb(sync)] // Synchronous mode for simplicity of the demo
pub fn greet(name: String) -> String {
    format!("Hello, {name}!")
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}

#[flutter_rust_bridge::frb(sync)]
pub fn encode(image_data: Vec<u8>, width: u32, height: u32, components_x: u32, components_y: u32) -> String {
    // Преобразуем Vec<u8> в DynamicImage
    let img = ImageBuffer::from_vec(width, height, image_data)
        .map(|buffer| DynamicImage::ImageRgb8(buffer))
        .expect("Failed to create image from buffer");

    let mut factors: Vec<[f32; 3]> = Vec::new();

    for y in 0..components_y {
        for x in 0..components_x {
            let factor = calculate_factor(&img, x, y, components_x, components_y, width, height);
            factors.push(factor);
        }
    }

    let dc = factors[0];
    let ac = &factors[1..];

    let mut hash = String::new();
    
    // Encode size
    let size_flag = ((components_x - 1) + (components_y - 1) * 9) as u8;
    hash.push(base83_encode(size_flag as u32, 1));

    // Encode DC value
    let dc_value = encode_dc(dc);
    hash.push_str(&base83_encode(dc_value, 4));

    // Encode AC values
    for factor in ac {
        let ac_value = encode_ac(*factor);
        hash.push_str(&base83_encode(ac_value, 2));
    }

    hash
}

#[flutter_rust_bridge::frb(sync)]
pub fn decode(hash: &str, width: u32, height: u32, components_x: u32, components_y: u32) -> Vec<u8> {
    let mut img = ImageBuffer::new(width, height);
    let factors = decode_factors(hash, components_x, components_y);

    for y in 0..height {
        for x in 0..width {
            let mut rgb = [0.0f32; 3];

            for cy in 0..components_y {
                for cx in 0..components_x {
                    let basis = calculate_basis(x, y, cx, cy, width, height);
                    let factor = factors[cy as usize * components_x as usize + cx as usize];
                    
                    for i in 0..3 {
                        rgb[i] += factor[i] * basis;
                    }
                }
            }

            img.put_pixel(
                x,
                y,
                Rgb([
                    linear_to_srgb(rgb[0]) as u8,
                    linear_to_srgb(rgb[1]) as u8,
                    linear_to_srgb(rgb[2]) as u8,
                ]),
            );
        }
    }

    img.into_raw()
}

fn calculate_factor(
    image: &DynamicImage,
    cx: u32,
    cy: u32,
    components_x: u32,
    components_y: u32,
    width: u32,
    height: u32,
) -> [f32; 3] {
    let mut r = 0.0f32;
    let mut g = 0.0f32;
    let mut b = 0.0f32;
    let mut norm = 0.0f32;

    for y in 0..height {
        for x in 0..width {
            let basis = calculate_basis(x, y, cx, cy, width, height);
            let pixel = image.get_pixel(x, y);
            
            r += basis * srgb_to_linear(pixel[0] as f32 / 255.0);
            g += basis * srgb_to_linear(pixel[1] as f32 / 255.0);
            b += basis * srgb_to_linear(pixel[2] as f32 / 255.0);
            norm += basis * basis;
        }
    }

    let scale = if cx == 0 && cy == 0 { 1.0 } else { 2.0 } / norm;

    [r * scale, g * scale, b * scale]
}

fn calculate_basis(x: u32, y: u32, cx: u32, cy: u32, width: u32, height: u32) -> f32 {
    let fx = PI * cx as f32 * x as f32 / width as f32;
    let fy = PI * cy as f32 * y as f32 / height as f32;
    (fx.cos() * fy.cos())
}

fn decode_factors(hash: &str, components_x: u32, components_y: u32) -> Vec<[f32; 3]> {
    let mut factors = Vec::new();
    let _size_info = base83_decode(&hash[0..1]);
    let mut pos = 1;

    // Decode DC value
    let dc = decode_dc(base83_decode(&hash[pos..pos + 4]));
    factors.push(dc);
    pos += 4;

    // Decode AC values
    for _ in 1..(components_x * components_y) as usize {
        let ac = decode_ac(base83_decode(&hash[pos..pos + 2]));
        factors.push(ac);
        pos += 2;
    }

    factors
}

fn srgb_to_linear(value: f32) -> f32 {
    if value <= 0.04045 {
        value / 12.92
    } else {
        ((value + 0.055) / 1.055).powf(2.4)
    }
}

fn linear_to_srgb(value: f32) -> f32 {
    if value <= 0.0031308 {
        value * 12.92
    } else {
        1.055 * value.powf(1.0 / 2.4) - 0.055
    }
}

fn encode_dc(factor: [f32; 3]) -> u32 {
    let r = linear_to_srgb(factor[0]);
    let g = linear_to_srgb(factor[1]);
    let b = linear_to_srgb(factor[2]);
    
    ((r * 255.0).round() as u32) << 16 |
    ((g * 255.0).round() as u32) << 8 |
    ((b * 255.0).round() as u32)
}

fn decode_dc(value: u32) -> [f32; 3] {
    [
        srgb_to_linear(((value >> 16) & 255) as f32 / 255.0),
        srgb_to_linear(((value >> 8) & 255) as f32 / 255.0),
        srgb_to_linear((value & 255) as f32 / 255.0),
    ]
}

fn encode_ac(factor: [f32; 3]) -> u32 {
    let quant_r = quantize(factor[0]);
    let quant_g = quantize(factor[1]);
    let quant_b = quantize(factor[2]);
    
    (quant_r << 8 | quant_g << 4 | quant_b) as u32
}

fn decode_ac(value: u32) -> [f32; 3] {
    let quant_r = (value >> 8) & 15;
    let quant_g = (value >> 4) & 15;
    let quant_b = value & 15;
    
    [
        sign_pow((quant_r as f32 - 8.0) / 7.0, 2.0),
        sign_pow((quant_g as f32 - 8.0) / 7.0, 2.0),
        sign_pow((quant_b as f32 - 8.0) / 7.0, 2.0),
    ]
}

fn quantize(value: f32) -> u32 {
    let value = value.max(-1.0).min(1.0);
    ((value * 7.0 + 8.0).round() as u32).max(0).min(15)
}

fn sign_pow(value: f32, exp: f32) -> f32 {
    value.abs().powf(exp) * value.signum()
}

const CHARACTERS: &str = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz#$%*+,-.:;=?@[]^_{|}~";

fn base83_encode(value: u32, length: usize) -> String {
    let mut result = String::with_capacity(length);
    let mut val = value;
    
    for _ in 0..length {
        let digit = (val % 83) as usize;
        result.insert(0, CHARACTERS.chars().nth(digit).unwrap());
        val /= 83;
    }
    
    result
}

fn base83_decode(string: &str) -> u32 {
    let mut value = 0u32;
    
    for c in string.chars() {
        value = value * 83 + CHARACTERS.find(c).unwrap() as u32;
    }
    
    value
}
