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
a string.  The following is a quick gloss of regex.  More detail is easy to find
online, for example, in the [Awk
Manual](http://www.staff.science.uu.nl/~oostr102/docs/nawk/nawk_46.html).

#### Basic Expressions

The simplest regular expressions are alphanumeric strings, e.g., `/pattern/`,
will match the substring `"pattern"`.

#### Wild Cards and Quatifiers

The character `.` matches any character, so for example, the pattern `/.ed/` will
match all of `"sed"` and `"bed"` and `"1ed"`.

Quatifiers match the preceding expression multiple times.  There are several
quantifier expressions:

* `*` matches the preceding expression 0 or more times
* `+` matches the prededing expression 1 or more times
* `?` matches the preceding expression 0 or 1 times
* `{n}` matches the preceding expression `n` times, where `n` is a number

Combine wild cards with quantifiers to match arbitrary strings, e.g., `/.*ed/`
matches all of `"sed"`, `"ed"`, and `"foo bar baz ed"`.

#### Character Sets

Sometimes `.` is too powerful a wildcard, and what you really want is to match
some characters but not others.  Character sets let you do that.  A character
set is composed of square brackets around the characters you want to match.

For example, `[AEIOU]` matches any uppercase vowel.  You can also invert the
character set with a `^` after the `[`, i.e., `[^AEIOU]` matches anything BUT an
uppercase vowel.

#### Beginning and End of a String

You can match the start and end of a string with `^` and `$`, respectively.
As we will see with `sed` and `awk`, regular expressions are often evaluated
line by line over a file, and in these instances `^` and `$` refer to the start
and end of the line.


### sed

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

```
cat in.txt | sed 's/regexPattern/replacementString/flags' > out.txt
```



#### Line Deletion

### awk





