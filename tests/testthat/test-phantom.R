context("phantom")

test_that("canCallPhantomJS", {
  with_mock(
    `binman::process_yaml` = function(...){},
    `binman::list_versions` = mock_binman_list_versions_phantomjs,
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
      pDrv <- phantomjs()
      expect_identical(pDrv$output(), "infun")
      expect_identical(pDrv$error(), "infun")
      logOut <- pDrv$log()[["stdout"]]
      logErr <- pDrv$log()[["stderr"]]
      expect_identical(logOut, "super duper")
      expect_identical(logErr, "no error here")
      expect_identical(pDrv$stop(), "stopped")
    }
  )
  expect_identical(pDrv$process, "hello")
})

test_that("phantom_verErrorWorks", {
  with_mock(
    `binman::list_versions` = mock_binman_list_versions_phantomjs,
    expect_error(
      wdman:::phantom_ver("linux64", "noversion"),
      "doesnt match versions"
    )
  )
})
