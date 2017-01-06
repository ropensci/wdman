context("selenium")

test_that("canCallSelenium", {
  with_mock(
    `binman::process_yaml` = function(...){},
    `binman::list_versions` = mock_binman_list_versions_selenium,
    `binman::app_dir` = mock_binman_app_dir,
    `base::normalizePath` = mock_base_normalizePath,
    `base::list.files` = mock_base_list.files,
    `subprocess::spawn_process` = mock_subprocess_spawn_process,
    `subprocess::process_return_code` =
      mock_subprocess_process_return_code,
    `subprocess::process_read` =
      mock_subprocess_process_read_selenium,
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