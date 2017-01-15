context("iedriver")

test_that("canCallIEDriver", {
  with_mock(
    `binman::process_yaml` = function(...){},
    `binman::list_versions` = mock_binman_list_versions_iedriver,
    `binman::app_dir` = mock_binman_app_dir,
    `base::normalizePath` = mock_base_normalizePath,
    `base::list.files` = mock_base_list.files,
    `subprocess::spawn_process` = mock_subprocess_spawn_process,
    `subprocess::process_return_code` =
      mock_subprocess_process_return_code,
    `base::Sys.info` = function(...){
      structure("Windows", .Names = "sysname")
    },
    `wdman:::generic_start_log` = mock_generic_start_log,
    ieDrv <- iedriver()
  )
  expect_identical(ieDrv$process, "hello")
})

test_that("iedriver_verErrorWorks", {
  with_mock(
    `binman::list_versions` = mock_binman_list_versions_iedriver,
    expect_error(
      wdman:::ie_ver("linux64", "noversion"),
      "doesnt match versions"
    )
  )
})
