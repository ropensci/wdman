context("selenium")

test_that("canCallSelenium", {
  with_mock(
    `binman::process_yaml` = function(...){},
    `binman::list_versions` = function(...){
      list(
        generic = c("3.0.0", "3.0.0-beta4", "3.0.1")
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
    # CHROME
    `wdman:::chrome_check` = function(...){
      list(platform = "some.plat")
    },
    `wdman:::chrome_ver` = function(...){
      list(path = "some.path")
    },
    # GECKO
    `wdman:::gecko_check` = function(...){
      list(platform = "some.plat")
    },
    `wdman:::gecko_ver` = function(...){
      list(path = "some.path")
    },
    # PHANTOMJS
    `wdman:::phantom_check` = function(...){
      list(platform = "some.plat")
    },
    `wdman:::phantom_ver` = function(...){
      list(path = "some.path")
    },
    # INTERNET EXPLORER
    `wdman:::ie_check` = function(...){
      list(platform = "some.plat")
    },
    `wdman:::ie_ver` = function(...){
      list(path = "some.path")
    },
    selServ <- selenium(iedrver = "latest")
  )
  expect_identical(selServ$process, "hello")
})
