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
    `subprocess::process_kill` = mock_subprocess_process_kill,
    `wdman:::generic_start_log` = mock_generic_start_log,
    `wdman:::infun_read` = function(...){"infun"},
    {
      cDrv <- chrome()
      expect_identical(cDrv$output(), "infun")
      expect_identical(cDrv$error(), "infun")
      logOut <- cDrv$log()[["stdout"]]
      logErr <- cDrv$log()[["stderr"]]
      expect_identical(logOut, "super duper")
      expect_identical(logErr, "no error here")
      expect_identical(cDrv$stop(), "stopped")
    }
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
