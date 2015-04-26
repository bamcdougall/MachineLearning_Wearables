---
title: "ReadMe:  Transformation of Experimental Data to Analytic, Tidy Data"
author: "Brendan McDougall"
date: "Sunday, April 26, 2015"
output: html_document
---

##Abstract

This GitHub Repository contains four primary files:

- ReadMe.md (this file);
- run_analysis.R;
- CodeBook.md;
- SEC_GalaxyS_ATdata.txt.

##File Description

**ReadMe** provides a high-level description of the files in this GitHub Repository.

**run_analysis.R** is the R-script file that post-processes the special dataset provided by UCI
Machine Learning Repository that is titled:
**Human Activity Recognition Using Smartphones Data Set**

**CodeBook.md** provides a sparse summary of background information required to post-process 
experimental data provided by UCI Machine Learning Repository using **run_analysis.R**.

**SEC_GalaxyS_ATdata.txt** shows the first 20 lines from the 5940 lines of observables.

##Use of **run_analysis.R**

Execution of **run_analysis.R** requires that the script be in the top directory of the 
*Human Activity Recognition Using Smartphones Data Set*.  If unchanged from the extracted
zip archive, then the directory name is **UCI HAR Dataset**.  The script is not a function, so
the entire script is *sourced* to the Console.  The final output file **SEC_GalaxyS_ATdata.txt**
is sent to the current working directory.
