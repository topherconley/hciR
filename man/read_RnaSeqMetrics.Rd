% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read_RnaSeqMetrics.R
\name{read_RnaSeqMetrics}
\alias{read_RnaSeqMetrics}
\title{Read CollectRnaSeqMetrics output}
\usage{
read_RnaSeqMetrics(path = ".", pattern = "\\\\.txt$")
}
\arguments{
\item{path}{the path name to CollectRnaSeqMetrics output files, the default
corresponds to the working directory.}

\item{pattern}{a regular expression, default ".txt$". Only file names which
match the regular expression will be loaded.}
}
\value{
A list with coverage and stats tables
}
\description{
Reads CollectRnaSeqMetric output files and creates metrics and coverage tables.
}
\examples{
\dontrun{
   # read all *.txt files in out/ directory
   read_RnaSeqMetrics( "out")
   # read output files matching Control-1 in current directory
   read_RnaSeqMetrics( pattern="Control-1")
}
}
\author{
Chris Stubben
}

