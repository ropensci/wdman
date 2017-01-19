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
