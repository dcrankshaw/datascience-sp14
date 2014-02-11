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


The zip file includes the following files:
* **DBLP.csv**, 2617 citations of academic CS papers from [DBLP][DBLP]
* **DBLP_sample.csv**, 200 records sampled from above
* **ACM.csv**, 2295 citations of papers
* **ACM_samples.csv**, 200 records sampled from above
* **stopwords.txt**, a list of common English words
* **Template.ipynb**, a template IPython notebook to get you started

### Deliverables

Complete the all the exercises below and turn in a write up in the form of an IPython notebook.
The write up should include your code, answers to exercise questions, and plots of results.
A template notebook is provided with the assignment to get you started.


## Part 1: ER as Text Similarity

A simple approach to entity resolution is to treat all records as strings and compute their similarity with a string distance function.
In this section, we will build some components for bag-of-words text-analysis, and use them to compute record similarity.

### 1.1 Bags of Words

Bag-of-words is a conceptually simple yet powerful approach to text analysis.
The idea is to treat strings, a.k.a. **documents**, as *unordered collections* of words, or **tokens**, i.e., as bags of words.

> **Note on terminology**: "token" is more general than what we ordinarily mean by "word" and includes things like numbers, acronyms, and other exotica like word-roots and fixed-length character strings.
> Bag of words techniques all apply to any sort of token, so when we say "bag-of-words" we really mean "bag-of-tokens," strictly speaking.

Tokens become the atomic unit of text comparison.
If we want to compare two documents, we count how many tokens they share in common.
If we want to search for documents with keyword queries (this is what Google does), then we turn the keywords into tokens and find documents that contain them.

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


### 1.2 TF-IDF

Bag-of-words comparisons are not very good when all tokens are treated the same: some tokens are more important than others.
Weights give us a way to specify which tokens to favor.
With weights, when we compare documents, instead of counting common tokens, we sum up the weights of common tokens.

A good heuristic for assigning weights is called "Term-Frequency/Inverse-Document-Frequency," or TF-IDF for short.
TF rewards tokens that appear many times in the same document.
It is computed as the frequency of a token in a document, that is, if document `d` contains 100 tokens and token `t` appears in `d` 5 times, then the TF weight of `t` in `d` is `5/100 = 1/20`.
The intuition for TF is that if a word occurs often in a document, then it is more important to the meaning of the document.

IDF rewards tokens that are rare overall in a data set.
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


### 1.3 Cosine Similarity

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

1.  Implement `cosine_similarity(string1, string2)` that takes two strings and computes their cosine similarity.
Use `tokenize`, `tf`, and the IDF weights from exercise **1.2.2** for extracting tokens and assigning them weights.
**Note**:  You may treat the norm of every string to be 1; since the citation records all have roughly equal length, normalization will not affect the results much.

**TODO** Setting norms to 1 makes the final scores not be in [0, 1]... Will this be confusing??

2.  Now we can finally do some entity resolution.
For every DBLP citation record in the sample data set, use `cosine_similarity` to compute its similarity to every record in the ACM sample set.
Answer some questions... maybe make a plot... maybe do a quick threshold analysis??  **TODO** COME UP WITH DELIVERABLES FOR THIS EXERCISE.


## Part 2: Scalable ER

In the previous section we built a text similarity function and used it for small scale entity resolution.  Our implementation is limited by its quadratic run time complexity, and is not practical for even modestly sized data sets.  In this section we will implement a more scalable algorithm and use it to do entity resolution on the full data set.

### Inverted Indices

To improve our ER algorithm from **Part 1**, we should begin by analyzing its running time.
In particular, the algorithm above is quadratic in the size of the input data sets in two ways.
First, we did a lot of redundant computation of tokens and weights, since each record was reprocessed every time it was compared.
Second, we made qudratically many token comparisons between records.

