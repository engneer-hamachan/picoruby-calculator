require 'shell'
require 'm5unified'
require 'i2c'
require 'adc'

#<input_code>

# constants definition start
INTERNAL_CONSTANTS << 'KEYS'
INTERNAL_CONSTANTS << 'SHIFT_TABLE'
INTERNAL_CONSTANTS << 'FN_TABLE'
INTERNAL_CONSTANTS << 'CODE_AREA_Y_START'
INTERNAL_CONSTANTS << 'CODE_AREA_Y_END'

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
SHIFT_TABLE['-'] = '_'
SHIFT_TABLE['='] = '+'
SHIFT_TABLE['['] = '{'
SHIFT_TABLE[']'] = '}'
SHIFT_TABLE[';'] = ':'
SHIFT_TABLE["'"] = "\""
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

CODE_AREA_Y_START = 31
CODE_AREA_Y_END = 101
# constants definition end

# define adc object for battery display
bat_adc = ADC.new(10)

# define mruby execution sandbox
sandbox = Sandbox.new ''

# define statements
is_input = false
is_shift = false
is_fn = false
is_ctrl = false
is_need_redraw_input = false
is_need_redraw_result = false
code = ''
prev_code_display = ''
res = ''
display_res = ''
result_display_offset = 0
prev_res = ''
prev_status = ''
indent_ct = 0
code_lines = []
scroll_offset = 0
max_visible_lines = 7
current_row_number = 1
execute_code = ''
$completion_chars = nil
$dict = {}

def load_constants
  Object.constants.each do |constant|
    constant_str = constant.to_s

    # exclude internal constants
    if INTERNAL_CONSTANTS.include?(constant_str) || constant_str.index('Error') != nil
      next
    end

    $dict[constant_str] = true 
  end
end

# ti-doc: check if a string is a number
def is_number?(str)
  return false if str == ''
  str.each_char do |c|
    return false if c < '0' || c > '9'
  end

  true
end

# ti-doc: split code into tokens
def tokenize code
  tokens = []
  current_token = ''
  in_string = false
  string_end_char = ''
  token_ends = [' ', '(', ')', '{', '}', '[', ']', ',', ';', '.']

  code.each_char do |c|
    if in_string
      current_token << c
      if c == string_end_char
        tokens << current_token
        current_token = ''
        in_string = false
        string_end_char = ''
      end
    elsif c == "'" || c == '"'
      tokens << current_token if current_token != ''
      current_token = c
      in_string = true

      if c == "'"
        string_end_char = "'"
      else
        string_end_char = '"'
      end
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

# ti-doc: draw code with syntax highlighting
def draw_code_with_highlight(disp, code_str, x_pos, y_pos)
  keywords = [
    'def',
    'class',
    'module',
    'end',
    'if',
    'elsif',
    'else',
    'unless',
    'case',
    'when',
    'then',
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
    'next',
    'redo',
    'and',
    'or',
    'not',
    'super',
    'attr_accessor',
    'attr_reader',
    'alias',
    'require'
  ]

  tokens = tokenize code_str
  is_def = false

  tokens.each do |token|
    if token.length > 0 && (token[0] == "'" || token[0] == '"')
      # string literal color (brown/orange)
      disp.set_text_color 0xCE9178
    elsif token.length > 0 && token[0] == ':'
      # symbol color (blue)
      disp.set_text_color 0x569CD6
    elsif token.length > 1 && token[-1] == ':'
      # symbol color (blue)
      disp.set_text_color 0x569CD6
    elsif token.length > 1 && token[0] == '@' && token[1] == '@'
      # class variable color (light blue)
      disp.set_text_color 0x9CDCFE
    elsif token.length > 0 && token[0] == '@'
      # instance variable color (light blue)
      disp.set_text_color 0x9CDCFE
    elsif token.length > 0 && token[0] == '$'
      # global variable color (light blue)
      disp.set_text_color 0x9CDCFE
    elsif is_number?(token)
      # number color (light green)
      disp.set_text_color 0xB5CEA8
    elsif ['nil', 'true', 'false', 'self'].include?(token)
      # pseudo variables color (blue)
      disp.set_text_color 0x569CD6
    elsif token == 'def'
      is_def = true
      # keyword color (pink)
      disp.set_text_color 0xC586C0
    elsif keywords.include?(token)
      # keyword color (pink)
      disp.set_text_color 0xC586C0
    elsif token.length > 0 && token[0] >= 'A' && token[0] <= 'Z'
      # capitalized words (blue-green)
      disp.set_text_color 0x4EC9B0
    elsif token == ' ' || token == '.'
      # normal text color (white) 
      disp.set_text_color 0xD4D4D4
    elsif is_def
      # method name color (yellow) 
      disp.set_text_color 0xFFFCDA
      is_def = false
    else
      # normal text color (white) 
      disp.set_text_color 0xD4D4D4
    end

    disp.draw_string token, x_pos, y_pos
    x_pos += token.length * 6
  end
