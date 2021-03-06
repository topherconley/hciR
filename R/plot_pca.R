#' Highchart version of plotPCA in DESeq2
#'
#' Highchart version of sample PCA plot for transformed data
#'
#' @param object a DESeqTransform object
#' @param intgroup a character vector of names in colData(x) for grouping, default 'condition'
#' @param tooltip a character vector of names in colData(x) for tooltip display,
#'       default displays the object column names
#' @param ntop number of top variable genes to use for principal components
#' @param pc a vector of components to plot, default 1st and 2nd
#' @param \dots additional options passed to \code{hc_chart}
#'
#' @return A highchart
#'
#' @author Chris Stubben
#'
#' @examples
#' data(pasilla)
#' plot_pca(pasilla$rlog, "condition", tooltip=c("file", "type"))
#' plot_pca(pasilla$rlog, c("condition", "type"))
#' @export

plot_pca <- function(object, intgroup="condition", tooltip, ntop = 500, pc=c(1,2), ...){
   if(length(pc)!=2) stop( "pc should be a vector of length 2")
   if(!all(intgroup %in% names( SummarizedExperiment::colData(object)))) stop("intgroup should match columns of colData(object)")
   n  <- apply( SummarizedExperiment::assay(object), 1, stats::var)
   x  <-  utils::head( SummarizedExperiment::assay(object)[ order(n, decreasing=TRUE),], ntop)
   pca <- stats::prcomp(t(x))
   percentVar <- round(pca$sdev^2/sum(pca$sdev^2) * 100, 1)

   group <-  apply( as.data.frame(SummarizedExperiment::colData(object)[, intgroup, drop=FALSE]), 1, paste, collapse=": ")

   d <- data.frame( PC1 = pca$x[, pc[1] ], PC2 = pca$x[, pc[2] ], INTGRP = group,
         COLNAMES = colnames(object), SummarizedExperiment::colData(object) )

   # if tooltip is missing use column names
   if(missing(tooltip)){
      tooltipJS <- "this.point.COLNAMES"
    }else{
       if(!all(tooltip %in% names(SummarizedExperiment::colData(object)))) stop("tooltip should match columns of colData(object)")
       ## if tooltip = ID, patient, gender  then tooltipJS =
      ##  'ID: ' + this.point.ID + '<br>patient: ' + this.point.patient + '<br>gender: ' + this.point.gender
      tooltipJS <-  paste0("'", paste( tooltip, ": ' + this.point.", tooltip, sep="", collapse = " + '<br>"))
   }
   highcharter::highchart() %>%
   highcharter::hc_add_series(d , type = "scatter", mapping = highcharter::hcaes( x= PC1, y= PC2, group= INTGRP) ) %>%
    highcharter::hc_tooltip(formatter = htmlwidgets::JS( paste0("function(){ return (", tooltipJS, ")}"))) %>%
     highcharter::hc_xAxis(title = list(text = paste0("PC",  pc[1], ": ", percentVar[ pc[1] ], "% variance")),
             gridLineWidth=1, tickLength=0, startOnTick="true", endOnTick="true") %>%
      highcharter::hc_yAxis(title = list(text = paste0("PC", pc[2], ": ", percentVar[ pc[2] ], "% variance"))) %>%
       highcharter::hc_chart(zoomType = "xy", ...)  %>%
        highcharter::hc_exporting(enabled=TRUE, filename = "pca")
}
