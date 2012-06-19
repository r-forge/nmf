\name{NMFStop}
\alias{NMFStop}
\alias{nmf.stop.connectivity}
\alias{nmf.stop.iteration}
\alias{nmf.stop.stationary}
\alias{nmf.stop.threshold}
\alias{stop-NMF}
\title{Stopping Criteria for NMF Iterative Strategies}
\usage{
  NMFStop(val)

  nmf.stop.iteration(n)

  nmf.stop.threshold(threshold)

  nmf.stop.stationary(object, i, y, x,
    stationary.th = 10^-6, check.interval = 10, ...)

  nmf.stop.connectivity(object, i, y, x, stopconv = 40,
    check.interval = 10, ...)
}
\arguments{
  \item{val}{access key that can be a character string, a
  single integer or numeric, or a function.}

  \item{n}{maximum number of iteration to perform.}

  \item{threshold}{default stationarity threshold}

  \item{object}{an NMF strategy object}

  \item{i}{the current iteration}

  \item{y}{the target matrix}

  \item{x}{the current NMF model}

  \item{stationary.th}{maximum difference for two objective
  values to be considered equal.}

  \item{check.interval}{interval (in number of iterations)
  on which stationarity is computed.}

  \item{...}{extra arguments passed to the function
  \code{\link{objective}}, which computes the objective
  value between \code{x} and \code{y}.}

  \item{stopconv}{number of iterations intervals over which
  the connectivity matrix must not change for stationarity
  to be achieved.}
}
\value{
  a function that can be passed to argument \code{.stop} of
  function \code{\link{nmf}}.

  a function that can be used as a stopping criterion for
  NMF algorithms defined as
  \code{\linkS4class{NMFStrategyIterative}} objects. That
  is a function with arguments \code{(strategy, i, target,
  data, ...)} that returns \code{TRUE} if the stopping
  criterion is satisfied -- which in turn stops the
  iterative process, and \code{FALSE} otherwise.
}
\description{
  The function documented here implement
  stopping/convergence criteria commonly used in NMF
  algorithms.

  \code{nmf.stop.iteration} generates a function that
  implements the stopping criterion that limits the number
  of iterations to a maximum of \code{n}), i.e. that
  returns \code{TRUE} if \code{i>=n}, \code{FALSE}
  otherwise.

  \code{nmf.stop.threshold} generates a function that
  implements the stopping criterion that stops when a given
  stationarity threshold is achieved by successive
  iterations. The returned function is identical to
  \code{nmf.stop.stationary}, but with the default
  threshold set to \code{threshold}.

  \code{nmf.stop.stationary} implements the stopping
  criterion of stationarity of the objective value, which
  stops when the objective value does not change anymore
  with further iterations. Objective values are compared at
  given regular intervals and using a given threshold.

  \code{nmf.stop.connectivity} implements the stopping
  criterion that is based on the stationarity of the
  connectivity matrix.
}
\details{
  \code{NMFStop} acts as a factory method that create
  stopping criterion functions to be used with
  \code{\link{nmf}}, from different types of values.

  \code{NMFStop} returns functions unchanged, integer
  values are used to create a stopping criterion of that
  number of iterations via \code{nmf.stop.iteration},
  numeric values are used to create a stopping criterion of
  that stationary threshold via \code{nmf.stop.threshold}.
  Character strings are assumed to be access keys for
  registered criteria (currently available:
  \dQuote{connectivity} and \dQuote{stationary}), or a
  function name in the global environment or the namespace
  of the loading package.
}
