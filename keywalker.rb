#!/usr/bin/ruby
# KeyWalker:
# generate a lot of keyboard sequence passwords
# (c) 2015 Michael Hendrickx - @ndrix

# this thing creates passwords such as: !@#qweasd, 1qazxsw2 and 0okmnji9
# if they look random, type them on a keyboard.

require 'getoptlong'

puts "## -[ KeyWalker ]---"
puts "## by @ndrix\n\n"

def displayHelp()
  puts "Options:"
  puts "  --help | -h : this screen"
  puts "Password generation options"
  puts "  --min N     : at least N characters" 
  puts "  --max M     : at most  M characters" 
  puts "  --range N-M : between N and M chars (inclusive)" 
  puts "  --shift     : puts uppercase characters (A..Z, !@#, ...)" 
  puts "  --digits    : ensures there are numeric values present"
  puts "  --special   : ensures there are special chars present"
  # puts "  --complex   : combines shift, digits and spacial chars"
end

opts = GetoptLong.new(
  [ '--help', '-h',     GetoptLong::NO_ARGUMENT ],
  [ '--min', '-m',      GetoptLong::REQUIRED_ARGUMENT ],
  [ '--max', '-M',      GetoptLong::REQUIRED_ARGUMENT ],
  [ '--range', '-r',    GetoptLong::REQUIRED_ARGUMENT ],
  [ '--shift', '-s',    GetoptLong::NO_ARGUMENT ],
  [ '--digits', '-d',   GetoptLong::NO_ARGUMENT ],
  [ '--special', '-S',  GetoptLong::NO_ARGUMENT ],
  [ '--upper', '-u',    GetoptLong::NO_ARGUMENT ]
)

@minlen = 1
@maxlen = 10
@has_digits = false
@has_special = false
@has_upper = false

@useshift = false


opts.each do |opt, arg|
  case opt
    when '--help'
      displayHelp()
      exit
    when '--min'
      @minlen = arg.to_i
    when '--max'
      @maxlen = arg.to_i
    when '--range'
      r = arg.split("-")
      @minlen = r[0].to_i || @minlen
      @maxlen = r[1].to_i || @maxlen
    when '--shift'
      @useshift = true
    when '--upper'
      @has_upper = true
    when '--digits'
      @has_digits = true
    when '--special'
      @has_special = true
  end
end

if @maxlen < @minlen
  puts "Minimum length should be less or equal to maximum length"
  exit
end

# print a summary

if @maxlen == @minlen
  puts "## of exactly #{@maxlen} characters"
else
  puts "## generating passwords between #{@minlen} and #{@maxlen} characters"
end

# all ok, munch some pw's
SHIFT = 4

# directions
DIR_LEFT_TO_RIGHT        =  0
DIR_RIGHT_TO_LEFT       = 1
DIR_DIAGONAL_RIGHT_DOWN = 2
DIR_DIAGONAL_RIGHT_UP   = 3 
DIR_DIAGONAL_LEFT_DOWN   = 4
DIR_DIAGONAL_LEFT_UP     = 5

