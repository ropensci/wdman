wdman
==========================
| CRAN version       | Travis build status   | Appveyor build status   | Coverage |
| :-------------: |:-------------:|:-------------:|:-------------:|
| [![](http://www.r-pkg.org/badges/version/wdman)](https://CRAN.R-project.org/package=wdman) | [![Build Status](https://travis-ci.org/johndharrison/binman.svg?branch=master)](https://travis-ci.org/johndharrison/wdman) | [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/johndharrison/wdman?branch=master&svg=true)](https://ci.appveyor.com/project/johndharrison/wdman) | [![codecov](https://codecov.io/gh/johndharrison/wdman/branch/master/graph/badge.svg)](https://codecov.io/gh/johndharrison/wdman)|

## Installation

You can install wdman from github with:


```
# install.packages("devtools")
devtools::install_github("johndharrison/wdman")
```
The package can also be installed from CRAN:

```
install.packages("wdman")
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
* [PhantomJS binary](http://phantomjs.org/download.html)
* [geckodriver](https://github.com/mozilla/geckodriver/releases)
* [iedriver](https://github.com/SeleniumHQ/selenium/wiki/InternetExplorerDriver)

Associated with the above are five functions to download/manage the binaries:

* selenium(...)
* chrome(...)
* phantomjs(...)
* gecko(...)
* iedriver(...)


## Example

As an example we show how one would run the Selenuium standalone binary
as a process:

### Running the Selenium binary

The binary takes a port argument which defaults to `port = 4567L`. There
are a number of optional arguments to use a particular version of the
binaries related to browsers selenium may control. By default the
`selenium` function will look to use the latest version of each. 

```
selServ <- selenium(verbose = FALSE)
selServ$process

## Process Handle
## command   : /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java -Dwebdriver.chrome.driver=/home/john/.local/share/binman_chromedriver/linux64/2.27/chromedriver -Dwebdriver.gecko.driver=/home/john/.local/share/binman_geckodriver/linux64/0.13.0/geckodriver -Dphantomjs.binary.path=/home/john/.local/share/binman_phantomjs/linux64/2.1.1/phantomjs-2.1.1-linux-x86_64/bin/phantomjs -jar /home/john/.local/share/binman_seleniumserver/generic/3.0.1/selenium-server-standalone-3.0.1.jar -port 4567
## system id : 105698
## state     : running
```

The selenium function returns a list of functions and a handle representing 
the running process.

The returned `output`, `error` and `log` functions give access to the 
stdout/stderr pipes and the cumulative stdout/stderr messages rerspectively.

```
selServ$log()

## $stderr
##  [1] "10:28:57.720 INFO - Selenium build info: version: '3.0.1', revision: '1969d75'"                                                                                          
##  [2] "10:28:57.721 INFO - Launching a standalone Selenium Server"                                                                                                              
##  [3] "2017-01-17 10:28:57.736:INFO::main: Logging initialized @186ms"                                                                                                          
##  [4] ""                                                                                                                                                                        
##  [5] "10:28:57.780 INFO - Driver provider org.openqa.selenium.ie.InternetExplorerDriver registration is skipped:"                                                              
##  [6] " registration capabilities Capabilities [{ensureCleanSession=true, browserName=internet explorer, version=, platform=WINDOWS}] does not match the current platform LINUX"
##  [7] "10:28:57.781 INFO - Driver provider org.openqa.selenium.edge.EdgeDriver registration is skipped:"                                                                        
##  [8] " registration capabilities Capabilities [{browserName=MicrosoftEdge, version=, platform=WINDOWS}] does not match the current platform LINUX"                             
##  [9] "10:28:57.781 INFO - Driver class not found: com.opera.core.systems.OperaDriver"                                                                                          
## [10] "10:28:57.782 INFO - Driver provider com.opera.core.systems.OperaDriver registration is skipped:"                                                                         
## [11] "Unable to create new instances on this machine."                                                                                                                         
## [12] "10:28:57.782 INFO - Driver class not found: com.opera.core.systems.OperaDriver"                                                                                          
## [13] "10:28:57.783 INFO - Driver provider com.opera.core.systems.OperaDriver is not registered"                                                                                
## [14] "10:28:57.784 INFO - Driver provider org.openqa.selenium.safari.SafariDriver registration is skipped:"                                                                    
## [15] " registration capabilities Capabilities [{browserName=safari, version=, platform=MAC}] does not match the current platform LINUX"                                        
## [16] "2017-01-17 10:28:57.815:INFO:osjs.Server:main: jetty-9.2.15.v20160210"                                                                                                   
## [17] ""                                                                                                                                                                        
## [18] "2017-01-17 10:28:57.836:INFO:osjsh.ContextHandler:main: Started o.s.j.s.ServletContextHandler@2ef5e5e3{/,null,AVAILABLE}"                                                
## [19] ""                                                                                                                                                                        
## [20] "2017-01-17 10:28:57.849:INFO:osjs.ServerConnector:main: Started ServerConnector@724af044{HTTP/1.1}{0.0.0.0:4567}"                                                        
## [21] ""                                                                                                                                                                        
## [22] "2017-01-17 10:28:57.851:INFO:osjs.Server:main: Started @301ms"                                                                                                           
## [23] ""                                                                                                                                                                        
## [24] "10:28:57.852 INFO - Selenium Server is up and running"                                                                                                                   
## 
## $stdout
## character(0)
```

The `stop` function sends a signal that terminates the process:

```
selServ$stop()

## [1] TRUE
```

### Available browsers

By default the `selenium` function includes paths to chromedriver/geckodriver/
phantomjs so that the Chrome/Firefox and PhantomJS browsers are available 
respectively. All versions (chromever, geckover etc) are given as "latest". 
If the user passes a value of NULL for any driver it will be excluded.

On Windows operating systems the option to included the Internet Explorer
driver is also given. This is set to `iedrver = NULL` so not ran by default.
Set it to `iedrver = "latest"` or a specific version string to include it
on your Windows.

### Issues with Windows and Firefox/GeckoDriver

To run the binaries related to the Selenium/webdriver projects `wdman` 
uses the R package `subprocess`. Currently the windows version of this
package uses blocking pipes when it instantiates a process. This causes 
issues with firefox/geckodriver when called from selenium. A "shim" is 
required as the stderr pipe is blocking and firefox/geckodriver waits for 
the pipe to free. 

An example of implementing this shim for windows can be seen in the 
[Rselenium](https://github.com/ropensci/RSelenium) package. The 
`rsDriver` function currently implements such a shim. It basically 
clears the error pipe so the firefox/geckodriver can finish its startup.

## Further details

For further details please see the package vignette:

[wdman: Basics](http://rpubs.com/johndharrison/wdman-Basics)
