# Transformation methods for matrix-like and NMF objects
# 
# Author: Renaud Gaujoux
# Creation: 19 Jan 2012
###############################################################################

#' @include NMF-class.R
#' @include Bioc-layer.R
NULL

#' Transforming from Mixed-sign to Nonnegative Data
#' 
#' \code{nneg}  is a generic function to transform a data objects that 
#' contains negative values into a similar object that only contains 
#' values that are nonnegative or greater than a given threshold.
#' 
#' @param object The data object to transform
#' @param ... extra arguments to allow extension or passed down to \code{nneg,matrix}
#' or \code{rposneg,matrix} in subsequent calls.
#' 
#' @return an object of the same class as argument \code{object}.
#' @export
#' @inline
#' 
setGeneric('nneg', function(object, ...) standardGeneric('nneg'))
#' Transforms a mixed-sign matrix into a nonnegative matrix, optionally apply a
#' lower threshold. 
#' This is the workhorse method, that is eventually called by all other 
#' methods defined in the \code{\link{NMF}} package.
#' 
#' @param threshold Nonnegative lower threshold value (single numeric). 
#' See argument \code{shit} for details on how the threshold is used and affects
#' the result. 
#' @param method Name of the transformation method to use, that is partially 
#' matched against the following possible methods:
#' \describe{
#' \item{pmax}{Each entry is constrained to be above threshold \code{threshold}.}
#' 
#' \item{posneg}{The matrix is split into its "positive" and "negative" parts, 
#' with the entries of each part constrained to be above threshold \code{threshold}.
#' The result consists in these two parts stacked in rows (i.e. \code{\link{rbind}}-ed)
#' into a single matrix, which has double the number of rows of the input 
#' matrix \code{object}.}
#' 
#' \item{absolute}{The absolute value of each entry is constrained to be above 
#' threshold \code{threshold}.}
#' }
#' 
#' @param shift a logical indicating whether the entries below the threshold 
#' value \code{threshold} should be forced (shifted) to 0 (default) or to 
#' the threshold value itself. 
#' In other words, if \code{shift=TRUE} (default) all entries in 
#' the result matrix are either 0 or strictly greater than \code{threshold}.
#' They are all greater or equal than \code{threshold} otherwise.
#' 
#' @seealso \code{\link{pmax}}
#' @examples
#' 
#' # random mixed sign data (normal distribution)
#' set.seed(1)
#' x <- rmatrix(5,5, rnorm, mean=0, sd=5)
#' x
#' 
#' # pmax (default)
#' nneg(x)
#' # using a threshold
#' nneg(x, 2)
#' # without shifting the entries lower than threshold
#' nneg(x, 2, shift=FALSE)
#' 
#' # posneg: split positive and negative part
#' nneg(x, method='posneg')
#' nneg(x, 2, method='pos')
#' 
#' # absolute
#' nneg(x, method='absolute')
#' nneg(x, 2, method='abs')
#' 
setMethod('nneg', 'matrix'
, function(object, threshold=0, shift=TRUE, method=c('pmax', 'posneg', 'absolute')){
	# match argument
	method <- match.arg(method)
	if( !is.numeric(threshold) || length(threshold) != 1L )
		stop("nneg - Invalid threshold value in argument `threshold` [",threshold,"]: must be a single numeric value.")
	if( threshold < 0 )
		stop("nneg - Invalid threshold value in argument `threshold` [",threshold,"]: must be nonnegative.")
	
	# define threshold to use: 1-step transform if no shift is required
	th <- if( !shift ) threshold else 0
		
	object <- 
	switch(method
	, pmax = pmax(object, th)
	, posneg = rbind(pmax(object, th), pmax(-object, th))
	, absolute = pmax(abs(object), th)
	, stop("nneg - Unexpected error: unimplemented transformation method '", method, "'.")
	)

	# 2nd-step if shifting: entries under threshold
	if( shift ) object[object<=threshold] <- 0
	
	# return modified object
	object
}
)

