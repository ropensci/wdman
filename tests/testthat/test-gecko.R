context("gecko")

test_that("canCallGecko", {
  with_mock(
    `binman::process_yaml` = function(...){},
    `binman::list_versions` = mock_binman_list_versions_gecko,
    `binman::app_dir` = mock_binman_app_dir,
    `base::normalizePath` = mock_base_normalizePath,
    `base::list.files` = mock_base_list.files,
    `subprocess::spawn_process` = mock_subprocess_spawn_process,
    `subprocess::process_return_code` =
      mock_subprocess_process_return_code,
    `wdman:::generic_start_log` = mock_generic_start_log,
    `wdman:::infun_read` = function(...){"infun"},
    {
      gDrv <- gecko()
      expect_identical(gDrv$output(), "infun")
      expect_identical(gDrv$error(), "infun")
      logOut <- gDrv$log()[["stdout"]]
      logErr <- gDrv$log()[["stderr"]]
      expect_identical(logOut, "super duper")
      expect_identical(logErr, "no error here")
    }
  )
  expect_identical(gDrv$process, "hello")
})

test_that("gecko_verErrorWorks", {
  with_mock(
    `binman::list_versions` = mock_binman_list_versions_gecko,
    expect_error(
      wdman:::gecko_ver("linux64", "noversion"),
      "doesnt match versions"
    )
  )
})
