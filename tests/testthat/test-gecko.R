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
    `subprocess::process_kill` = mock_subprocess_process_kill,
    `wdman:::generic_start_log` = mock_generic_start_log,
    `wdman:::infun_read` = function(...){"infun"},
    {
      gDrv <- gecko()
      retCommand <- gecko(retcommand = TRUE)
      expect_identical(gDrv$output(), "infun")
      expect_identical(gDrv$error(), "infun")
      logOut <- gDrv$log()[["stdout"]]
      logErr <- gDrv$log()[["stderr"]]
      expect_identical(logOut, "super duper")
      expect_identical(logErr, "no error here")
      expect_identical(gDrv$stop(), "stopped")
    }
  )
  expect_identical(gDrv$process, "hello")
  expect_identical(retCommand,
                   "some.path --port=4567 --log=info")
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

test_that("pickUpErrorFromReturnCode", {
  with_mock(
    `binman::process_yaml` = function(...){},
    `binman::list_versions` = mock_binman_list_versions_gecko,
    `binman::app_dir` = mock_binman_app_dir,
    `base::normalizePath` = mock_base_normalizePath,
    `base::list.files` = mock_base_list.files,
    `subprocess::spawn_process` = mock_subprocess_spawn_process,
    `subprocess::process_return_code` = function(...){"some error"},
    `subprocess::process_read` =
      mock_subprocess_process_read_selenium,
    `wdman:::generic_start_log` = mock_generic_start_log,
    {
      expect_error(gecko(version = "0.11.0"),
                   "Geckodriver couldn't be started")
    }
  )
})

test_that("pickUpErrorFromPortInUse", {
  with_mock(
    `binman::process_yaml` = function(...){},
    `binman::list_versions` = mock_binman_list_versions_gecko,
    `binman::app_dir` = mock_binman_app_dir,
    `base::normalizePath` = mock_base_normalizePath,
    `base::list.files` = mock_base_list.files,
    `subprocess::spawn_process` = mock_subprocess_spawn_process,
    `subprocess::process_return_code` =
      mock_subprocess_process_return_code,
    `subprocess::process_read` =
      mock_subprocess_process_read_selenium,
    `subprocess::process_kill` = mock_subprocess_process_kill,
    `wdman:::generic_start_log` = function(...){
      list(stderr = "Address in use")
    },
    {
      expect_error(gecko(version = "0.11.0"),
                   "Gecko Driver signals port")
    }
  )
})

