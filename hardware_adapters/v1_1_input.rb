COL3 = GPIO.new(3, GPIO::IN) 
COL4 = GPIO.new(4, GPIO::IN)
COL5 = GPIO.new(5, GPIO::IN)
COL6 = GPIO.new(6, GPIO::IN)
COL7 = GPIO.new(7, GPIO::IN)
COL13 = GPIO.new(13, GPIO::IN)
COL15 = GPIO.new(15, GPIO::IN)

ROW8 = GPIO.new(8, GPIO::OUT)
ROW9 = GPIO.new(9, GPIO::OUT) 
ROW11 = GPIO.new(11, GPIO::OUT)

KEYS = {}
KEYS['13001'] = 'ctrl'
KEYS['13000'] = 'opt'
KEYS['15001'] = 'alt'
KEYS['15000'] = 'z'
KEYS['3001'] = 'x'
KEYS['3000'] = 'c'
KEYS['4001'] = 'v'
KEYS['4000'] = 'b'
KEYS['5001'] = 'n'
KEYS['5000'] = 'm'
KEYS['6001'] = ','
KEYS['6000'] = '.'
KEYS['7001'] = '/'
KEYS['7000'] = ' '
KEYS['13101'] = 'fn'
KEYS['13100'] = 'shift'
KEYS['15101'] = 'a'
KEYS['15100'] = 's'
KEYS['3101'] = 'd'
KEYS['3100'] = 'f'
KEYS['4101'] = 'g'
KEYS['4100'] = 'h'
KEYS['5101'] = 'j'
KEYS['5100'] = 'k'
KEYS['6101'] = 'l'
KEYS['6100'] = ';'
KEYS['7101'] = "'"
KEYS['7100'] = 'ret'
KEYS['13011'] = 'tab'
KEYS['13010'] = 'q'
KEYS['15011'] = 'w'
KEYS['15010'] = 'e'
KEYS['3011'] = 'r'
KEYS['3010'] = 't'
KEYS['4011'] = 'y'
KEYS['4010'] = 'u'
KEYS['5011'] = 'i'
KEYS['5010'] = 'o'
KEYS['6011'] = 'p'
KEYS['6010'] = '['
KEYS['7011'] = ']'
KEYS['7010'] = '\\'
KEYS['13111'] = '`'
KEYS['13110'] = '1'
KEYS['15111'] = '2'
KEYS['15110'] = '3'
KEYS['3111'] = '4'
KEYS['3110'] = '5'
KEYS['4111'] = '6'
KEYS['4110'] = '7'
KEYS['5111'] = '8'
KEYS['5110'] = '9'
KEYS['6111'] = '0'
KEYS['6110'] = '_'
KEYS['7111'] = '='
KEYS['7110'] = 'del'

PATTERN = 
  [
    [0, 0, 0],
    [0, 0, 1],
    [0, 1, 0],
    [0, 1, 1],
    [1, 0, 0],
    [1, 0, 1],
    [1, 1, 0],
    [1, 1, 1]
  ]

# ti-doc: initialize keyboard
def init_keyboard
  true
end

# ti-doc: read keyboard input
def get_input
  PATTERN.each do |pat|
    ROW8.write pat[0]
    ROW9.write pat[1]
    ROW11.write pat[2]

    base_key = pat[0].to_s + pat[1].to_s + pat[2].to_s

    if COL3.low?
      key = '3' + base_key
      return KEYS[key]
    end

    if COL4.low?
      key = '4' + base_key
      return KEYS[key]
    end

    if COL5.low?
      key = '5' + base_key
      return KEYS[key]
    end

    if COL6.low?
      key = '6' + base_key
      return KEYS[key]
    end

    if COL7.low?
      key = '7' + base_key
      return KEYS[key]
    end

    if COL13.low?
      key = '13' + base_key
      return KEYS[key]
    end

    if COL15.low?
      key = '15' + base_key
      return KEYS[key]
    end
  end

  ''
end

# internal constants
INTERNAL_CONSTANTS = [
  'COL3',
  'COL4',
  'COL5',
  'COL6',
  'COL7',
  'COL13',
  'COL15',
  'ROW8',
  'ROW9',
  'ROW11', 
  'PATTERN', 
]
