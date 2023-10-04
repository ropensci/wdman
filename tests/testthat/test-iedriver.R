normalizePath <- function(...) base::normalizePath(...)
list.files <- function(...) base::list.files(...)
Sys.info <- function(...) base::Sys.info(...)

test_that("canCallIEDriver", {
  skip_on_os(c("mac", "linux"))

  local_mocked_bindings(
    process_yaml = binman_process_yaml,
    list_versions = mock_binman_list_versions_iedriver,
    app_dir = mock_binman_app_dir,
    .package = "binman"
  )
  local_mocked_bindings(
    normalizePath = mock_base_normalizePath,
    list.files = mock_base_list.files,
    Sys.info = function(...) {
      structure("Windows", .Names = "sysname")
    },
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

  ieDrv <- iedriver()
  retCommand <- iedriver(retcommand = TRUE)
  expect_identical(ieDrv$output(), "infun")
  expect_identical(ieDrv$error(), "infun")
  logOut <- ieDrv$log()[["stdout"]]
  logErr <- ieDrv$log()[["stderr"]]
  expect_identical(logOut, "super duper")
  expect_identical(logErr, "no error here")
  expect_identical(ieDrv$stop(), "stopped")
  expect_identical(ieDrv$process, "hello")
  expect_true(grepl("some.path /port=4567 /log-level=FATAL", retCommand))
})


test_that("iedriver_verErrorWorks", {
  local_mocked_bindings(
    list_versions = mock_binman_list_versions_iedriver,
    .package = "binman"
  )

  expect_error(
    wdman:::ie_ver("linux64", "noversion"),
    "doesnt match versions"
  )
})


test_that("pickUpErrorFromReturnCode", {
  skip_on_os(c("mac", "linux"))

  local_mocked_bindings(
    process_yaml = binman_process_yaml,
    list_versions = mock_binman_list_versions_iedriver,
    app_dir = mock_binman_app_dir,
    .package = "binman"
  )
  local_mocked_bindings(
    normalizePath = mock_base_normalizePath,
    list.files = mock_base_list.files,
    Sys.info = function(...) {
      structure("Windows", .Names = "sysname")
    },
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
    iedriver(),
    "iedriver couldn't be started"
  )
})


test_that("pickUpErrorFromPortInUse", {
  skip_on_os(c("mac", "linux"))

  local_mocked_bindings(
    process_yaml = binman_process_yaml,
    list_versions = mock_binman_list_versions_iedriver,
    app_dir = mock_binman_app_dir,
    .package = "binman"
  )
  local_mocked_bindings(
    normalizePath = mock_base_normalizePath,
    list.files = mock_base_list.files,
    Sys.info = function(...) {
      structure("Windows", .Names = "sysname")
    },
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
    iedriver(),
    "IE Driver signals port"
  )
})
