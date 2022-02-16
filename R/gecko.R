#' Start gecko driver
#'
#' Start gecko driver
#' @param port Port to run on
#' @param version what version of geckodriver to run. Default = "latest"
#'     which runs the most recent version. To see other version currently
#'     sourced run binman::list_versions("geckodriver")
#' @param loglevel Set Gecko log level [values: fatal, error,
#'     warn, info, config, debug, trace]
#' @param check If TRUE check the versions of geckodriver available. If
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
#' gDrv <- gecko()
#' gDrv$output()
#' gDrv$stop()
#' }

gecko <- function(port = 4567L, version = "latest", check = TRUE,
                  loglevel = c("info", "fatal", "error", "warn", "config",
                          "debug", "trace"), verbose = TRUE,
                  retcommand = FALSE, ...){
  assert_that(is_integer(port))
  assert_that(is_string(version))
  assert_that(is_logical(verbose))
  loglevel <- match.arg(loglevel)
  geckocheck <- gecko_check(verbose, check = check)
  geckoplat <- geckocheck[["platform"]]
  geckoversion <- gecko_ver(geckoplat, version)
  eopts <- list(...)
  args <- c(Reduce(c, eopts[names(eopts) == "args"]))
  args[["port"]] <- sprintf("--port=%s", port)
  args[["log"]] <- sprintf("--log=%s", loglevel)
  if(retcommand){
    return(paste(c(geckoversion[["path"]], args), collapse = " "))
  }
  pfile <- pipe_files()
  geckodrv <- spawn_tofile(geckoversion[["path"]],
                           args, pfile[["out"]], pfile[["err"]])
  if(isFALSE(geckodrv$is_alive())){
    err <- paste0(readLines(pfile[["err"]]), collapse = "\n")
    stop("Geckodriver couldn't be started\n", err)
  }
  startlog <- generic_start_log(geckodrv,
                                outfile = pfile[["out"]],
                                errfile = pfile[["err"]])
  if(length(startlog[["stderr"]]) >0){
    if(any(grepl("Address already in use", startlog[["stderr"]]))){
      kill_process(geckodrv)
      stop("Gecko Driver signals port = ", port, " is already in use.")
    }
  }
  log <- as.environment(startlog)
  list(
    process = geckodrv,
    output = function(timeout = 0L){
      infun_read(geckodrv, log, "stdout", timeout = timeout,
                 outfile = pfile[["out"]], errfile = pfile[["err"]])
    },
    error = function(timeout = 0L){
      infun_read(geckodrv, log, "stderr", timeout = timeout,
                 outfile = pfile[["out"]], errfile = pfile[["err"]])
    },
    stop = function(){kill_process(geckodrv)},
    log = function(){
      infun_read(geckodrv, log, outfile = pfile[["out"]], errfile = pfile[["err"]])
      as.list(log)
    }
  )
}

gecko_check <- function(verbose, check = TRUE){
  geckoyml <- system.file("yaml", "geckodriver.yml", package = "wdman")
  gyml <- yaml::yaml.load_file(geckoyml)
  platvec <- c("predlfunction", "binman::predl_github_assets","platform")
  gyml[[platvec]] <-
    switch(Sys.info()["sysname"],
           Linux = grep(os_arch("linux"), gyml[[platvec]], value = TRUE),
           Windows = grep(os_arch("win"), gyml[[platvec]], value = TRUE),
           Darwin = grep("mac", gyml[[platvec]], value = TRUE),
           stop("Unknown OS")
    )
  tempyml <- tempfile(fileext = ".yml")
  write(yaml::as.yaml(gyml), tempyml)
  if(check){
    if(verbose) message("checking geckodriver versions:")
    process_yaml(tempyml, verbose)
  }
  geckoplat <- gyml[[platvec]]
  list(yaml = gyml, platform = geckoplat)
}

gecko_ver <- function(platform, version){
  geckover <- binman::list_versions("geckodriver")[[platform]]
  geckover <- if(identical(version, "latest")){
    as.character(max(semver::parse_version(geckover)))
  }else{
    mtch <- match(version, geckover)
    if(is.na(mtch) || is.null(mtch)){
      stop("version requested doesnt match versions available = ",
           paste(geckover, collapse = ","))
    }
    geckover[mtch]
  }
  geckodir <- normalizePath(
    file.path(app_dir("geckodriver"), platform, geckover)
  )
  geckopath <- list.files(geckodir,
                          pattern = "geckodriver($|.exe$)",
                          full.names = TRUE)
  list(version = geckover, dir = geckodir, path = geckopath)
}
