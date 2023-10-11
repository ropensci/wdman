normalizePath <- function(...) base::normalizePath(...)
list.files <- function(...) base::list.files(...)
Sys.info <- function(...) base::Sys.info(...)
Sys.which <- function(...) base::Sys.which(...)

test_that("canCallSelenium", {
  local_mocked_bindings(
    process_yaml = binman_process_yaml,
    list_versions = mock_binman_list_versions_selenium,
    app_dir = mock_binman_app_dir,
  )
  local_mocked_bindings(
    normalizePath = mock_base_normalizePath,
    list.files = mock_base_list.files,
    Sys.info = mock_base_Sys.info_windows,
    .package = "base",
  )
  local_mocked_bindings(
    check_bindings = function(...) {},
    .package = "testthat"
  )
  local_mocked_bindings(
    process = mock_processx_process,
    .package = "processx"
  )
  local_mocked_bindings(
    generic_start_log = mock_generic_start_log,
    infun_read = function(...) {
      "infun"
    },
    kill_process = mock_subprocess_process_kill,
    chrome_check = mock_generic_check,
    chrome_ver = mock_generic_ver,
    gecko_check = mock_generic_check,
    gecko_ver = mock_generic_ver,
    phantom_check = mock_generic_check,
    phantom_ver = mock_generic_ver,
    ie_check = mock_generic_check,
    ie_ver = mock_generic_ver,
  )

  selServ <- selenium(iedrver = "latest")
  retCommand <- selenium(iedrver = "latest", retcommand = TRUE)
  expect_identical(selServ$output(), "infun")
  expect_identical(selServ$error(), "infun")
  logOut <- selServ$log()[["stdout"]]
  logErr <- selServ$log()[["stderr"]]
  expect_identical(logOut, "super duper")
  expect_identical(logErr, "no error here")
  expect_identical(selServ$stop(), "stopped")
  expect_identical(selServ$process$test, "hello")
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
  local_mocked_bindings(
    Sys.which = function(...) {
      ""
    },
    .package = "base"
  )

  expect_error(selenium(), "PATH to JAVA not found")
})

test_that("errorIfVersionNotFound", {
  local_mocked_bindings(
    process_yaml = binman_process_yaml,
    list_versions = mock_binman_list_versions_selenium,
  )
  local_mocked_bindings(
    Sys.which = function(...) {
      "im here"
    },
    .package = "base"
  )

  expect_error(
    selenium(version = "nothere"),
    "version requested doesnt match versions available"
  )
})

test_that("pickUpErrorFromReturnCode", {
  local_mocked_bindings(
    process_yaml = binman_process_yaml,
    list_versions = mock_binman_list_versions_selenium,
    app_dir = mock_binman_app_dir,
  )
  local_mocked_bindings(
    normalizePath = mock_base_normalizePath,
    list.files = mock_base_list.files,
    Sys.info = mock_base_Sys.info_windows,
    .package = "base",
  )
  local_mocked_bindings(
    check_bindings = function(...) {},
    .package = "testthat"
  )
  local_mocked_bindings(
    process = mock_processx_process_fail,
    .package = "processx"
  )
  local_mocked_bindings(
    generic_start_log = mock_generic_start_log,
    chrome_check = mock_generic_check,
    chrome_ver = mock_generic_ver,
    gecko_check = mock_generic_check,
    gecko_ver = mock_generic_ver,
    phantom_check = mock_generic_check,
    phantom_ver = mock_generic_ver,
    ie_check = mock_generic_check,
    ie_ver = mock_generic_ver,
  )

  expect_error(
    selenium(version = "3.0.1", iedrver = "latest"),
    "Selenium server couldn't be started"
  )
})

test_that("pickUpErrorFromPortInUse", {
  local_mocked_bindings(
    process_yaml = binman_process_yaml,
    list_versions = mock_binman_list_versions_selenium,
    app_dir = mock_binman_app_dir,
  )
  local_mocked_bindings(
    normalizePath = mock_base_normalizePath,
    list.files = mock_base_list.files,
    Sys.info = mock_base_Sys.info_windows,
    .package = "base"
  )
  local_mocked_bindings(
    check_bindings = function(...) {},
    .package = "testthat"
  )
  local_mocked_bindings(
    process = mock_processx_process,
    .package = "processx"
  )
  local_mocked_bindings(
    generic_start_log = function(...) {
      list(stderr = "Address already in use")
    },
    kill_process = mock_subprocess_process_kill,
    chrome_check = mock_generic_check,
    chrome_ver = mock_generic_ver,
    gecko_check = mock_generic_check,
    gecko_ver = mock_generic_ver,
    phantom_check = mock_generic_check,
    phantom_ver = mock_generic_ver,
    ie_check = mock_generic_check,
    ie_ver = mock_generic_ver,
  )

  expect_error(selenium(), "Selenium server signals port")
})

test_that("pickUpWarningOnNoStderr", {
  local_mocked_bindings(
    process_yaml = binman_process_yaml,
    list_versions = mock_binman_list_versions_selenium,
    app_dir = mock_binman_app_dir,
  )
  local_mocked_bindings(
    normalizePath = mock_base_normalizePath,
    list.files = mock_base_list.files,
    Sys.info = mock_base_Sys.info_windows,
    .package = "base",
  )
  local_mocked_bindings(
    check_bindings = function(...) {},
    .package = "testthat"
  )
  local_mocked_bindings(
    process = mock_processx_process,
    .package = "processx"
  )
  local_mocked_bindings(
    generic_start_log = function(...) {
      list(stdout = character(), stderr = character())
    },
    chrome_check = mock_generic_check,
    chrome_ver = mock_generic_ver,
    gecko_check = mock_generic_check,
    gecko_ver = mock_generic_ver,
    phantom_check = mock_generic_check,
    phantom_ver = mock_generic_ver,
    ie_check = mock_generic_check,
    ie_ver = mock_generic_ver,
  )

  expect_warning(selenium(), "No output to stderr yet detected")
})
