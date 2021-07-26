-- Copyright (c) 2018. tangzx(love.tangzx@qq.com)
--
-- Licensed under the Apache License, Version 2.0 (the "License"); you may not
-- use this file except in compliance with the License. You may obtain a copy of
-- the License at
--
-- http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
-- WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
-- License for the specific language governing permissions and limitations under
-- the License.

---
--- The type *string* represents immutable sequences of bytes. Lua is 8-bit
--- clean: strings can contain any 8-bit value, including embedded zeros
--- ('`\0`'). Lua is also encoding-agnostic; it makes no assumptions about
--- the contents of a string.
---@class string
string = {}

---
--- Returns the internal numerical code of the `i`-th character of `s`, or **nil**
--- if the index is out of range. If i is absent, then it is assumed to be 1.
--- i may be negative.
---
--- Note that numerical codes are not necessarily portable across platforms.
---@overload fun(s:string):number
---@param s string
---@param i number
---@return number
function string.byte(s, i) end

---
--- Receives zero or more integers. Returns a string with length equal to
--- the number of arguments, in which each character has the internal numerical
--- code equal to its corresponding argument.
---
--- Note that numerical codes are not necessarily portable across platforms.
---@return string
function string.char(...) end

---
--- Returns a binary representation of the given function, so that a later
--- `loadstring` on that string returns a copy of the function. `function` must be a
--- Lua function without upvalues.
---@param func function
---@return string
function string.dump(func) end

---
--- Looks for the first match of `pattern` in the string `s`. If it finds a
--- match, then `find` returns the indices of `s` where this occurrence starts
--- and ends; otherwise, it returns **nil**. A third, optional numerical
--- argument `init` specifies where to start the search; its default value is 1
--- and can be negative. A value of **true** as a fourth, optional argument
--- `plain` turns off the pattern matching facilities, so the function does a
--- plain "find substring" operation, with no characters in `pattern` being
--- considered "magic". Note that if `plain` is given, then `init` must be given
--- as well.
---
--- If the pattern has captures, then in a successful match the captured values
--- are also returned, after the two indices.
---
--- Refer to the Lua manual's [section on patterns](https://www.lua.org/manual/5.0/manual.html#pm)
--- for more details. Take particular note of `()` empty captures which capture
--- a number rather than a string.
---@overload fun(s: string, pattern: string, init: number): nil | (number, number, (number | string)...)
---@overload fun(s: string, pattern: string): nil | (number, number, (number | string)...)
---@param s string
---@param pattern string
---@param init number
---@param plain boolean
---@return nil | (number, number, (number | string)...)
function string.find(s, pattern, init, plain) end

---
--- Returns a formatted version of its variable number of arguments following
--- the description given in its first argument (which must be a string). The
--- format string follows the same rules as the ISO C function `sprintf`. The
--- only differences are that the options/modifiers `*`, `h`, `L`, `l`, `n`, and
--- `p` are not supported and that there is an extra option, `q`.
---
--- The `q` option formats booleans, nil, numbers, and strings in a way that the
--- result is a valid constant in Lua source code. Booleans and nil are written
--- in the obvious way (`true`, `false`, `nil`). Floats are written in
--- hexadecimal, to preserve full precision. A string is written between double
--- quotes, using escape sequences when necessary to ensure that it can safely
--- be read back by the Lua interpreter. For instance, the call
---
--- string.format('%q', 'a string with "quotes" and \n new line') may produce
--- the string:
---
--- > "a string with \"quotes\" and \
--- > new line"
---
--- The options `A`, `a`, `E`, `e`, `f`, `g`, `G` and `g` all expect a number as
--- argument. Options `c`, `d`, `i`, `o`, `u`, `X`, and `x` expect an integer.
--- When Lua is compiled with a C89 compiler, options `A` and `a` (hexadecimal
--- floats) do not support any modifier (flags, width, length).
---
--- Option `s` expects a string; if its argument is not a string, it is
--- converted to one following the same rules of `tostring`. If the option
--- has any modifier (flags, width, length), the string argument should not
--- contain embedded zeros.
---@param formatstring string
---@return string
function string.format(formatstring, ...) end

--- Returns an iterator function that, each time it is called, returns the next
--- captures from pattern pat over string s.
---
--- If pat specifies no captures, then the whole match is produced in each call.
---
--- As an example, the following loop
---
--- >  s = "hello world from Lua"
--- >  for w in string.gfind(s, "%a+") do
--- >    print(w)
--- >  end
--- will iterate over all the words from string s, printing one per line. The next
--- example collects all pairs key=value from the given string into a table:
--- >  t = {}
--- >  s = "from=world, to=Lua"
--- >  for k, v in string.gfind(s, "(%w+)=(%w+)") do
--- >    t[k] = v
--- > end
---
--- Refer to the Lua manual's [section on patterns](https://www.lua.org/manual/5.0/manual.html#pm)
--- for more details. Take particular note of `()` empty captures which capture
--- a number rather than a string.
---@param s string
---@param pat string
---@return fun(): (number | string)...
function string.gfind(s, pat) end

