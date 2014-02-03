## Data cleaning and transformation with sed and awk

In this exercise we will learn how to use command line tools to transform
structured data into a clean CSV format.

### Data

Data analysts spend a large fraction of their time cleaning and prepraring data
for use.  The reason is simple:  given all the uses of data, it is natural for
it to be stored in a wide variety of formats, each with its own strengths and
weaknesses, and each appropriate to its particular application.  Rarely is data
found in the wild in exactly the proper format for a desired analysis tool, so
analysts must transform the data before loading it.  UNIX tools provide powerful
low-level support for cleaning and transformation operations, and can be
invaluable aids for rapid data ingest.

A common case is to work with data structured for presentation (e.g., in a wiki
table) instead of for analysis.

For this exercise, we will be working with one such example.  Download the file
[worldcup.txt](https://github.com/shivaram/datascience-labs/raw/master/lab1/data/worldcup.txt)
(e.g., with `curl` or `wget`).  This file contains the source of a wiki table
listing top finishers in the soccer (football?) World Cup since 1938.

The goal of this exercise is to transform the World Cup data file into a clean,
relational format:

```
nation,year,place
ITA,1938,1
...
```

To get there, we will need to remove syntactic cruft and pivot the data layout,
all of which can be done with two powerful tools: `sed` and `awk`.

### Regular Expressions

All of the operations we will be using are driven by regular expression pattern
matching.  Regular expressions are encoded patterns that can be matched against
a string.  The following is a quick gloss of regex (hopefully, you already have
some familiarity with regex, but if not at least you get to experience
[this](https://xkcd.com/208/) today.  More detail is easy to find online, for
example, in the [Awk
Manual](http://www.staff.science.uu.nl/~oostr102/docs/nawk/nawk_46.html).

#### Basic Expressions

The simplest regular expressions are alphanumeric strings, e.g., `/pattern/`,
will match the substring `"pattern"`.

#### Wild Cards and Quatifiers

The character `.` matches any character, so for example, the pattern `/.ed/`
will match all of `"sed"` and `"bed"` and `"1ed"`.

Quatifiers match the preceding expression multiple times.  There are several
quantifier expressions:

* `*` matches the preceding expression 0 or more times `+` matches the prededing
* expression 1 or more times `?` matches the preceding expression 0 or 1 times
* `{n}` matches the preceding expression `n` times, where `n` is a number

Combine wild cards with quantifiers to match arbitrary strings, e.g., `/.*ed/`
matches all of `"sed"`, `"ed"`, and `"foo bar baz ed"`.

#### Character Sets

Sometimes `.` is too powerful a wildcard, and what you really want is to match
some characters but not others.  Character sets let you do that.  A character
set is composed of square brackets around the characters you want to match.

For example, `[AEIOU]` matches any uppercase vowel.  You can also invert the
character set with a `^` after the `[`, i.e., `[^AEIOU]` matches anything BUT an
uppercase vowel.  For convenience, you may also list character ranges, e.g.,
`[A-Z]` or `[0-9]`.

#### Beginning and End of a String

You can match the start and end of a string with `^` and `$`, respectively.  As
we will see with `sed` and `awk`, regular expressions are often evaluated line
by line over a file, and in these instances `^` and `$` refer to the start and
end of the line.


### Removing Cruft with sed

Time to start cleaning the data!

The first thing to notice about `worldcup.txt` is that there is a lot of raw
HTML and wiki cruft in it.  Our first goal is to remove the extraneous bits.

`sed` (short for "Stream EDitor") is a tool for modifying text files
programmatically and line by line.  We will use two important `sed` commands to
clean up the file.

#### Substitution

Substitution with `sed` is essentially an efficient way to perform search and
replace on a file with regular expressions.  You can run a substitute command as
follows:

``` cat in.txt | sed 's/regexPattern/replacementString/flags' > out.txt ```

Lets use substitution to start removing cruft from our file.  First, we will
focus on lines that contain country codes (these look like `BRA`, `ITA`, `GER`,
etc.).  These lines all look something like the following:

``` |bgcolor=#FFF68F|{{fb|BRA}} ```

Here, the only piece of actual data is `BRA`, so we want to delete the rest.
The cruft is a fixed string in all cases so we can use two simple regex
patterns:

``` cat worldcup.txt | sed 's/^|bgcolor=#FFF68F|{{fb|//' | sed 's/}}$//' ```

#### Line Deletion

Another useful `sed` command is line deletion, i.e., delete all lines that match
a regex pattern.  The syntax is:

``` cat in.txt | sed '/regexPattern/d' > out.txt ```

In `worldcup.txt` there are many lines that do not contain content.  We will use
`sed` delete to remove the footer lines from the file.  These lines all look
something like the following:

``` :<div id="1">''<nowiki>*</nowiki> = hosts'' ```

We can use their common prefix, `":<div id="`, to match them.  Then we run:

``` cat worldcup.txt | sed '/^:<div id="/d' ```

#### Task

Use `sed` substitution and deletion to remove meaningless content from
`worldcup.txt`.  In the end, you should have a file that only contains the
relevant data: country codes, years, and in what place teams finished.

Note that some of the important data is not encoded explicitly in the file.
(For example, how do you know in what years a team finished in 3rd place?)  Be
careful while cleaning the file not to lose any of the meaningful content from
the data!  In the following section, we will use `awk` to make all of the data
explicit.


### awk

By this point, we have a relatively clean data file, but its structure is
complex.  Some lines have country codes on them while others have years.  Some
lines with years list multiple years while others list just one (or none!).

We will use `awk` to transform the data into a simple CSV format.  `awk` is a
Turing complete scripting language with an interface especially good at
processing files line by line.  A brief introduction to `awk` follows, and as
always, for more information try `man awk` or Google for the `awk` manual (or
other great resources) online.

The basic structure of an `awk` script is as follows:

``` awk 'BEGIN { init } /pattern1/ { pattern1expr } /pattern2/ { pattern2expr }
...  END { finish }' file.txt ```

Here, the code contained between curly braces are code expressions to be
evaluated when the preceding pattern is matched.  `awk` loops over the input
file line by line, and when the current line matches a pattern, the code
belonging to that pattern is run.  `BEGIN` and `END` are special patterns that
match the beginning and end of the file, respectively (they are optional).

To demonstrate a simple script, we will count the number of countries listed in
`worldcup.txt`.  We assume country codes are all on their own line at this
point.  Then we run:

``` awk 'BEGIN { i = 0 } /^[A-Z]{3}$ { ++i } END { print i }' clean_worldcup.txt
```

This script initializes a counter, `i`, at the start, increments it on every
line matching our country code pattern, and uses the `print` statement to write
the counter to `stdout` after the file is done.

Keep in mind that each code block can run any number of statements (including
loops and conditionals) separated by semicolons.  The syntax is C-like and
should be familiar; type `man awk` to get a concise overview of available
commands and functions.

#### Fields

`awk` is especially good at parsing structured (i.e., record-like) lines of
text.  Invoking `awk` with the flag `-F<regex>` sets the "field separator" to
the provided regular expression (usually just a comma or tab character).  With
the field separator set, fields in a matched line become available to script
code as the variables `$1, $2, ...`.  So the following two commands are
equivalent:

``` awk -F, '/.*/ { print $2 }' file cut -d, -f2 file ```

NB: the variable `$0` contains the text of the entire current line.

#### Task

Write an `awk` script (or small set of scripts) to transform your cleaned
`worldcup.txt` data file into a CSV with the following structure:

``` nation,year,place ITA,1938,1 ...  ```



