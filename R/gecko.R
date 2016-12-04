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
#' @return
#' @export
#'
#' @examples

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
           Linux = grep("linux", gyml[[platvec]], value = TRUE),
           windows = grep("win", gyml[[platvec]], value = TRUE),
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
  cmd <- sprintf( "%s --port %s --log %s", shQuote(geckopath), port, log)
  geckodrv <- process$new(commandline = cmd)
  Sys.sleep(1)
  if(!geckodrv$is_alive()){stop("Geckodriver couldn't be started",
                                geckodrv$read_error_lines())}
  list(process = geckodrv)
}
