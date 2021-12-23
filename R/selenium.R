#' Start Selenium Server
#'
#' Start Selenium Server
#' @param port Port to run on
#' @param version what version of Selenium Server to run. Default = "latest"
#'     which runs the most recent version. To see other version currently
#'     sourced run binman::list_versions("seleniumserver")
#' @param chromever what version of Chrome driver to run. Default = "latest"
#'     which runs the most recent version. To see other version currently
#'     sourced run binman::list_versions("chromedriver"), A value of NULL
#'     excludes adding the chrome browser to Selenium Server.
#' @param geckover what version of Gecko driver to run. Default = "latest"
#'     which runs the most recent version. To see other version currently
#'     sourced run binman::list_versions("geckodriver"), A value of NULL
#'     excludes adding the firefox browser to Selenium Server.
#' @param phantomver what version of PhantomJS to run. Default = "2.2.1"
#'     which runs the most recent stable version. To see other version
#'     currently
#'     sourced run binman::list_versions("phantomjs"), A value of NULL
#'     excludes adding the PhantomJS headless browser to Selenium Server.
#' @param iedrver what version of IEDriverServer to run. Default = "latest"
#'     which runs the most recent version. To see other version currently
#'     sourced run binman::list_versions("iedriverserver"), A value of NULL
#'     excludes adding the internet explorer browser to Selenium Server.
#'     NOTE this functionality is Windows OS only.
#' @param check If TRUE check the versions of selenium available and the
#'    versions of associated drivers (chromever, geckover, phantomver,
#'    iedrver). If new versions are available they will be downloaded.
#' @param verbose If TRUE, include status messages (if any)
#' @param retcommand If TRUE return only the command that would be passed
#'     to \code{\link[processx]{process}}
#' @param ... pass additional options to the driver
#'
#' @return Returns a list with named elements \code{process}, \code{output},
#'     \code{error}, \code{stop}, and \code{log}.
#'     \code{process} is the object from calling \code{\link[processx]{process}}.
#'     \code{output} and \code{error} are the functions reading the latest
#'     messages from "stdout" and "stderr" since the last call whereas \code{log}
#'     is the function that reads all messages.
#'     Lastly, \code{stop} call the \code{kill} method in
#'     \code{\link[processx]{process}} to the kill the \code{process}.
#' @export
#'
#' @examples
#' \dontrun{
#' selServ <- selenium()
#' selServ$output()
#' selServ$stop()
#' }

selenium <- function(port = 4567L,
                     version = "latest",
                     chromever = "latest",
                     geckover = "latest",
                     iedrver = NULL,
                     phantomver = "2.1.1",
                     check = TRUE,
                     verbose = TRUE,
                     retcommand = FALSE,
                     ...){
  assert_that(is_integer(port))
  assert_that(is_string(version))
  assert_that(is_string_or_null(chromever))
  assert_that(is_string_or_null(geckover))
  assert_that(is_string_or_null(phantomver))
  assert_that(is_logical(retcommand))
  assert_that(is_logical(verbose))
  javapath <- java_check()
  seleniumcheck <- selenium_check(verbose, check = check)
  selplat <- seleniumcheck[["platform"]]
  seleniumversion <- selenium_ver(selplat, version)
  eopts <- list(...)
  jvmargs <- c(Reduce(c, eopts[names(eopts) == "jvmargs"]))
  selargs <- c(Reduce(c, eopts[names(eopts) == "selargs"]))
  jvmargs <- selenium_check_drivers(chromever, geckover, phantomver,
                                    iedrver, check = check,
                                    verbose = verbose, jvmargs)
  # should be the last JVM argument
  jvmargs[["jar"]] <- "-jar"
  jvmargs[["selpath"]] <- shQuote(seleniumversion[["path"]])
  # Selenium JAR arguments
  selargs[["portswitch"]] <- "-port"
  selargs[["port"]] <- port
  if(retcommand){
    return(paste(c(javapath, jvmargs, selargs), collapse = " "))
  }
  pfile <- pipe_files()
  seleniumdrv <- spawn_tofile(javapath, args = c(jvmargs, selargs),
                              pfile[["out"]], pfile[["err"]])
  if(isFALSE(seleniumdrv$is_alive())){
    err <- paste0(readLines(pfile[["err"]]), collapse = "\n")
    stop("Selenium server  couldn't be started\n", err)
  }
  startlog <- generic_start_log(seleniumdrv, # poll = 10000L,
                                outfile = pfile[["out"]],
                                errfile = pfile[["err"]])
  if(length(startlog[["stderr"]]) >0){
    if(any(grepl("Address already in use", startlog[["stderr"]]))){
      kill_process(seleniumdrv)
      stop("Selenium server signals port = ", port, " is already in use.")
    }
  }else{
    warning(
      "No output to stderr yet detected. Please check ",
      "log and that process is running manually."
      )
  }
  log <- as.environment(startlog)
  list(
    process = seleniumdrv,
    output = function(timeout = 0L){
      infun_read(seleniumdrv, log, "stdout", timeout = timeout,
                 outfile = pfile[["out"]], errfile = pfile[["err"]])
    },
    error = function(timeout = 0L){
      infun_read(seleniumdrv, log, "stderr", timeout = timeout,
                 outfile = pfile[["out"]], errfile = pfile[["err"]])
    },
    stop = function(){kill_process(seleniumdrv)},
    log = function(){
      infun_read(seleniumdrv, log,
                 outfile = pfile[["out"]], errfile = pfile[["err"]])
      as.list(log)
    }
  )
}

