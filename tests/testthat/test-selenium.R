context("selenium")

normalizePath <- function(...) base::normalizePath(...)
list.files <- function(...) base::list.files(...)
Sys.info <- function(...) base::Sys.info(...)
Sys.which <- function(...) base::Sys.which(...)

test_that("canCallSelenium", {
  with_mock(
    `binman::process_yaml` = function(...) {},
    `binman::list_versions` = mock_binman_list_versions_selenium,
    `binman::app_dir` = mock_binman_app_dir,
    normalizePath = mock_base_normalizePath,
    list.files = mock_base_list.files,
    `subprocess::spawn_process` = mock_subprocess_spawn_process,
    `subprocess::process_return_code` =
      mock_subprocess_process_return_code,
    `subprocess::process_read` =
      mock_subprocess_process_read_selenium,
    `subprocess::process_kill` = mock_subprocess_process_kill,
    `wdman:::generic_start_log` = mock_generic_start_log,
    `wdman:::infun_read` = function(...) {
      "infun"
    },
    Sys.info = function(...) {
      structure("Windows", .Names = "sysname")
    },
    # CHROME
    `wdman:::chrome_check` = function(...) {
      list(platform = "some.plat")
    },
    `wdman:::chrome_ver` = function(...) {
      list(path = "some.path")
    },
    # GECKO
    `wdman:::gecko_check` = function(...) {
      list(platform = "some.plat")
    },
    `wdman:::gecko_ver` = function(...) {
      list(path = "some.path")
    },
    # PHANTOMJS
    `wdman:::phantom_check` = function(...) {
      list(platform = "some.plat")
    },
    `wdman:::phantom_ver` = function(...) {
      list(path = "some.path")
    },
    # INTERNET EXPLORER
    `wdman:::ie_check` = function(...) {
      list(platform = "some.plat")
    },
    `wdman:::ie_ver` = function(...) {
      list(path = "some.path")
    },
    {
      selServ <- selenium(iedrver = "latest")
      retCommand <- selenium(iedrver = "latest", retcommand = TRUE)
      expect_identical(selServ$output(), "infun")
      expect_identical(selServ$error(), "infun")
      logOut <- selServ$log()[["stdout"]]
      logErr <- selServ$log()[["stderr"]]
      expect_identical(logOut, "super duper")
      expect_identical(logErr, "no error here")
      expect_identical(selServ$stop(), "stopped")
    }
  )
  expect_identical(selServ$process, "hello")
  exRet <- "-Dwebdriver.chrome.driver='some.path' " %+%
    "-Dwebdriver.gecko.driver='some.path' " %+%
    "-Dphantomjs.binary.path='some.path' " %+%
    "-Dwebdriver.ie.driver='some.path' " %+%
    "-jar 'some.path' -port 4567"
  if (identical(.Platform[["OS.type"]], "unix")) {
    expect_true(grepl(exRet, retCommand))
  } else {
    expect_true(grepl(gsub("'", "\"", exRet), retCommand))
  }
})

test_that("errorIfJavaNotFound", {
  with_mock(
    Sys.which = function(...) {
      ""
    },
    expect_error(selenium(), "PATH to JAVA not found")
  )
})

test_that("errorIfVersionNotFound", {
  with_mock(
    Sys.which = function(...) {
      "im here"
    },
    `binman::process_yaml` = function(...) {},
    `binman::list_versions` = mock_binman_list_versions_selenium,
    expect_error(
      selenium(version = "nothere"),
      "version requested doesnt match versions available"
    )
  )
})

