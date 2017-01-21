# wdman 0.2.2

* Moved unix based systems to write pipes to file.
* Fixed issue with shell escaping paths.

# wdman 0.2.1

* Added a read_pipes internal function for windows drivers
* Fixed an issue with Windows and blocking pipes. A batch file is now ran
  with stdout/stderr piped to file.

# wdman 0.2.0

* Added verbose arguments to the driver functions
* Import semver for parsing semantic versions
* Added basic vignette on operation.
* Set default PhantomJS version to 2.1.1 (2.5.0-beta runs old ghostdriver
  currently).
* Added a check argument to all driver functions.
* Added tests and refactored code.

# wdman 0.1.5

* Use binman::sem_ver for versioning.
* Remove the v in gecko versions.
* Improve logging in selenium function.

# wdman 0.1.4

* Added tests for driver functions.

# wdman 0.1.3

* Added selenium function.
* Added iedriver function.

# wdman 0.1.2

* Added phantomjs function.

# wdman 0.1.1

* Added chrome function.
* Added gecko function.

# wdman 0.1.0

* Added a `NEWS.md` file to track changes to the package.



