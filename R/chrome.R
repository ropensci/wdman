#' Start chrome driver
#'
#' Start chrome driver
#' @param port Port to run on
#' @param version what version of chromedriver to run. Default = "latest"
#'     which runs the most recent version. To see other version currently
#'     sourced run binman::list_versions("chromedriver")
#' @param path base URL path prefix for commands, e.g. wd/hub
#'
#' @return
#' @export
#'
#' @examples

chrome <- function(port = 4567L, version = "latest", path = "wd/hub",
                   subprocess = TRUE){
  assert_that(is_integer(port))
  assert_that(is_string(version))
  assert_that(is_string(path))
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
  chromedir <- file.path(app_dir("chromedriver"), chromeplat, chromever)
  chromepath <- list.files(chromedir,
                           pattern = "chromedriver($|.exe$)",
                           full.names = TRUE)
  if(subprocess){
    args <- c()
    tFile <- tempfile(fileext = ".txt")
    args[["port"]] <- sprintf("--port=%s", port)
    args[["url-base"]] <- sprintf("--url-base=%s", path)
    args[["verbose"]] <- "--verbose"
    args[["log-path"]] <- sprintf("--log-path=%s", tFile)
    chromedrv <- subprocess::spawn_process(chromepath, arguments = args,
                                          workdir = "/home/john/")
    if(!is.na(subprocess::process_return_code(chromedrv))){
      stop("Chromedriver couldn't be started",
           subprocess::process_read(chromedrv, "stderr"))
    }
    list(process = chromedrv)
  }else{
    cmd <- sprintf(
      "%s --port=%s --url-base=%s",
      shQuote(chromepath), port, path
    )
    chromedrv <- process$new(commandline = cmd)
    Sys.sleep(1)
    if(!chromedrv$is_alive()){stop("Chromedriver couldn't be started",
                                   chromedrv$read_error_lines())}
  }
  list(process = chromedrv)
}
