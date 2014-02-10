# Assignment 1

## Overview: Entity Resolution and Text Analysis

Entity resolution is a common, yet difficult problem in data cleaning and integration.
In this assignment, we will use powerful and scalable text analysis techniques to perform entity resolution across two data sets of academic citations.

### Entity Resolution

Entity resolution, also known as record deduplication, is the process of identifying rows in one or more data sets that refer to the same real world entity.
To do meaningful analysis on aggragated data sets, duplicate records often need to be identified and consolidated to ensure clean and unbiased results.

Finding duplicates is a hard problem for several reasons.
First, the criteria for identifying duplicates are often vague and impossible to encode in rules.
Second, from a purely computational perspective, the problem is quadratic in size compared to the size of the inputs: naively, all pairs of records need to be compared to find all the duplicates. 
In this assignment, we will begin to address both challenges.

### Data

The data we will be working with is a pair of collections of citations of academic papers, one from [DBLP](#LINK-ME!) and the other from the ACM.
You can download the data files from `LINK-HERE!!!`.
For part 1 of the exercise we will be working with a sample of the data to make processing time faster.
The smaller versions of the data sets have names that end with `_sample`.

TODO:
* Is data CSV or Pickle? (Do preprocessing or have them do it?)

Include:
* DBLP, DBLP_sample
* ACM, ACM_sample
* utils.py
* stopwords

Some utility code (and a template for part 1?) is also include in the zip file.  You can find these in `utils.py` and/or `template.py`.

### Deliverables

Complete the all the exercises below and turn in a write up in the form of an IPython notebook.
The write up should include your code, answers to exercise questions, and plots of results.
A template notebook is provided with the assignment to get you started.


## Part 1: ER as Text Similarity

A simple approach to entity resolution is to treat all records as strings and compute their similarity with a string distance function.
In this section, we will build some components for bag-of-words text-analysis, and use them to compute record similarity.

### Bags of Words

Bag-of-words is a conceptually simple yet powerful approach to text analysis.
The idea is to treat strings, a.k.a. **documents**, as *unordered collections* of words, or **tokens**, i.e., as bags of words.

> **Note on terminology**: "token" is more general than what we ordinarily mean by "word" and includes things like numbers, acronyms, and other exotic things like word-roots and fixed-length character strings.
> Bag of words techniques all apply to any sort of token.

Tokens become the atomic unit of text comparison.
If we want to compare two documents, we count how many tokens they share in common.
If we want to search for document with keywords (think Google), then we turn the keywords into tokens and find documents that contain them.

The power of this approach is that it makes string comparisons insensitive to small differences that probably do not affect meaning much, for example, punctuation and word order.

#### Exercises

1. Implement the function `tokenize(string)` that takes a string and returns a list of tokens in the string.
`tokenize` should split strings using the provided regular expression `splitter` in `utils.py`.

2. *Stopwords* are common words that do not contribute much to the content or meaning of a document (e.g., "the", "a", "is", "to", etc.).
Stopwords add noise to bag-of-words comparisons, so the are usually excluded.
Using the included dictionary `data['stopwords']`, modify `tokenize` so that it does not include stopwords in the tokens it returns.

3. Load the two small data sets, `DBLP_sample` and `ACM_sample`.
For each one build a dictionary of tokens, i.e., a dictionary where the record IDs are the keys, and the output of `tokenize` is the values.
How many tokens, total, are there in the two data sets?
Which ACM record has the biggest number of tokens?


### TF-IDF

Bag-of-words comparisons are not very good when all tokens are treated the same: some tokens are more important than others.
Weights give us a way to specify which tokens to favor.
With weights, when we compare documents, instead of counting common tokens, we sum up the weights of common tokens.

A good heuristic for assigning weights is called "Term-Frequency/Inverse-Document-Frequency," or TF-IDF for short.
TF rewards tokens that appear many times in the same document.
It is computed as the frequency of a token in a document, that is, if document `d` contains 100 tokens and token `t` appears in `d` 5 times, then the TF weight of `t` in `d` is `5/100 = 1/20`.
The intuition for TF is that is a word occurs often in a document, then it is more important to the meaning of the document.

IDF rewards tokens that are rare overall in a data set.
So, "orange" will usually have a smaller IDF weight than "tangelo".
The intuition is that it is more significant if two documents share a rare word than a common one.
IDF weight for a token *t* in a set of documents *U* is computed as follows: find *n*, the number of documents in *U* that contain *t*, and *N*, the total number of documents in *U*, then *IDF = N/n*.
Note that *n/N* is the frequency of *t* in *U*, and *N/n* is the inverse frequency.

In pactice, we work with the log of the TF and IDF weights described above, so that we can sum the weights of multiple tokens.

**TODO**: Mention total weight?  Mention local vs. global weights?

#### Exercises

4.  Implement `tf(tokens)` that takes a list of tokens and returns a dictionary mapping tokens to TF weights.

5.  Compute IDF weights for every unique token in the sample data sets.  Store them in a dictionary mapping token to IDF weight.

6.  Use the result of *5* to answer the following questions: FILL IN QUESTIONS!!!

**TODO**: Add some sanity check numbers??


### Cosine Similarity

Now we are ready to do text comparisons in a formal way.
The metric of string distance we will use is called **cosine similarity**.
In brief, we will treat each document as a vector in some high dimensional space, and then to compare two documents we compute the cosine of the angle between their two document vectors.
This is easier than it sounds.

The first question to answer is how do we represent documents as vectors?
The answer we already do this, in fact, with weighted bag-of-words.
Just treat each unique token as a dimension, and treat token weights as magnitudes in their respective token dimensions.
For example, suppose we use simple counts as weights, and we want to interpret the string "Hello, world!  Goodbye, world!" as a vector.
Then in the "hello" and "goodbye" dimensions the vector has value 1, in the "world" dimension it has value 2, and it is zero in all other dimensions.

Next question is given two vectors how do we find the cosine of the angle between them?
Recall the formula for the dot product of two vectors:

![Dot product FTW](http://upload.wikimedia.org/math/f/5/b/f5bc23b26d095a4040d25dd340554f5d.png)

We can rearrange terms and solve for the cosine to find it is simply the normalized dot product of the vectors.
With our vector model, the dot product and norm computations are simple functions of the bag-of-words document representations, so we now have a formal way to compute similarity:

![How to compute cosine similarity](http://upload.wikimedia.org/math/f/3/6/f369863aa2814d6e283f859986a1574d.png)

#### Exercises

7.  Implement `cosine_similarity(string1, string2)` that takes two strings and computes their cosine similarity.
Use `tokenize`, `tf`, and the IDF weights from exercise **5** for extracting tokens and assigning them weights.
**Note**:  You may treat the norm of every string to be 1; since the citation records all have roughly equal length, normalization will not affect the results much.

8.  Now we can finally do some entity resolution.
For every DBLP citation record in the sample data set, use `cosine_similarity` to compute its similarity to every record in the ACM sample set.
Answer some questions... maybe make a plot... maybe do a quick threshold analysis??  **TODO** COME UP WITH DELIVERABLES FOR THIS EXERCISE.


## Part 2: Scalable ER

In the previous section we built a text similarity function and used it for small scale entity resolution.  Our implementation is limited by its quadratic run time complexity, and is not practical for even modestly sized data sets.  In this section we will implement a more scalable algorithm and use it to do entity resolution on the full data set.

### Inverted Indices

* What and why
* Build inverted indices on the data sources
* Build look up tables for: TF, [others?]
* Questions...

### ER on the Full Data

* Use inverted index to compute token-wise list of pairs
* Aggregate results to get full pairwise similarity table

### Analysis

* Discuss false positives and false negatives
* Setting a similarity threshold
* Compute (plot?) precision, recall, and f-measure for different thresholds


## Part 3: Multi-attribute ER

In this section, we will use the structure of our data sets to improve the accuracy of our 

