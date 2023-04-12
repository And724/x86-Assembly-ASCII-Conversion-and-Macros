# x86-Assembly-String-Primitives-and-Macros
Project features the designing, implementation, and calling of low-level I/O procedures and implements the use of macros. The overall goal of this program was to read a user's numeric input and validate it the hard way. This means the user's numeric input is read as a string (ASCII) and is then converted to an integer. There are no uses of ReadInt, ReadDec, WriteInt, or WriteDec and all conversions are done using LODSB and/or STOSB. Additionally, the entire program is broken into smaller procedures and all values, aside from any global values, are passed via the stack and the stack frame is cleaned up by the called procedure. 

# Usage
