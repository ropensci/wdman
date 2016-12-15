context("chrome")
test_that("canCallChrome", {
  with_mock(
    `binman::process_yaml` = binman_process_yaml,
    `binman::list_versions` = mock_binman_list_versions_chrome,
    `binman::app_dir` = mock_binman_app_dir,
    `base::normalizePath` = mock_base_normalizePath,
    `base::list.files` = mock_base_list.files,
    `subprocess::spawn_process` = mock_subprocess_spawn_process,
    `subprocess::process_return_code` =
      mock_subprocess_process_return_code,
    cDrv <- chrome()
  )
  expect_identical(cDrv$process, "hello")
})

test_that("chrome_verErrorWorks", {
  with_mock(
    `binman::list_versions` = mock_binman_list_versions_chrome,
    expect_error(
      wdman:::chrome_ver("linux64", "noversion"),
      "doesnt match versions"
    )
  )
})
