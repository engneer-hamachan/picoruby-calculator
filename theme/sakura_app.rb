require 'm5unified'
require 'gpio'
require 'adc'

#<input_code>

# Constants definition start
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
# Constants definition end

# ti-doc: Draw static UI elements - Sakura Theme
def draw_static_ui(disp)
  # background
  disp.fill_rect 0, 0, 240, 2, 0xFFB6C1

  # title
  disp.set_text_color 0xFFB6C1
  disp.draw_string '~' * 39, 3, 3
  disp.set_text_color 0xFFC8DC
  disp.draw_string '<', 57, 15
  disp.draw_string '>', 177, 15
  disp.set_text_color 0xFFFDF0
  disp.draw_string 'sakura/dentaku.rb', 69, 15

  # input
  disp.set_text_color 0xFFB6C1
  disp.draw_string '>', 6, 48


  # output
  disp.set_text_color 0xFFB6C1
  disp.draw_string '>', 6, 93

  # footer
  disp.set_text_color 0xFFB6C1
  disp.draw_string '_' * 39, 3, 113

  # initial dots line
  disp.set_text_color 0xFFE4EB
  disp.draw_string '. . ' * 11, 0, 25
  disp.draw_string '. . ' * 11, 0, 70
end

# ti-doc: draw animation ui
def draw_animation_ui(disp, blink_count)
  blink_phase = (blink_count / 60) % 2

  20.times do |i|
    x_pos = 3 + (i * 12)
    if (i % 2 == 0 && blink_phase == 0) || (i % 2 == 1 && blink_phase == 1)
      disp.set_text_color 0xFFB6C1
    else
      disp.set_text_color 0xFFFFFF
    end
    disp.draw_string '*', x_pos, 3
    disp.draw_string '*', x_pos, 113
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
blink_count = 0

# M5 start
M5.begin

# Wait for M5 begin
sleep 0.2

# setup display 
disp = M5.Display
disp.set_text_size 1

# initial draw
draw_static_ui(disp)

loop do
  M5.update

  draw_animation_ui disp, blink_count
  blink_count = blink_count + 1

  # draw input area
  code_display = " #{code}_"
  if code_display != prev_code_display || is_need_redraw_input
    disp.fill_rect 12, 48, 228, 8, 0x000000
    disp.set_text_color 0xFFFDF0
    disp.draw_string code_display, 12, 48
    prev_code_display = code_display
    is_need_redraw_input = false
  end

  # draw result area
  if res.to_s != prev_res || code_executed.to_s != prev_code_executed
    disp.fill_rect 12, 93, 228, 8, 0x000000
    disp.set_text_color 0xFFE4EB
    disp.set_text_color 0xFFFDF0
    disp.draw_string " #{res}", 12, 93
    prev_res = res.to_s
    prev_code_executed = code_executed.to_s
  end

  # draw status area
  status = is_shift ? '[SFT]' : '[NML]'
  if status != prev_status
    battery_voltage = bat_adc.read_voltage
    status_with_battery = "#{status} BAT:#{battery_voltage}V"
    disp.fill_rect 0, 125, 240, 10, 0x000000
    disp.set_text_color 0xFFC8DC
    disp.draw_string status_with_battery, 0, 125
    prev_status = status
  end

  key_input = get_input

  if key_input == 'ret' && code != '' && !is_input
    is_input = true

    code_executed = code
    res = ''

    unless sandbox.compile "_ = (#{code})", remove_lv: true
      res = 'syntax error'
      code = ''

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
