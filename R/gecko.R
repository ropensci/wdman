#' Start gecko driver
#'
#' Start gecko driver
#' @param port Port to run on
#' @param version what version of geckodriver to run. Default = "latest"
#'     which runs the most recent version. To see other version currently
#'     sourced run binman::list_versions("geckodriver")
#' @param log Set Gecko log level [values: fatal, error,
#'     warn, info, config, debug, trace]
#' @param path base URL path prefix for commands, e.g. wd/hub
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

gecko <- function(port = 4567L, version = "latest",
                  log = c("fatal", "error", "warn", "info", "config",
                          "debug", "trace")){
  assert_that(is_integer(port))
  assert_that(is_string(version))
  log <- match.arg(log)
  geckoyml <- system.file("yaml", "geckodriver.yml", package = "wdman")
  gyml <- yaml::yaml.load_file(geckoyml)
  platvec <- c("predlfunction", "binman::predl_github_assets","platform")
  gyml[[platvec]] <-
    switch(Sys.info()["sysname"],
           Linux = grep(os_arch("linux"), gyml[[platvec]], value = TRUE),
           windows = grep(os_arch("win"), gyml[[platvec]], value = TRUE),
           Darwin = grep("mac", gyml[[platvec]], value = TRUE),
           stop("Unknown OS")
    )
  tempyml <- tempfile(fileext = ".yml")
  write(yaml::as.yaml(gyml), tempyml)
  message("checking geckodriver versions:")
  process_yaml(tempyml)
  geckoplat <- gyml[[platvec]]
  geckover <- binman::list_versions("geckodriver")[[geckoplat]]
  geckover <- if(identical(version, "latest")){
    vermax <- as.character(max(package_version(gsub("v", "", geckover))))
    paste0("v", vermax)
  }else{
    mtch <- match(version, geckover)
    if(is.na(mtch) || is.null(mtch)){
      stop("version requested doesnt match versions available = ",
           paste(geckover, collpase = ","))
    }
    geckover[mtch]
  }
  geckodir <- file.path(app_dir("geckodriver"), geckoplat, geckover)
  geckopath <- list.files(geckodir,
                           pattern = "geckodriver($|.exe$)",
                           full.names = TRUE)
  args <- c()
  args[["port"]] <- sprintf("--port=%s", port)
  args[["log"]] <- sprintf("--log=%s", log)
  geckodrv <- subprocess::spawn_process(
    geckopath, arguments = args,
    environment = Sys.getenv()[!grepl("R_", names(Sys.getenv()))])
  if(!is.na(subprocess::process_return_code(geckodrv))){
    stop("Geckodriver couldn't be started",
         subprocess::process_read(geckodrv, "stderr"))
  }
  if(!is.na(subprocess::process_return_code(geckodrv))){
    stop("Geckodriver couldn't be started",
         subprocess::process_read(geckodrv, "stderr"))
  }
  list(
    process = geckodrv,
    output = function(timeout = 0L){
      subprocess::process_read(geckodrv, timeout = timeout)
    },
    error = function(timeout = 0L){
      subprocess::process_read(geckodrv, pipe = "stderr", timeout)
    },
    stop = function(){subprocess::process_kill(geckodrv)}
  )
}
