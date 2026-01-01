require 'm5unified'
require 'gpio'
require 'adc'

# Constants definition start
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
KEYS['13000'] = 'ept'
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

SHIFT_TABLE = {}
SHIFT_TABLE['`'] = '~'
SHIFT_TABLE['1'] = '!'
SHIFT_TABLE['2'] = '@'
SHIFT_TABLE['3'] = '#'
SHIFT_TABLE['4'] = '$'
SHIFT_TABLE['5'] = '%'
SHIFT_TABLE['6'] = '^'
SHIFT_TABLE['7'] = '&'
SHIFT_TABLE['8'] = '*'
SHIFT_TABLE['9'] = '('
SHIFT_TABLE['0'] = ')'
SHIFT_TABLE['_'] = '-'
SHIFT_TABLE['='] = '+'
SHIFT_TABLE['['] = '{'
SHIFT_TABLE[']'] = '}'
SHIFT_TABLE[';'] = ':'
SHIFT_TABLE["'"] = "'"
SHIFT_TABLE[','] = '<'
SHIFT_TABLE['.'] = '>'
SHIFT_TABLE['/'] = '?'
SHIFT_TABLE['a'] = 'A'
SHIFT_TABLE['b'] = 'B'
SHIFT_TABLE['c'] = 'C'
SHIFT_TABLE['d'] = 'D'
SHIFT_TABLE['e'] = 'E'
SHIFT_TABLE['f'] = 'F'
SHIFT_TABLE['g'] = 'G'
SHIFT_TABLE['h'] = 'H'
SHIFT_TABLE['i'] = 'I'
SHIFT_TABLE['j'] = 'J'
SHIFT_TABLE['k'] = 'K'
SHIFT_TABLE['l'] = 'L'
SHIFT_TABLE['m'] = 'M'
SHIFT_TABLE['n'] = 'N'
SHIFT_TABLE['o'] = 'O'
SHIFT_TABLE['p'] = 'P'
SHIFT_TABLE['q'] = 'Q'
SHIFT_TABLE['r'] = 'R'
SHIFT_TABLE['s'] = 'S'
SHIFT_TABLE['t'] = 'T'
SHIFT_TABLE['u'] = 'U'
SHIFT_TABLE['v'] = 'V'
SHIFT_TABLE['w'] = 'W'
SHIFT_TABLE['x'] = 'X'
SHIFT_TABLE['y'] = 'Y'
SHIFT_TABLE['z'] = 'Z'
SHIFT_TABLE['\\'] = '|'

FN_TABLE = {}
FN_TABLE[';'] = 'up'
FN_TABLE['.'] = 'down'
FN_TABLE[','] = 'left'
FN_TABLE['/'] = 'right'
FN_TABLE['/'] = 'right'

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

# Constants definition end

# ti-doc: Read keyboard input
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

CODE_AREA_Y_START = 35
CODE_AREA_Y_END = 100


# ti-doc: Check if a string is a number
def is_number?(str)
  return false if str == ''
  str.each_char do |c|
    return false if c < '0' || c > '9'
  end
  true
end

# ti-doc: Split code into tokens, handling string literals
def tokenize code
  # Split code into tokens, handling string literals
  tokens = []
  current_token = ''
  in_string = false
  string_char = ''
  token_ends = [' ', '(', ')', '{', '}', '[', ']', ',', ';', '_' , '.']

  code.each_char do |c|
    if in_string
      current_token << c
      if c == string_char
        tokens << current_token
        current_token = ''
        in_string = false
        string_char = ''
      end
    elsif c == "'" || c == '"'
      tokens << current_token if current_token != ''
      current_token = c
      in_string = true
      string_char = c
    elsif token_ends.include?(c)
      tokens << current_token if current_token != ''
      tokens << c
      current_token = ''
    else
      current_token << c
    end
  end

  tokens << current_token if current_token != ''

  tokens
end

