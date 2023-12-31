% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/clusterMany.R
\name{clusterMany}
\alias{clusterMany}
\alias{clusterMany,matrixOrHDF5-method}
\alias{clusterMany,SingleCellExperiment-method}
\alias{clusterMany,ClusterExperiment-method}
\alias{clusterMany,SummarizedExperiment-method}
\alias{clusterMany,data.frame-method}
\title{Create a matrix of clustering across values of parameters}
\usage{
\S4method{clusterMany}{matrixOrHDF5}(
  x,
  reduceMethod = "none",
  nReducedDims = NA,
  transFun = NULL,
  isCount = FALSE,
  ...
)

\S4method{clusterMany}{SingleCellExperiment}(
  x,
  ks = NA,
  clusterFunction,
  reduceMethod = "none",
  nFilterDims = defaultNDims(x, reduceMethod, type = "filterStats"),
  nReducedDims = defaultNDims(x, reduceMethod, type = "reducedDims"),
  alphas = 0.1,
  findBestK = FALSE,
  sequential = FALSE,
  removeSil = FALSE,
  subsample = FALSE,
  silCutoff = 0,
  distFunction = NA,
  betas = 0.9,
  minSizes = 1,
  transFun = NULL,
  isCount = FALSE,
  verbose = TRUE,
  parameterWarnings = FALSE,
  mainClusterArgs = NULL,
  subsampleArgs = NULL,
  seqArgs = NULL,
  whichAssay = 1,
  makeMissingDiss = if (ncol(x) < 1000) TRUE else FALSE,
  ncores = 1,
  random.seed = NULL,
  run = TRUE,
  ...
)

\S4method{clusterMany}{ClusterExperiment}(
  x,
  reduceMethod = "none",
  nFilterDims = defaultNDims(x, reduceMethod, type = "filterStats"),
  nReducedDims = defaultNDims(x, reduceMethod, type = "reducedDims"),
  eraseOld = FALSE,
  ...
)

\S4method{clusterMany}{SummarizedExperiment}(x, ...)

\S4method{clusterMany}{data.frame}(x, ...)
}
\arguments{
\item{x}{the data matrix on which to run the clustering. Can be object of the
following classes: matrix (with genes in rows),
\code{\link[SummarizedExperiment]{SummarizedExperiment}},
\code{\link[SingleCellExperiment]{SingleCellExperiment}}
or \code{ClusterExperiment}.}

\item{reduceMethod}{character A character identifying what type of
dimensionality reduction to perform before clustering. Options are 1)
"none", 2) one of listBuiltInReducedDims() or listBuiltInFitlerStats OR 3)
stored filtering or reducedDim values in the object.}

\item{nReducedDims}{vector of the number of dimensions to use (when
\code{reduceMethod} gives a dimensionality reduction method).}

\item{transFun}{a transformation function to be applied to the data. If the
transformation applied to the data creates an error or NA values, then the
function will throw an error. If object is of class
\code{ClusterExperiment}, the stored transformation will be used and giving
this parameter will result in an error.}

\item{isCount}{if \code{transFun=NULL}, then \code{isCount=TRUE} will
determine the transformation as defined by \code{function(x){log2(x+1)}},
and \code{isCount=FALSE} will give a transformation function
\code{function(x){x}}. Ignored if \code{transFun=NULL}. If object is of
class \code{ClusterExperiment}, the stored transformation will be used and
giving this parameter will result in an error.}

\item{...}{For signature \code{matrix}, arguments to be passed on to mclapply
(if ncores>1). For all the other signatures, arguments to be passed to the
method for signature \code{matrix}.}

\item{ks}{the range of k values (see details for the meaning of \code{k} for
different choices of other parameters).}

\item{clusterFunction}{function used for the clustering. This must be either 
1) a character vector of built-in clustering techniques, or 2) a
\emph{named} list of \code{\link{ClusterFunction}} objects. Current
functions can be found by typing \code{listBuiltInFunctions()} into the
command-line.}

\item{nFilterDims}{vector of the number of the most variable features to keep
(when "var", "abscv", or "mad" is identified in \code{reduceMethod}).}

\item{alphas}{values of alpha to be tried. Only used for clusterFunctions of
type '01'. Determines tightness required in creating clusters from the
dissimilarity matrix. Takes on values in [0,1]. See documentation of
\code{\link{ClusterFunction}}.}

\item{findBestK}{logical, whether should find best K based on average
silhouette width (only used when clusterFunction of type "K").}

\item{sequential}{logical whether to use the sequential strategy (see details
of \code{\link{seqCluster}}). Can be used in combination with
\code{subsample=TRUE} or \code{FALSE}.}

\item{removeSil}{logical as to whether remove when silhouette < silCutoff
(only used if clusterFunction of type "K")}

