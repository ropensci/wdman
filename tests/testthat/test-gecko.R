context("gecko")

test_that("canCallChromeGecko", {
  with_mock(
    `binman::process_yaml` = function(...){},
    `binman::list_versions` = function(...){
      list(
        linux64 = c("v0.10.0", "v0.11.0", "v0.11.1"),
        macos = c("v0.10.0", "v0.11.0", "v0.11.1"),
        win64 = c("v0.10.0", "v0.11.0", "v0.11.1")
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
    gDrv <- gecko()
  )
  expect_identical(gDrv$process, "hello")
})