The first source of quadratic overhead can be eliminated with precomputation and look-up tables, but the second source is a little more tricky.
In the worst case, every token in every record in one data set exists in every record in the other data set, and therefore every token makes a nonzero contribution to the cosine similarity.
In this case, token comparison is unavoidably quadratic.

But in reality most records have nothing (or very little) in common.
Moreover, it is typical for a record in one data set to have at most one duplicate record in the other data set (this is the case assuming each data set has been de-duplicated against itself).
In this case, the output is linear in the size of the input and we can hope to achieve linear running time.

An **inverted index** is a data structure that will allow us to avoid making quadratically many token comparisons, and instead compare only the tokens we know match across two records.

In text search, a *forward index* maps documents in a data set to the tokens they contain.  An inverted index reverses the relationship.  It maps each token in the data set to the list of documents that contain the token.  With an inverted index we can quickly look up, for each token, what records match on that token.

#### Exercises

> **Note**: For this section, use the complete DBLP and ACM data sets, not the samples

1. To address the overhead of recomputing tokens and token-weights, build look up tables that map records in both data sets to their tokens and weights.

2. Build inverted indices of both data sources.

3. We are now in position to efficiently perform ER on the full data sets.
Use the inverted indices to build a dictionary of record pairs mapped to tokens common to both records in the pair.
How big is this data structure?
Compare its size to that of the input data sets.

4. Use the data structure computed above to build a dictionary to store our final similarity results, i.e., it should map record pairs to cosine similarity scores.

**TODO** ADD SOME QUESTIONS 

### Analysis

Now we have an authoritative list of record-pair similarities, but we need a way to use those similarities to decide if two records are duplicates or not.
The simplest approach is to pick a threshold.
Pairs whose similarity is above the threshold are declared duplicates, and pairs below the threshold are declared distinct.
To decide where to set the threshold we need to understand what kind of errors result at different levels.
If we set the threshold too low, we get more **false positive**, that is, record-pairs we say are duplicates that in reality are not.
If we set the threshold too high, we get more **false negatives**, that is, record-pairs that really are duplicates but that we miss.

ER algorithms are evaluated by the common metrics from information retrieval and search called **precision** and **recall**.
Precision asks of all the record-pairs marked duplicates, what fraction are true duplicates?
Recall asks of all the true duplicates in the data, what fraction did we successfully find?
As with false positives and false negatives, there is a trade-off between precision and recall.
A third metric, called **F-measure**, takes the harmonic mean of precision and recall to measure overall goodness in a single value.

![The formula for F-measure](http://upload.wikimedia.org/math/9/9/1/991d55cc29b4867c88c6c22d438265f9.png)

#### Exercises

1. What is the relationship between false-positives and -negatives on the one hand and precision and recall on the other?

2. Plot precision, recall, and F-measure for different threshold values (use a set of values that covers the whole similarity space).

3. Using the plot, pick the optimal threshold value and argue for why it is optimal.
If false-positives are considered much worse than false-negatives, how does that change your answer?

### Additional Exercises

1. **Pruning common tokens**.
In *Part 1* we eliminated stopwords, that is, common words with little content value, from our tokenization function.
The stopwords we used were common terms from the English language in general.
We can get similar value by eliminating *domain specific stopwords*, that is, tokens that appear very frequently in our data sets.
    * Identify the top ten most frequent terms in our data.
    What are they?
    Argue that they can be safely removed from our similarity computations.
    * Remove these tokens from your inverted indices, then rebuild the data structure from exercise 2.1.3.
    How much smaller is this dictionary with the top ten terms removed?
    * Regerate similarity results for the full data set, and recreate the plot from exercise 2.2.2.
    How have results changed?
    * When is it a good idea to remove domain specific stopwords?
    How do you know how many to remove?

2. **Multi-attribute similarity**.
Until now, we have treated the citation records as unstructured strings.
Recompute similarities for each individual attribute, then combine them, then repeat the precision/recall analysis.
**TODO** IS THIS TOO MUCH TO ASK?  ALSO, NEEDS TO BE FLESHED OUT


