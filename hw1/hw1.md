# Assignment 1

## Text Analysis for Entity Resolution

Entity resolution is a common, yet difficult problem in data cleaning and integration.
In this assignment, we will use powerful and scalable text analysis techniques to perform entity resolution across two data sets of academic citations.

### Entity Resolution

Entity resolution, also known as record deduplication, is the process of identifying rows in one or more data sets that refer to the same real world entity.
To do meaningful analysis on aggragated data sets, duplicate records often need to be identified and dealt with (consolidated) to make sure the results are clean an unbiased.

But finding duplicates is a hard problem for several reasons.
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

Some utility code (and a template for part 1?) is also include in the zip file.  You can find these in `utils.py` and/or `template.py`.


## Part 1: ER as Text Similarity

A simple approach to entity resolution is to treat all records as strings and compute their similarity as some string distance function.
In this section, we will build some components for bag-of-words text-analysis, and use them to compute record similarity.

### Bags of Words

Bag of words techniques are simple but powerful approach to text analysis.
The idea is to treat strings, a.k.a. *documents*, as unordered collections of words, or *tokens*, i.e., as bags of words.
(Note on terminology: "token" is more general than what we ordinarily mean by "word" and includes things like numbers, acronyms, and other exotic things like word-roots and fixed-length character strings.
Bag of words techniques all apply to any sort of token.)

Tokens become the atomic unit of text comparison.
If we want to compare two documents, we count how many tokens they share in common.
If we want to search for document with keywords (think Google), then we turn the keywords into tokens and find documents that contain them.

The power of this approach is that it makes string comparisons insensitive to small differences that probably do not affect meaning much, for example, punctuation and exact word order.

#### Exercises

1. Implement the function `tokenize(str)` that takes a string and returns a list of tokens in the string.  `tokenize(str)` should split strings using the provided regular expression `splitter` in `utils.py`.

2. *Stopwords* are common words that do not contribute much to the content or meaning of a document (e.g., "the", "a", "is", "to", etc.).  Stopwords add noise to bag-of-words comparisons, so the are usually excluded.  Using the included dictionary `stopwords`, modify `tokenize(str)` so that it does not include stopwords in the tokens it returns.

3. Load the two small data sets, `DBLP_sample` and `ACM_sample`.  For each one build a dictionary of tokens, i.e., a dictionary where the record IDs are the keys, and the output of `tokenize` is the values.  How many tokens, total, are there in the two data sets?  Which ACM record has the biggest number of tokens?


### TF-IDF

Bag-of-words comparisons are not very good when all tokens are treated the same: some tokens are more important than others.
Weights give us a way to specify which tokens to favor.
With weights, when comparing documents, instead of counting common tokens, we sum up the weights of common tokens.

A good heuristic for assigning weights is called Term-Frequency, Inverse-Document-Frequency, or TF-IDF for short.
TF rewards tokens that appear many times in the same document.
It is computed as the frequency of a token in a document, that is, if document `d` contains 100 tokens and token `t` appears in `d` 5 times, then the TF weight of `t` in `d` is `5/100 = 1/20`.
The intuition for TF is that is a word occurs often in a document, then it is more important to the meaning of the document.

IDF rewards tokens that are rare overall in a data set.
So, "orange" will usually have a smaller IDF weight than "tangelo".
The intuition is that it is more significant if two documents share a rare word than a common one.
IDF weights are computed for each token by counting the number of documents that contain the token, then taking the recipricol of that number.

#### Exercises

4.  Implement `tf(tokens)` that takes a list of tokens and returns a dictionary mapping tokens to TF weights.

5.  Compute IDF weights for every unique token in the sample data sets.  Store them in a dictionary mapping token to IDF weight.

6.  Use the result of *5* to answer the following questions: FILL IN QUESTIONS!!!


### Cosine Similarity

* Describe cosine similarity (vector space model?)
* Finish the similarity function
* Use the similarity function to do ER on small data set
  * Do something with the results


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