java_check <- function(){
  javapath <- Sys.which("java")
  if(identical(unname(javapath), "")){
    stop("PATH to JAVA not found. Please check JAVA is installed.")
  }
  javapath
}

selenium_check <- function(verbose, check = TRUE){
  syml <- system.file("yaml", "seleniumserver.yml", package = "wdman")
  if(check){
    if(verbose) message("checking Selenium Server versions:")
    process_yaml(syml, verbose)
  }
  selplat <- "generic"
  list(yaml = syml, platform = selplat)
}

selenium_ver <- function(platform, version){
  selver <- binman::list_versions("seleniumserver")[[platform]]
  selver <- if(identical(version, "latest")){
    as.character(max(semver::parse_version(selver)))
  }else{
    mtch <- match(version, selver)
    if(is.na(mtch) || is.null(mtch)){
      stop("version requested doesnt match versions available = ",
           paste(selver, collapse = ","))
    }
    selver[mtch]
  }
  seldir <- normalizePath(
    file.path(app_dir("seleniumserver"), platform, selver)
  )
  selpath <- list.files(seldir,
                        pattern = "selenium-server-standalone",
                        full.names = TRUE)
  if(file.access(selpath, 1) < 0){
    Sys.chmod(selpath, '0755')
  }
  list(version = selver, dir = seldir, path = selpath)
}

selenium_check_drivers <- function(chromever, geckover, phantomver,
                                   iedrver, check, verbose, jvmargs){
  if(!is.null(chromever)){
    chromecheck <- chrome_check(verbose, check)
    cver <- chrome_ver(chromecheck[["platform"]], chromever)
    jvmargs[["chrome"]] <- sprintf(
      "-Dwebdriver.chrome.driver=%s",
      shQuote(cver[["path"]])
    )
  }
  if(!is.null(geckover)){
    geckocheck <- gecko_check(verbose, check)
    gver <- gecko_ver(geckocheck[["platform"]], geckover)
    jvmargs[["gecko"]] <- sprintf(
      "-Dwebdriver.gecko.driver=%s",
      shQuote(gver[["path"]])
    )
  }
  if(!is.null(phantomver)){
    phantomcheck <- phantom_check(verbose, check)
    pver <- phantom_ver(phantomcheck[["platform"]], phantomver)
    jvmargs[["phantom"]] <- sprintf(
      "-Dphantomjs.binary.path=%s",
      shQuote(pver[["path"]])
    )
  }
  if(!is.null(iedrver)){
    iecheck <- ie_check(verbose, check)
    iever <- ie_ver(iecheck[["platform"]], iedrver)
    jvmargs[["internetexplorer"]] <- sprintf(
      "-Dwebdriver.ie.driver=%s",
      shQuote(iever[["path"]])
    )
  }
  jvmargs
}
