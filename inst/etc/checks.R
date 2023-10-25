library(wdman)

tries <- list()

tries$chrome <- tryCatch(
  {
    print("chrome")
    tmp <- chrome(verbose = TRUE)
    print(tmp$log())
    tmp$stop()
    tmp
  },
  error = function(e) {
    print(e$message)
    e
  }
)

tries$chrome_old <- tryCatch(
  {
    # Version of chrome that is not on the Chrome for Testing site
    print("chrome (old)")
    tmp <- chrome(verbose = TRUE, version = "114.0.5735.90")
    print(tmp$log())
    tmp$stop()
    tmp
  },
  error = function(e) {
    print(e$message)
    e
  }
)

tries$gecko <- tryCatch(
  {
    print("gecko")
    tmp <- gecko(verbose = TRUE)
    print(tmp$log())
    tmp$stop()
    tmp
  },
  error = function(e) {
    print(e$message)
    e
  }
)

tries$phantomjs <- tryCatch(
  {
    print("phantomjs")
    tmp <- phantomjs(verbose = TRUE)
    print(tmp$log())
    tmp$stop()
    tmp
  },
  error = function(e) {
    print(e$message)
    e
  }
)

if (Sys.info()[["sysname"]] == "Windows") {
  tries$iedriver <- tryCatch(
    {
      print("iedriver")
      tmp <- iedriver(verbose = TRUE)
      print(tmp$log())
      tmp$stop()
      tmp
    },
    error = function(e) {
      print(e$message)
      e
    }
  )
}

tries$selenium <- tryCatch(
  {
    print("selenium")
    tmp <- selenium(verbose = TRUE)
    print(tmp$log())
    tmp$stop()
    tmp
  },
  error = function(e) {
    print(e$message)
    e
  }
)

errors <- sapply(tries, function(x) is(x, "simpleError"))
if (any(errors)) {
  stop("Failing ", paste(names(errors[errors]), collapse = ", "))
}
