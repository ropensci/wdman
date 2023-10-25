#' Pre-download function for Chrome-for-testing site
#'
#' @param url URL of the JSON to use for files
#' @param platform One of `c("linux64", "mac-arm64", "mac-x64",
#'                           "win32", "win64")
#' @param history Integer number of recent entries
#' @param appname Name of the app, typically `"chromedriver"`
#' @param platformregex A filter for platforms. Defaults to the platform names.
#'
#' @return A named list of dataframes.  The name indicates the platform.  The dataframe should contain the version, url, and file to
#' be processed.  Used as input for `binman::download_files()` or an equivalent.
#' @importFrom binman assign_directory
#' @export
predl_chrome_for_testing <- function(url, platform, history,
                                     appname,
                                     platformregex = platform) {
  assert_that(is_URL_file(url))
  assert_that(is_character(platform))
  assert_that(is_integer(history))
  assert_that(is_string(appname))
  assert_that(is_character(platformregex))
  ver_data <- jsonlite::fromJSON(url)[[2]]
  ver_data <- Filter(
    function(x) !is.null(x$downloads[[appname]]),
    ver_data
  )
  ver_data <- ver_data[order(as.numeric(names(ver_data)))]
  unwrap <- function(entry) {
    version <- entry$version
    downloads <- entry$downloads[[appname]]
    if (!is.null(downloads)) {
      platform <- downloads$platform
      url <- downloads$url
      file <- basename(url)
      data.frame(version, platform, url, file)
    }
  }
  extracted <- do.call(rbind, lapply(ver_data, unwrap))
  app_links <- tapply(extracted, extracted$platform, identity)
  print(names(app_links))
  print(platform)
  app_links <- app_links[platform]
  print(app_links)
  assign_directory(app_links, appname)
}

#' Unzip/untar the chromedriver file
#'
#' Unzip or untar a downloaded chromedriver file, then extract it from
#' its folder.
#'
#' @param ... Passed into [binman::unziptar_dlfiles].
#'
#' @return The same as [binman::unziptar_dlfiles].
#'
#' @export
unziptar_chromedriver <- function(...) {
  chmod <- list(...)$chmod
  x <- binman::unziptar_dlfiles(...)
  for (f in x$processed) {
    dir <- tools::file_path_sans_ext(f)
    file.copy(list.files(dir, full.names = TRUE), dirname(dir), copy.mode = TRUE)

    if (chmod && .Platform$OS.type != "windows") {
      Sys.chmod(list.files(dirname(dir), pattern = "^chromedriver$", full.names = TRUE), "0755")
    }
  }
  x
}
