# portfolio

A small portfolio, demonstrating some of my experience with various data analysis methods and programming languages. Also includes some of my projects/papers/presentations from grad school, to give a taste of my scientific writing. All code and writing is entirely my own, unless noted otherwise.

## Contents

* C - CS50 - Pset4
  * My problem set code for week 4 of the free, online Harvard computer science course, cs50
  * This week focused on managing memory in C, and the problem set focused on handling image data
  * helpers.c contains a series of "filters" for images, from grayscale, sepia, blur, and a simple edge-detection algorithm
  * recover.c reads a given binary memory stream and recovers any jpeg images that are found in the stream

* Python - Nand2tetris - VMTranslator
  * My project code for the free, online course [nand2tetris](https://www.nand2tetris.org/), which implements a simple, virtual 16-bit computer platform (called Hack), from basic boolean logic gates up through a functioning operating system
  * This folder contains my Python code for the computer's VM translator (main code in VMTranslator.py), the back-end of the computer's compiler, which takes the virtual machine code of the Jack programming language, and translates it to the assembly language that runs on the Hack platform
  * More of my project files for this course can be seen in my [nand2tetris repo](https://github.com/mda2894/nand2tetris)

* R - Data Mining - Final Project
  * Contains code, paper, and presentation slides for my final project in CPH 636: Data Mining in Public Health
  * The goal of the project was to take a publicly available dataset (preferably related to public health) and apply a few different statistical learning methods we learned in the course
  * The dataset I chose utilized features extracted from retinal images to predict whether an ophthalmic patient had diabetic retinopathy or not
  * The data mining techniques I used were penalized logistic regression, generalized additive models, and extremely randomized trees (similar to a random forest)
  * I also used a few different model ensembling techniques to try to get better prediction than any one method alone

* R - Dissertation Work
  * Contains my literature review and code for the first part of my dissertation research into a nonparametric regression technique developed by my advisor (original publication [here](https://doi.org/10.1002/cjs.10104))
  * The R code file here is my own software implementation of the method, based on the description of the method laid out in the paper linked above
  * This code would have been the start of my own R package based on the extensions of this method developed by myself and other students of my advisor

* R - Movie Barcodes - Weekend Project
  * A weekend project of mine, inspired by [this reddit post](https://www.reddit.com/r/dataisbeautiful/comments/f773m1/oc_visualization_of_the_colour_palette_or_barcode/)
  * The original post created "movie barcodes" from the highest grossing movies of all time, using Python
  * I wanted to see if I could implement the same thing in R. It turned out to be more complicated than I originally imagined, and had to use [ffmpeg](https://ffmpeg.org/) to get a directory of frames from the film first, then process the frames one by one in R
  * The Barcodes subdirectory contains the actual movie barcodes I created, including two different types of barcode (one using uniform vertical lines of color, and another using heterogeneous vertical lines of color) for all 8 Harry Potter movies as well as a recent favorite of mine, Knives Out

* SAS - Survival Analysis - Final Project
  * My final paper for STA 635, the survival analysis course I took during my Master's coursework
  * Just to demonstrate my familiarity with SAS, as well as this particular area of statistical methodology
  * I would go on to receive a TA position for a different survival analysis course, based on my work in this course

* SQL - CS50 - Pset7
  * My problem set code for week 7 of the free, online Harvard computer science course, cs50
  * This week focused on SQL, and how to use SQL in Python
  * movies.sql is a series of queries made on an SQL database consisting of IMDB movie data, including movie ratings, actors, and directors
  * The two python files are for reading data on Hogwarts students from a CSV into an SQL database (in import.py) and then printing out a roster of formatted student information from that database, based on a given Hogwarts house (in roster.py)
