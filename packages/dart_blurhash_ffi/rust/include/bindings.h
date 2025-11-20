#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

typedef struct WrappedEncodeResult {
  bool success;
  char *data;
  char *error_message;
} WrappedEncodeResult;

typedef struct WrappedDecodeResult {
  bool success;
  uint8_t *data;
  char *error_message;
} WrappedDecodeResult;

struct WrappedEncodeResult blurhash_encode(uint32_t components_x,
                                           uint32_t components_y,
                                           const uint8_t *rgba_image,
                                           uint32_t rgba_image_len);

struct WrappedDecodeResult blurhash_decode(const uint8_t *blurhash,
                                           uint32_t blurhash_len,
                                           uint32_t width,
                                           uint32_t height,
                                           float punch);

bool blurhash_is_valid(const uint8_t *blurhash, uint32_t blurhash_len);

void blurhash_free_string(char *ptr);

void blurhash_free_bytes(uint8_t *ptr, uint32_t len);