\item{subsample}{logical as to whether to subsample via
\code{\link{subsampleClustering}}. If TRUE, clustering in mainClustering
step is done on the co-occurance between clusterings in the subsampled
clustering results.  If FALSE, the mainClustering step will be run directly
on \code{x}/\code{diss}}

\item{silCutoff}{Requirement on minimum silhouette width to be included in
cluster (only for combinations where removeSil=TRUE).}

\item{distFunction}{a vector of character strings that are the names of
distance functions found in the global environment. See the help pages of
\code{\link{clusterSingle}} for details about the required format of
distance functions. Currently, this distance function must be applicable
for all clusterFunction types tried. Therefore, it is not possible in
\code{clusterMany} to intermix type "K" and type "01" algorithms if you
also give distances to evaluate via \code{distFunction} unless all
distances give 0-1 values for the distance (and hence are possible for both
type "01" and "K" algorithms).}

\item{betas}{values of \code{beta} to be tried in sequential steps. Only used
for \code{sequential=TRUE}. Determines the similarity between two clusters
required in order to deem the cluster stable. Takes on values in [0,1]. See
documentation of \code{\link{seqCluster}}.}

\item{minSizes}{the minimimum size required for a cluster (in the
\code{mainClustering} step). Clusters smaller than this are not kept and samples
are left unassigned.}

\item{verbose}{logical. If TRUE it will print informative messages.}

\item{parameterWarnings}{logical, as to whether warnings and comments 
from checking the validity of the parameter combinations should be printed.}

\item{mainClusterArgs}{list of arguments to be passed for the mainClustering
step, see help pages of \code{\link{mainClustering}}.}

\item{subsampleArgs}{list of arguments to be passed to the subsampling step
(if \code{subsample=TRUE}), see help pages of
\code{\link{subsampleClustering}}.}

\item{seqArgs}{list of arguments to be passed to \code{\link{seqCluster}}.}

\item{whichAssay}{numeric or character specifying which assay to use. See
\code{\link[SummarizedExperiment]{assay}} for details.}

\item{makeMissingDiss}{logical. Whether to calculate necessary distance 
matrices needed when input is not "diss". If TRUE, then when a clustering 
function calls for a inputType "diss", but the given matrix is of type "X",
the function will calculate a distance function. A dissimilarity matrix
will also be calculated if a post-processing argument like \code{findBestK}
or \code{removeSil} is chosen, since these rely on calcualting silhouette
widths from distances.}

\item{ncores}{the number of threads}

\item{random.seed}{a value to set seed before each run of clusterSingle (so
that all of the runs are run on the same subsample of the data). Note, if
'random.seed' is set, argument 'ncores' should NOT be passed via
subsampleArgs; instead set the argument 'ncores' of clusterMany directly
(which is preferred for improving speed anyway).}

\item{run}{logical. If FALSE, doesn't run clustering, but just returns matrix
of parameters that will be run, for the purpose of inspection by user (with
rownames equal to the names of the resulting column names of clMat object
that would be returned if \code{run=TRUE}). Even if \code{run=FALSE},
however, the function will create the dimensionality reductions of the data
indicated by the user input.}

