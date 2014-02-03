## File System Analytics

In this exercise, we'll use some of the basic aggregation facilities provided by UNIX tools to do some analysis of the file system on your virtual machine.

### Navigating the file system

If you've used the terminal on a Linux or UNIX system before, you're probably very familiar with `ls` and `cd`. `ls` has some great extended options, but accessing the results of `ls` programmatically can be difficult, and tasks like getting access to filenames recursively can be tricky.

#### find

`find` provides a much more flexible interface to listing files that match a particular criteria than ls. In particular, you can easily restrict yourself to a particular type of file (e.g. directories or plain files), recurse indefinitely or to some maximum depth, dispatch an action on file names that match your search, or pair the results of find with a command like `xargs` to do something further with files that match your filters.

For example, the command `find /usr/bin -type f -name 'py*'` will tell find to list the names of all ordinary files (not directories) in `/usr/bin` whose names start with "py".

#### du

Understanding what files/directories are using space on the file system is a problem that people have been dealing with since UNIX was invented. According to the man page for `du`, "A `du` command appeared in Version 1 AT&T UNIX."

`du` allows you to report usage statistics of files and directories in your system. By default, it reports its usage statistics at the block level, but the `-h` option provides this information in a human-readable format. It's worth noting that the results of `du` 

Try running `du -hs *` in your home directory to see where the space is going. 

Now, think about how you could output the results of `find` into `du` to do reporting on a subset of files.

### Sorting

The `sort` command is pretty powerful. In most systems, it is implemented via an external merge sort - this makes it possible to sort really huge files, even ones that don't fit into memory, in a reasonable amount of time. 

By default, `sort` will sort items lexicographically, but with the `-n` flag it will sort in numeric order. This means that 10100 will come after 2 in numeric sort order, even though it precedes 2 lexicographically. In recent versions of GNU `sort`, the command also takes a `-h` parameter, which allows you to sort human-readable numbers (like file sizes produced by du -h).

Additionally, `sort` will let you select exactly which fields of a file you want to sort on (by default, it's the whole line), and in which order these fields should be sorted.

### Exercises
1. What are the 10 biggest directories in /usr/lib on your virtual machine?
2. What are the 5 biggest directories in /home/saasbook, including hidden folders?

## Log processing with command line tools

In the next exercise we will look at tools which you can use to quickly analyze
and explore text files.

### Downloading data files

The first step in data analyis is typically downloading data files that you need
to process. While typically you might be used to downloading files using your web
browser, this gets tedious when you want to download many files or if you want to
automate the process. There are UNIX command line tools which you can use in
such cases to download files

#### curl
`curl` is a commonly used tool for downloading files. It is typically available
on most UNIX machines and should be installed in your VM. To download a file
using curl you need to run `curl <url> -o <filename>`. For example to download
the course webpage in html you can run something like

    curl http://amplab.github.io/datascience-sp14/index.html -o index.html

This will download the course webpage and save it to a file named `index.html`
in your current directory. This is of course a simple example of how you can use
`curl`. You can find other options using and features in the curl manpage using
`man curl`.

#### wget
Another popular command line tool used for downloading data is `wget`. You might
have seen this used in other examples or used it before. For simple use cases
you can use either tool and we will use `curl` for this exercise. A more detailed
comparison of the two tools can be seen at
[curl vs wget](http://daniel.haxx.se/docs/curl-vs-wget.html).

### HTTP Logs Dataset

For this exercise we will be using HTTP access logs from the 1998 Soccer
WorldCup website. The [complete
dataset](http://ita.ee.lbl.gov/html/contrib/WorldCup.html) contains
around 1.3 billion requests, and we will use a subset of it for this exercise.
As a first step download the sample dataset using `curl` from
`https://github.com/shivaram/datascience-labs/raw/master/lab1/wc_day6_1_log.tar.bz2` .

The dataset has been compressed to make the download finish faster. To get the
raw data unzip the downloaded file by running `tar -xf <filename>`. (Note: `tar`
is also a very frequently used command line tool and you can learn more about it
with `man tar`).

Having extracted the file, take a look at how the file looks by running `less
wc_day6_1.log`. This will show you the first few lines of the file and you can
page through the file using the arrow keys. You will notice that each hit or
access to the website is logged as in a new line in the log file. The format of
each line is in the [Common Log File
Format](https://en.wikipedia.org/wiki/Common_Log_Format) and this format is used
by most HTTP servers. In this case the data has been annonymized and lets take a
look at one line from the file to explain each field

    57 - - [30/Apr/1998:22:00:48 +0000] "GET /english/images/lateb_new.gif HTTP/1.0" 200 1431

In the above line `57` refers to a `clientID`, a unique integer identifier for the
client that issued the request. While this field typically contains the IP
address, for privacy reasons it has been replaced with an integer. The next two
fields are `-` and say that the fields are missing from the log entry. Again
these correspond to `user-identifier`, `userid` and have been removed for
privacy reasons.

The next field is the time at which the request was made and this is followed by
the HTTP request that was made. In this example a GET request was made for
`lateb_new.gif`. The next field is the HTTP return code and in this example it
is 200. You can find a list of codes and their meanings from
[w3](http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html). The last field is
the size of the object returned to the client, measured in bytes.

### Exploring the dataset

Before we get to the exercises, lets explore the dataset and try out some basic
commands.

First up lets count how many visits the website got. To do this we just count
the number of lines in the file by running `wc -l wc_day6_1.log`. Your output
should look like

    1193353 wc_day6_1.log

We can do something more interesting by finding out how many times the ticketing
webpage was visited. To do this you could run

    grep tickets wc_day6_1.log | wc -l
    29818

However the above line counts images and other elements which have the word
`tickets` in their path. (Note: You can verify this using `less`). To restrict
it to just `html` pages, you can use a regular expression

    grep "tickets.*html" wc_day6_1.log | wc -l
    2776

We can also prune the dataset to only look at interesting parts of it. For
example we can just look at the first 50 URLs and their sizes using the `head`
and `cut` command.

    head -50 wc_day6_1.log | cut -d ' ' -f 7,10

In the above command the `-d` flag denotes what delimiter to use and `-f` stats
what fields should be selected from the line. Try out different delimiter and
field values to see how `cut` works.

Finally we can see how many unique URLs are there in the first 50 visits. To do
this we could run something like

    head -50 wc_day6_1.log | cut -d ' ' -f 7 | sort | uniq | wc -l

Here we use the tool `uniq` to only count unique URLs. Note that the input to
`uniq` should be sorted, so we use `sort` before calling `uniq`.

### Exercises

Now use the above tools to answer some analysis questions

1. What are the 5 most frequently visited URLs ?
2. Print the number of requests that had HTTP return code 404. Next break down
number of 404 requests by date (i.e how many on 30th April and how many on 1st
May).
3. Print the number of HTTP requests that had return code 200 in each hour of
the day.
4. Finally print the top 5 URLs which did not have return code 200.
5. 


