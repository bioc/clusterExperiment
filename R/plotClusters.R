#' Visualize cluster assignments across multiple clusterings
#'
#' Align multiple clusterings of the same set of samples and provide a
#' color-coded plot of their shared cluster assignments
#' @name plotClusters
#' @docType methods
#' @param object A matrix of with each column corresponding to a clustering
#'   and each row a sample or a \code{\link{ClusterExperiment}} object. If a
#'   matrix, the function will plot the clusterings in order of this matrix, and
#'   their order influences the plot greatly.
#' @param orderSamples A predefined order in which the samples will be plotted.
#'   Otherwise the order will be found internally by aligning the clusters
#'   (assuming \code{input="clusters"})
#' @param colData If \code{clusters} is a matrix, \code{colData} gives a 
#'   matrix of additional cluster/sample data on the samples to be plotted with 
#'   the clusterings given in clusters. Values in \code{colData} will be 
#'   added to the end (bottom) of the plot. NAs in the \code{colData} matrix
#'   will trigger an error. If \code{clusters} is a \code{ClusterExperiment}
#'   object, the input in \code{colData} refers to columns of the the
#'   \code{colData} slot of the \code{ClusterExperiment} object to be plotted
#'   with the clusters. In this case, \code{colData} can be TRUE (i.e. all
#'   columns will be plotted), or an index or a character vector that references
#'   a column or column name, respectively, of the \code{colData} slot of the
#'   \code{ClusterExperiment} object. If there are NAs in the \code{colData}
#'   columns, they will be encoded as 'unassigned' and receive the same color as
#'   'unassigned' samples in the clustering.
#' @param reuseColors Logical. Whether each row should consist of the same set
#'   of colors. By default (FALSE) each cluster that the algorithm doesn't
#'   identify to the previous rows clusters gets a new color.
#' @param matchToTop Logical as to whether all clusters should be aligned to the
#'   first row. By default (FALSE) each cluster is aligned to the ordered
#'   clusters of the row above it.
#' @param plot Logical as to whether a plot should be produced.
#' @param unassignedColor If ``-1'' in \code{clusters}, will be given this color
#'   (meant for samples not assigned to cluster).
#' @param missingColor If ``-2'' in clusters, will be given this color (meant
#'   for samples that were missing from the clustering, mainly when comparing
#'   clusterings run on different sets of samples)
#' @param minRequireColor In aligning colors between rows of clusters, require
#'   this percent overlap.
#' @param startNewColors logical, indicating whether in aligning colors between
#'   rows of clusters, should the colors restart at beginning of colPalette as
#'   long as colors are not in immediately proceeding row (the colors at the end 
#'   of \code{massivePalette} are all of \code{\link{colors}()} and many will be
#'   indistinguishable, so this option can be useful if you have a large cluster
#'   matrix).
#' @param colPalette a vector of colors used for the different clusters. Must be
#'   as long as the maximum number of clusters found in any single
#'   clustering/column given in \code{clusters} or will otherwise return an
#'   error.
#' @param input indicate whether the input matrix is matrix of integer assigned
#'   clusters, or contains the colors. If \code{input="colors"}, then the object
#'   \code{clusters} is a matrix of colors and there is no alignment (this
#'   option allows the user to manually adjust the colors and replot, for
#'   example).
#' @param clusterLabels names to go with the columns (clusterings) in matrix 
#'   \code{colorMat}. If \code{colData} argument is not \code{NULL}, the 
#'   \code{clusterLabels} argument must include names for the sample data too. 
#'   If the user gives only names for the clusterings, the code will try to 
#'   anticipate that and use the column names of the sample data, but this is
#'   fragile. If set to \code{FALSE}, then no labels will be plotted.
#' @param add whether to add to existing plot.
#' @param xCoord values on x-axis at which to plot the rows (samples).
#' @param ylim vector of limits of y-axis.
#' @param tick logical, whether to draw ticks on x-axis for each sample.
#' @param ylab character string for the label of y-axis.
#' @param xlab character string for the label of x-axis.
#' @param axisLine the number of lines in the axis labels on y-axis should be
#'   (passed to \code{line = ...} in the axis call).
#' @param box logical, whether to draw box around the plot.
#' @param ... for \code{plotClusters} arguments passed either to the method
#'   of \code{plotClusters} for matrices, or ultimately to \code{\link{plot}}
#'   (if \code{add=FALSE}).
#' @param existingColors how to make use of the exiting colors in the 
#'   \code{ClusterExperiment} object. 'ignore' will ignore them and assign new 
#'   colors. 'firstOnly' will use the existing colors of only the 1st 
#'   clustering, and then align the remaining clusters and give new colors for
#'   the remaining only. 'all' will use all of the existing colors.
#' @param resetNames logical. Whether to reset the names of the clusters in
#'   \code{clusterLegend} to be the aligned integer-valued ids from
#'   \code{plotClusters}.
#' @param resetColors logical. Whether to reset the colors in
#'   \code{clusterLegend} in the \code{ClusterExperiment} returned to be the
#'   colors from the \code{plotClusters}.
#' @param resetOrderSamples logical. Whether to replace the existing
#'   \code{orderSamples} slot in the \code{ClusterExperiment} object with the
#'   new order found.
#' @inheritParams getClusterIndex
#' @details All arguments of the matrix version can be passed to the
#'   \code{ClusterExperiment} version. As noted above, however, some arguments
#'   have different interpretations.
#' @details If \code{whichClusters = "workflow"}, then the workflow clusterings
#'   will be plotted in the following order: final, mergeClusters, makeConsensus,
#'   clusterMany.
#' @return If \code{clusters} is a \code{\link{ClusterExperiment}} Object, then
#'   \code{plotClusters} returns an updated \code{ClusterExperiment} object,
#'   where the \code{clusterLegend} and/or \code{orderSamples} slots have been
#'   updated (depending on the arguments).
#' @return If \code{clusters} is a matrix, \code{plotClusters} returns
#'   (invisibly) the orders and other things that go into making the matrix.
#'   Specifically, a list with the following elements.
#' \itemize{
#'
#' \item{\code{orderSamples}}{ a vector of length equal to 
#' \code{nrows(clusters)} giving the order of the samples (rows) to 
#'  use to get the original clusters matrix
#' into the order made by \code{plotClusters}.}
#'
#' \item{\code{colors}}{ matrix of color assignments for each element of
#' original clusters matrix. Matrix is in the same order as original clusters
#' matrix. The matrix \code{colors[orderSamples,]} is the matrix that can be 
#' given back to \code{plotClusters} to recreate the plot (see examples).}
#'
#' \item{\code{alignedClusterIds}}{ a matrix of integer valued cluster
#' assignments that match the colors. This is useful if you want to have cluster
#' identification numbers that are better aligned than that given in the
#' original clusters. Again, the rows/samples are in same order as original 
#' input matrix.}
#'
#' \item{\code{clusterLegend}}{ list of length equal to the number of columns of
#' input matrix. The elements of the list are matrices, each with three columns
#' named "Original","Aligned", and "Color" giving, respectively, the
#' correspondence between the original cluster ids in \code{clusters}, the
#' aligned cluster ids in \code{aligned}, and the color.}
#' 
#' \item{\code{origClusters}}{The original matrix of clusters given to
#' \code{plotClusters}}
#' }
#'
#' @author Elizabeth Purdom and Marla Johnson (based on the tracking plot in
#'   \link[ConsensusClusterPlus]{ConsensusClusterPlus} by Matt Wilkerson and Peter
#'   Waltman).
#'
#' @seealso The \code{\link[ConsensusClusterPlus]{ConsensusClusterPlus}} package.
#' @references Wilkerson, D. M, Hayes and Neil D (2010). "ConsensusClusterPlus: a class discovery tool with confidence assessments and item tracking." Bioinformatics, 26(12), pp. 1572-1573. 
#' @export
#'
#' @examples
#' \dontrun{
#' #clustering using pam: try using different dimensions of pca and different k
#' data(simData)
#'
#' cl <- clusterMany(simData, nReducedDims=c(5, 10, 50), reduceMethod="PCA",
#' clusterFunction="pam", ks=2:4, findBestK=c(TRUE,FALSE),
#' removeSil=c(TRUE,FALSE), makeMissingDiss=TRUE)
#'
#' clusterLabels(cl)
#'
#' #make names shorter for better plotting
#' x <- clusterLabels(cl)
#' x <- gsub("TRUE", "T", x)
#' x <- gsub("FALSE", "F", x)
#' x <- gsub("k=NA,", "", x)
#' x <- gsub("Features", "", x)
#' clusterLabels(cl) <- x
#'
#' par(mar=c(2,10,1,1))
#' #this will make the choices of plotClusters
#' cl <- plotClusters(cl, axisLine=-1, resetOrderSamples=TRUE, resetColors=TRUE)
#'
#' #see the new cluster colors
#' clusterLegend(cl)[1:2]
#'
#' #We can also change the order of the clusterings. Notice how this
#' #dramatically changes the plot!
#' clOrder <- c(3:6, 1:2, 7:ncol(clusterMatrix(cl)))
#' cl <- plotClusters(cl, whichClusters=clOrder, resetColors=TRUE,
#' resetOrder=TRUE, axisLine=-2)
#'
#' #We can manually switch the red ("#E31A1C") and green ("#33A02C") in the
#' #first cluster:
#'
#' #see what the default colors are and their names
#' showPalette(wh=1:5)
#'
#' #change "#E31A1C" to "#33A02C"
#' newColorMat <- clusterLegend(cl)[[clOrder[1]]]
#' newColorMat[2:3, "color"] <- c("#33A02C", "#E31A1C")
#' clusterLegend(cl)[[clOrder[1]]]<-newColorMat
#'
#' #replot by setting 'input="colors"'
#' par(mfrow=c(1,2))
#' plotClusters(cl, whichClusters=clOrder, orderSamples=orderSamples(cl),
#' existingColors="all")
#' plotClusters(cl, whichClusters=clOrder, resetColors=TRUE, resetOrder=TRUE,
#' axisLine=-2)
#' par(mfrow=c(1,1))
#'
#' #set some of clusterings arbitrarily to "-1", meaning not clustered (white),
#' #and "-2" (another possible designation getting gray, usually for samples not
#' #included in original clustering)
#' clMatNew <- apply(clusterMatrix(cl), 2, function(x) {
#'	wh <- sample(1:nSamples(cl), size=10)
#'	x[wh]<- -1
#'	wh <- sample(1:nSamples(cl), size=10)
#'	x[wh]<- -2
#'	return(x)
#'	})
#'
#' #make a new object
#' cl2 <- ClusterExperiment(assay(cl), clMatNew,
#' transformation=transformation(cl))
#' plotClusters(cl2)
#' }
#' @rdname plotClusters
#' @export
#' @importFrom grDevices gray
#' @importFrom stringr str_sort str_order
#' @aliases plotClusters,ClusterExperiment-method
setMethod(
  f = "plotClusters",
  signature = signature(object = "ClusterExperiment"),
  definition = function(object, whichClusters, 
  	existingColors=c("ignore","all","firstOnly"),
    resetNames=FALSE, resetColors=FALSE, resetOrderSamples=FALSE, colData=NULL, clusterLabels=NULL,...)
  {
	if(missing(whichClusters)){
	  if(!is.null(workflowClusterDetails(object))) whichClusters<-"workflow"
	  else whichClusters<-"all"	  	
	}
	whichClusters<-getClusterIndex(object,whichClusters=whichClusters,noMatch="throwError")
    existingColors<-match.arg(existingColors)
    args<-list(...)    
		checkIgnore<-.depricateArgument(passedArgs=args,"colData","sampleData") #06/2018 added in BioC 3.8
		if(!is.null(checkIgnore)){
			args<-checkIgnore$passedArgs
			colData<-checkIgnore$val
		}
    colData<-.pullColData(object,colData,fixNA="unassigned")
    if(is.null(clusterLabels)) clusterLabels<-clusterLabels(object)[whichClusters]
    if(existingColors!="ignore") useExisting<-TRUE else useExisting<-FALSE
    if(useExisting){ #using existing colors in some way:
      plotArg<-TRUE #the default
      if("plot" %in% names(args) ){
        whPlot<-which(names(args)=="plot")
        plotArg<-args[[whPlot]]
        if(length(args)>length(whPlot)){
          args<-args[-whPlot]
        }
        else{
          args<-NULL
        }
      }
      
      #if firstRow, add greys to the color palette for the first row so don't "use" up good colors on those
      colPaletteArg<-massivePalette #the default
      if("colPalette" %in% names(args) ){
        whPlot<-which(names(args)=="colPalette")
        colPaletteArg<-args[[whPlot]]
        if(length(args)>length(whPlot)){
          args<-args[-whPlot]
        }
        else{
          args<-NULL
        }
      }
      colPalGood<-colPaletteArg
      if(existingColors=="firstOnly"){
        nadd<-nrow(clusterLegend(object)[[whichClusters[[1]]]])
        addgreys<-gray(seq(0.01,.99,length=nadd))
        colPaletteArg<-c(addgreys,colPaletteArg)
      }
      
      #------------
      #align the samples, but don't plot them.
      #------------
      outval<-do.call(plotClusters, c(list(object=clusterMatrix(object)[,whichClusters,drop=FALSE], input="clusters", plot=FALSE, colData=colData,colPalette=colPaletteArg),args))
      #------------
      #make new color matrix with existing Colors
      #------------
      if(existingColors=="all"){
        newColorMat<-convertClusterLegend(object, whichClusters=whichClusters, output="matrixColors")
      }
      if(existingColors=="firstOnly"){
        #pre-existing colors for first clustering
        firstRow<-as.vector(convertClusterLegend(object, whichClusters=whichClusters[1], output="matrixColors"))
        #current assignment of colors all clusters:
        newColorMat<-outval$colors
        
        #integer values that match across the clusterings
        #note could skip this matrix, but just in case the colors are not unique, this guarantees don't change all of them....
        alignCl<-outval$alignedClusterIds[,1]
        firstCl<-clusterMatrix(object)[,whichClusters[1]]
        valsToChange<-unique(alignCl[firstCl>0]) #don't mess with assignment of -1/-2
        #match them and make them the existing color
        unusedColors<-colPalGood[!colPalGood %in% c(as.vector(newColorMat),firstRow)]
        ###Note: Need to update color legend in out val because used if resetColors
        ###Also, dimensions of outval matrices may be bigger than that of whichClusters because colData was added...
        for(val in valsToChange){
          wh<-which(alignCl==val)
          newCol<-unique(firstRow[wh])
          if(length(newCol)!=1) stop("internal coding error in existingColors='first'")
          #make sure not the same as existing color	
          if(any(newColorMat==newCol)){
            newColorMat[newColorMat==newCol]<-unusedColors[1]
            unusedColors<-tail(unusedColors,-1)
          }
          #alignedClusterIds aligns to a number even if -1/-2)
          newColorMat[outval$alignedClusterIds==val & !outval$origClusters%in% c("-1","-2")]<-newCol
        }
        outval$colors<-newColorMat
        ###make new clusterLegend from color matrix
        temp<-lapply(seq_len(ncol(outval$alignedClusterIds)),function(ii){
          oldMat<-outval$clusterLegend[[ii]]
          alignMat<-unique(cbind(alignedClusterIds=as.character(outval$alignedClusterIds[,ii]),color=newColorMat[,ii]))
          m<-match(oldMat[,"alignedClusterIds"],alignMat[,"alignedClusterIds"])
          if(any(is.na(m))) stop("internal coding error in make new clusterLegend")
          alignMat<-alignMat[m,]
          oldMat[,"color"]<-alignMat[,"color"]
          return(oldMat)
        })
        names(temp)<-names(outval$clusterLegend)
        outval$clusterLegend<-temp
        # $PublishedClusters
        #       clusterIds alignedClusterIds color     name
        #  [1,] "-2"       "1"               "black"   "1"
        #  [2,] "1"        "2"               "#161616" "2"
        #  [3,] "10"       "3"               "#292929" "3"
        #  [4,] "11"       "4"               "#3C3C3C" "4"
        
      }
      #------------
      #now plot them
      #------------
      if(plotArg) do.call(plotClusters,c(list(object=newColorMat[outval$orderSamples,], input="colors", clusterLabels=clusterLabels,colData=colData), args))
      
    }
    else{
			outval<-do.call(plotClusters,c(list(object=clusterMatrix(object)[,whichClusters,drop=FALSE],input="clusters",colData=colData,clusterLabels=clusterLabels), args))
    }
    if(resetColors | resetNames){
      ## recall, everything from outval is in the order of whichClusters!
      ## also includes values from colData, which are always at the bottom, so don't affect anything.
      oldClMat<-clusterMatrix(object)[,whichClusters]
      newClMat<-outval$alignedClusterIds
      #make both colors switch to aligned values (but keep name the same!)
      #can't convert the cluster ids because then wouldn't be consecutive numbers... but can give them names that match.
      convertAlignedColorLegend<-function(ii){
        oldColMat<-clusterLegend(object)[whichClusters][[ii]]
        newColMat<-outval$clusterLegend[[ii]]
        #weird space introduced in plotCluster to clusterIds
        newColMat[,"clusterIds"]<-as.character(as.numeric(newColMat[,"clusterIds"]))
        if(nrow(newColMat)!=nrow(oldColMat)) stop("error in aligning colorLegend") #just to make sure
        #update colors
        if(resetColors){
          m<-match(oldColMat[,"clusterIds"],newColMat[,"clusterIds"])
          oldColMat[,"color"]<-newColMat[m,"color"]
        }
        #convert from old to new names
        if(resetNames){
          
          newCl<-newClMat[,ii]
          oldCl<-oldClMat[,ii]
          oldNew<-unique(cbind(old=oldCl,new=newCl))
          if(nrow(oldNew)!=nrow(oldColMat)) stop("error in converting colorLegend from plotClusters output")
          #update clusterIds -- can't do
          m<-match(oldColMat[,"clusterIds"],oldNew[,"old"])
          oldColMat[,"name"]<-oldNew[m,"new"]
          if(any(oldColMat[,"clusterIds"] %in% c(-1,-2))){
            whNeg<-which(oldColMat[,"clusterIds"] %in% c(-1,-2))
            oldColMat[whNeg,"name"]<-as.character(oldColMat[whNeg,"clusterIds"])
          }
        }
        return(oldColMat)
      }
      newClLegend<-lapply(seq_len(NCOL(oldClMat)),convertAlignedColorLegend)
      names(newClLegend)<-colnames(oldClMat)
      clusterLegend(object)[whichClusters]<-newClLegend
      ch<-.checkClusterLegend(object)
      if(!is.logical(ch)) stop(ch)
    }
    if(resetOrderSamples) orderSamples(object)<-outval$orderSamples
    invisible(object)
    
  })



