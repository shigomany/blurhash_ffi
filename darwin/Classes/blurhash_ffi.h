#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

char *blurhash_encode(uint32_t components_x,
                      uint32_t components_y,
                      uint32_t width,
                      uint32_t height,
                      const uint8_t *rgba_image,
                      uintptr_t rgba_image_len);

uint8_t *blurhash_decode(const uint8_t *blurhash,
                         uintptr_t blurhash_len,
                         uint32_t width,
                         uint32_t height,
                         float punch);

bool is_valid_blurhash(const uint8_t *blurhash, uintptr_t blurhash_len);

void free_string(char *ptr);

void free_decoded_data(uint8_t *ptr, uintptr_t len);
