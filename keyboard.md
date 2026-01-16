keyboard spec
https://docs.m5stack.com/ja/core/Cardputer-Adv

picoruby i2c
https://picoruby.org/I2C.html

---

## M5Stack Cardputer Adv Keyboard Specification

### Hardware
- **Keyboard Controller**: TCA8418 I2C Keypad Matrix Driver
- **Number of Keys**: 56 keys (mechanical keyboard)
- **Matrix Configuration**: 6 rows x 10 columns

### I2C Configuration
- **I2C Address**: 0x34 (7-bit)
- **SDA Pin**: GPIO 8
- **SCL Pin**: GPIO 9
- **Frequency**: 400kHz

### Communication Protocol (TCA8418)
1. Write register address `0x04` (KEY_EVENT_A) to I2C address 0x34
2. Read 1 byte from I2C address 0x34 to get key event
3. Parse key event byte:
   - **Bit 7**: Key state (1 = pressed, 0 = released)
   - **Bits 0-6**: Key code (matrix position)
4. Return value `0x00` means FIFO is empty (no key event)

### Key Code Mapping (Matrix Position to Character)
| Key Code | Character | Key Code | Character | Key Code | Character |
|----------|-----------|----------|-----------|----------|-----------|
| 0        | `         | 20       | fn        | 40       | ctrl      |
| 1        | 1         | 21       | a         | 41       | opt       |
| 2        | 2         | 22       | s         | 42       | alt       |
| 3        | 3         | 23       | d         | 43-45    | space     |
| 4        | 4         | 24       | f         | 46       | ret       |
| 5        | 5         | 25       | g         | 47       | 0         |
| 6        | 6         | 26       | h         | 48       | p         |
| 7        | 7         | 27       | j         | 49       | ;         |
| 8        | 8         | 28       | k         | 50       | \         |
| 9        | 9         | 29       | l         | 51       | ]         |
| 10       | tab       | 30       | shift     | 52       | [         |
| 11       | q         | 31       | z         | 53       | -         |
| 12       | w         | 32       | x         | 54       | =         |
| 13       | e         | 33       | c         | 55       | del       |
| 14       | r         | 34       | v         | 56       | '         |
| 15       | t         | 35       | b         | 57       | /         |
| 16       | y         | 36       | n         |          |           |
| 17       | u         | 37       | m         |          |           |
| 18       | i         | 38       | ,         |          |           |
| 19       | o         | 39       | .         |          |           |

### Function Key Combinations (FN_TABLE)
When `fn` key is held:
- `;` → up
- `.` → down
- `,` → left
- `/` → right

### Shift Key Mapping (SHIFT_TABLE)
Standard shift mappings:
- Numbers: `1-9, 0` → `!, @, #, $, %, ^, &, *, (, )`
- Symbols: `` ` `` → `~`, `-` → `_`, `=` → `+`
- Brackets: `[` → `{`, `]` → `}`
- Punctuation: `;` → `:`, `'` → `"`, `,` → `<`, `.` → `>`, `/` → `?`, `\` → `|`
- Letters: lowercase → uppercase

### PicoRuby Implementation Example

```ruby
require 'i2c'

KEYBOARD_I2C_ADDR = 0x34
TCA8418_KEY_EVENT_A = 0x04
I2C_SDA_PIN = 8
I2C_SCL_PIN = 9
KEYBOARD_I2C = I2C.new(unit: 0, sda_pin: I2C_SDA_PIN, scl_pin: I2C_SCL_PIN, frequency: 400000)

def get_input
  begin
    # Write register address (KEY_EVENT_A)
    KEYBOARD_I2C.write(KEYBOARD_I2C_ADDR, [TCA8418_KEY_EVENT_A])

    # Read 1 byte from FIFO
    data = KEYBOARD_I2C.read(KEYBOARD_I2C_ADDR, 1)
    return '' if data.nil? || data.length == 0

    # Get key event byte
    key_event = data.ord
    return '' if key_event == 0x00

    # Extract key code (bits 0-6) and key state (bit 7)
    key_code = key_event & 0x7F
    key_pressed = (key_event & 0x80) != 0

    # Only process key press events, ignore key release
    return '' unless key_pressed

    # Map key code to character using KEY_MAP
    KEY_MAP[key_code] || ''
  rescue
    ''
  end
end
```

### Notes
- **TCA8418 FIFO**: The controller has a FIFO buffer for key events
- **Register-based I2C**: Must write register address before reading
- **Key State**: Bit 7 indicates press (1) or release (0)
- **Key Code**: Bits 0-6 contain the matrix position
- **Empty FIFO**: Returns `0x00` when no keys are pressed
- **Error Handling**: Return empty string on I2C communication failure
- **Polling Mode**: Call `get_input` in main loop continuously
