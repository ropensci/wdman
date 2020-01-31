os_arch <- function(string = ""){
  assert_that(is_string(string))
  arch <- c("32", "64")[.Machine$sizeof.pointer/4]
  paste0(string, arch)
}

infun_read <- function(handle, env, pipe = "both",
                       timeout = 0L, outfile, errfile){
  msg <- read_pipes(env, outfile, errfile, pipe = pipe, timeout = timeout)

  if(identical(pipe, "both")){
    env[["stdout"]] <- c(env[["stdout"]], msg[["stdout"]])
    env[["stderr"]] <- c(env[["stderr"]], msg[["stderr"]])
  }
  if(identical(pipe, "stdout")){
    env[["stdout"]] <- c(env[["stdout"]], msg)
  }
  if(identical(pipe, "stderr")){
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

read_pipes <- function(env, outfile, errfile, pipe = "both",
                       timeout){
  Sys.sleep(timeout/1000)
  outres <- readLines(outfile)
  outres <- utils::tail(outres, length(outres) - length(env[["stdout"]]))
  errres <- readLines(errfile)
  errres <- utils::tail(errres, length(errres) - length(env[["stderr"]]))
  if(identical(pipe, "both")){
    return(list(stdout = outres, stderr = errres))
  }
  if(identical(pipe, "stdout")){
    return(outres)
  }
  if(identical(pipe, "stderr")){
    return(errres)
  }
}

unix_spawn_tofile <- function(command, args, outfile, errfile, ...){
  tfile <- tempfile(fileext = ".sh")
  write("#!/bin/sh", tfile)
  write(paste(c(shQuote(command), args, ">",
                shQuote(outfile), "2>", shQuote(errfile)), collapse = " "),
        tfile, append = TRUE)
  Sys.chmod(tfile)
  processx::process$new(tfile)
}

windows_spawn_tofile <- function(command, args, outfile, errfile, ...){
  tfile <- tempfile(fileext = ".bat")
  write(paste(c(shQuote(command), args, ">",
                shQuote(outfile), "2>", shQuote(errfile)), collapse = " "),
        tfile)
  processx::process$new(tfile)
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
