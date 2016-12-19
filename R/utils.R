os_arch <- function(string = ""){
  assert_that(is_string(string))
  arch <- c("32", "64")[.Machine$sizeof.pointer/4]
  paste0(string, arch)
}

infun_read <- function(handle, env, pipe = PIPE_BOTH, timeout = 0L){
  msg <- subprocess::process_read(handle, pipe = pipe, timeout = timeout)
  env[["stdout"]] <- c(env[["stdout"]], msg[["stdout"]])
  env[["stderr"]] <- c(env[["stderr"]], msg[["stderr"]])
  msg
}
