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
#' @param check If TRUE check the versions of IE driver available. If
#'     new versions are available they will be downloaded.
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
#' ieDrv <- iedriver()
#' ieDrv$output()
#' ieDrv$stop()
#' }

iedriver <- function(port = 4567L, version = "latest", check = TRUE,
                     loglevel = c("FATAL", "TRACE", "DEBUG", "INFO",
                                  "WARN", "ERROR"), verbose = TRUE,
                     retcommand = FALSE, ...){
  assert_that(is_integer(port))
  assert_that(is_string(version))
  assert_that(is_logical(verbose))
  loglevel <- match.arg(loglevel)
  iecheck <- ie_check(verbose, check = check)
  ieplat <- iecheck[["platform"]]
  ieversion <- ie_ver(ieplat, version)
  eopts <- list(...)
  args <- c(Reduce(c, eopts[names(eopts) == "args"]))
  args[["port"]] <- sprintf("/port=%s", port)
  args[["log-level"]] <- sprintf("/log-level=%s", loglevel)
  if(retcommand){
    return(paste(c(ieversion[["path"]], args), collapse = " "))
  }
  pfile <- pipe_files()
  iedrv <- spawn_tofile(ieversion[["path"]],
                        args, pfile[["out"]], pfile[["err"]])
  if(isFALSE(iedrv$is_alive())){
    err <- paste0(readLines(pfile[["err"]]), collapse = "\n")
    stop("iedriver couldn't be started\n", err)
  }
  startlog <- generic_start_log(iedrv,
                                outfile = pfile[["out"]],
                                errfile = pfile[["err"]])
  if(length(startlog[["stderr"]]) >0){
    if(any(grepl("Address already in use", startlog[["stderr"]]))){
      kill_process(iedrv)
      stop("IE Driver signals port = ", port, " is already in use.")
    }
  }
  log <- as.environment(startlog)
  list(
    process = iedrv,
    output = function(timeout = 0L){
      infun_read(iedrv, log, "stdout", timeout = timeout,
                 outfile = pfile[["out"]], errfile = pfile[["err"]])
    },
    error = function(timeout = 0L){
      infun_read(iedrv, log, "stderr", timeout = timeout,
                 outfile = pfile[["out"]], errfile = pfile[["err"]])
    },
    stop = function(){kill_process(iedrv)},
    log = function(){
      infun_read(iedrv, log, outfile = pfile[["out"]], errfile = pfile[["err"]])
      as.list(log)
    }
  )
}

ie_check <- function(verbose, check = TRUE){
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
  if(check){
    if(verbose) message("checking iedriver versions:")
    process_yaml(tempyml, verbose)
  }
  ieplat <- iyml[[platvec[-4]]]
  list(yaml = iyml, platform = ieplat)
}

ie_ver <- function(platform, version){
  iever <- binman::list_versions("iedriverserver")[[platform]]
  iever <- if(identical(version, "latest")){
    as.character(max(semver::parse_version(iever)))
  }else{
    mtch <- match(version, iever)
    if(is.na(mtch) || is.null(mtch)){
      stop("version requested doesnt match versions available = ",
           paste(iever, collapse = ","))
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