if( isClass('ExpressionSet') ){
	#' Apply \code{nneg} to the expression matrix of an \code{\link{ExpressionSet}} 
	#' object (i.e. \code{exprs(object)}). 
	#' All extra arguments in \code{...} are passed to the method \code{nneg,matrix}.
	#' 
	#' @examples
	#' 
	#' E <- ExpressionSet(x)
	#' nnE <- nneg(e)
	#' exprs(nnE)
	#' 
	setMethod('nneg', 'ExpressionSet'
	, function(object, ...){
		exprs(object) <- nneg(exprs(object), ...)
		object
	}
	)
}
#' Apply \code{nneg} to the basis matrix of an \code{\link{NMF}} 
#' object (i.e. \code{basis(object)}).
#' All extra arguments in \code{...} are passed to the method \code{nneg,matrix}.
#' 
#' @examples
#' 
#' # random 
#' M <- nmfModel(x, rmatrix(ncol(x), 3))
#' nnM <- nneg(M) 
#' basis(nnM)
#' # mixture coefficients are not affected
#' identical( coef(M), coef(nnM) )
#' 
setMethod('nneg', 'NMF'
, function(object, ...){
	basis(object) <- nneg(basis(object), ...)
	object
}
)

#' \code{posneg} is a shortcut for \code{nneg(..., method='posneg')}, to split 
#' mixed-sign data into its positive and negative part. 
#' See description for method \code{"posneg"}, in \code{\link{nneg}}.
#' 
#' @export
#' @rdname nneg
#' @examples
#' # shortcut for the "posneg" transformation
#' posneg(x)
#' posneg(x, 2)
#' 
posneg <- function(...) nneg(..., method='posneg')

#' Transforming from Nonnegative to Mixed Sign Data
#' 
#' \code{rposneg} performs the "reverse" transformation of the \code{\link{posneg}} function.
#' 
#' @return an object of the same type of \code{object}
#' @rdname nneg
#' @inline
#' 
setGeneric('rposneg', function(object, ...) standardGeneric('rposneg'))
#' @param unstack Logical indicating whether the positive and negative parts 
#' should be unstacked and combined into a matrix as \code{pos - neg}, which contains 
#' half the number of rows of \code{object} (default), or left 
#' stacked as \code{[pos; -neg]}.
#'   
#' @export
#' @examples
#' 
#' # random mixed sign data (normal distribution)
#' set.seed(1)
#' x <- rmatrix(5,5, rnorm, mean=0, sd=5)
#' x
#'  
#' # posneg-transform: split positive and negative part
#' y <- posneg(x)
#' dim(y)
#' # posneg-reverse
#' z <- rposneg(y)
#' identical(x, z)
#' rposneg(y, unstack=FALSE)
#' 
#' # But posneg-transformation with a non zero threshold is not reversible
#' y1 <- posneg(x, 1)
#' identical(rposneg(y1), x)
#' 
setMethod('rposneg', 'matrix'
, function(object, unstack=TRUE){
	
	# check that the number of rows is pair
	if( nrow(object) %% 2 != 0 )
		stop("rposneg - Invalid input matrix: must have a pair number of rows [",nrow(object),"].")
	n2 <- nrow(object)
	n <- n2/2
	if( unstack ) object <- object[1:n,,drop=FALSE] - object[(n+1):n2,,drop=FALSE]
	else object[(n+1):n2,] <- - object[(n+1):n2,,drop=FALSE]
	
	# return modified object
	object
}
)

if( isClass('ExpressionSet') ){
	#' Apply \code{rposneg} to the expression matrix of an \code{\link{ExpressionSet}} 
	#' object (i.e. \code{exprs(object)}). 
	#' 
	#' @examples
	#' 
	#' E <- ExpressionSet(x)
	#' nnE <- posneg(E)
	#' E2 <- rposneg(nnE)
	#' all.equal(E, E2)
	#' 
	setMethod('rposneg', 'ExpressionSet'
	, function(object, ...){
		exprs(object) <- rposneg(exprs(object), ...)
		object
	}
	)
}

#' Apply \code{rposneg} to the basis matrix of an \code{\link{NMF}} object.
#' 
#' @examples
#' 
#' # random mixed signed NMF model 
#' M <- nmfModel(rmatrix(10, 3, rnorm), rmatrix(3, 4))
#' # split positive and negative part
#' nnM <- posneg(M)
#' M2 <- rposneg(nnM)
#' identical(M, M2)
setMethod('rposneg', 'NMF'
, function(object, ...){ 
	basis(object) <- rposneg(basis(object), ...)
	object
}
)