#' @rdname plotClusters
#' @export
setMethod(
  f = "plotClusters",
  signature = signature(object = "matrix"),
  definition = function(object, 
              orderSamples=NULL,colData=NULL,reuseColors=FALSE,matchToTop=FALSE,
              plot=TRUE,unassignedColor="white",missingColor="grey",
              minRequireColor=0.3,startNewColors=FALSE,colPalette=massivePalette,
              input=c("clusters","colors"),clusterLabels=colnames(object),
              add=FALSE,xCoord=NULL,ylim=NULL,tick=FALSE,ylab="",xlab="",
              axisLine=0,box=FALSE,...)
{
  if(!is.matrix(object)) stop("object must be a matrix")
	  
	  
  if(!is.null(orderSamples) && !all(orderSamples %in% seq_len(nrow(object))))
	  stop("invalid values for orderSamples")
  index<-orderSamples #match to old arguments
  input<-match.arg(input)

  #------------
  ###Add any additional colData to the bottom
  #------------
	if(!is.null(colData) & input=="clusters"){
	  if(!is.matrix(colData) && !is.data.frame(colData)){
      if(length(colData)!=nrow(object)){
        stop("if colData is a single vector, it must be the same length as nrow(object)")
        if(is.list(colData)) stop("colData cannot be a list, must be vector or matrix")
      }
	  }
	  else{
	    if(nrow(colData)!=nrow(object)) stop("colData must have same number of observations as clusterings")

	  }
	  
    clusters<-cbind(object,colData)
	}
	else clusters<-object
    
	#------------
	# deal with given clusterLabels 
    #------------
	clNames<-clusterLabels
	if(is.logical(clNames)){
		if(!clNames) clNames<-rep("",ncol(clusters))
		else clNames<-colnames(clusters)
	}
	
    if(length(clNames)!=ncol(clusters)){
		if(is.null(clNames)){
			clNames<-rep("",ncol(clusters))
		}
		else{
	    	if(length(clNames==ncol(clusters)-ncol(colData))){
	    		clNames<-c(clNames,colnames(colData))
			}
			else stop("number of cluster labels given in clusterLabels must be equal to the number of clusterings (or sample data columns plus clusterings)")
			
		}
    } 

	dnames<-dimnames(clusters)
	#------------
	# arguments to be passed at various calls (these are ones that do not change across the 
	#	different internal calls)
    #------------
	clusterPlotArgs<-list(clNames=clNames,add=add,xCoord=xCoord,ylim=ylim,tick=tick,ylab=ylab,xlab=xlab,axisLine=axisLine,box=box)
	plotTrackArgs<-list(index=index,reuseColors=reuseColors,matchToTop=matchToTop,minRequireColor=minRequireColor,startNewColors=startNewColors,colPalette=colPalette)

	if(input=="clusters"){
		clusters<-t(clusters) #original code had clusters in rows, rather than columns.
		if(any(apply(clusters,1,function(x){any(is.na(x))}))) stop("clusters should not have 'NA' values; non-clustered samples should get a '-1' or '-2' value depending on why they are not clustered.")
		if(any(as.character(clusters)%in%c("-1","-2"))){
			#------------
			# if have any -1/-2, have to do ordering without plotting, then fix it up by overwriting the -1/-2 colors
		    #------------
			### To Do: somehow reuse internal code of .makeColors to do this.		  	
			### To DO: do this ordering without -1/-2 so not lose a color to them.
			
			#1. align them, including "-1","-2" as a cluster. 
			out<-do.call(".plotClustersInternal",c(list(clusters=clusters,plot=FALSE),plotTrackArgs,clusterPlotArgs ,list(...)))
			#take out -1

			#2. replace colors of -1/-2 in clusterLegend (used to update clusterLegend if resetColors=TRUE)
			newColorLeg<-lapply(seq_len(nrow(clusters)),function(i){
				leg<-out$clusterLegend[[i]]
				if(any(wh<-leg[,"clusterIds"]== -1))
				leg[wh,"color"]<-unassignedColor
				if(any(wh<-leg[,"clusterIds"]== -2))
				leg[wh,"color"]<-missingColor
				return(leg)
			})
			names(newColorLeg)<-names(out$clusterLegend)
			#3. Update colors in colors matrix
			xColors<-do.call("cbind",lapply(seq_len(nrow(clusters)),function(i){
				out$colors[clusters[i,]=="-1",i]<-unassignedColor
				out$colors[clusters[i,]=="-2",i]<-missingColor
				return(out$colors[,i])
			}))
			#4. call .clusterTrackingPlot to make plot			
			if(plot) do.call(".clusterTrackingPlot",c(list(colorMat=xColors[out$orderSamples,]),clusterPlotArgs,list(...)))
			out$colors<-xColors
			dimnames(out$colors)<-dnames
			out$clusterLegend<-newColorLeg
		}
		else{
			out<-do.call(".plotClustersInternal",c(list(clusters=clusters,plot=plot),plotTrackArgs,clusterPlotArgs ,list(...)))
		}
		invisible(out)
	}
	else{
		do.call(".clusterTrackingPlot",c(list(colorMat=clusters),clusterPlotArgs,list(...)))
	}
})

