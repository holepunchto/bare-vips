include_guard(GLOBAL)

set(args
  --wrap-mode=forcefallback

  # Reduce the build to the core library. Dynamic modules, introspection, the
  # C++ API, the example programs, and the deprecated components are all things
  # we do not need.
  -Dmodules=disabled
  -Dintrospection=disabled
  -Dcplusplus=false
  -Dexamples=false
  -Ddeprecated=false

  # Disable every optional external image format library. These can be enabled
  # individually later as features, each backed by its own port.
  -Dcfitsio=disabled
  -Dcgif=disabled
  -Dexif=disabled
  -Dfftw=disabled
  -Dfontconfig=disabled
  -Darchive=disabled
  -Dheif=disabled
  -Dimagequant=disabled
  -Djpeg=disabled
  -Djpeg-xl=disabled
  -Dlcms=disabled
  -Dmagick=disabled
  -Dmatio=disabled
  -Dnifti=disabled
  -Dopenexr=disabled
  -Dopenjpeg=disabled
  -Dopenslide=disabled
  -Dhighway=disabled
  -Dorc=disabled
  -Dpangocairo=disabled
  -Dpdfium=disabled
  -Dpng=disabled
  -Dpoppler=disabled
  -Dquantizr=disabled
  -Draw=disabled
  -Drsvg=disabled
  -Dspng=disabled
  -Dtiff=disabled
  -Duhdr=disabled
  -Dwebp=disabled
)

declare_port(
  "github:libvips/libvips@8.18.4"
  vips
  MESON
  BYPRODUCTS
    lib/libvips.a
    lib/libgio-2.0.a
    lib/libgobject-2.0.a
    lib/libgmodule-2.0.a
    lib/libglib-2.0.a
    lib/libffi.a
    lib/libpcre2-8.a
    lib/libz.a
    lib/libexpat.a
    lib/libintl.a
  PATCHES
    patches/001-connection-io-h.patch
  WRAPS
    subprojects/glib.wrap
    subprojects/expat.wrap
    subprojects/libffi.wrap
    subprojects/pcre2.wrap
    subprojects/zlib.wrap
    subprojects/proxy-libintl.wrap
  ARGS ${args}
)

macro(declare_port_library name)
  add_library(${name} STATIC IMPORTED GLOBAL)

  add_dependencies(${name} ${vips})

  set_target_properties(
    ${name}
    PROPERTIES
    IMPORTED_LOCATION "${vips_PREFIX}/lib/lib${name}.a"
  )
endmacro()

declare_port_library(vips)
declare_port_library(gio-2.0)
declare_port_library(gobject-2.0)
declare_port_library(gmodule-2.0)
declare_port_library(glib-2.0)
declare_port_library(ffi)
declare_port_library(pcre2-8)
declare_port_library(z)
declare_port_library(expat)
declare_port_library(intl)

file(MAKE_DIRECTORY "${vips_PREFIX}/include")
file(MAKE_DIRECTORY "${vips_PREFIX}/include/glib-2.0")
file(MAKE_DIRECTORY "${vips_PREFIX}/lib/glib-2.0/include")

target_include_directories(
  vips
  INTERFACE
    "${vips_PREFIX}/include"
    "${vips_PREFIX}/include/glib-2.0"
    "${vips_PREFIX}/lib/glib-2.0/include"
)

target_compile_definitions(
  vips
  INTERFACE
    G_INTL_STATIC_COMPILATION=1
)

target_link_libraries(
  vips
  INTERFACE
    gio-2.0
    gobject-2.0
    gmodule-2.0
    glib-2.0
    expat
    z
)

target_link_libraries(
  gio-2.0
  INTERFACE
    gobject-2.0
    gmodule-2.0
    glib-2.0
    z
)

target_link_libraries(
  gobject-2.0
  INTERFACE
    glib-2.0
    ffi
)

target_link_libraries(
  gmodule-2.0
  INTERFACE
    glib-2.0
)

target_link_libraries(
  glib-2.0
  INTERFACE
    pcre2-8
    intl
)

if(APPLE)
  target_link_libraries(
    glib-2.0
    INTERFACE
      "-framework Foundation"
      "-framework CoreFoundation"
      "-framework AppKit"
      "-framework Carbon"
      "-liconv"
      "-lresolv"
      m
  )
elseif(LINUX OR ANDROID)
  target_link_libraries(
    glib-2.0
    INTERFACE
      "-lresolv"
      "-pthread"
      m
      ${CMAKE_DL_LIBS}
  )
elseif(WIN32)
  target_link_libraries(
    glib-2.0
    INTERFACE
      ws2_32
      winmm
      shlwapi
      ole32
  )
endif()
