% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/deseq_from_tibble.R
\name{deseq_from_tibble}
\alias{deseq_from_tibble}
\alias{factor_trts}
\title{Run DESeq from tibbles}
\usage{
deseq_from_tibble(count_tbl, sample_tbl, ...)

factor_trts(samples)
}
\arguments{
\item{count_tbl}{a count table with feature ids in row 1}

\item{sample_tbl}{a sample table with names matching count table column names in row 1}

\item{samples}{a sample table}

\item{\dots}{additional options like design formula passed to \code{DESeqDataSetFromMatrix}}
}
\value{
A DESeqDataSet object
}
\description{
Creates DESeqDataSet object using count and sample tibbles as input and run DESeq
}
\section{Functions}{
\itemize{
\item \code{factor_trts}: Avoid warnings about factors
}}
\note{
This function first runs \code{\link{sort_counts}} to check and
reorder count_tbl columns by the first column in sample_tbl, and then \code{DESeqDataSetFromMatrix}
and \code{DESeq}
}
\examples{
\dontrun{
   deseq_from_tibble(count_tbl, sample_tbl, design = ~ trt)
}
}
\author{
Chris Stubben
}

