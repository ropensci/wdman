#' Pre-download function for Chrome for Testing site
#'
#' Prepare to download Chromedriver from the Chrome for Testing site.
#'
#' @param url URL containing the JSON used to locate files.
#' @param platform One of `c("linux64", "mac-arm64", "mac-x64",
#'                           "win32", "win64")`.
#'
#' @return
#' A named list of dataframes. The name indicates the platform. The
#' dataframe should contain the version, url, and file to be processed.
#' Used as input for [binman::download_files()] or equivalent.
#'
#' @examples
#' \dontrun{
#' # predl_chrome_for_testing() is used by chrome()
#' chrome <- chrome()
#' chrome$stop()
#' }
#'
#' @importFrom binman assign_directory
#'
#' @export
predl_chrome_for_testing <- function(url, platform) {
  assert_that(is_URL_file(url))
  assert_that(is_character(platform))
  ver_data <- jsonlite::fromJSON(url)[[2]]
  ver_data <- Filter(
    function(x) !is.null(x$downloads[["chromedriver"]]),
    ver_data
  )
  ver_data <- ver_data[order(as.numeric(names(ver_data)))]
  unwrap <- function(entry) {
    version <- entry$version
    downloads <- entry$downloads[["chromedriver"]]
    if (!is.null(downloads)) {
      platform <- downloads$platform
      url <- downloads$url
      file <- basename(url)
      data.frame(version, platform, url, file)
    }
  }
  extracted <- do.call(rbind, lapply(ver_data, unwrap))
  app_links <- tapply_identity(extracted, extracted$platform)
  app_links <- app_links[platform]
  assign_directory(app_links, "chromedriver")
}

# The same as tapply(x, y, identity), but works on older versions of R.
tapply_identity <- function(x, y) {
  res <- lapply(unique(y), function(z) x[y == z, ])

  names(res) <- unique(y)

  as.array(res)
}

#' Unzip/untar the chromedriver file
#'
#' Unzip or untar a downloaded chromedriver file, then extract it from
#' its folder.
#'
#' @param dlfiles Passed into [binman::unziptar_dlfiles]: A data frame of
#'   files.
#' @param chmod If `TRUE`, the files are made executable.
#'
#' @returns The same as [binman::unziptar_dlfiles()]: a list of character
#'   vectors representing the processed files.
#'
#' @examples
#' \dontrun{
#' # unziptar_chromedriver() is used by chrome()
#' chrome <- chrome()
#' chrome$stop()
#' }
#'
#' @export
unziptar_chromedriver <- function(dlfiles, chmod = TRUE) {
  x <- binman::unziptar_dlfiles(dlfiles, chmod = chmod)

  for (f in x$processed) {
    dir <- tools::file_path_sans_ext(f)
    file.copy(list.files(dir, full.names = TRUE), dirname(dir), copy.mode = TRUE)

    if (chmod && .Platform$OS.type != "windows") {
      Sys.chmod(list.files(dirname(dir), pattern = "^chromedriver$", full.names = TRUE), "0755")
    }
  }
  x
}