---
--- Returns a copy of `s` in which all occurrences of the pattern `pat` have
--- been replaced by a replacement string specified by `repl`. `gsub` also
--- returns, as a second value, the total number of substitutions made.
---
--- If `repl` is a string, then its value is used for replacement. Any sequence
--- in `repl` of the form `%n`, with `n` between 1 and 9, stands for the value
--- of the `n`-th captured substring (see below).
---
--- If `repl` is a function, then this function is called every time a match
--- occurs, with all captured substrings passed as arguments, in order; if the
--- pattern specifies no captures, then the whole match is passed as a sole
--- argument. If the value returned by this function is a string, then it is
--- used as the replacement string; otherwise, the replacement string is the
--- empty string.
---
--- The optional last parameter `n` limits the maximum number of substitutions
--- to occur. For instance, when `n` is 1 only the first occurrence of `pat` is
--- replaced.
---
--- Here are some examples:
--- `x = string.gsub("hello world", "(%w+)", "%1 %1")`
--- `--> x="hello hello world world"`
--- `x = string.gsub("hello world", "%w+", "%0 %0", 1)`
--- `--> x="hello hello world"`
--- `x = string.gsub("hello world from Lua", "(%w+)%s*(%w+)", "%2 %1")`
--- `--> x="world hello Lua from"`
--- `x = string.gsub("home = $HOME, user = $USER", "%$(%w+)", os.getenv)`
--- `--> x="home = /home/roberto, user = roberto"`
--- `x = string.gsub("4+5 = $return 4+5$", "%$(.-)%$", function (s)`
---  >> return loadstring(s)()
---  > end)
--- `--> x="4+5 = 9"`
--- `local t = {name="lua", version="5.0"}
--- `x = string.gsub("$name_$version.tar.gz", "%$(%w+)", function (v)`
--- `--> x="lua_5.0.tar.gz"`
---
--- Refer to the Lua manual's [section on patterns](https://www.lua.org/manual/5.0/manual.html#pm)
--- for more details. Take particular note of `()` empty captures which capture
--- a number rather than a string.
---@overload fun(s: string, pattern: string, repl: string | fun: string): string, number
---@param s string
---@param pattern string
---@param repl string | fun: string
---@param n number
---@return string, number
function string.gsub(s, pattern, repl, n) end

---
--- Receives a string and returns its length. The empty string `""` has
--- length 0. Embedded zeros are counted, so `"a\000bc\000"` has length 5.
---@param s string
---@return number
function string.len(s) end

---
--- Receives a string and returns a copy of this string with all uppercase
--- letters changed to lowercase. All other characters are left unchanged. The
--- definition of what an uppercase letter is depends on the current locale.
---@param s string
---@return string
function string.lower(s) end

---
--- Returns a string that is the concatenation of `n` copies of the string
--- `s` separated by the string `sep`. The default value for `sep` is the empty
--- string (that is, no separator). Returns the empty string if n is not
--- positive.
---
--- Note that it is very easy to exhaust the memory of your machine with a
--- single call to this function.
---@overload fun(s:string, n:number):string
---@param s string
---@param n number
---@param sep string
---@return string
function string.rep(s, n, sep) end

---
--- Returns the substring of `s` that starts at `i` and continues until
--- `j`; `i` and `j` can be negative. If `j` is absent, then it is assumed to
--- be equal to -1 (which is the same as the string length). In particular,
--- the call `string.sub(s,1,j)` returns a prefix of `s` with length `j`, and
--- `string.sub(s, -i)` (for a positive i) returns a suffix of `s` with length
--- `i`.
---
--- If, after the translation of negative indices, `i` is less than 1, it is
--- corrected to 1. If `j` is greater than the string length, it is corrected to
--- that length. If, after these corrections, `i` is greater than `j`, the
--- function returns the empty string.
---@overload fun(s:string, i:number):string
---@param s string
---@param i number
---@param j number
---@return string
function string.sub(s, i, j) end

---
--- Receives a string and returns a copy of this string with all lowercase
--- letters changed to uppercase. All other characters are left unchanged. The
--- definition of what a lowercase letter is depends on the current locale.
---@param s string
---@return string
function string.upper(s) end
