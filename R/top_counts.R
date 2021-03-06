#' Get a count matrix of top genes
#'
#' Join DESeq results to rlog or other counts, mainly for plotting gene heatmaps.
#'
#' @param res an annotated DESeq2 results file
#' @param rld rlog or other counts in DESeqTransform object
#' @param by join count rownames by this column number in results, default id
#' @param filter filter the results using \code{\link{top_genes}}
#' @param col_names a column name in colData(rld) to use as column names
#' @param row_names a column name in results to use as row names, default gene_name
#' @param \dots additional options passed to \code{\link{top_genes}}
#'
#' @return A tibble with colData attribute
#'
#' @author Chris Stubben
#'
#' @examples
#' \dontrun{
#'  x <- top_counts(res[[1]], rld)
#'  pheatmap(as_matrix(x))
#'  plot_genes(x, "trt")
#' }
#' @export

top_counts <- function(res, rld, by="id",  filter = TRUE, col_names, row_names="gene_name", ...){
    if(!class(rld) == "DESeqTransform") stop("rld shoud be a DESeqTransform")
    rldx <- SummarizedExperiment::assay(rld)
    colx <- data.frame( SummarizedExperiment::colData(rld) , drop=FALSE)
    ## rename columns in heatmap
    if(!missing(col_names)){
         n <- as.character( SummarizedExperiment::colData(rld)[[col_names]] )
         if(is.null(n)) stop("No column matching ", col_names, " in colData(rld)")
         colnames(rldx) <- n
         rownames(colx) <- n
      }

      if(filter){
         x <- top_genes(res, ...)
      }else{
         x <- res
      }
      if( !row_names %in% colnames(x)){
          message( "gene_name is missing from results, using id for row names")
          row_names <- "id"
      }
      ## match column 1 in results to count rownames
      n <- match(x[[ by ]], rownames(rldx))
      if(all(is.na(n))) stop("Column ", by, " in results and rownames in counts do not match")
      if(any(is.na(n))) stop(sum(is.na(n)) , " result rows not in count matrix" )
      mat <- rldx[n, ]
      ## gene name by default as id  - use id if missing
      if(row_names == "gene_name"){
           n <- is.na( x[["gene_name"]]) | x[["gene_name"]] ==""
           x[["gene_name"]][n] <- x[["id"]][n]
        }

     mat <- dplyr::bind_cols( tibble::tibble(id=x[[ row_names ]]), tibble::as_tibble(mat) )
    attr(mat, "colData") <- colx
    mat
}
