os_arch <- function(string = ""){
  assert_that(is_string(string))
  arch <- c("32", "64")[.Machine$sizeof.pointer/4]
  paste0(string, arch)
}

infun_read <- function(handle, env, pipe = subprocess::PIPE_BOTH,
                       timeout = 0L, outfile, errfile){
  msg <- if(identical(.Platform[["OS.type"]], "windows")){
    read_pipes(env, outfile, errfile, pipe = pipe, timeout = timeout)
  }else{
    subprocess::process_read(handle, pipe = pipe, timeout = timeout)
  }

  if(identical(pipe, subprocess::PIPE_BOTH)){
    env[["stdout"]] <- c(env[["stdout"]], msg[["stdout"]])
    env[["stderr"]] <- c(env[["stderr"]], msg[["stderr"]])
  }
  if(identical(pipe, subprocess::PIPE_STDOUT)){
    env[["stdout"]] <- c(env[["stdout"]], msg)
  }
  if(identical(pipe, subprocess::PIPE_STDERR)){
    env[["stderr"]] <- c(env[["stderr"]], msg)
  }
  msg
}

generic_start_log <- function(handle, poll = 3000L, increment = 500L,
                              outfile, errfile){
  startlog <- list(stdout = character(), stderr = character())
  progress <- 0L
  while(progress < poll){
    begin <- Sys.time()
    errchk <- tryCatch(
      {
        if(identical(.Platform[["OS.type"]], "windows")){
          read_pipes(startlog, outfile, errfile,
                     timeout = min(increment, poll))
        }else{
          subprocess::process_read(handle, timeout = min(increment, poll))
        }
      },
      error = function(e){
        e
      }
    )
    end <- Sys.time()
    progress <-
      progress + min(as.numeric(end-begin)*1000L, increment, poll)
    startlog <- Map(c, startlog, errchk)
    nocontent <- identical(unlist(errchk), character())
    slcontent <- sum(vapply(startlog, length, integer(1)))
    if(nocontent && slcontent > 0){break}
  }
  startlog
}

`%+%` <- function(chr1, chr2){
  paste0(chr1, chr2)
}

read_pipes <- function(env, outfile, errfile, pipe = subprocess::PIPE_BOTH,
                       timeout){
  Sys.sleep(timeout/1000)
  outres <- readLines(outfile)
  outres <- tail(outres, length(outres) - length(env[["stdout"]]))
  errres <- readLines(errfile)
  errres <- tail(errres, length(errres) - length(env[["stderr"]]))
  if(identical(pipe, subprocess::PIPE_BOTH)){
    return(list(stdout = outres, stderr = errres))
  }
  if(identical(pipe, subprocess::PIPE_STDOUT)){
    return(outres)
  }
  if(identical(pipe, subprocess::PIPE_STDERR)){
    return(errres)
  }
}