test_that("pickUpErrorFromReturnCode", {
  with_mock(
    `binman::process_yaml` = function(...) {},
    `binman::list_versions` = mock_binman_list_versions_selenium,
    `binman::app_dir` = mock_binman_app_dir,
    normalizePath = mock_base_normalizePath,
    list.files = mock_base_list.files,
    `subprocess::spawn_process` = mock_subprocess_spawn_process,
    `subprocess::process_return_code` = function(...) {
      "some error"
    },
    `subprocess::process_read` =
      mock_subprocess_process_read_selenium,
    `wdman:::generic_start_log` = mock_generic_start_log,
    Sys.info = function(...) {
      structure("Windows", .Names = "sysname")
    },
    # CHROME
    `wdman:::chrome_check` = function(...) {
      list(platform = "some.plat")
    },
    `wdman:::chrome_ver` = function(...) {
      list(path = "some.path")
    },
    # GECKO
    `wdman:::gecko_check` = function(...) {
      list(platform = "some.plat")
    },
    `wdman:::gecko_ver` = function(...) {
      list(path = "some.path")
    },
    # PHANTOMJS
    `wdman:::phantom_check` = function(...) {
      list(platform = "some.plat")
    },
    `wdman:::phantom_ver` = function(...) {
      list(path = "some.path")
    },
    # INTERNET EXPLORER
    `wdman:::ie_check` = function(...) {
      list(platform = "some.plat")
    },
    `wdman:::ie_ver` = function(...) {
      list(path = "some.path")
    },
    expect_error(
      selenium(version = "3.0.1", iedrver = "latest"),
      "Selenium server couldn't be started"
    )
  )
})

test_that("pickUpErrorFromPortInUse", {
  with_mock(
    `binman::process_yaml` = function(...) {},
    `binman::list_versions` = mock_binman_list_versions_selenium,
    `binman::app_dir` = mock_binman_app_dir,
    normalizePath = mock_base_normalizePath,
    list.files = mock_base_list.files,
    `subprocess::spawn_process` = mock_subprocess_spawn_process,
    `subprocess::process_return_code` =
      mock_subprocess_process_return_code,
    `subprocess::process_read` =
      mock_subprocess_process_read_selenium,
    `subprocess::process_kill` = mock_subprocess_process_kill,
    `wdman:::generic_start_log` = function(...) {
      list(stderr = "Address already in use")
    },
    Sys.info = function(...) {
      structure("Windows", .Names = "sysname")
    },
    # CHROME
    `wdman:::chrome_check` = function(...) {
      list(platform = "some.plat")
    },
    `wdman:::chrome_ver` = function(...) {
      list(path = "some.path")
    },
    # GECKO
    `wdman:::gecko_check` = function(...) {
      list(platform = "some.plat")
    },
    `wdman:::gecko_ver` = function(...) {
      list(path = "some.path")
    },
    # PHANTOMJS
    `wdman:::phantom_check` = function(...) {
      list(platform = "some.plat")
    },
    `wdman:::phantom_ver` = function(...) {
      list(path = "some.path")
    },
    # INTERNET EXPLORER
    `wdman:::ie_check` = function(...) {
      list(platform = "some.plat")
    },
    `wdman:::ie_ver` = function(...) {
      list(path = "some.path")
    },
    expect_error(selenium(), "Selenium server signals port")
  )
})

test_that("pickUpWarningOnNoStderr", {
  with_mock(
    `binman::process_yaml` = function(...) {},
    `binman::list_versions` = mock_binman_list_versions_selenium,
    `binman::app_dir` = mock_binman_app_dir,
    normalizePath = mock_base_normalizePath,
    list.files = mock_base_list.files,
    `subprocess::spawn_process` = mock_subprocess_spawn_process,
    `subprocess::process_return_code` =
      mock_subprocess_process_return_code,
    `subprocess::process_read` =
      mock_subprocess_process_read_selenium,
    `wdman:::generic_start_log` =
      function(...) {
        list(stdout = character(), stderr = character())
      },
    Sys.info = function(...) {
      structure("Windows", .Names = "sysname")
    },
    # CHROME
    `wdman:::chrome_check` = function(...) {
      list(platform = "some.plat")
    },
    `wdman:::chrome_ver` = function(...) {
      list(path = "some.path")
    },
    # GECKO
    `wdman:::gecko_check` = function(...) {
      list(platform = "some.plat")
    },
    `wdman:::gecko_ver` = function(...) {
      list(path = "some.path")
    },
    # PHANTOMJS
    `wdman:::phantom_check` = function(...) {
      list(platform = "some.plat")
    },
    `wdman:::phantom_ver` = function(...) {
      list(path = "some.path")
    },
    # INTERNET EXPLORER
    `wdman:::ie_check` = function(...) {
      list(platform = "some.plat")
    },
    `wdman:::ie_ver` = function(...) {
      list(path = "some.path")
    },
    expect_warning(selenium(), "No output to stderr yet detected")
  )
})
