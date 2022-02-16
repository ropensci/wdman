#' Start phantomjs
#'
#' Start phantomjs in webdriver mode
#' @param port Port to run on
#' @param version what version of phantomjs to run. Default = "2.2.1"
#'     which runs the most recent stable version. To see other version currently
#'     sourced run binman::list_versions("phantomjs")
#' @param loglevel Set phantomjs log level [values: fatal, error,
#'     warn, info, config, debug, trace]
#' @param check If TRUE check the versions of phantomjs available. If
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
#' pjs <- phantomjs()
#' pjs$output()
#' pjs$stop()
#' }
#'
phantomjs <- function(port = 4567L, version = "2.1.1", check = TRUE,
                      loglevel = c("INFO", "ERROR", "WARN", "DEBUG"),
                      verbose = TRUE, retcommand = FALSE, ...) {
  assert_that(is_integer(port))
  assert_that(is_string(version))
  assert_that(is_logical(verbose))
  loglevel <- match.arg(loglevel)
  phantomcheck <- phantom_check(verbose, check = check)
  phantomplat <- phantomcheck[["platform"]]
  phantomversion <- phantom_ver(phantomplat, version)
  eopts <- list(...)
  args <- c(Reduce(c, eopts[names(eopts) == "args"]))
  args[["webdriver"]] <- sprintf("--webdriver=%s", port)
  args[["log-level"]] <- sprintf("--webdriver-loglevel=%s", loglevel)
  if (retcommand) {
    return(paste(c(phantomversion[["path"]], args), collapse = " "))
  }
  pfile <- pipe_files()
  phantomdrv <- spawn_tofile(
    phantomversion[["path"]],
    args, pfile[["out"]], pfile[["err"]]
  )
  if (isFALSE(phantomdrv$is_alive())) {
    err <- paste0(readLines(pfile[["err"]]), collapse = "\n")
    stop("PhantomJS couldn't be started\n", err)
  }
  startlog <- generic_start_log(phantomdrv,
    outfile = pfile[["out"]],
    errfile = pfile[["err"]]
  )
  if (length(startlog[["stdout"]]) > 0) {
    if (any(
      grepl("GhostDriver - main.fail.*sourceURL", startlog[["stdout"]])
    )) {
      kill_process(phantomdrv)
      stop("PhantomJS signals port = ", port, " is already in use.")
    }
  }
  log <- as.environment(startlog)
  list(
    process = phantomdrv,
    output = function(timeout = 0L) {
      infun_read(phantomdrv, log, "stdout",
        timeout = timeout,
        outfile = pfile[["out"]], errfile = pfile[["err"]]
      )
    },
    error = function(timeout = 0L) {
      infun_read(phantomdrv, log, "stderr",
        timeout = timeout,
        outfile = pfile[["out"]], errfile = pfile[["err"]]
      )
    },
    stop = function() {
      kill_process(phantomdrv)
    },
    log = function() {
      infun_read(phantomdrv, log,
        outfile = pfile[["out"]], errfile = pfile[["err"]]
      )
      as.list(log)
    }
  )
}

phantom_check <- function(verbose, check = TRUE) {
  phantomyml <- system.file("yaml", "phantomjs.yml", package = "wdman")
  pjsyml <- yaml::yaml.load_file(phantomyml)
  platvec <- c(
    "predlfunction", "binman::predl_bitbucket_downloads",
    "platform", "platformregex"
  )
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
  if (check) {
    if (verbose) message("checking phantomjs versions:")
    process_yaml(tempyml, verbose)
  }
  phantomplat <- pjsyml[[platvec[-4]]]
  list(yaml = pjsyml, platform = phantomplat)
}

phantom_ver <- function(platform, version) {
  phantomver <- binman::list_versions("phantomjs")[[platform]]
  phantomver <- if (identical(version, "latest")) {
    as.character(max(semver::parse_version(phantomver)))
  } else {
    mtch <- match(version, phantomver)
    if (is.na(mtch) || is.null(mtch)) {
      stop(
        "version requested doesnt match versions available = ",
        paste(phantomver, collapse = ",")
      )
    }
    phantomver[mtch]
  }
  phantomdir <- normalizePath(
    file.path(app_dir("phantomjs"), platform, phantomver)
  )
  phantompath <- list.files(phantomdir,
    pattern = "phantomjs($|\\.exe$)",
    recursive = TRUE,
    full.names = TRUE
  )
  if (file.access(phantompath, 1) < 0) {
    Sys.chmod(phantompath, "0755")
  }
  list(version = phantomver, dir = phantomdir, path = phantompath)
}