end

# ti-doc: draw static UI elements
def draw_static_ui(disp)
  # header border
  disp.set_text_color 0x808080
  disp.draw_string '+' + '-' * 38 + '+', 0, 0
  disp.set_text_color 0x808080
  disp.draw_string '| ', 0, 10
  # filename
  disp.set_text_color 0x808080
  disp.draw_string '/home/geek/picoruby/calc.rb', 12, 10
  disp.set_text_color 0x808080
  disp.draw_string '|', 234, 10
  disp.set_text_color 0x808080
  disp.draw_string '+' + '-' * 38 + '+', 0, 20

  # separator
  disp.set_text_color 0x808080
  disp.draw_string '_' * 40, 0, 100

  # result
  disp.set_text_color 0x808080
  disp.draw_string '=>', 0, 110

  # footer
  disp.set_text_color 0x808080
  disp.draw_string '_' * 40, 0, 115
end

# ti-doc: search and draw completion candidates
def draw_completion disp, current_code
  $completion_chars = nil

  return if current_code == ''

  tokens = tokenize current_code
  target_code = tokens.last

  # find matching completions
  candidates = []

  $dict.keys.each do |key|
    if key.length > target_code.length && key[0, target_code.length] == target_code
      candidates << key
    end
  end

  return if candidates.length == 0

  # limit to 3 candidates
  candidates = candidates[0, 5]
  $completion_chars = candidates[0][target_code.length, candidates[0].length] 

  # draw completion box
  padding = 2
  box_x = 118 - padding
  box_y = 41 - padding
  box_width = 90 + (padding * 2)
  box_height = (candidates.length * 10) + (padding * 2)

  # draw completion box background
  disp.fill_rect box_x, box_y, box_width, box_height, 0x0A0A0A

  # draw border
  border_color = 0xD4D4D4
  disp.draw_fast_h_line box_x, box_y, box_width, border_color
  disp.draw_fast_h_line box_x, box_y + box_height - 1, box_width, border_color
  disp.draw_fast_v_line box_x, box_y, box_height, border_color
  disp.draw_fast_v_line box_x + box_width - 1, box_y, box_height, border_color

  # draw candidates
  candidates.each_with_index do |candidate, idx|
    y_pos = box_y + (padding + 1) + (idx * 10)

    if candidate[0] >= 'A' && candidate[0] <= 'Z'
      disp.set_text_color 0x4EC9B0
    else
      disp.set_text_color 0xFFFCDA
    end

    disp.draw_string candidate, box_x + 4 + padding, y_pos
  end
end