\item{eraseOld}{logical. Only relevant if input \code{x} is of class
\code{ClusterExperiment}. If TRUE, will erase existing workflow results
(clusterMany as well as mergeClusters and makeConsensus). If FALSE, existing
workflow results will have "\code{_i}" added to the clusterTypes value,
where \code{i} is one more than the largest such existing workflow
clusterTypes.}
}
\value{
If \code{run=TRUE} will
  return a \code{ClusterExperiment} object, where the results are stored as
  clusterings with clusterTypes \code{clusterMany}. Depending on
  \code{eraseOld} argument above, this will either delete existing such
  objects, or change the clusterTypes of existing objects. See argument
  \code{eraseOld} above. Arbitrarily the first clustering is set as the
  primaryClusteringIndex.

If \code{run=FALSE} a list with elements:
\itemize{
  \item{\code{paramMatrix}}{ a matrix giving the parameters of each
  clustering, where each column is a possible parameter set by the user and
  passed to \code{\link{clusterSingle}} and each row of paramMatrix
  corresponds to a clustering in \code{clMat}} 
  \item{\code{mainClusterArgs}}{
  a list of (possibly modified) arguments to mainClusterArgs}
  \item{\code{seqArgs=seqArgs}}{a list of (possibly modified) arguments to
  seqArgs} 
  \item{\code{subsampleArgs}}{a list of (possibly modified)
  arguments to subsampleArgs} }
}
\description{
Given a range of parameters, this function will return a matrix with the
clustering of the samples across the range, which can be passed to
\code{plotClusters} for visualization.
}
\details{
Some combinations of these parameters are not feasible. See the
  documentation of \code{\link{clusterSingle}} for important information on
  how these parameter choices interact.

While the function allows for multiple values of clusterFunction,
  the code does not reuse the same subsampling matrix and try different
  clusterFunctions on it. This is because if sequential=TRUE, different
  subsample clusterFunctions will create different sets of data to subsample
  so it is not possible; if sequential=FALSE, we have not implemented
  functionality for this reuse. Setting the \code{random.seed} value,
  however, should mean that the subsampled matrix is the same for each, but
  there is no gain in computational complexity (i.e. each subsampled
  co-occurence matrix is recalculated for each set of parameters).

The argument \code{ks} is interpreted differently for different
  choices of the other parameters. When/if sequential=TRUE, \code{ks} defines
  the argument \code{k0} of \code{\link{seqCluster}}. Otherwise, \code{ks}
  values are the \code{k} values for \strong{both} the mainClustering and
  subsampling step (i.e. assigned to the \code{subsampleArgs} and
  \code{mainClusterArgs} that are passed to \code{\link{mainClustering}} and
  \code{\link{subsampleClustering}} unless \code{k} is set appropriately in
  \code{subsampleArgs}. The passing of these arguments via
  \code{subsampleArgs} will only have an effect if `subsample=TRUE`.
  Similarly, the passing of \code{mainClusterArgs[["k"]]} will only have an
  effect when the clusterFunction argument includes a clustering algorithm of
  type "K". When/if "findBestK=TRUE", \code{ks} also defines the
  \code{kRange} argument of \code{\link{mainClustering}} unless \code{kRange}
  is specified by the user via the \code{mainClusterArgs}; note this means
  that the default option of setting \code{kRange} that depends on the input
  \code{k} (see \code{\link{mainClustering}}) is not available in
  \code{clusterMany}, only in \code{\link{clusterSingle}}.

If the input is a \code{ClusterExperiment} object, current
  implementation is that existing \code{orderSamples},\code{coClustering} or
  the many dendrogram slots will be retained.

If \code{run=FALSE}, the function will still calculate reduced 
  dimensions or filter statistics if not already calculated and saved in the object.
  Moreover the results of these calculations will not be save. Therefore, if these 
steps are lengthy for large datasets it is
  recommended to do them before calling the function.

The given \code{reduceMethod} values must either be \emph{all}
  precalculated filtering/dimensionality reduction stored in the appropriate
  location, or must \emph{all} be character values giving a built-in
  filtering/dimensionality reduction methods to be calculated. If some of the
  filtering/dimensionality methods are already calculated and stored, but not
  all, then they will \emph{all} be recalculated (and if they are not all
  built-in methods, this will give an error). So to save computational time
  with pre-calculated dimensionality reduction, the user must make sure they
  are \emph{all} precalculated. Also, user-defined values (i.e. not built-in
  functions) cannot be mixed with built-in functions unless they have already
  been precalculated (see \code{\link{makeFilterStats}} or
  \code{\link{makeReducedDims}}).
}
\examples{
\dontrun{
data(simData)

#Example: clustering using pam with different dimensions of pca and different
#k and whether remove negative silhouette values
#check how many and what runs user choices will imply:
checkParams <- clusterMany(simData,reduceMethod="PCA", makeMissingDiss=TRUE,
   nReducedDims=c(5,10,50), clusterFunction="pam", isCount=FALSE,
   ks=2:4,findBestK=c(TRUE,FALSE),removeSil=c(TRUE,FALSE),run=FALSE)
print(head(checkParams$paramMatrix))

#Now actually run it
cl <- clusterMany(simData,reduceMethod="PCA", nReducedDims=c(5,10,50),  isCount=FALSE,
   clusterFunction="pam",ks=2:4,findBestK=c(TRUE,FALSE),makeMissingDiss=TRUE, 
   removeSil=c(TRUE,FALSE))
print(cl)
head(colnames(clusterMatrix(cl)))

#make names shorter for plotting
clNames <- clusterLabels(cl)
clNames <- gsub("TRUE", "T", clNames)
clNames <- gsub("FALSE", "F", clNames)
clNames <- gsub("k=NA,", "", clNames)

par(mar=c(2, 10, 1, 1))
plotClusters(cl, axisLine=-2,clusterLabels=clNames)


#following code takes around 1+ minutes to run because of the subsampling
#that is redone each time:
system.time(clusterTrack <- clusterMany(simData, ks=2:15,
    alphas=c(0.1,0.2,0.3), findBestK=c(TRUE,FALSE), sequential=c(FALSE),
    subsample=c(FALSE), removeSil=c(TRUE), clusterFunction="pam", 
    makeMissingDiss=TRUE,
     mainClusterArgs=list(minSize=5, kRange=2:15), ncores=1, random.seed=48120))
}

}
