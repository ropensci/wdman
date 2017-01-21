os_arch <- function(string = ""){
  assert_that(is_string(string))
  arch <- c("32", "64")[.Machine$sizeof.pointer/4]
  paste0(string, arch)
}

infun_read <- function(handle, env, pipe = subprocess::PIPE_BOTH,
                       timeout = 0L, outfile, errfile){
  msg <- read_pipes(env, outfile, errfile, pipe = pipe, timeout = timeout)

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
        read_pipes(startlog, outfile, errfile,
                   timeout = min(increment, poll))
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
  outres <- utils::tail(outres, length(outres) - length(env[["stdout"]]))
  errres <- readLines(errfile)
  errres <- utils::tail(errres, length(errres) - length(env[["stderr"]]))
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

unix_spawn_tofile <- function(command, args, outfile, errfile, ...){
  tfile <- tempfile(fileext = ".sh")
  tfile2 <- tempfile(fileext = ".sh")
  write("#!/bin/sh", tfile)
  write(paste(c(command, args, ">", outfile, "2>", errfile),
              collapse = " "),
        tfile, append = TRUE)
  Sys.chmod(tfile)
  # write("#!/bin/sh", tfile2)
  # write(paste(tfile, ">", outfile, "2>", errfile, collapse = " "),
  #       tfile2, append = TRUE)
  # Sys.chmod(tfile2)
  # subprocess::spawn_process(tfile2, ...)
  subprocess::spawn_process(tfile, ...)
}

windows_spawn_tofile <- function(command, args, outfile, errfile, ...){
  tfile <- tempfile(fileext = ".bat")
  write(paste(c(command, args), collapse = " "), tfile)
  subprocess::spawn_process(tfile, arguments = c(">", outTfile,
                                                 "2>", errTfile))
}

spawn_tofile <- function(command, args, outfile, errfile, ...){
  if(identical(.Platform[["OS.type"]], "windows")){
    windows_spawn_tofile(command, args, outfile, errfile, ...)
  }else{
    unix_spawn_tofile(command, args, outfile, errfile, ...)
  }
}

pipe_files <- function(){
  errTfile <- tempfile(fileext = ".txt")
  write(character(), errTfile)
  outTfile <- tempfile(fileext = ".txt")
  write(character(), outTfile)
  list(out = outTfile, err = errTfile)
}
