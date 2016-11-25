#' Start chrome driver
#'
#' Start chrome driver
#' @param type Run locally (chromedriver only) or as a remote driver
#'     (selenium)
#' @param port Port to run on
#' @param path base URL path prefix for commands, e.g. wd/hub
#'
#' @return
#' @export
#'
#' @examples

chrome <- function(type = c("browser", "selenium"), port = 4567L,
                   path = "wd/hub"){
  type <- match.arg(type)
  assert_that(is.integer(port))
  chromeyml <- system.file("yaml", "chromedriver.yml", package = "wdman")
  cyml <- yaml::yaml.load_file(chromeyml)
  platvec <- c("predlfunction", "binman::predl_google_storage","platform")
  cyml[[platvec]] <-
    switch(Sys.info()["sysname"],
           Linux = grep("linux", cyml[[platvec]], value = TRUE),
           windows = grep("win", cyml[[platvec]], value = TRUE),
           Darwin = grep("mac", cyml[[platvec]], value = TRUE),
           stop("Unknown OS")
    )
  tempyml <- tempfile(fileext = ".yml")
  write(yaml::as.yaml(cyml), tempyml)
  message("checking chromedriver versions:")
  process_yaml(tempyml)
  chromeplat <- cyml[[platvec]]
  chromever <- binman::list_versions("chromedriver")[[chromeplat]]
  chromever <- as.character(max(package_version(chromever)))
  chromedir <- file.path(app_dir("chromedriver"), chromeplat, chromever)
  chromepath <- list.files(chromedir,
                           pattern = "chromedriver($|.exe$)",
                           full.names = TRUE)
  cmd <- sprintf(
    "%s --port=%s --url-base=%s",
    shQuote(chromepath), port, path
  )
  chromedrv <- process$new(commandline = cmd)
  Sys.sleep(1)
  if(!chromedrv$is_alive()){stop("Chromedriver couldn't be started",
                                 chromedrv$read_error_lines())}
  list(process = chromedrv)
}
