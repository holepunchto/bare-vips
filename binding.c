#include <assert.h>
#include <bare.h>
#include <js.h>
#include <utf.h>
#include <uv.h>
#include <vips/vips.h>

static uv_once_t bare_vips__init_guard = UV_ONCE_INIT;
static int bare_vips__init_status = 0;

static void
bare_vips__init(void) {
  if (VIPS_INIT("bare-vips")) bare_vips__init_status = -1;
}

static js_value_t *
bare_vips_version(js_env_t *env, js_callback_info_t *info) {
  int err;

  js_value_t *result;
  err = js_create_string_utf8(env, (const utf8_t *) vips_version_string(), -1, &result);
  assert(err == 0);

  return result;
}

static js_value_t *
bare_vips_exports(js_env_t *env, js_value_t *exports) {
  int err;

  uv_once(&bare_vips__init_guard, bare_vips__init);

  if (bare_vips__init_status != 0) {
    err = js_throw_error(env, NULL, "Failed to initialize libvips");
    assert(err == 0);

    return NULL;
  }

#define V(name, fn) \
  { \
    js_value_t *val; \
    err = js_create_function(env, name, -1, fn, NULL, &val); \
    assert(err == 0); \
    err = js_set_named_property(env, exports, name, val); \
    assert(err == 0); \
  }

  V("version", bare_vips_version)
#undef V

  return exports;
}

BARE_MODULE(bare_vips, bare_vips_exports)
