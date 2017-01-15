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
    {
      testenv <- new.env()
      ifout <- wdman:::infun_read(handle = "",
                                  pipe = subprocess::PIPE_STDOUT,
                                  env = testenv)
      iferr <- wdman:::infun_read(handle = "",
                                  pipe = subprocess::PIPE_STDERR,
                                  env = testenv)
      ifboth <- wdman:::infun_read(handle = "",
                                   pipe = subprocess::PIPE_BOTH,
                                   env = testenv)
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
