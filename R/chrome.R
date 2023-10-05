#' Start chrome driver
#'
#' Start chrome driver
#' @param port Port to run on
#' @param version what version of chromedriver to run. Default = "latest"
#'     which runs the most recent version. To see other version currently
#'     sourced run binman::list_versions("chromedriver")
#' @param path base URL path prefix for commands, e.g. wd/hub
#' @param check If TRUE check the versions of chromedriver available. If
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
#' cDrv <- chrome()
#' cDrv$output()
#' cDrv$stop()
#' }
#'
chrome <- function(port = 4567L, version = "latest", path = "wd/hub",
                   check = TRUE, verbose = TRUE, retcommand = FALSE, ...) {
  assert_that(is_integer(port))
  assert_that(is_string(version))
  assert_that(is_string(path))
  assert_that(is_logical(verbose))
  chromecheck <- chrome_check(verbose, check = check)
  chromeplat <- chromecheck[["platform"]]
  chromeversion <- chrome_ver(chromeplat, version)
  eopts <- list(...)
  args <- c(Reduce(c, eopts[names(eopts) == "args"]))
  args[["port"]] <- sprintf("--port=%s", port)
  args[["url-base"]] <- sprintf("--url-base=%s", path)
  args[["verbose"]] <- "--verbose"
  if (retcommand) {
    return(paste(c(chromeversion[["path"]], args), collapse = " "))
  }
  pfile <- pipe_files()
  errTfile <- tempfile(fileext = ".txt")
  write(character(), errTfile)
  outTfile <- tempfile(fileext = ".txt")
  write(character(), outTfile)
  chromedrv <- spawn_tofile(
    chromeversion[["path"]],
    args, pfile[["out"]], pfile[["err"]]
  )
  if (isFALSE(chromedrv$is_alive())) {
    err <- paste0(readLines(pfile[["err"]]), collapse = "\n")
    stop("Chromedriver couldn't be started\n", err)
  }
  startlog <- generic_start_log(chromedrv,
    outfile = pfile[["out"]],
    errfile = pfile[["err"]]
  )
  if (length(startlog[["stderr"]]) > 0) {
    if (any(grepl("Address already in use", startlog[["stderr"]]))) {
      kill_process(chromedrv)
      stop("Chrome Driver signals port = ", port, " is already in use.")
    }
  }
  log <- as.environment(startlog)
  list(
    process = chromedrv,
    output = function(timeout = 0L) {
      infun_read(chromedrv, log, "stdout",
        timeout = timeout,
        outfile = pfile[["out"]], errfile = pfile[["err"]]
      )
    },
    error = function(timeout = 0L) {
      infun_read(chromedrv, log, "stderr",
        timeout = timeout,
        outfile = pfile[["out"]], errfile = pfile[["err"]]
      )
    },
    stop = function() {
      kill_process(chromedrv)
    },
    log = function() {
      infun_read(chromedrv, log,
        outfile = pfile[["out"]], errfile = pfile[["err"]]
      )
      as.list(log)
    }
  )
}

chrome_check <- function(verbose, check = TRUE) {
  chromeyml <- system.file("yaml", "chromedriver.yml", package = "wdman")
  cyml <- yaml::yaml.load_file(chromeyml)
  platvec <- c("predlfunction", "binman::predl_google_storage", "platform")
  cyml[[platvec]] <-
    switch(Sys.info()["sysname"],
      Linux = grep(os_arch("linux"), cyml[[platvec]], value = TRUE),
      Windows = grep("win", cyml[[platvec]], value = TRUE),
      Darwin = grep(mac_machine(), cyml[[platvec]], value = TRUE),
      stop("Unknown OS")
    )

  # Need regex that can tell mac64 and mac64_m1 apart
  if (cyml[[platvec]] %in% c("mac64", "mac64_m1")) {
    platregexvec <- c("predlfunction", "binman::predl_google_storage", "platformregex")
    cyml[[platregexvec]] <- paste0(cyml[[platvec]], "\\.")
  }

  tempyml <- tempfile(fileext = ".yml")
  write(yaml::as.yaml(cyml), tempyml)
  if (check) {
    if (verbose) message("checking chromedriver versions:")
    process_yaml(tempyml, verbose)
  }
  chromeplat <- cyml[[platvec]]
  list(yaml = cyml, platform = chromeplat)
}

chrome_ver <- function(platform, version) {
  chromever <- list_versions("chromedriver")[[platform]]
  chromever <- if (identical(version, "latest")) {
    as.character(max(package_version(chromever)))
  } else {
    mtch <- match(version, chromever)
    if (is.na(mtch) || is.null(mtch)) {
      stop(
        "version requested doesnt match versions available = ",
        paste(chromever, collapse = ",")
      )
    }
    chromever[mtch]
  }
  chromedir <- normalizePath(
    file.path(app_dir("chromedriver"), platform, chromever)
  )
  chromepath <- list.files(chromedir,
    pattern = "^chromedriver($|.exe$)",
    full.names = TRUE
  )
  list(version = chromever, dir = chromedir, path = chromepath)
}
