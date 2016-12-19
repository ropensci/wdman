#' Start IE driver server
#'
#' Start IE driver server
#' @param port Port to run on
#' @param version what version of IE driver server to run. Default = "latest"
#'     which runs the most recent version. To see other version currently
#'     sourced run binman::list_versions("iedriverserver")
#' @param loglevel Specifies the log level used by the server. Valid values
#' are: TRACE, DEBUG, INFO, WARN, ERROR, and FATAL. Defaults to FATAL
#' if not specified.
#' @param verbose If TRUE, include status messages (if any)
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
#' ieDrv <- iedriver()
#' ieDrv$output()
#' ieDrv$stop()
#' }

iedriver <- function(port = 4567L, version = "latest",
                     loglevel = c("FATAL", "TRACE", "DEBUG", "INFO",
                                  "WARN", "ERROR"), verbose = TRUE){
  assert_that(is_integer(port))
  assert_that(is_string(version))
  assert_that(is_logical(verbose))
  loglevel <- match.arg(loglevel)
  iecheck <- ie_check(verbose)
  ieplat <- iecheck[["platform"]]
  ieversion <- ie_ver(ieplat, version)
  args <- c()
  tFile <- tempfile(fileext = ".txt")
  args[["port"]] <- sprintf("/port=%s", port)
  args[["log-level"]] <- sprintf("/log-level=%s", loglevel)
  args[["log-path"]] <- sprintf("/log-file=%s", tFile)
  iedrv <- subprocess::spawn_process(
    ieversion[["path"]], arguments = args
  )
  if(!is.na(subprocess::process_return_code(iedrv))){
    stop("iedriver couldn't be started",
         subprocess::process_read(iedrv, "stderr"))
  }
  startlog <- generic_start_log(iedrv)
  if(length(startlog[["stderr"]]) >0){
    if(any(grepl("Address in use", startlog[["stderr"]]))){
      subprocess::process_kill(iedrv)
      stop("IE Driver signals port = ", port, " is already in use.")
    }
  }
  log <- as.environment(startlog)
  list(
    process = iedrv,
    output = function(timeout = 0L){
      infun_read(iedrv, log, "stdout", timeout = timeout)
    },
    error = function(timeout = 0L){
      infun_read(iedrv, log, "stderr", timeout = timeout)
    },
    stop = function(){subprocess::process_kill(iedrv)},
    log = function(){
      infun_read(iedrv, log)
      as.list(log)
    }
  )
}

ie_check <- function(verbose){
  ieyml <- system.file("yaml", "iedriverserver.yml", package = "wdman")
  iyml <- yaml::yaml.load_file(ieyml)
  platvec <- c("predlfunction", "binman::predl_google_storage",
               "platform", "platformregex")
  platmatch <-
    switch(Sys.info()["sysname"],
           Windows = grep(os_arch("win"), iyml[[platvec[-4]]]),
           stop("IEDriverServer not available for this platform")
    )
  iyml[[platvec[-4]]] <- iyml[[platvec[-4]]][platmatch]
  iyml[[platvec[-3]]] <- iyml[[platvec[-3]]][platmatch]
  tempyml <- tempfile(fileext = ".yml")
  write(yaml::as.yaml(iyml), tempyml)
  if(verbose) message("checking iedriver versions:")
  process_yaml(tempyml, verbose)
  ieplat <- iyml[[platvec[-4]]]
  list(yaml = iyml, platform = ieplat)
}

ie_ver <- function(platform, version){
  iever <- binman::list_versions("iedriverserver")[[platform]]
  iever <- if(identical(version, "latest")){
    as.character(max(binman::sem_ver(iever)))
  }else{
    mtch <- match(version, iever)
    if(is.na(mtch) || is.null(mtch)){
      stop("version requested doesnt match versions available = ",
           paste(iever, collpase = ","))
    }
    iever[mtch]
  }
  iedir <- normalizePath(
    file.path(app_dir("iedriverserver"), platform, iever)
  )
  iepath <- list.files(iedir,
                           pattern = "IEDriverServer($|.exe$)",
                           full.names = TRUE)
  list(version = iever, dir = iedir, path = iepath)
}
