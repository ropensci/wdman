context("utils")

test_that("canCallInfun_read", {
  with_mock(
    `subprocess::process_read` = function(handle, pipe, ...){
      out <- list()
      if(pipe %in% c(subprocess::PIPE_STDOUT)){
        return("stdout here")
      }
      if(pipe %in% c(subprocess::PIPE_STDERR)){
        return("stderr here")
      }
      if(pipe %in% c(subprocess::PIPE_BOTH)){
        return(list(stdout = "stdout here", stderr = "stderr here"))
      }
    },
    `wdman:::read_pipes` = function(pipe, ...){
      out <- list()
      if(pipe %in% c(subprocess::PIPE_STDOUT)){
        return("stdout here")
      }
      if(pipe %in% c(subprocess::PIPE_STDERR)){
        return("stderr here")
      }
      if(pipe %in% c(subprocess::PIPE_BOTH)){
        return(list(stdout = "stdout here", stderr = "stderr here"))
      }
    },
    {
      testenv <- new.env()
      ifout <- wdman:::infun_read(handle = "",
                                  pipe = subprocess::PIPE_STDOUT,
                                  env = testenv, outfile = "",
                                  errfile = "")
      iferr <- wdman:::infun_read(handle = "",
                                  pipe = subprocess::PIPE_STDERR,
                                  env = testenv, outfile = "",
                                  errfile = "")
      ifboth <- wdman:::infun_read(handle = "",
                                   pipe = subprocess::PIPE_BOTH,
                                   env = testenv, outfile = "",
                                   errfile = "")
      expect_identical(ifboth, list(stdout = "stdout here",
                                    stderr = "stderr here"))
    }
  )
  expect_identical(ifout, "stdout here")
  expect_identical(iferr, "stderr here")
  expect_identical(ifboth, list(stdout = "stdout here",
                                stderr = "stderr here"))
  expect_identical(testenv[["stdout"]], rep("stdout here", 2))
  expect_identical(testenv[["stderr"]], rep("stderr here", 2))
  rm(testenv)
})

test_that("canCallGeneric_start_log", {
  with_mock(
    `subprocess::process_read` = mock_subprocess_process_read_utils,
    `wdman:::read_pipes` = mock_subprocess_process_read_utils,
    out <- generic_start_log("", poll = 1500L, outfile = "",
                             errfile = "")
  )
  expect_identical(out, list(stdout = character(), stderr = character()))
})


test_that("canRead_pipes", {
  outfile <- tempfile(fileext = ".txt")
  write(c("hello", "i am out"), outfile)
  errfile <- tempfile(fileext = ".txt")
  write(c("world", "i am err"), errfile)
  env <- list(stdout = "hello", stderr = "world")
  bothres <- read_pipes(env, outfile, errfile, timeout = 20)
  outres <- read_pipes(env, outfile, errfile, subprocess::PIPE_STDOUT,
                       timeout = 20)
  errres <- read_pipes(env, outfile, errfile, subprocess::PIPE_STDERR,
                       timeout = 20)
  expect_identical(bothres, list(stdout = "i am out", stderr = "i am err"))
  expect_identical(outres, "i am out")
  expect_identical(errres, "i am err")
})

test_that("canWindows_spawn_tofile", {
  outfile <- tempfile(fileext = ".txt")
  errfile <- tempfile(fileext = ".txt")
  with_mock(
    `subprocess::spawn_process`= function(command, ...){
      readLines(command)
    },
    out <- windows_spawn_tofile("hello", "world", outfile, errfile)
  )
  exRes <- paste(c(shQuote("hello"), "world", ">",
                   shQuote(outfile), "2>", shQuote(errfile)),
                 collapse = " ")
  expect_identical(out, exRes)
})
