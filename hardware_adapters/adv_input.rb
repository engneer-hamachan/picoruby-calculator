KEYBOARD_I2C_ADDR = 0x34
TCA8418_REG_CFG = 0x01
TCA8418_REG_INT_STAT = 0x02
TCA8418_KEY_EVENT_A = 0x04
TCA8418_REG_KP_GPIO1 = 0x1D
TCA8418_REG_KP_GPIO2 = 0x1E
TCA8418_REG_KP_GPIO3 = 0x1F
TCA8418_CFG_AI = 0x80
TCA8418_CFG_KE_IEN = 0x01
I2C_SDA_PIN = 8
I2C_SCL_PIN = 9
KEYBOARD_I2C = I2C.new(unit: "ESP32_I2C1", sda_pin: I2C_SDA_PIN, scl_pin: I2C_SCL_PIN, frequency: 400000)

KEYS = {}
KEYS[1] = '`'
KEYS[2] = 'tab'
KEYS[3] = 'fn'
KEYS[4] = 'ctrl'
KEYS[5] = '1'
KEYS[6] = 'q'
KEYS[7] = 'shift'
KEYS[8] = 'opt'
KEYS[11] = '2'
KEYS[12] = 'w'
KEYS[13] = 'a'
KEYS[14] = 'alt'
KEYS[15] = '3'
KEYS[16] = 'e'
KEYS[17] = 's'
KEYS[18] = 'z'
KEYS[21] = '4'
KEYS[22] = 'r'
KEYS[23] = 'd'
KEYS[24] = 'x'
KEYS[25] = '5'
KEYS[26] = 't'
KEYS[27] = 'f'
KEYS[28] = 'c'
KEYS[31] = '6'
KEYS[32] = 'y'
KEYS[33] = 'g'
KEYS[34] = 'v'
KEYS[35] = '7'
KEYS[36] = 'u'
KEYS[37] = 'h'
KEYS[38] = 'b'
KEYS[41] = '8'
KEYS[42] = 'i'
KEYS[43] = 'j'
KEYS[44] = 'n'
KEYS[45] = '9'
KEYS[46] = "o"
KEYS[47] = 'k'
KEYS[48] = 'm'
KEYS[51] = '0'
KEYS[52] = 'p'
KEYS[53] = 'l'
KEYS[54] = ','
KEYS[55] = '_'
KEYS[56] = "["
KEYS[57] = ';'
KEYS[58] = '.'
KEYS[61] = '='
KEYS[62] = ']'
KEYS[63] = "'"
KEYS[64] = '/'
KEYS[65] = 'del'
KEYS[66] = "\\"
KEYS[67] = 'ret'
KEYS[68] = ' '

# ti-doc: initialize keyboard
def init_keyboard
  max_retries = 5
  retry_count = 0

  while retry_count < max_retries
    begin
      sleep 0.05

      KEYBOARD_I2C.write(KEYBOARD_I2C_ADDR, [TCA8418_REG_CFG])
      test_read = KEYBOARD_I2C.read(KEYBOARD_I2C_ADDR, 1)

      if test_read.nil? || test_read.length == 0
        retry_count += 1
        sleep 0.1
        next
      end

      KEYBOARD_I2C.write(KEYBOARD_I2C_ADDR, [TCA8418_REG_KP_GPIO1, 0xFF])
      sleep 0.02

      KEYBOARD_I2C.write(KEYBOARD_I2C_ADDR, [TCA8418_REG_KP_GPIO2, 0xFF])
      sleep 0.02

      KEYBOARD_I2C.write(KEYBOARD_I2C_ADDR, [TCA8418_REG_KP_GPIO3, 0x03])
      sleep 0.02

      cfg_value = TCA8418_CFG_AI | TCA8418_CFG_KE_IEN
      KEYBOARD_I2C.write(KEYBOARD_I2C_ADDR, [TCA8418_REG_CFG, cfg_value])
      sleep 0.02

      KEYBOARD_I2C.write(KEYBOARD_I2C_ADDR, [TCA8418_REG_INT_STAT, 0xFF])
      sleep 0.02

      50.times do
        KEYBOARD_I2C.write(KEYBOARD_I2C_ADDR, [TCA8418_KEY_EVENT_A])
        data = KEYBOARD_I2C.read(KEYBOARD_I2C_ADDR, 1)
        break if data.nil? || data.length == 0 || data.ord == 0x00
      end

      return true

    rescue => e
      retry_count += 1
      sleep 0.1
    end
  end

  return false
end

# ti-doc: read keyboard input 
def get_input
  begin
    KEYBOARD_I2C.write(KEYBOARD_I2C_ADDR, [TCA8418_KEY_EVENT_A])

    data = KEYBOARD_I2C.read(KEYBOARD_I2C_ADDR, 1)
    return '' if data.nil? || data.length == 0

    key_event = data.ord
    return '' if key_event == 0x00

    key_code = key_event & 0x7F
    key_pressed = (key_event & 0x80) != 0

    return '' unless key_pressed

    KEYS[key_code] || ''
  rescue => e
    ''
  end
end

# internal constants
INTERNAL_CONSTANTS = [
  'KEYBOARD_I2C_ADDR',
  'TCA8418_REG_CFG',
  'TCA8418_REG_INT_STAT',
  'TCA8418_KEY_EVENT_A',
  'TCA8418_REG_KP_GPIO1',
  'TCA8418_REG_KP_GPIO2',
  'TCA8418_REG_KP_GPIO3',
  'TCA8418_CFG_AI',
  'TCA8418_CFG_KE_IEN',
  'I2C_SDA_PIN', 
  'I2C_SCL_PIN', 
  'KEYBOARD_I2C',
]
