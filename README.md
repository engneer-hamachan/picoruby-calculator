# 💎 PicoRuby Calculator ✨

![Calculator Demo](image/main.jpg)

🚀 **Ruby REPL in your pocket!** 🎒 Write and execute Ruby code **anywhere** with this M5Stack Cardputer(ADV or v1.1)-powered handheld device! ⚡ Features real-time code execution, syntax error detection, and battery monitoring - because why should Ruby be stuck on your desktop? 🖥️❌

> 📌 **Note:** This project is specifically designed for **M5Stack Cardputer** 🎮

---

## 🛠️ Setup

### 1️⃣ Update submodules
```bash
git submodule update --init --recursive
```

### 2️⃣ Update CMakeLists

📝 Edit `components/picoruby-esp32/CMakeLists.txt`:

**➕ Add to SRCS:**
```cmake
${COMPONENT_DIR}/../picoruby-m5unified/ports/esp32/m5unified_core.cpp
${COMPONENT_DIR}/../picoruby-m5unified/ports/esp32/m5gfx_color.cpp
${COMPONENT_DIR}/../picoruby-m5unified/ports/esp32/m5gfx_display.cpp
${COMPONENT_DIR}/../picoruby-m5unified/ports/esp32/m5gfx_draw.cpp
${COMPONENT_DIR}/../picoruby-m5unified/ports/esp32/m5gfx_fill.cpp
${COMPONENT_DIR}/../picoruby-m5unified/ports/esp32/m5gfx_image.cpp
${COMPONENT_DIR}/../picoruby-m5unified/ports/esp32/m5gfx_lowlevel.cpp
${COMPONENT_DIR}/../picoruby-m5unified/ports/esp32/m5gfx_text.cpp
${COMPONENT_DIR}/../picoruby-m5unified/ports/esp32/m5gfx_util.cpp
```

**➕ Add to INCLUDE_DIRS:**
```cmake
${COMPONENT_DIR}/../picoruby-m5unified/include
```

**➕ Add to PRIV_REQUIRES:**
```cmake
M5Unified
M5GFX
```

### 3️⃣ Update build configuration

📝 Edit `components/picoruby-esp32/picoruby/build_config/xtensa-esp.rb`:

```ruby
conf.gem File.expand_path('../../../picoruby-m5unified', __dir__)
```

### 4️⃣ Apply theme 🎨

Choose and apply a theme for your calculator:

```bash
# List available themes
make list-themes

# Apply your chosen theme with device type
# DEVICE: adv (current model) or v1_1 (legacy Cardputer v1.1)
make apply-theme THEME=default DEVICE=adv
```

### 5️⃣ Build and flash 🔥

```bash
. $(YOUR_ESP_IDF_PATH)/export.sh
idf.py set-target esp32s3
idf.py build
idf.py flash
```

---

## 🎨 Themes

This calculator comes with multiple themes to customize your experience:

### 🌸 Sakura Theme
A soft, elegant theme inspired by Japanese cherry blossoms with pastel pink tones.

![Sakura Theme](image/sakura-theme.png)

**[Sakura Theme Page →](https://engneer-hamachan.github.io/picoruby-calculator/sakura_preview.html)**

### 🌃 Cyber Retro Theme
A vibrant theme with hot magenta and neon orange - retro arcade energy!

![Cyber Retro Theme](image/cyber-retro-theme.png)

**[Cyber Retro Theme Page →](https://engneer-hamachan.github.io/picoruby-calculator/cyber_retro_preview.html)**

### 📝 Editor Theme
A professional code editor theme with full syntax highlighting and line numbers.

![Editor Theme](image/editor-theme.png)

**[Editor Theme Page →](https://engneer-hamachan.github.io/picoruby-calculator/editor_preview.html)**

**Features:**
- Line numbers with auto-alignment
- Full Ruby syntax highlighting (keywords, strings, numbers, variables, etc.)
- Multi-line input support with auto-indentation

### 📋 Default Theme
A clean, classic terminal-style interface with standard colors.

**To switch themes:**
```bash
make list-themes                              # List available themes
make apply-theme THEME=cyber_retro DEVICE=adv # Apply cyber retro theme
make apply-theme THEME=sakura DEVICE=adv      # Apply sakura theme
make apply-theme THEME=editor DEVICE=adv      # Apply editor theme
make apply-theme THEME=default DEVICE=adv     # Apply default theme
```

---

## ⚠️ Known Issues

🚧 **Work in Progress** - The following issues are currently being fixed:

- 🔄 **Resource Exhaustion**: After multiple executions, resources may become exhausted, causing the device to restart

Stay tuned for updates! 🛠️

