normalizePath <- function(...) base::normalizePath(...)
list.files <- function(...) base::list.files(...)

test_that("canCallChrome", {
  local_mocked_bindings(
    process_yaml = binman_process_yaml,
    list_versions = mock_binman_list_versions_chrome,
    app_dir = mock_binman_app_dir,
    .package = "binman"
  )
  local_mocked_bindings(
    normalizePath = mock_base_normalizePath,
    list.files = mock_base_list.files,
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
  )

  cDrv <- chrome()
  retCommand <- chrome(retcommand = TRUE)
  expect_identical(cDrv$output(), "infun")
  expect_identical(cDrv$error(), "infun")
  logOut <- cDrv$log()[["stdout"]]
  logErr <- cDrv$log()[["stderr"]]
  expect_identical(logOut, "super duper")
  expect_identical(logErr, "no error here")
  expect_identical(cDrv$stop(), "stopped")
  expect_identical(cDrv$process$test, "hello")
  expect_identical(
    retCommand,
    "some.path --port=4567 --url-base=wd/hub --verbose"
  )
})

test_that("chrome_verErrorWorks", {
  local_mocked_bindings(
    list_versions = mock_binman_list_versions_chrome,
    .package = "binman"
  )

  expect_error(
    wdman:::chrome_ver("linux64", "noversion"),
    "doesnt match versions"
  )
})

test_that("pickUpErrorFromReturnCode", {
  local_mocked_bindings(
    process_yaml = binman_process_yaml,
    list_versions = mock_binman_list_versions_chrome,
    app_dir = mock_binman_app_dir,
    .package = "binman"
  )
  local_mocked_bindings(
    normalizePath = mock_base_normalizePath,
    list.files = mock_base_list.files,
    .package = "base"
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
  )

  expect_error(
    chrome(),
    "Chromedriver couldn't be started"
  )
})

test_that("pickUpErrorFromPortInUse", {
  local_mocked_bindings(
    process_yaml = binman_process_yaml,
    list_versions = mock_binman_list_versions_chrome,
    app_dir = mock_binman_app_dir,
    .package = "binman"
  )
  local_mocked_bindings(
    normalizePath = mock_base_normalizePath,
    list.files = mock_base_list.files,
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
    kill_process = mock_subprocess_process_kill
  )

  expect_error(
    chrome(),
    "Chrome Driver signals port"
  )
})
