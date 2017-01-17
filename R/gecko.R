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
#'     to \code{\link{spawn_process}}
#' @param ... pass additional options to the driver
#'
#' @return Returns a list with named elements process, output, error and
#'     stop. process is the output from calling \code{\link{spawn_process}}
#'     output, error and stop are functions calling
#'     \code{\link{process_read}}, \code{\link{process_read}} with "stderr"
#'     pipe and \code{\link{process_kill}}  respectively  on process.
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
  geckodrv <- subprocess::spawn_process(
    geckoversion[["path"]], arguments = args
  )
  if(!is.na(subprocess::process_return_code(geckodrv))){
    stop("Geckodriver couldn't be started",
         subprocess::process_read(geckodrv, "stderr"))
  }
  startlog <- generic_start_log(geckodrv)
  if(length(startlog[["stderr"]]) >0){
    if(any(grepl("Address in use", startlog[["stderr"]]))){
      subprocess::process_kill(geckodrv)
      stop("Gecko Driver signals port = ", port, " is already in use.")
    }
  }
  log <- as.environment(startlog)
  list(
    process = geckodrv,
    output = function(timeout = 0L){
      infun_read(geckodrv, log, "stdout", timeout = timeout)
    },
    error = function(timeout = 0L){
      infun_read(geckodrv, log, "stderr", timeout = timeout)
    },
    stop = function(){subprocess::process_kill(geckodrv)},
    log = function(){
      infun_read(geckodrv, log)
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
           paste(geckover, collpase = ","))
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
