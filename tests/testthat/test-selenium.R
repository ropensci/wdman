context("selenium")

test_that("canCallSelenium", {
  with_mock(
    `binman::process_yaml` = function(...){},
    `binman::list_versions` = mock_binman_list_versions_selenium,
    `binman::app_dir` = mock_binman_app_dir,
    `base::normalizePath` = mock_base_normalizePath,
    `base::list.files` = mock_base_list.files,
    `subprocess::spawn_process` = mock_subprocess_spawn_process,
    `subprocess::process_return_code` =
      mock_subprocess_process_return_code,
    `subprocess::process_read` =
      mock_subprocess_process_read_selenium,
    `subprocess::process_kill` = mock_subprocess_process_kill,
    `wdman:::generic_start_log` = mock_generic_start_log,
    `wdman:::infun_read` = function(...){"infun"},
    `base::Sys.info` = function(...){
      structure("Windows", .Names = "sysname")
    },
    # CHROME
    `wdman:::chrome_check` = function(...){
      list(platform = "some.plat")
    },
    `wdman:::chrome_ver` = function(...){
      list(path = "some.path")
    },
    # GECKO
    `wdman:::gecko_check` = function(...){
      list(platform = "some.plat")
    },
    `wdman:::gecko_ver` = function(...){
      list(path = "some.path")
    },
    # PHANTOMJS
    `wdman:::phantom_check` = function(...){
      list(platform = "some.plat")
    },
    `wdman:::phantom_ver` = function(...){
      list(path = "some.path")
    },
    # INTERNET EXPLORER
    `wdman:::ie_check` = function(...){
      list(platform = "some.plat")
    },
    `wdman:::ie_ver` = function(...){
      list(path = "some.path")
    },
    {
      selServ <- selenium(iedrver = "latest")
      expect_identical(selServ$output(), "infun")
      expect_identical(selServ$error(), "infun")
      logOut <- selServ$log()[["stdout"]]
      logErr <- selServ$log()[["stderr"]]
      expect_identical(logOut, "super duper")
      expect_identical(logErr, "no error here")
      expect_identical(selServ$stop(), "stopped")
    }
  )
  expect_identical(selServ$process, "hello")
})

test_that("errorIfJavaNotFound", {
  with_mock(
    `base::Sys.which`= function(...){""},
    expect_error(selenium(), "PATH to JAVA not found")
  )
})

test_that("errorIfVersionNotFound", {
  with_mock(
    `base::Sys.which`= function(...){"im here"},
    `binman::process_yaml` = function(...){},
    `binman::list_versions` = mock_binman_list_versions_selenium,
    expect_error(selenium(version = "nothere"),
                 "version requested doesnt match versions available")
  )
})

test_that("pickUpErrorFromReturnCode", {
  with_mock(
    `binman::process_yaml` = function(...){},
    `binman::list_versions` = mock_binman_list_versions_selenium,
    `binman::app_dir` = mock_binman_app_dir,
    `base::normalizePath` = mock_base_normalizePath,
    `base::list.files` = mock_base_list.files,
    `subprocess::spawn_process` = mock_subprocess_spawn_process,
    `subprocess::process_return_code` = function(...){"some error"},
    `subprocess::process_read` =
      mock_subprocess_process_read_selenium,
    `wdman:::generic_start_log` = mock_generic_start_log,
    `base::Sys.info` = function(...){
      structure("Windows", .Names = "sysname")
    },
    # CHROME
    `wdman:::chrome_check` = function(...){
      list(platform = "some.plat")
    },
    `wdman:::chrome_ver` = function(...){
      list(path = "some.path")
    },
    # GECKO
    `wdman:::gecko_check` = function(...){
      list(platform = "some.plat")
    },
    `wdman:::gecko_ver` = function(...){
      list(path = "some.path")
    },
    # PHANTOMJS
    `wdman:::phantom_check` = function(...){
      list(platform = "some.plat")
    },
    `wdman:::phantom_ver` = function(...){
      list(path = "some.path")
    },
    # INTERNET EXPLORER
    `wdman:::ie_check` = function(...){
      list(platform = "some.plat")
    },
    `wdman:::ie_ver` = function(...){
      list(path = "some.path")
    },
    expect_error(selenium(version = "3.0.1", iedrver = "latest"),
                 "Selenium server couldn't be started")
  )
})

test_that("pickUpErrorFromPortInUse", {
  with_mock(
    `binman::process_yaml` = function(...){},
    `binman::list_versions` = mock_binman_list_versions_selenium,
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
      list(stderr = "Address already in use")
    },
    `base::Sys.info` = function(...){
      structure("Windows", .Names = "sysname")
    },
    # CHROME
    `wdman:::chrome_check` = function(...){
      list(platform = "some.plat")
    },
    `wdman:::chrome_ver` = function(...){
      list(path = "some.path")
    },
    # GECKO
    `wdman:::gecko_check` = function(...){
      list(platform = "some.plat")
    },
    `wdman:::gecko_ver` = function(...){
      list(path = "some.path")
    },
    # PHANTOMJS
    `wdman:::phantom_check` = function(...){
      list(platform = "some.plat")
    },
    `wdman:::phantom_ver` = function(...){
      list(path = "some.path")
    },
    # INTERNET EXPLORER
    `wdman:::ie_check` = function(...){
      list(platform = "some.plat")
    },
    `wdman:::ie_ver` = function(...){
      list(path = "some.path")
    },
    expect_error(selenium(), "Selenium server signals port")
  )
})

test_that("pickUpWarningOnNoStderr", {
  with_mock(
    `binman::process_yaml` = function(...){},
    `binman::list_versions` = mock_binman_list_versions_selenium,
    `binman::app_dir` = mock_binman_app_dir,
    `base::normalizePath` = mock_base_normalizePath,
    `base::list.files` = mock_base_list.files,
    `subprocess::spawn_process` = mock_subprocess_spawn_process,
    `subprocess::process_return_code` =
      mock_subprocess_process_return_code,
    `subprocess::process_read` =
      mock_subprocess_process_read_selenium,
    `wdman:::generic_start_log` =
      function(...){list(stdout = character(), stderr = character())},
    `base::Sys.info` = function(...){
      structure("Windows", .Names = "sysname")
    },
    # CHROME
    `wdman:::chrome_check` = function(...){
      list(platform = "some.plat")
    },
    `wdman:::chrome_ver` = function(...){
      list(path = "some.path")
    },
    # GECKO
    `wdman:::gecko_check` = function(...){
      list(platform = "some.plat")
    },
    `wdman:::gecko_ver` = function(...){
      list(path = "some.path")
    },
    # PHANTOMJS
    `wdman:::phantom_check` = function(...){
      list(platform = "some.plat")
    },
    `wdman:::phantom_ver` = function(...){
      list(path = "some.path")
    },
    # INTERNET EXPLORER
    `wdman:::ie_check` = function(...){
      list(platform = "some.plat")
    },
    `wdman:::ie_ver` = function(...){
      list(path = "some.path")
    },
    expect_warning(selenium(), "No output to stderr yet detected")
  )
})
