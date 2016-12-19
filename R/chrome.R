#' Start chrome driver
#'
#' Start chrome driver
#' @param port Port to run on
#' @param version what version of chromedriver to run. Default = "latest"
#'     which runs the most recent version. To see other version currently
#'     sourced run binman::list_versions("chromedriver")
#' @param path base URL path prefix for commands, e.g. wd/hub
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
#' cDrv <- chrome()
#' cDrv$output()
#' cDrv$stop()
#' }

chrome <- function(port = 4567L, version = "latest", path = "wd/hub",
                   verbose = TRUE){
  assert_that(is_integer(port))
  assert_that(is_string(version))
  assert_that(is_string(path))
  assert_that(is_logical(verbose))
  chromecheck <- chrome_check(verbose)
  chromeplat <- chromecheck[["platform"]]
  chromeversion <- chrome_ver(chromeplat, version)
  args <- c()
  tFile <- tempfile(fileext = ".txt")
  args[["port"]] <- sprintf("--port=%s", port)
  args[["url-base"]] <- sprintf("--url-base=%s", path)
  args[["verbose"]] <- "--verbose"
  chromedrv <- subprocess::spawn_process(
    chromeversion[["path"]], arguments = args
  )
  if(!is.na(subprocess::process_return_code(chromedrv))){
    stop("Chromedriver couldn't be started",
         subprocess_read(chromedrv, "stderr")[["stderr"]])
  }
  startlog <- generic_start_log(chromedrv)
  if(length(startlog[["stderr"]]) >0){
    if(any(grepl("Address already in use", startlog[["stderr"]]))){
      subprocess::process_kill(chromedrv)
      stop("Chrome Driver signals port = ", port, " is already in use.")
    }
  }
  log <- as.environment(startlog)
  list(
    process = chromedrv,
    output = function(timeout = 0L){
      infun_read(chromedrv, log, "stdout", timeout = timeout)
    },
    error = function(timeout = 0L){
      infun_read(chromedrv, log, "stderr", timeout = timeout)
    },
    stop = function(){subprocess::process_kill(chromedrv)},
    log = function(){
      infun_read(chromedrv, log)
      as.list(log)
    }
  )
}

chrome_check <- function(verbose){
  chromeyml <- system.file("yaml", "chromedriver.yml", package = "wdman")
  cyml <- yaml::yaml.load_file(chromeyml)
  platvec <- c("predlfunction", "binman::predl_google_storage", "platform")
  cyml[[platvec]] <-
    switch(Sys.info()["sysname"],
           Linux = grep(os_arch("linux"), cyml[[platvec]], value = TRUE),
           Windows = grep("win", cyml[[platvec]], value = TRUE),
           Darwin = grep("mac", cyml[[platvec]], value = TRUE),
           stop("Unknown OS")
    )
  tempyml <- tempfile(fileext = ".yml")
  write(yaml::as.yaml(cyml), tempyml)
  if(verbose) message("checking chromedriver versions:")
  process_yaml(tempyml, verbose)
  chromeplat <- cyml[[platvec]]
  list(yaml = cyml, platform = chromeplat)
}

chrome_ver <- function(platform, version){
  chromever <- binman::list_versions("chromedriver")[[platform]]
  chromever <- if(identical(version, "latest")){
    as.character(max(package_version(chromever)))
  }else{
    mtch <- match(version, chromever)
    if(is.na(mtch) || is.null(mtch)){
      stop("version requested doesnt match versions available = ",
           paste(chromever, collpase = ","))
    }
    chromever[mtch]
  }
  chromedir <- normalizePath(
    file.path(app_dir("chromedriver"), platform, chromever)
  )
  chromepath <- list.files(chromedir,
                           pattern = "chromedriver($|.exe$)",
                           full.names = TRUE)
  list(version = chromever, dir = chromedir, path = chromepath)
}
