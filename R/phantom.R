#' Start phantomjs
#'
#' Start phantomjs in webdriver mode
#' @param port Port to run on
#' @param version what version of phantomjs to run. Default = "latest"
#'     which runs the most recent version. To see other version currently
#'     sourced run binman::list_versions("phantomjs")
#' @param loglevel Set phantomjs log level [values: fatal, error,
#'     warn, info, config, debug, trace]
#'
#' @return Returns a list with named elements process, output, error, stop
#'     and log. process is the output from calling \code{\link{spawn_process}}
#'     output, error and stop are functions calling
#'     \code{\link{process_read}}, \code{\link{process_read}} with "stderr"
#'     pipe and \code{\link{process_kill}}  respectively  on process.
#'     log is a function which returns the contents of the log file.
#' @export
#'
#' @examples
#' \dontrun{
#' pjs <- phantomjs()
#' pjs$output()
#' pjs$stop()
#' }

phantomjs <- function(port = 4567L, version = "latest",
                      loglevel = c('INFO', 'ERROR', 'WARN', 'DEBUG')){
  assert_that(is_integer(port))
  assert_that(is_string(version))
  loglevel <- match.arg(loglevel)
  phantomcheck <- phantom_check()
  phantomplat <- phantomcheck[["platform"]]
  phantomversion <- phantom_ver(phantomplat, version)
  args <- c()
  tFile <- tempfile(fileext = ".txt")
  args[["webdriver"]] <- sprintf("--webdriver=%s", port)
  args[["log-path"]] <- sprintf("--webdriver-logfile=%s", tFile)
  args[["log-level"]] <- sprintf("--webdriver-loglevel=%s", loglevel)
  phantomdrv <- subprocess::spawn_process(
    phantomversion[["path"]], arguments = args
  )
  if(!is.na(subprocess::process_return_code(phantomdrv))){
    stop("PhantomJS couldn't be started",
         subprocess::process_read(phantomdrv, "stderr"))
  }
  list(
    process = phantomdrv,
    output = function(timeout = 0L){
      subprocess::process_read(phantomdrv, timeout = timeout)
    },
    error = function(timeout = 0L){
      subprocess::process_read(phantomdrv, pipe = "stderr", timeout)
    },
    stop = function(){subprocess::process_kill(phantomdrv)},
    log = function(){readLines(tFile)}
  )
}

phantom_check <- function(){
  phantomyml <- system.file("yaml", "phantomjs.yml", package = "wdman")
  pjsyml <- yaml::yaml.load_file(phantomyml)
  platvec <- c("predlfunction", "binman::predl_bitbucket_downloads",
               "platform", "platformregex")
  platmatch <-
    switch(Sys.info()["sysname"],
           Linux = grep(os_arch("linux"), pjsyml[[platvec[-4]]]),
           Windows = grep("win", pjsyml[[platvec[-4]]]),
           Darwin = grep("mac", pjsyml[[platvec[-4]]]),
           stop("Unknown OS")
    )
  pjsyml[[platvec[-4]]] <- pjsyml[[platvec[-4]]][platmatch]
  pjsyml[[platvec[-3]]] <- pjsyml[[platvec[-3]]][platmatch]
  tempyml <- tempfile(fileext = ".yml")
  write(yaml::as.yaml(pjsyml), tempyml)
  message("checking phantomjs versions:")
  process_yaml(tempyml)
  phantomplat <- pjsyml[[platvec[-4]]]
  list(yaml = pjsyml, platform = phantomplat)
}

phantom_ver <- function(platform, version){
  phantomver <- binman::list_versions("phantomjs")[[platform]]
  phantomver <- if(identical(version, "latest")){
    as.character(max(package_version(phantomver)))
  }else{
    mtch <- match(version, phantomver)
    if(is.na(mtch) || is.null(mtch)){
      stop("version requested doesnt match versions available = ",
           paste(phantomver, collpase = ","))
    }
    phantomver[mtch]
  }
  phantomdir <- file.path(app_dir("phantomjs"), phantomplat,
                          phantomver)
  phantompath <- list.files(phantomdir,
                            pattern = "phantomjs($|\\.exe$)",
                            recursive = TRUE,
                            full.names = TRUE)
  if(file.access(phantompath, 1) < 0){
    Sys.chmod(phantompath, '0755')
  }
  list(version = phantomver, dir = phantomdir, path = phantompath)
}
