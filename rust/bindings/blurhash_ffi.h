#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

char *encode(uint32_t components_x,
             uint32_t components_y,
             uint32_t width,
             uint32_t height,
             const uint8_t *rgba_image,
             uintptr_t rgba_image_len);

uint8_t *decode(const uint8_t *blurhash,
                uintptr_t blurhash_len,
                uint32_t width,
                uint32_t height,
                float punch);

void free_string(char *ptr);

void free_decoded_data(uint8_t *ptr, uintptr_t len);
