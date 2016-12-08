context("chrome")

test_that("canCallChrome", {
  with_mock(
    `binman::process_yaml` = function(...){},
    `binman::list_versions` = function(...){
      list(
        linux64 = c("2.23", "2.24", "2.25", "2.26"),
        mac64 = c("2.23", "2.24", "2.25"),
        win32 = c("2.23", "2.24", "2.25")
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
    cDrv <- chrome()
  )
  expect_identical(cDrv$process, "hello")
})
