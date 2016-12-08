context("iedriver")

test_that("canCallIEDriver", {
  myNP <- normalizePath
  with_mock(
    `binman::process_yaml` = function(...){},
    `binman::list_versions` = function(...){
      list(
        win64 = c("2.53.0", "2.53.1", "3.0.0"),
        win64 = c("2.53.0", "2.53.1", "3.0.0")
      )
    },
    `binman::app_dir` = function(...){
      "some.dir"
    },
    `base::normalizePath` = function(path, winslash, mustWork){
      path
    },
    `base::list.files` = function(...){
      "some.path"
    },
    `subprocess::spawn_process` = function(...){
      "hello"
    },
    `subprocess::process_return_code` = function(...){
      NA
    },
    `base::Sys.info` = function(...){
      structure("Windows", .Names = "sysname")
    },
    ieDrv <- iedriver()
  )
  expect_identical(ieDrv$process, "hello")
})
