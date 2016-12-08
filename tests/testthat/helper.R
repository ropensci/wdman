binman_process_yaml = function(...){}

mock_binman_list_versions_chrome <- function(...){
  list(
    linux64 = c("2.23", "2.24", "2.25", "2.26"),
    mac64 = c("2.23", "2.24", "2.25"),
    win32 = c("2.23", "2.24", "2.25")
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