.plotClustersInternal<-function(clusters, index, reuseColors, matchToTop, plot, minRequireColor, startNewColors, colPalette, ...){
	# clusters is a nclusterings x nsamples matrix.
  # The order of the rows (clusters) determines how the tracking will be done.
	# If given, index is the order of the samples (columns) for plotting. Otherwise determined by program
	# matchToTop allows that the comparison for color assignment be done, not row by row, but always back to the first row.

	# Check that no row has more than length(colPalette) number of unique entries
	colPalette<-unique(colPalette)
	tabVals<-apply(clusters,1,function(x){length(table(x))})
	if(any(tabVals> length(colPalette))) stop("Must give colPalette (i.e. distinct colors to be assigned to clustres) longer than number of clusters. Largest number of distinct clusters in the clusterings:",max(tabVals),". Length of colPalette:",length(colPalette))

	######
	#this for loop assigns colors to clusters
	######
	pastColorVector<-NULL
	colorM = rbind() #matrix of colors. gives colors for cluster assignments that give the 'right' color throughout the different rows
	for(i in seq_len(nrow(clusters))){
	  # Below calls the function:
		#.setClusterColors <- function(past_ct,ct,colorU,colorList,reuseColors,minRequireColor=0.5){
		# About this function:
  	  #description: sets common color of clusters between different K
			#takes previous row's colors and defines color assignments for next row.
			#assignments are done by:
				#start with largest cluster, assign to old cluster with largest overlap
			#returns a vector of colors

	#eap: rewrote a little, to make it easier to read. 5/27/2015
		currCl<-as.character(unlist(clusters[i,]))#as.numeric(as.character(unlist(clusters[i,]))) #think I've fixed it so don't need to convert to numeric.
		if(i == 1) pastCl<-NULL
		else{
			if(!matchToTop) pastCl<-as.character(unlist(clusters[i-1,]))#as.numeric(as.character(unlist(clusters[i-1,])))
			else pastCl<-as.character(unlist(clusters[1,]))#as.numeric(as.character(unlist(clusters[1,])))
		}
		newColorVector<- .setClusterColors(past_ct=pastCl,ct=currCl ,colorU=colPalette,past_colors=pastColorVector,reuseColors=reuseColors,minRequireColor=minRequireColor,startNewColors=startNewColors)

		if(i == 1) colorListTop<-newColorVector
		if(any(is.na(newColorVector))) stop("Error in internal code: NA values")
		if(!identical(sort(unname(table(newColorVector))),sort(unname(table(unlist(clusters[i,])))))) stop("Coding error, colors to do not have same number as original")
		crossTab<-paste(newColorVector,unlist(clusters[i,]),sep=";")
		if(!identical(sort(unname(table(crossTab))),sort(unname(table(unlist(clusters[i,])))))) stop("Coding error, colors to do not have same assignments as original")
		colorM = rbind(colorM,newColorVector)
		if(!matchToTop) pastColorVector<-newColorVector
			else pastColorVector<-colorM[1,]
	}
	dimnames(colorM)<-dimnames(clusters)

	###########
	#give integer values to alignCl
	###########
	allColors<-unique(as.vector(colorM))
	#make in order of input colPalette so that first row is names like 1,2,3 etc...
	tmp<-colPalette[colPalette %in% allColors]
	ord<-match(tmp,allColors)
	if(length(ord)!=length(allColors)) stop("coding error in the bowels of plotClusters. Contact mantainers.")
	allColors<-allColors[ord]
	#give numbers
	if(nrow(colorM)>1) alignCl<-apply(colorM,2,function(x){match(x,allColors)})
	else alignCl<-matrix(match(colorM[1,],allColors),nrow=1)
	dimnames(alignCl)<-dimnames(clusters)

	###########
	###Order the samples
	###########
	if(is.null(index)){
		tmp<-lapply(seq_len(nrow(alignCl)),function(i){unlist(alignCl[i,])})
		index<-do.call("order",tmp)
	}
	

	if(plot) .clusterTrackingPlot(t(colorM[,index,drop=FALSE]),...)

	###########
    # Make color legend
	###########
	clusterLegend<-lapply(seq_len(nrow(clusters)),function(ii){
		mat<-cbind("clusterIds"=unlist(clusters[ii,]),"alignedClusterIds"=unlist(alignCl[ii,]),"color"=unlist(colorM[ii,]))
		mat<-cbind(mat,"name"=mat[,"alignedClusterIds"])
		rownames(mat)<-NULL
		mat<-(unique(mat))
		mat<-mat[order(mat[,"clusterIds"]),,drop=FALSE]
        return(mat)
	})
	names(clusterLegend)<-rownames(clusters)
	invisible(list(orderSamples=index,colors=t(colorM),alignedClusterIds=t(alignCl),clusterLegend=clusterLegend,origClusters=t(clusters)))

}