# ti-doc: Draw code with syntax highlighting
def draw_code_with_highlight(disp, code_str, x, y)
  x_pos = x
  keywords = [
    'def',
    'class',
    'end',
    'if',
    'elsif',
    'else',
    'unless',
    'case',
    'when',
    'while',
    'until',
    'for',
    'do',
    'begin',
    'rescue',
    'ensure',
    'return',
    'yield',
    'break',
    'next'
  ]

  tokens = tokenize code_str

  # Draw each token with appropriate color
  tokens.each do |token|
    if token.length > 0 && (token[0] == "'" || token[0] == '"')
      # String literal color (orange)
      disp.set_text_color 0xFF9F1C
    elsif is_number?(token)
      # Number color (blue)
      disp.set_text_color 0x5B9FED
    elsif keywords.include?(token)
      # Keyword color (pink/magenta)
      disp.set_text_color 0xFF007C
    elsif token.length > 0 && token[0] >= 'A' && token[0] <= 'Z'
      # Capitalized words (green)
      disp.set_text_color 0x009A00
    else
      # Normal text color (white)
      disp.set_text_color 0xF7F7FF
    end

    disp.draw_string token, x_pos, y
    x_pos += token.length * 6
  end
end

# ti-doc: Draw static UI elements
def draw_static_ui(disp)
  # Header
  disp.set_text_color 0xFF007C
  disp.draw_string '+' + '-' * 38 + '+', 0, 0
  disp.set_text_color 0xFF007C
  disp.draw_string '| ', 0, 10
  disp.set_text_color 0xFF9F1C
  disp.draw_string '/home/geek/picoruby/calc.rb', 12, 10
  disp.set_text_color 0xFF007C
  disp.draw_string '|', 234, 10
  disp.set_text_color 0xFF007C
  disp.draw_string '+' + '-' * 38 + '+', 0, 20

  # Separator
  disp.set_text_color 0x3A1C71
  disp.draw_string '_' * 40, 0, 100

  # Result
  disp.set_text_color 0xFF9F1C
  disp.draw_string '=>', 0, 110

  # Footer
  disp.set_text_color 0x3A1C71
  disp.draw_string '_' * 40, 0, 115
end

# ti-doc: Redraw code area with scroll offset
def redraw_code_area(
  disp,
  code_lines,
  scroll_offset,
  max_visible_lines,
  current_code,
  indent_ct
)
  code_area_start = CODE_AREA_Y_START
  code_area_height = CODE_AREA_Y_END - CODE_AREA_Y_START

  # Clear code area
  disp.fill_rect 0, code_area_start, 240, code_area_height, 0x000000

  # Calculate which lines to show (reserve 1 line for input)
  total_lines = code_lines.length
  max_history_lines = max_visible_lines - 1
  start_line = [0, total_lines - max_history_lines].max
 
  # Draw history lines
  y_pos = code_area_start
  (start_line...total_lines).each do |i|
    line_data = code_lines[i]
    disp.set_text_color 0xFF007C

    # Special marker for [RUN]
    if line_data[:text] == '[RUN]'
      disp.draw_string '*', 0, y_pos
      disp.set_text_color 0x3A1C71
      disp.draw_string '[RUN]', 12, y_pos
    else
      disp.draw_string '*', 0, y_pos
      draw_code_with_highlight disp, "#{'  ' * line_data[:indent]}#{line_data[:text]}", 12, y_pos
    end

    y_pos += 10
  end

  # Draw current input line
  if y_pos <= CODE_AREA_Y_END - 10
    disp.set_text_color 0xFF007C
    disp.draw_string '>', 0, y_pos
    code_display = "#{'  ' * indent_ct}#{current_code}_"
    draw_code_with_highlight disp, code_display, 12, y_pos
  end
end

# define adc object for battery display
bat_adc = ADC.new(10)

# define mruby execution sandbox
sandbox = Sandbox.new ''

# define statements
is_input = false
is_shift = false
is_fn = false
is_need_redraw_input = false
code = ''
prev_code_display = ''
res = ''
prev_res = ''
code_executed = ''
prev_code_executed = ''
prev_status = ''
indent_ct = 0
code_lines = []  # History of code lines with {text: "", indent: 0}
scroll_offset = 0  # How many lines scrolled
max_visible_lines = 6  # Max lines visible in code area (35-95px, 10px per line)

