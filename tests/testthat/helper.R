binman_process_yaml <- function(...){}

mock_binman_list_versions_chrome <- function(...){
  list(
    linux64 = c("2.23", "2.24", "2.25", "2.26"),
    mac64 = c("2.23", "2.24", "2.25"),
    win32 = c("2.23", "2.24", "2.25")
  )
}

mock_binman_list_versions_phantomjs <- function(...){
  list(
    linux32 = c("1.9.7", "1.9.8", "2.1.1"),
    linux64 = c("1.9.7", "1.9.8", "2.1.1"),
    macosx = c("1.9.8", "2.0.0", "2.1.1"),
    windows = c("1.9.8", "2.0.0", "2.1.1")
  )
}

mock_binman_list_versions_gecko <- function(...){
  list(
    linux64 = c("0.10.0", "0.11.0", "0.11.1"),
    macos = c("0.10.0", "0.11.0", "0.11.1"),
    win32 = c("0.10.0", "0.11.0", "0.11.1"),
    win64 = c("0.10.0", "0.11.0", "0.11.1")
  )
}

mock_binman_list_versions_iedriver <- function(...){
  list(
    win32 = c("2.53.0", "2.53.1", "3.0.0"),
    win64 = c("2.53.0", "2.53.1", "3.0.0")
  )
}

mock_binman_list_versions_selenium <- function(...){
  list(
    generic = c("3.0.0", "3.0.0-beta4", "3.0.1")
  )
}

mock_base_normalizePath <- function(path, winslash, mustWork){
  path
}

mock_base_list.files <- function(...){
  "some.path"
}

mock_binman_app_dir <- function(...){
  "some.dir"
}

mock_subprocess_spawn_process <- function(...){
  "hello"
}

mock_subprocess_process_return_code <- function(...){
  NA
}

mock_subprocess_process_read_selenium <- function(...){
  "Selenium Server is up and running"
}

mock_subprocess_process_read_utils <- function(...){
  Sys.sleep(1)
  list(stdout = character(), stderr = character())
}

mock_generic_start_log <- function(...){
  list(stdout = "super duper", stderr = "no error here")
}