@kb = [] 
# us keyboard layout
@kb << %w( 1 2 3 4 5 6 7 8 9 0 - = )
@kb << %w( q w e r t y u i o p [ ] \\ )
@kb << %w( a s d f g h j k l ; ')
@kb << %w( z x c v b n m , . / )
@kb << %w( ! @ # $ % ^ & * ( ) _ + )
@kb << %w( Q W E R T Y U I O P { } | )
@kb << %w( A S D F G H J K L : " )
@kb << %w( Z X C V B N M < > ? )

@currkey = { col: 0, row: 0 }
@shifton = false

def validpw(pw)
  return false if pw.size < @minlen or pw.size > @maxlen
  return false if @has_special and /[^a-zA-Z0-9]/.match(pw).nil?
  return false if @has_digits and /[\d]/.match(pw).nil?
  return false if @has_upper and /[A-Z]/.match(pw).nil?
  return true
end


# recursive function that does X characters in Y direction
# ex: qwe , #$% or okm
# dir: 0 -> ltr, 1 -> rtl, 2 -> \ down, 3 -> \ up, 4 -> / down, 5 -> / up.
def seq(row = 0, col = 0, len = 3, dir = 0)
  ret = ""
  len.times do |i|
    case dir
      when DIR_LEFT_TO_RIGHT
        @currkey[:row] = row;   
        @currkey[:col] = col + i
      when DIR_RIGHT_TO_LEFT
        @currkey[:row] = row;   
        @currkey[:col] = col - i
      when DIR_DIAGONAL_RIGHT_DOWN
        @currkey[:row] = row+i; 
        @currkey[:col] = col 
      when DIR_DIAGONAL_RIGHT_UP
        @currkey[:row] = row-i; 
        @currkey[:col] = col+i
      when DIR_DIAGONAL_LEFT_DOWN
        @currkey[:row] = row+i; 
        @currkey[:col] = col-i 
      when DIR_DIAGONAL_LEFT_UP
        @currkey[:row] = row-i; 
        @currkey[:col] = col
    end
    ret += getkey()
  end
  ret
end

# get the current key from the keyboard
def getkey
  # TODO: make sure this is part of the keyboard
  nil if @currkey[:row] < 0 or @currkey[:col] < 0
  nil if @shifton.eql?(false) && @currkey[:row] > SHIFT
  nil if @shifton && @currkey[:row] < SHIFT
  nil if @currkey[:col] > @currkey[:row].size
  @kb[@currkey[:row]+(@shifton ? SHIFT : 0)][@currkey[:col]].to_s
end

def parallelSequence(num, len, dir, jump, shift = false, offset_x = 0, offset_y = 0)
  ret = ""
  start = [offset_x, offset_y]
  num.times do |idx|
    ret += seq(start[0], start[1], len, dir)
    start[0] += jumpKey(jump)[0]
    start[1] += jumpKey(jump)[1]
  end
  puts ret if validpw(ret)

  if shift
    fmtst = "%0"+num.to_s+"b"
    1.upto((2**num)-1).each do |n| 
      ret = ""
      start = [offset_x, offset_y]
      # create all possible "shifts" into a matrix
      # use shift when we hit '1'
      possibilities = (fmtst % n).split(//)
      possibilities.each do |poss|
        @shifton = poss.eql?('1')
        ret += seq(start[0], start[1], len, dir)
        start[0] += jumpKey(jump)[0]
        start[1] += jumpKey(jump)[1]
      end
      puts ret if validpw(ret)
      @shifton = false
    end
  end
end

# zigzag: this does a sequence, but reverses the 2nd
def zigzag(num, len, dir, jump, shift = false, offset_x = 0, offset_y = 0)
  ret = ""
  start = [offset_x, offset_y]
  num.times do |idx|
    r = seq(start[0], start[1], len, dir)
    r.reverse! if idx % 2 == 1 # the opposite dir is a reverse
    ret += r
    start[0] += jumpKey(jump)[0]
    start[1] += jumpKey(jump)[1]
  end
  puts ret if validpw(ret)

  if shift
    fmtst = "%0"+num.to_s+"b"
    1.upto((2**num)-1).each do |n| 
      ret = ""
      start = [offset_x, offset_y]
      possibilities = (fmtst % n).split(//)
      possibilities.each do |poss|
        @shifton = poss.eql?('1')
        r = seq(start[0], start[1], len, dir)
        r.reverse! if n % 2 == 1 # the opposite dir is a reverse
        ret += r
        start[0] += jumpKey(jump)[0]
        start[1] += jumpKey(jump)[1]
      end
      puts ret if validpw(ret)
      @shifton = false
    end
  end
end
  
# jumpKey - the direction dictates row, col
def jumpKey(dir)
  case dir
    when DIR_LEFT_TO_RIGHT
      return 0, 1
    when DIR_RIGHT_TO_LEFT
      return 0, -1
    when DIR_DIAGONAL_RIGHT_DOWN
      return 1, 0 
    when DIR_DIAGONAL_RIGHT_UP
      return -1, 1 
    when DIR_DIAGONAL_LEFT_DOWN
      return 1, -1 
    when DIR_DIAGONAL_LEFT_UP
      return -1, 0 
  end # case
end

# turn one direction right
def turnClockWise(dir)
  [ DIR_DIAGONAL_RIGHT_DOWN, DIR_DIAGONAL_LEFT_UP, 
    DIR_RIGHT_TO_LEFT, DIR_LEFT_TO_RIGHT,
    DIR_RIGHT_TO_LEFT, DIR_LEFT_TO_RIGHT ][dir]
end

def turnCounterClockWise(dir)
  [ DIR_DIAGONAL_LEFT_UP, DIR_DIAGONAL_RIGHT_DOWN, 
    DIR_LEFT_TO_RIGHT, DIR_RIGHT_TO_LEFT, 
    DIR_LEFT_TO_RIGHT, DIR_RIGHT_TO_LEFT ][dir]
end

def halfcircle(num, len, dir, shift = false)
  start = [0,0]
  ret = ""
  @currkey[:row] = start[0]
  @currkey[:col] = start[1]
  num.times do |idx|
    ret += seq(@currkey[:row], @currkey[:col], len-1, dir)
    @currkey[:row] += jumpKey(dir)[0]
    @currkey[:col] += jumpKey(dir)[1]
    dir = turnClockWise(dir)
  end
  ret += getkey()
  puts ret if validpw(ret)
end

# qwe234%^&

dirs = [ DIR_LEFT_TO_RIGHT, DIR_RIGHT_TO_LEFT, DIR_DIAGONAL_RIGHT_DOWN,
         DIR_DIAGONAL_RIGHT_UP, DIR_DIAGONAL_LEFT_DOWN, DIR_DIAGONAL_LEFT_UP]
maxshift = [ 8, 8, 4, 4, 4, 4 ]


for dir in dirs do 
  puts "## -- #{dir} --"
  for i in 0..maxshift[dir] do
    #parallelSequence(3, 4, dir, turnClockWise(dir), true, 0, i) ;
    #parallelSequence(3, 4, dir, turnCounterClockWise(dir), true, 0, i) ;
  end # i
end # dir in dirs

# normal sequences
for i in 0..8 do
  for num in (@minlen-1)..(@maxlen) do
    for len in (@minlen-1)..(@maxlen) do
      next if num*len < @minlen or num*len > @maxlen
      if num*len >= @minlen and num*len <= @maxlen
        parallelSequence(num, len, DIR_LEFT_TO_RIGHT, DIR_DIAGONAL_RIGHT_DOWN, @useshift, 0, i) ;
      end
    end
  end
end
exit
for i in 0..6 do
  parallelSequence(3, 4, DIR_LEFT_TO_RIGHT, DIR_DIAGONAL_RIGHT_DOWN, true, 1, i) ;
end
for i in 0..8 do
  parallelSequence(3, 4, DIR_DIAGONAL_RIGHT_DOWN, DIR_LEFT_TO_RIGHT, true,  0, i) ;
end
for i in 0..6 do
  parallelSequence(3, 4, DIR_DIAGONAL_RIGHT_UP, DIR_LEFT_TO_RIGHT, true,  3, i) ;
end
for i in 3..9 do
  parallelSequence(3, 4, DIR_DIAGONAL_LEFT_DOWN, DIR_LEFT_TO_RIGHT, true,  0, i) ;
end
for i in 0..7 do
  parallelSequence(3, 4, DIR_DIAGONAL_LEFT_UP, DIR_LEFT_TO_RIGHT, true, 3, i) ;
end

puts "----------zigzag--------------"
puts "------=== normal start ==-----------"
for i in 0..8 do
  zigzag(3, 4, DIR_LEFT_TO_RIGHT, DIR_DIAGONAL_RIGHT_DOWN, true, 0, i) ;
end
puts "------=== normal end ==-----------"
for i in 0..6 do
  zigzag(3, 4, DIR_DIAGONAL_RIGHT_UP, DIR_LEFT_TO_RIGHT, true, 3, i) ;
end


puts "----------half--------------"
halfcircle(3, 4, DIR_LEFT_TO_RIGHT, false)
halfcircle(4, 3, DIR_LEFT_TO_RIGHT, false)