# M5 start
M5.begin

# setup display 
disp = M5.Display
disp.set_text_size 1

# initial draw
draw_static_ui(disp)
redraw_code_area disp, code_lines, scroll_offset, max_visible_lines, code, indent_ct

execute_code = ''

loop do
  M5.update

  # draw input area
  code_display = "#{code}"

  if code_display != prev_code_display || is_need_redraw_input
    redraw_code_area disp, code_lines, scroll_offset, max_visible_lines, code, indent_ct

    prev_code_display = code_display

    is_need_redraw_input = false
  end

  # draw result area
  if res.to_s != prev_res || code_executed.to_s != prev_code_executed
    disp.fill_rect 18, 110, 222, 8, 0x000000

    if res.class == Integer
      disp.set_text_color 0x5B9FED
    elsif res.class == String
      disp.set_text_color 0xFF9F1C
    else
      disp.set_text_color 0xF7F7FF
    end

    disp.draw_string " #{res}", 18, 110

    prev_res = res.to_s
    prev_code_executed = code_executed.to_s
  end

  # draw status area
  status = is_shift ? '[ SHIFT ]' : '[ NORMAL ]'
  if status != prev_status
    battery_voltage = bat_adc.read_voltage
    status_with_battery = "#{status} BAT:#{battery_voltage}V"
    disp.fill_rect 0, 125, 240, 10, 0x000000
    disp.set_text_color 0xFF9F1C
    disp.draw_string status_with_battery, 0, 125
    prev_status = status
  end

  key_input = get_input

  if key_input == 'ret' && (code != '' || execute_code != '') && !is_input
    is_input = true

    execute_code << code
    execute_code << '; '

    if !is_shift && code != ''
      tokens = tokenize code

      # Adjust indent before adding to history
      target_tokens = ['end', 'else', 'elsif', 'when']

      tokens.each do |token|
        if target_tokens.include? token
          if indent_ct > 0
            indent_ct = indent_ct - 1
          end

          break
        end
      end

      # Add line to history
      code_lines << {text: code, indent: indent_ct}

      target_tokens = ['class', 'def', 'if', 'elsif', 'else', 'do', 'case', 'when']

      # Adjust indent for next line
      tokens.each do |token|
        if target_tokens.include? token
          indent_ct = indent_ct + 1
          break
        end
      end

      code = ''

      # Redraw code area with scroll
      redraw_code_area disp, code_lines, scroll_offset, max_visible_lines, code, indent_ct

      next
    end

    if code == ''
      # Add [RUN] marker to history
      code_lines << {text: '[RUN]', indent: 0}
    end

    is_shift = false

    code_executed = execute_code
    res = ''

    unless sandbox.compile "_ = (#{execute_code})", remove_lv: true
      res = 'syntax error'
      code = ''
      execute_code = ''
      code_lines = []
      indent_ct = 0

      next
    end

    sandbox.execute
    sandbox.wait timeout: nil
    error = sandbox.error

    if error.nil?
      res = sandbox.result
    else
      res = error.to_s
    end

    sandbox.suspend

    code = ''
    execute_code = ''
    code_lines = []
    indent_ct = 0

    # Redraw code area (clear it)
    redraw_code_area disp, code_lines, scroll_offset, max_visible_lines, code, indent_ct

    next
  end

  if key_input != '' && key_input != 'ret' && !is_input
    is_input = true

    if key_input == 'shift'
      is_shift = !is_shift

      next
    end

    if key_input == 'fn'
      is_fn = !is_fn
      
      next
    end

    if key_input == 'del'
      code = code[0..-2]
      is_shift = false
      is_fn = false

      next
    end

    if is_shift
      code << SHIFT_TABLE[key_input]
      is_shift = false

      next
    end

    if is_fn
      key_input = FN_TABLE[key_input]
      is_fn = false

      if key_input == 'up'
        code = prev_code_executed
      else
        code << key_input
      end

      next
    end
      
    code << key_input

    next
  end

  if key_input == ''
    is_input = false
  end
end
