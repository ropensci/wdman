test_that("assertionsWork", {
  expect_error(assertthat::assert_that(is_list("")), "is not a list")
  expect_error(
    assertthat::assert_that(is_env("")),
    "is not an environment"
  )
  expect_error(
    assertthat::assert_that(is_list_of_df("")),
    "is not a list of data.frames"
  )
  expect_error(
    assertthat::assert_that(is_url("")),
    "is not a url"
  )
  expect_error(
    assertthat::assert_that(is_file("")),
    "is not a file"
  )
  expect_error(
    assertthat::assert_that(is_URL_file("")),
    "is not a URL or file"
  )
  expect_true(is_URL_file("http://www.google.com"))
  expect_error(
    assertthat::assert_that(is_character(1L)),
    "should be an character vector"
  )
  expect_error(
    assertthat::assert_that(is_data.frame(1L)),
    "should be a data.frame"
  )
  expect_error(
    assertthat::assert_that(contains_required("", "nothere")),
    "does not have one of"
  )
  expect_error(
    assertthat::assert_that(app_dir_exists("")),
    "app directory not found"
  )
})