.setClusterColors <- function(past_ct,ct,colorU,past_colors,reuseColors,minRequireColor,startNewColors){
	#description: sets common color of clusters between different K
	#takes previous row's colors and defines color assignments for next row.
	#assignments are done by:
		#start with largest cluster, assign to old cluster with largest overlap
	#past_ct is the past (i.e. previous row's) assigment to indices;
	#ct is the new cluster ids that need to be aligned to the past_ct
	#colorU is set of possible colors to take from
  #returns a vector of colors


	colorU<-rep(colorU,30) #so never run out of colors
	if(is.null(past_colors) | is.null(past_ct)){
		#map values of ct to 1:(# unique values)
		ncl<-length(unique(ct))
		v<-seq_len(ncl)
		names(v)<-stringr::str_sort(unique(ct),locale="en")
		clNum<-v[match(ct,names(v))]
		newColors = colorU[clNum]
	}
	else{
		#############
		#check that past_ct and past_colors line up
		#############
		pastTab<-table(past_ct,past_colors)
		if(nrow(pastTab)!=ncol(pastTab)) stop("past_ct and past_colors have different numbers of categories")
		pastTab<-t(apply(pastTab,1,sort,decreasing=TRUE)) #numeric sort, can use sort
		#each row should have only 1 non-zero category, so once order by row, then should all be zero except first
		if(any(colSums(pastTab[,-1,drop=FALSE])>0)) stop("past_ct and past_colors do not imply the same clustering of samples.")

		if(!startNewColors){
			whShared<-which(colorU %in% past_colors)
			m<-max(whShared)
			colorU<-c(colorU[m:length(colorU)],colorU[seq_len(m)]) #puts the used by previous rows colors at the end
		}
		colorU<-colorU[!colorU %in% past_colors]
		colorU<-unique(colorU) #make sure unique colors, at least per cluster
		if(length(colorU)==0) stop("not enough colors given -- all are in past_colors")

		colori<-0 #index which color will give next.
		newColors = rep(NA,length=length(past_colors)) #NULL #NA?

		####Tabulate the two clusters
		mo=table(past_ct,ct)
		#m=mo/apply(mo,1,sum) #for each old cluster, tells the percentage of the new cluster. Shouldn't it be the other way around?(EAP)
		m=mo #use raw number instead of percentage of cluster.
						# Browse[4]> m
						#        ct
						# past_ct  1  2  3  4  9 10
						#       1 18  7  0  0  0  0
						#       3  4  0 67 45  0  0
						#       9  0  0  1  0 21  1

		#EAP: change so do the one with the most overlap first, simplifies code.
		whichClusters<-order(apply(m,2,max),decreasing = TRUE)
		usedClusters<-vector("numeric") #index of m of used clusters (pci) if !reuseColors; if reuseColors, used slightly differently
		for(tci in whichClusters){ # for each cluster EAP: in order of size

			if(!reuseColors){
				#pci tells which old cluster has the greatest number of the new cluster
				vals<-unique(m[,tci])
				vals<-vals[vals>0] #remove zeros
				pvals<-vals/sum(m[,tci])
				maxvals<-max(pvals)
				vals<-vals[pvals >= min(c(minRequireColor,maxvals))]#require 30% overlap to take on new cluster value
				if(length(vals)>0){
					vals<-sort(vals,decreasing=TRUE) #numeric sort
					#for each value, determine its matching cluster (if any) then take highest
					matchPci<-sapply(vals,function(v){
						whMatch<-which(m[,tci]==v)
						whAv<-sapply(whMatch,function(x){!x %in% usedClusters})
						if(any(whAv)) return(whMatch[which(whAv)][1]) #pick the first of the available ones
						else return(NA)
					})
					newColor<-all(is.na(matchPci))
				}
				else{ newColor<-TRUE}
				if( newColor){ #new color
					colori=colori+1
					if(colori > length(colorU)) stop("not enough colors in color list (colorU)")
					newValue<-colorU[colori]
				}
				else{
					pci <- matchPci[!is.na(matchPci)][1] #take that with highest percentage that matches
					newValue<-unique(past_colors[which(as.character(past_ct)==rownames(m)[pci])])
					usedClusters<-c(usedClusters,pci)
				}
			}
			else{
				#pci tells which old cluster has the greatest number of the new cluster
				mCurr<-m
				if(length(usedClusters)>=nrow(m)){
					colori=colori+1
					newValue<-colorU[colori]
				}
				else{
					if(length(usedClusters)>0 & length(usedClusters)<nrow(m)){
						mCurr<-m[-usedClusters, , drop=FALSE]
					}
					maxC = max(mCurr[,tci])
					pci = row.names(mCurr)[which(mCurr[,tci] == maxC)]
					newValue<-unique(past_colors[which(as.character(past_ct)==pci)])
				}
				usedClusters<-c(usedClusters,grep(pci,row.names(m)))
			}
			newColors[which(as.character(ct)==colnames(m)[tci])] <-  newValue #EAP: fixed so no longer assumes cluster assignments were numeric integers with no gaps...
			tab<-table(newColors,ct)
			nPerColor<-apply(tab,1,function(x){sum(x!=0)})
			if(any(nPerColor!=1)) stop("color assigned twice within group.")
		}
	}
	if(any(is.na(newColors))) stop("Coding Error: some samples not given a color")
	tabOld<-table(ct)
	tabNew<-table(newColors)
	if(!identical(sort(unname(tabNew)),sort(unname(tabOld)))) stop("Coding error, didn't get same number of entries of each")
	#	if(length(tabNew)!=length(tabOld) || any(sort(tabNew)!=sort(tabOld))) stop("Coding error, didn't get same number of entries of each")
	return(newColors)
}

