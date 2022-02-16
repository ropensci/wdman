is_string <- function(x) {
  is.character(x) && length(x) == 1 && !is.na(x)
}

assertthat::on_failure(is_string) <- function(call, env) {
  paste0(deparse(call$x), " is not a string")
}

is_string_or_null <- function(x) {
  is_string(x) || is.null(x)
}

assertthat::on_failure(is_string_or_null) <- function(call, env) {
  paste0(env$x, " is not a string or null")
}

is_list <- function(x) {
  is.list(x)
}

assertthat::on_failure(is_list) <- function(call, env) {
  paste0(deparse(call$x), " is not a list")
}

is_env <- function(x) {
  is.environment(x)
}

assertthat::on_failure(is_env) <- function(call, env) {
  paste0(deparse(call$x), " is not an environment")
}

is_list_of_df <- function(x) {
  is_list(x) && all(vapply(x, is.data.frame, logical(1)))
}

assertthat::on_failure(is_list_of_df) <- function(call, env) {
  paste0(deparse(call$x), " is not a list of data.frames")
}

is_url <- function(x) {
  is_string(x) && grepl("^https?://", x, useBytes = TRUE)
}

assertthat::on_failure(is_url) <- function(call, env) {
  paste0(deparse(call$x), " is not a url")
}

is_file <- function(x) {
  is_string(x) && file.exists(x)
}

assertthat::on_failure(is_file) <- function(call, env) {
  paste0(deparse(call$x), " is not a file")
}


is_URL_file <- function(x) {
  if (is_url(x) || is_file(x)) {
    TRUE
  } else {
    FALSE
  }
}

assertthat::on_failure(is_URL_file) <- function(call, env) {
  paste0(deparse(call$x), " is not a URL or file")
}

is_integer <- function(x) {
  is.integer(x)
}

assertthat::on_failure(is_integer) <- function(call, env) {
  paste0(deparse(call$x), " should be an integer value.")
}

is_character <- function(x) {
  is.character(x)
}

assertthat::on_failure(is_character) <- function(call, env) {
  paste0(deparse(call$x), " should be an character vector.")
}

is_logical <- function(x) {
  is.logical(x)
}

assertthat::on_failure(is_logical) <- function(call, env) {
  paste0(deparse(call$x), " should be an logical vector.")
}

is_data.frame <- function(x) {
  is.data.frame(x)
}

assertthat::on_failure(is_data.frame) <- function(call, env) {
  paste0(deparse(call$x), " should be a data.frame.")
}

contains_required <- function(x, required) {
  is.list(x) && all(required %in% names(x))
}

assertthat::on_failure(contains_required) <- function(call, env) {
  required <- eval(call$required, env)
  paste0(
    deparse(call$x),
    " does not have one of ",
    paste(required, collapse = ","),
    " as required by specification."
  )
}

app_dir_exists <- function(x) {
  dir.exists(x)
}

assertthat::on_failure(app_dir_exists) <- function(call, env) {
  paste0(env[[deparse(call$x)]], " app directory not found.")
}