# ti-doc: redraw code area with scroll offset
def redraw_code_area(
  disp,
  code_lines,
  scroll_offset,
  max_visible_lines,
  current_code,
  indent_ct,
  current_row_number
)
  code_area_start = CODE_AREA_Y_START
  code_area_height = CODE_AREA_Y_END - CODE_AREA_Y_START

  # clear code area
  disp.fill_rect 0, code_area_start, 240, code_area_height, 0x000000

  # calculate which lines to show
  total_lines = code_lines.length
  max_history_lines = max_visible_lines - 1
  start_line = [0, total_lines - max_history_lines].max
 
  # draw history lines
  y_pos = code_area_start

  (start_line...total_lines).each do |i|
    line_data = code_lines[i]
  
    disp.set_text_color 0x808080
    line_number = i + 1

    # calculate left space
    if line_number > 9
      space_ct = 1
    else
      space_ct = 2
    end

    disp.draw_string "#{' ' * space_ct}#{line_number} |", 0, y_pos
    draw_code_with_highlight disp, "#{'  ' * line_data[:indent]}#{line_data[:text]}", 36, y_pos


    y_pos += 10
  end

  # completion
  draw_completion disp, current_code

  # draw current input line
  if y_pos <= CODE_AREA_Y_END - 10
    # calculate left space
    if current_row_number > 9
      space_ct = 1
    else
      space_ct = 2
    end

    disp.set_text_color 0x808080
    disp.draw_string "#{' ' * space_ct}#{current_row_number} |", 0, y_pos
    code_display = "#{'  ' * indent_ct}#{current_code}"
    draw_code_with_highlight disp, code_display, 36, y_pos
    disp.set_text_color 0xD4D4D4
    disp.draw_string '_', 36 + (code_display.length * 6), y_pos
  end

  # append dict for class define
  code_lines.each do |line|
    tokens = tokenize line[:text]

    tokens.each_with_index do |token, idx|
      if token == 'class' && idx == 0
        $dict['attr_reader'] = true
        $dict['attr_accessor'] = true
        $dict['initialize'] = true
        break
      end
    end
  end
end

# M5 start
M5.begin

# Wait for M5 begin
sleep 0.2

# Initialize keyboard controller
init_keyboard

# setup display
disp = M5.Display
disp.set_text_size 1

# initial draw
draw_static_ui(disp)
redraw_code_area(
  disp,
  code_lines,
  scroll_offset,
  max_visible_lines,
  code,
  indent_ct,
  current_row_number
)

# setup dict
load_constants

