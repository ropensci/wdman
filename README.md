wdman
==========================
| CRAN version       | Travis build status   | Appveyor build status   | Coverage |
| :-------------: |:-------------:|:-------------:|:-------------:|
|  | [![Build Status](https://travis-ci.org/johndharrison/binman.svg?branch=master)](https://travis-ci.org/johndharrison/wdman) | [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/johndharrison/wdman?branch=master&svg=true)](https://ci.appveyor.com/project/johndharrison/wdman) | [![codecov](https://codecov.io/gh/johndharrison/wdman/branch/master/graph/badge.svg)](https://codecov.io/gh/johndharrison/wdman)|

## Installation

You can install wdman from github with:


``` r
# install.packages("devtools")
devtools::install_github("johndharrison/wdman")
```

## Introduction

`wdman` (Webdriver Manager) is an R package that allows the user to manage
the downloading/running of third party binaries relating to the webdriver/selenium
projects. The package was inspired by a similar node package 
[webdriver-manager](https://www.npmjs.com/package/webdriver-manager).

The checking/downloading of binaries is handled by the [binman](https://github.com/johndharrison/binman) package and the
running of the binaries as processes is handled by the [subprocess](https://github.com/lbartnik/subprocess) package.


The `wdman` package currently manages the following binaries:

* [Selenium standalone binary](http://selenium-release.storage.googleapis.com/index.html)
* [chromedriver](https://chromedriver.storage.googleapis.com/index.html)
* [PhamtonJS binary](http://phantomjs.org/download.html)
* [geckodriver](https://github.com/mozilla/geckodriver/releases)
* [iedriver](https://github.com/SeleniumHQ/selenium/wiki/InternetExplorerDriver)
