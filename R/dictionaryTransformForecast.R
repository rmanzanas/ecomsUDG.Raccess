#' Performs variable transformation
#' 
#' Performs variable transformation according to dictionary specifications.
#' Sub-routine of the \code{loadSeasonalForecast} methods.
#' 
#' @param dic Dictionary line for the variable, as returned by \code{dictionaryLookup.ECOMS}
#' @param foreTimePars A list of time selection parameters, as returned by \code{getTimeDomain}
#' @param mdArray A n-dimensional array, as returned by \code{makeSubset}
#' @return The transformed n dimensional array of data. See details.
#' @details When performing deaccumulation, the shape of the output array may change. This is due to the re-ordering
#' of the dimensions done by \code{apply}, and also in the length of the time dimension, as usually the first time value
#' of each runtime is lost in the deaccumulation. The function handles the re-ordering of the "dimensions" label in this case.
#' @note The current implementation does not support deaccumulation of CFSv2 variables (not needed so far...)
#' @author J. Bedia \email{joaquin.bedia@@gmail.com}

dictionaryTransformForecast <- function(dic, foreTimePars, mdArray) {
      dimNames <- attr(mdArray, "dimensions")
      mdArray <- mdArray * dic$scale + dic$offset
	if (dic$deaccum != 0) {
	      t.ranges <- c(0, cumsum(sapply(1:length(foreTimePars$ForeTimeRangesList), function(x) {
	            foreTimePars$ForeTimeRangesList[[x]]$length()})))
            dff <- foreTimePars$deaccumFromFirst
            if (length(dimNames) == 1) {
                  mdArray <- deaccum(mdArray, t.ranges, dff)
                  attr(mdArray, "dimensions") <- dimNames
            } else {
                  margin <- c(1:length(dim(mdArray)))[-grep("^time", dimNames)]  
                  mdArray <- apply(mdArray, MARGIN = margin, FUN = deaccum, t.ranges, dff)
                  dimNames <- c(grep("^time", dimNames, value = TRUE), dimNames[-grep("^time", dimNames)])
                  attr(mdArray, "dimensions") <- dimNames
            }
	}
      return(mdArray)
}
# End
	 