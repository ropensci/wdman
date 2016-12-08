context("phantom")

test_that("canCallPhantomJS", {
  with_mock(
    `binman::process_yaml` = function(...){},
    `binman::list_versions` = function(...){
      list(
        linux32 = c("1.9.7", "1.9.8", "2.1.1"),
        linux64 = c("1.9.7", "1.9.8", "2.1.1"),
        macosx = c("1.9.8", "2.0.0", "2.1.1"),
        windows = c("1.9.8", "2.0.0", "2.1.1")
      )
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
    pDrv <- phantomjs()
  )
  expect_identical(pDrv$process, "hello")
})
