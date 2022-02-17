library(wdman)

tries <- list()

tries$chrome <- tryCatch({
  tmp <- chrome(verbose = TRUE)
  print(tmp$log())
  tmp$stop()
  tmp
})

tries$gecko <- tryCatch({
  tmp <- gecko(verbose = TRUE)
  print(tmp$log())
  tmp$stop()
  tmp
})

tries$phantomjs <- tryCatch({
  tmp <- phantomjs(verbose = TRUE)
  print(tmp$log())
  tmp$stop()
  tmp
})

if (Sys.info()[["sysname"]] == "Windows") {
  tries$iedriver <- tryCatch({
    tmp <- iedriver(verbose = TRUE)
    print(tmp$log())
    tmp$stop()
    tmp
  })
}

tries$selenium <- tryCatch({
  tmp <- selenium(verbose = TRUE)
  print(tmp$log())
  tmp$stop()
  tmp
})

errors <- sapply(tries, function(x) is(x, "try-error"))
if (any(errors)) {
  stop("Failing ", paste(names(errors[errors]), collapse = ", "))
}