loop do
  M5.update

  # draw input area
  code_display = "#{code}"

  if code_display != prev_code_display || is_need_redraw_input
    redraw_code_area(
      disp,
      code_lines,
      scroll_offset,
      max_visible_lines,
      code,
      indent_ct,
      current_row_number
    )

    prev_code_display = code_display

    is_need_redraw_input = false
  end

  # draw result area
  if res.to_s != prev_res || is_need_redraw_result
    disp.fill_rect 18, 110, 222, 8, 0x000000

    if res.class == Integer || res.class == Float
      disp.set_text_color 0xB5CEA8
    elsif res.class == String
      disp.set_text_color 0xCE9178
    elsif res.class == NilClass
      disp.set_text_color 0x569CD6
      display_res = "nil"
    elsif res.class == TrueClass || res.class == FalseClass
      disp.set_text_color 0x569CD6
    else
      disp.set_text_color 0xD4D4D4
    end

    disp.draw_string "#{display_res[result_display_offset..]}", 18, 110

    prev_res = res.to_s
    is_need_redraw_result = false
  end

  # draw status area
  status = is_shift ? '[ SHIFT ]' : '[ NORMAL ]'
  if status != prev_status
    battery_voltage = bat_adc.read_voltage
    status_with_battery = "#{status} BAT:#{battery_voltage}V"
    disp.fill_rect 0, 125, 240, 10, 0x000000
    disp.set_text_color 0x808080
    disp.draw_string status_with_battery, 0, 125
    prev_status = status
  end

  key_input = get_input

  if key_input == 'tab' && !is_input
    is_input = true

    if $completion_chars.is_a?(String)
      code = code + $completion_chars
      next
    end
  end

  if key_input == 'ret' && (code != '' || execute_code != '') && !is_input
    is_input = true

    execute_code << code
    execute_code << "\n"

    if !is_shift && code != ''
      tokens = tokenize code

      # calculate minus indent
      target_tokens = ['end', 'else', 'elsif', 'when']

      tokens.each do |token|
        if target_tokens.include? token
          if indent_ct > 0
            indent_ct = indent_ct - 1
          end

          break
        end
      end

      code_lines << {text: code, indent: indent_ct}

      # calculate plus indent
      target_tokens = [
        'class',
        'module',
        'def',
        'if',
        'unless',
        'elsif',
        'else',
        'do',
        'case',
        'when',
        'while',
        'until',
        'for'
      ]

      tokens.each_with_index do |token, idx|
        if (target_tokens.include?(token) && idx == 0) || (token == 'do')
          indent_ct = indent_ct + 1
          break
        end
      end

      code = ''

      redraw_code_area(
        disp,
        code_lines,
        scroll_offset,
        max_visible_lines,
        code,
        indent_ct,
        current_row_number
      )

      current_row_number += 1

      next
    end

    is_shift = false

    res = ''
    display_res = ''

    unless sandbox.compile "_ = (#{execute_code})", remove_lv: true
      res = 'syntax error'
      display_res = 'syntax error'
      code = ''
      execute_code = ''
      code_lines = []
      indent_ct = 0
      current_row_number = 1

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

    display_res = res.to_s

    # append completion dict item
    code_lines.each do |line|
      tokens = tokenize line[:text]
      is_def = false
      is_attr_reader = false
      ignore_tokens = ['self', '.', ' ', ',', '(', ')', 'initialize']
      define_tokens = ['def', 'class', 'module']
      attr_tokens = ['attr_accessor', 'attr_reader']

      tokens.each_with_index do |token, idx|
        if define_tokens.include?(token) && idx == 0
          if token == 'class'
            $dict['new'] = true
          end

          is_def = true
          next
        end

        if attr_tokens.include?(token) && idx == 0
          is_attr_reader = true
          next
        end

        if is_def && !$dict[token] && !ignore_tokens.include?(token)
          $dict[token] = true
          is_def = false
        end

        if is_attr_reader && !ignore_tokens.include?(token) && !$dict[token[1, token.length]]
          $dict[token[1, token.length]] = true
        end

        if token == 'require'
          load_constants
        end
      end

      is_def = false
      is_attr_reader = false
    end

    # remove tmp dict item
    $dict.delete 'attr_reader'
    $dict.delete 'attr_accessor'
    $dict.delete 'initialize'

    sandbox.suspend

    code = ''
    execute_code = ''
    code_lines = []
    indent_ct = 0
    current_row_number = 1
    result_display_offset = 0

    redraw_code_area(
      disp,
      code_lines,
      scroll_offset,
      max_visible_lines,
      code,
      indent_ct,
      current_row_number
    )

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

    if key_input == 'ctrl'
      is_ctrl = !is_ctrl
      
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

      if key_input.nil?
        key_input = ''
        next
      end

      if key_input == 'right'
        check_offset = result_display_offset + 37
        if display_res.length >= check_offset
          result_display_offset += 37
          is_need_redraw_result = true
        end
        
        next
      end

      if key_input == 'left'
        check_offset = result_display_offset - 37
        if 0 <= check_offset
          result_display_offset -= 37
        else
          result_display_offset = 0
        end

        is_need_redraw_result = true
        
        next
      end

      if key_input == 'up' && code_lines.length > 0
        indent_ct = code_lines[code_lines.length - 1][:indent]
        code_lines = code_lines[0, code_lines.length - 1]
        execute_code = ''

        code_lines.each do |line|
          execute_code << line[:text].to_s + "\n" 
        end

        current_row_number -= 1

        is_need_redraw_input = true
        next
      end

      code << key_input

      next
    end

    if is_ctrl && key_input == 'd'
      code = ''
      code_lines = []
      indent_ct = 0
      execute_code = ''
      is_ctrl = false
      is_need_redraw_input = true
      current_row_number = 1

      next
    end

    if is_ctrl && key_input == 'c'
      code = ''
      is_ctrl = false

      next
    end

    if ['alt', 'opt'].include? key_input
      next
    end
      
    code << key_input

    next
  end

  if key_input == ''
    is_input = false
  end
end
