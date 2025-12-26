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

# Screen: 240x135px, Char: 6px width, 40 chars per line
# ti-doc: Draw static UI elements - Sakura Theme
def draw_static_ui(disp)
  # background
  disp.fill_rect 0, 0, 240, 2, 0xFFB6C1

  # title
  disp.set_text_color 0xFFB6C1  # 桜ピンク
  disp.draw_string '~' * 39, 3, 3  # ~のみ描画
  disp.set_text_color 0xFFC8DC
  disp.draw_string '<', 57, 15
  disp.draw_string '>', 177, 15
  disp.set_text_color 0xFFFDF0
  disp.draw_string 'sakura/dentaku.rb', 69, 15  # 17文字

  # input
  disp.set_text_color 0xFFB6C1
  disp.draw_string '>', 6, 48


  # output
  disp.set_text_color 0xFFB6C1
  disp.draw_string '>', 6, 93

  # footer
  disp.set_text_color 0xFFB6C1
  disp.draw_string '_' * 39, 3, 113  # _のみ描画

  # 初期ドット線描画 - 上部の線 (y=25)
  disp.set_text_color 0xFFE4EB
  disp.draw_string '  . ' * 10, 0, 25
  disp.set_text_color 0xFFB6C1
  disp.draw_string '.   ' * 10, 0, 25

  # 初期ドット線描画 - 下部の線 (y=70)
  disp.set_text_color 0xFFE4EB
  disp.draw_string '   .' * 10, 0, 70
  disp.set_text_color 0xFFB6C1
  disp.draw_string ' .  ' * 10, 0, 70
end

# ti-doc: draw animation ui
def draw_animation_ui(disp, blink_count)
  blink_phase = (blink_count / 60) % 2  # 60フレームごとに切り替え

  20.times do |i|
    x_pos = 3 + (i * 12)  # 3, 15, 27, 39, ... (文字幅6px×2文字ごと)
    if (i % 2 == 0 && blink_phase == 0) || (i % 2 == 1 && blink_phase == 1)
      disp.set_text_color 0xFFB6C1  # ピンク
    else
      disp.set_text_color 0xFFFFFF  # 白
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
anim_offset = 0
frame_count = 0
blink_count = 0

# M5 start
M5.begin

# setup display 
disp = M5.Display
disp.set_text_size 1

# initial draw
draw_static_ui(disp)

loop do
  M5.update

  draw_animation_ui disp, blink_count
  blink_count = blink_count + 1

  # フレームカウンタを増やして、60フレームに1回だけオフセットを更新（速度を遅く）
  frame_count = frame_count + 1
  if frame_count >= 60
    anim_offset = (anim_offset + 1) % 4
    frame_count = 0

    # アニメーションが更新される時だけ描画 - 上部の線 (y=25) - 右から左へ
    pattern1 = '  . ' * 20  # パターンを2倍の長さに
    shifted_pattern1 = pattern1[(4 - anim_offset) % 4, 40]  # 逆方向
    disp.fill_rect 0, 25, 240, 8, 0x000000
    disp.set_text_color 0xFFE4EB
    disp.draw_string shifted_pattern1, 0, 25

    pattern2 = '.   ' * 20
    shifted_pattern2 = pattern2[(4 - anim_offset) % 4, 40]  # 逆方向
    disp.set_text_color 0xFFB6C1
    disp.draw_string shifted_pattern2, 0, 25

    # アニメーション描画 - 下部の線 (y=70) - 左から右へ
    pattern3 = '   .' * 20
    shifted_pattern3 = pattern3[anim_offset % 4, 40]
    disp.fill_rect 0, 70, 240, 8, 0x000000
    disp.set_text_color 0xFFE4EB
    disp.draw_string shifted_pattern3, 0, 70

    pattern4 = ' .  ' * 20
    shifted_pattern4 = pattern4[anim_offset % 4, 40]
    disp.set_text_color 0xFFB6C1
    disp.draw_string shifted_pattern4, 0, 70
  end

  # draw input area - 桜テーマ (y=48, x=12から表示)
  code_display = " #{code}_"
  if code_display != prev_code_display || is_need_redraw_input
    disp.fill_rect 12, 48, 228, 8, 0x000000  # >の後ろをクリア
    disp.set_text_color 0xFFFDF0  # 淡いクリーム色
    disp.draw_string code_display, 12, 48
    prev_code_display = code_display
    is_need_redraw_input = false
  end

  # draw result area - 桜テーマ (y=93から)
  if res.to_s != prev_res || code_executed.to_s != prev_code_executed
    disp.fill_rect 12, 93, 228, 8, 0x000000  # 結果エリアクリア
    disp.set_text_color 0xFFE4EB  # 薄桜色（式表示）
    disp.set_text_color 0xFFFDF0  # 淡いクリーム色（結果）
    disp.draw_string " #{res}", 12, 93
    prev_res = res.to_s
    prev_code_executed = code_executed.to_s
  end

  # draw status area - 桜テーマ (y=125)
  status = is_shift ? '[SFT]' : '[NML]'
  if status != prev_status
    battery_voltage = bat_adc.read_voltage
    status_with_battery = "#{status} BAT:#{battery_voltage}V"
    disp.fill_rect 0, 125, 240, 10, 0x000000
    disp.set_text_color 0xFFC8DC  # 明るい桜色
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
