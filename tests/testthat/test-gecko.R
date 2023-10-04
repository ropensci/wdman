normalizePath <- function(...) base::normalizePath(...)
list.files <- function(...) base::list.files(...)

test_that("canCallGecko", {
  local_mocked_bindings(
    process_yaml = binman_process_yaml,
    list_versions = mock_binman_list_versions_gecko,
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

  gDrv <- gecko()
  retCommand <- gecko(retcommand = TRUE)
  expect_identical(gDrv$output(), "infun")
  expect_identical(gDrv$error(), "infun")
  logOut <- gDrv$log()[["stdout"]]
  logErr <- gDrv$log()[["stderr"]]
  expect_identical(logOut, "super duper")
  expect_identical(logErr, "no error here")
  expect_identical(gDrv$stop(), "stopped")
  expect_identical(gDrv$process$test, "hello")
  expect_identical(
    retCommand,
    "some.path --port=4567 --log=info"
  )
})

test_that("gecko_verErrorWorks", {
  local_mocked_bindings(
    list_versions = mock_binman_list_versions_gecko,
    .package = "binman"
  )

  expect_error(
    wdman:::gecko_ver("linux64", "noversion"),
    "doesnt match versions"
  )
})

test_that("pickUpErrorFromReturnCode", {
  local_mocked_bindings(
    process_yaml = binman_process_yaml,
    list_versions = mock_binman_list_versions_gecko,
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
    process = mock_processx_process_fail,
    .package = "processx"
  )
  local_mocked_bindings(
    generic_start_log = mock_generic_start_log,
  )

  expect_error(
    gecko(),
    "Geckodriver couldn't be started"
  )
})

test_that("pickUpErrorFromPortInUse", {
  local_mocked_bindings(
    process_yaml = binman_process_yaml,
    list_versions = mock_binman_list_versions_gecko,
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
    gecko(),
    "Gecko Driver signals port"
  )
})
