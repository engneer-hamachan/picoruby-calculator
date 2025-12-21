Add submodules
``` bash
git submodule add https://github.com/picoruby/picoruby-esp32.git components/picoruby-esp32
git submodule add https://github.com/m5stack/M5GFX.git components/M5GFX
git submodule add https://github.com/m5stack/M5Unified.git components/M5Unified
git submodule add https://github.com/kishima/picoruby-m5unified.git components/picoruby-m5unified
git submodule update --init --recursive
```

Update CMakeLists
```text
# vim components/picoruby-esp32/CMakeLists.txt

SRCS:
${COMPONENT_DIR}/../picoruby-m5unified/ports/esp32/m5unified_core.cpp
${COMPONENT_DIR}/../picoruby-m5unified/ports/esp32/m5gfx_color.cpp
${COMPONENT_DIR}/../picoruby-m5unified/ports/esp32/m5gfx_display.cpp
${COMPONENT_DIR}/../picoruby-m5unified/ports/esp32/m5gfx_draw.cpp
${COMPONENT_DIR}/../picoruby-m5unified/ports/esp32/m5gfx_fill.cpp
${COMPONENT_DIR}/../picoruby-m5unified/ports/esp32/m5gfx_image.cpp
${COMPONENT_DIR}/../picoruby-m5unified/ports/esp32/m5gfx_lowlevel.cpp
${COMPONENT_DIR}/../picoruby-m5unified/ports/esp32/m5gfx_text.cpp
${COMPONENT_DIR}/../picoruby-m5unified/ports/esp32/m5gfx_util.cpp

...

INCLUDE_DIRS:
${COMPONENT_DIR}/../picoruby-m5unified/include

PRIV_REQUIRES:
M5Unified
M5GFX
```

Update xtensa
```text
# vim components/picoruby-esp32/picoruby/build_config/xtensa-esp.rb
conf.gem File.expand_path('../../../picoruby-m5unified', __dir__)
```

Update build & flash
```text
. $(YOUR_ESP_IDF_PATH)/export.sh
idf.py set-target esp32s3
idf.py build
idf.py flash
```

