% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/top_counts.R
\name{top_counts}
\alias{top_counts}
\title{Get a count matrix of top genes}
\usage{
top_counts(res, rld, by = "id", col_names, row_names = "gene_name", ...)
}
\arguments{
\item{res}{an annotated DESeq2 results file (and \code{top_genes} will be run to subset)}

\item{rld}{rlog or other counts in DESeqTransform object}

\item{by}{join count rownames by this column number in results, default 1}

\item{col_names}{a column name in colData(rld) to use as column names}

\item{row_names}{a column name in results to use as row names, default gene_name}

\item{\dots}{additional options passed to \code{\link{top_genes}}}
}
\value{
A tibble with colData attribute
}
\description{
Join DESeq results to rlog or other counts, mainly for plotting gene heatmaps.
}
\examples{
\dontrun{
 x <- top_counts(res[[1]], rld)
 pheatmap(as_matrix(x))
 plot_genes(x, "trt")
}
}
\author{
Chris Stubben
}