.clusterTrackingPlot <- function(colorMat, clNames, add, xCoord, ylim, tick, ylab, xlab, axisLine, box, ...){
  	m<-t(colorMat)
  #description: plots cluster tracking plot
  #input: m - matrix where rows are k, columns are samples, and entries are color assignments
  #names: names that correspond with rows of m
	if(is.null(xCoord)){
		xleft<-seq(0,1-1/ncol(m),by=1/ncol(m))
		xright<-seq(1/ncol(m),1,by=1/ncol(m))
	}
	else{
		d<-unique(round(diff(xCoord),6)) #distance between x values; had to round because got differences due to small numerical storage issues
		if(length(d)!=1) stop("invalid x values given -- not evenly spaced")
		xleft<-xCoord-d/2
		xright<-xCoord+d/2
	}
	if(is.null(ylim)){
		ylim<-c(0,1)
	}
	d<-(ylim[2]-ylim[1])/nrow(m)
	if(nrow(m)>1){ #for safety. theoretically works regardless, but if numerical tolerance problems...
		ybottom<-seq(ylim[2]-d,ylim[1],by=-d)
		ytop<-seq(ylim[2],ylim[1]+d,by=-d)
	}
	else{
		ybottom<-ylim[1]
		ytop<-ylim[2]
	}
	if(!add) graphics::plot(NULL, xlim=range(c(xleft,xright)), ylim=ylim,axes=FALSE, ylab=ylab, xlab=xlab, bty="n",...)

	for(i in seq_len(nrow(m))){
    rect(  xleft=xleft, xright=xright,  ybottom=rep(ybottom[i],ncol(m)) , ytop=rep(ytop[i],ncol(m)), col=m[i,],border=NA,xpd=NA)
  }
  #hatch lines to indicate samples
  if(tick){
	xl = (xleft+xright)/2
  	axis(1,at=xl,labels=FALSE,tick=TRUE)
#segments(  xl, rep(-0.1,ncol(m)) , xl, rep(0,ncol(m)), col="black")    #** alt white and black color?
  }
	if(!is.null(clNames)){
		y<-(ybottom+ytop)/2
	  	axis(2,at=y,labels=clNames,xpd=NA,las=2,tick=FALSE,line=axisLine)
	}
	#draw box around
	if(box){
		rect(xleft=min(xleft), ybottom=min(ybottom), xright=max(xright), ytop=max(ytop))
	}
}


