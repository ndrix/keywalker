# KeyWalker

KeyWalker is a simple script that allows to create keyboard pattern passwords, such as "123qweasd" or "1qaz@WSX3edc".  If you think they look secure, type them on a keyboard and you'll see the pattern.

Many times, users use keyboard sequences, which may include special and numeric characters to create secure passwords.  While these may be non-dictionary words, they are predictable, and I hope this script helps you in generating them.

## Usage
--min N: generate passwords of at least N characters

--max M: generate passwords of maximum M characters

--range N-M: generate passwords between N and M characters (both inclusive).

--shift: press the "shift" key to create uppercase, or special characters

## Modes
### Parallel Sequence
This mode provides a series of parallel sequences in the same direction.  This generates passwords such as "345etrdfg".

### ZigZag
Like "1qazxsw2", this mode provides a "back and forth" sequence on a keyboard
while shifting rows / columns.  

### Snake
*Not done yet!*
This generates a snake alike movement, following a particular pattern.  This may create a password such as 1qazxsw2345.

## Feedback
Feel free to contact me for any code updates or comments: me@michaelhendrickx.com
