normalizePath <- function(...) base::normalizePath(...)
list.files <- function(...) base::list.files(...)

test_that("canCallPhantomJS", {
  local_mocked_bindings(
    process_yaml = binman_process_yaml,
    list_versions = mock_binman_list_versions_phantomjs,
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
  pDrv <- phantomjs(version = "latest")
  retCommand <- phantomjs(version = "latest", retcommand = TRUE)
  expect_identical(pDrv$output(), "infun")
  expect_identical(pDrv$error(), "infun")
  logOut <- pDrv$log()[["stdout"]]
  logErr <- pDrv$log()[["stderr"]]
  expect_identical(logOut, "super duper")
  expect_identical(logErr, "no error here")
  expect_identical(pDrv$stop(), "stopped")
  expect_identical(pDrv$process$test, "hello")
  expect_identical(
    retCommand,
    "some.path --webdriver=4567 --webdriver-loglevel=INFO"
  )
})

test_that("phantom_verErrorWorks", {
  local_mocked_bindings(
    list_versions = mock_binman_list_versions_phantomjs,
    .package = "binman"
  )
  expect_error(
    wdman:::phantom_ver("linux64", "noversion"),
    "doesnt match versions"
  )
})

test_that("pickUpErrorFromReturnCode", {
  local_mocked_bindings(
    process_yaml = binman_process_yaml,
    list_versions = mock_binman_list_versions_phantomjs,
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
    phantomjs(),
    "PhantomJS couldn't be started"
  )
})

test_that("pickUpErrorFromPortInUse", {
  local_mocked_bindings(
    process_yaml = binman_process_yaml,
    list_versions = mock_binman_list_versions_phantomjs,
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
      list(stdout = "GhostDriver - main.fail.*sourceURL")
    },
    kill_process = mock_subprocess_process_kill
  )
  expect_error(
    phantomjs(version = "2.1.1"),
    "PhantomJS signals port"
  )
})
