% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/iedriver.R
\name{iedriver}
\alias{iedriver}
\title{Start IE driver server}
\usage{
iedriver(
  port = 4567L,
  version = "latest",
  check = TRUE,
  loglevel = c("FATAL", "TRACE", "DEBUG", "INFO", "WARN", "ERROR"),
  verbose = TRUE,
  retcommand = FALSE,
  ...
)
}
\arguments{
\item{port}{Port to run on}

\item{version}{what version of IE driver server to run. Default = "latest"
which runs the most recent version. To see other version currently
sourced run binman::list_versions("iedriverserver")}

\item{check}{If TRUE check the versions of IE driver available. If
new versions are available they will be downloaded.}

\item{loglevel}{Specifies the log level used by the server. Valid values
are: TRACE, DEBUG, INFO, WARN, ERROR, and FATAL. Defaults to FATAL
if not specified.}

\item{verbose}{If TRUE, include status messages (if any)}

\item{retcommand}{If TRUE return only the command that would be passed
to \code{\link[processx]{process}}}

\item{...}{pass additional options to the driver}
}
\value{
Returns a list with named elements \code{process}, \code{output},
    \code{error}, \code{stop}, and \code{log}.
    \code{process} is the object from calling \code{\link[processx]{process}}.
    \code{output} and \code{error} are the functions reading the latest
    messages from "stdout" and "stderr" since the last call whereas \code{log}
    is the function that reads all messages.
    Lastly, \code{stop} call the \code{kill} method in
    \code{\link[processx]{process}} to the kill the \code{process}.
}
\description{
Start IE driver server
}
\examples{
\dontrun{
ieDrv <- iedriver()
ieDrv$output()
ieDrv$stop()
}

}
