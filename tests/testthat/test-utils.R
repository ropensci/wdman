test_that("canCallInfun_read", {
  local_mocked_bindings(
    read_pipes = function(pipe, ...) {
      out <- list()
      if (pipe %in% c("stdout")) {
        return("stdout here")
      }
      if (pipe %in% c("stderr")) {
        return("stderr here")
      }
      if (pipe %in% c("both")) {
        return(list(stdout = "stdout here", stderr = "stderr here"))
      }
    },
    .package = "wdman"
  )
  testenv <- new.env()
  ifout <- wdman:::infun_read(
    handle = "",
    pipe = "stdout",
    env = testenv, outfile = "",
    errfile = ""
  )
  iferr <- wdman:::infun_read(
    handle = "",
    pipe = "stderr",
    env = testenv, outfile = "",
    errfile = ""
  )
  ifboth <- wdman:::infun_read(
    handle = "",
    pipe = "both",
    env = testenv, outfile = "",
    errfile = ""
  )
  expect_identical(ifboth, list(
    stdout = "stdout here",
    stderr = "stderr here"
  ))

  expect_identical(ifout, "stdout here")
  expect_identical(iferr, "stderr here")
  expect_identical(ifboth, list(
    stdout = "stdout here",
    stderr = "stderr here"
  ))
  expect_identical(testenv[["stdout"]], rep("stdout here", 2))
  expect_identical(testenv[["stderr"]], rep("stderr here", 2))
  rm(testenv)
})


test_that("canCallGeneric_start_log", {
  local_mocked_bindings(
    read_pipes = mock_subprocess_process_read_utils,
    .package = "wdman"
  )
  out <- generic_start_log("",
    poll = 1500L, outfile = "",
    errfile = ""
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
  outres <- read_pipes(env, outfile, errfile, "stdout",
    timeout = 20
  )
  errres <- read_pipes(env, outfile, errfile, "stderr",
    timeout = 20
  )
  expect_identical(bothres, list(stdout = "i am out", stderr = "i am err"))
  expect_identical(outres, "i am out")
  expect_identical(errres, "i am err")
})


test_that("canWindows_spawn_tofile", {
  outfile <- tempfile(fileext = ".txt")
  errfile <- tempfile(fileext = ".txt")
  local_mocked_bindings(
    check_bindings = function(...) {},
    .package = "testthat"
  )
  local_mocked_bindings(
    process = R6::R6Class(
      "process_test",
      public = list(
        initialize = function(command, ...) {
          self$res <- readLines(command)
        },
        res = list()
      )
    ),
    .package = "processx"
  )
  out <- windows_spawn_tofile("hello", "world", outfile, errfile)
  exRes <- paste(c(
    shQuote("hello"), "world", ">",
    shQuote(outfile), "2>", shQuote(errfile)
  ),
  collapse = " "
  )
  expect_identical(out$res, exRes)
})
