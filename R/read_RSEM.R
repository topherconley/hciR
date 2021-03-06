#' Read RSEM output files
#'
#' Reads RSEM counts or stats files and optionally reshape into wide format.
#'
#' @param path the path to RSEM output files, the default corresponds to the working directory.
#' @param pattern regular expression for count file name matching, deafult .genes.results
#' @param reshape reshape into wide format with samples in rows (a count matrix).
#' @param value a string with the RSEM column name to populate cell values, default expected_count
#' @param stats read stat files, default counts
#'
#' @note The cnt and model files in the stats directory vary depending on RSEM options
#' and the parser may fail.
#'
#' @return A tibble in long or wide format if reshape=TRUE
#'
#' @author Chris Stubben
#' @references \url{https://github.com/deweylab/RSEM/blob/master/cnt_file_description.txt} and
#' \url{https://github.com/deweylab/RSEM/blob/master/model_file_description.txt} for output format
#'
#' @examples
#' \dontrun{
#'  # count matrix
#' rsem_counts <- read_RSEM( ".")
#' rsem_counts
#' # need to round expected counts for some functions
#'  rlog_values <- rlog( round( as.matrix(rsem_counts)))
#' rsem_all <- read_RSEM( ".", , reshape=TRUE)
#' rsem_all
#'  # create TPM or FPKM matrix
#' tpm <- dplyr::select( x, sample, gene_id, tpm) %>% tidyr::spread(sample, tpm)
#'
#'  # reshape uses alignments stats only (rows 1-3 in *.cnt files)
#' read_RSEM( ".", stats=TRUE)
#' # read all cnt and model stats into long format
#' rsem <- read_RSEM( ".", stats=TRUE, reshape=FALSE)
#'  plot Fragment length, Read length, Read start position, or Reads per alignment
#' x <- filter(rsem, stat=="Fragment length", n < 350)
#' hchart(x, "line", x=n ,  y= value, group=sample)
#'
#' xCol <- c("Unique", "Multiple", "Unaligned", "Filtered")
#' x <- filter(rsem, stat %in% xCol ) %>%
#'  mutate(stat = factor(stat, levels=xCol))
#' hchart(x, "bar", x=sample, y= value, group=stat) %>%
#'   hc_plotOptions(bar = list(stacking = "normal"))
#' }
#' @export

read_RSEM <- function(path = ".", pattern = "genes.results$", reshape = TRUE, value="expected_count", stats = FALSE){
   if(!stats){
      res1 <- read_sample_files(path, pattern)
      if(reshape){
          if(!value %in% c("expected_count", "TPM", "FPKM")) stop("value not found")
         res1 <- dplyr::select_(res1, "sample", "gene_id", value) %>% tidyr::spread_("sample", value)
           #  sort HCI samples as X1, X2, ..., X10, X11
          res1  <-  res1[, c(1, order_samples(colnames(res1)[-1])+1) ]
       }
   }else{
      cntF <- list.files(path, "\\.cnt$", recursive=TRUE, full.names=TRUE)
      if(length(cntF)==0) stop("No *.cnt files found")
      samples <- sample_names(cntF)
      out1 <- vector("list", length(cntF))
      for(i in seq_along(cntF)){
         message("Reading count and model files in ", gsub("/[^/]+$", "", cntF[i]))
         x1 <- utils::read.table(file = cntF[i], nrow=3 , fill=TRUE)
         x1 <- as.matrix(x1)  # to select rows without unlisting
         ## Reads per alignment starting in row 4
         x2 <- utils::read.table(file = cntF[i], skip=3, sep="\t")
         cnt <- dplyr::bind_rows(
           tibble::tibble(row=1, stat=c("Unaligned", "Aligned",  "Filtered", "Total" ), n=1:4,  value=x1[1,1:4] ),
           tibble::tibble(row=2, stat=c("Unique",    "Multiple", "Uncertain" ),         n=1:3,  value=x1[2,1:3] ),
           tibble::tibble(row=3, stat=c("Hits"),                                        n=1,    value=x1[3,1] ),
           tibble::tibble(row=1:nrow(x2)+3, stat="Reads per alignment",                 n=x2[,1], value=x2[,2] )
                        )
         # add sample and file ending
         cnt <- tibble::add_column(cnt, sample=samples[i], file = "count", .before=1)
         ## read model
         x3 <- readLines(gsub("cnt$", "model", cntF[i]), n=14)
         vec1 <- as.numeric( strsplit(x3[5], " ")[[1]])
         vec2 <- as.numeric( strsplit(x3[8], " ")[[1]])
         ## Check if has_optional_length_dist =0 and then adjust coordinates for RSPD (add 1 or 2?)
         if(x3[8] == "0"){
            message("  Missing Fragment length distribution")
            rld <- tibble::tibble(row=6, stat= "Read length", n=(vec1[1] + 1):vec1[2],  value=as.numeric(strsplit(x3[6], " ")[[1]]) )
            fld <- tibble::tibble()
            x3 <- c("add extra element for rspd parsing", x3)
         }else{
            fld <- tibble::tibble(row=6, stat= "Fragment length", n=(vec1[1] + 1):vec1[2], value=as.numeric(strsplit(x3[6], " ")[[1]]) )
            rld <- tibble::tibble(row=9, stat= "Read length",     n=(vec2[1] + 1):vec2[2], value=as.numeric(strsplit(x3[9], " ")[[1]]) )
         }
         ## Read start position is off by default.
         if(x3[11] == 0 & x3[12] == ""){
            message("  Missing Read Start position, add --estimate-rspd to rsem-calculate-expression")
            rspd <- tibble::tibble()
         }else{
            rspd <- tibble::tibble(row=13, stat= "Read start position",  n=1:x3[12], value=as.numeric(strsplit(x3[13], " ")[[1]]) )
         }
         # TO DO get Quality scores
         model <- dplyr::bind_rows(fld, rld, rspd)
         model <- tibble::add_column(model, sample=samples[i], file = "model", .before=1)
         out1[[i]] <- dplyr::bind_rows(cnt, model)
      }
      res1 <- dplyr::bind_rows(out1)
      if(reshape){
         res1 <-  dplyr::filter(res1, file=="count", row <= 3 ) %>%
                   dplyr::select(sample, stat, value) %>%
                    tidyr::spread(stat, value)
          res1  <-  res1[ order_samples(res1$sample), ]
      }
  }
  res1
}
