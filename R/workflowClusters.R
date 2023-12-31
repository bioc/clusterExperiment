#Update here if change workflow values. Also defines the order of them.
.workflowValues<-c("final","mergeClusters","makeConsensus","clusterMany")

#' @title Methods for workflow clusters
#'
#' @description The main workflow of the package is made of
#'   \code{\link{clusterMany}}, \code{\link{makeConsensus}}, and
#'   \code{\link{mergeClusters}}. The clusterings from these functions (and not
#'   those obtained in a different way) can be obtained with the functions
#'   documented here.
#' @param x a \code{\link{ClusterExperiment}} object.
#' @param iteration numeric. Which iteration of the workflow should be used.
#' @return \code{workflowClusters} returns a matrix consisting of the
#'   appropriate columns of the \code{clusterMatrix} slot.
#' @aliases workflowClusters workflowClusterTable workflowClusterDetails
#'   workflowClusters,ClusterExperiment-method
#' @name workflowClusters
#' @export
#' @examples
#' \dontrun{
#' data(simData)
#'
#' cl <- clusterMany(simData,nReducedDims=c(5,10,50),  reduceMethod="PCA",
#' clusterFunction="pam", ks=2:4, findBestK=c(FALSE), removeSil=TRUE,
#' subsample=FALSE, makeMissingDiss=TRUE)
#'
#' clCommon <- makeConsensus(cl, whichClusters="workflow", proportion=0.7,
#' minSize=10)
#'
#' clCommon <- makeDendrogram(clCommon)
#'
#' clMerged <- mergeClusters(clCommon,mergeMethod="adjP", DEMethod="limma")
#'
#' head(workflowClusters(clMerged))
#' workflowClusterDetails(clMerged)
#' workflowClusterTable(clMerged)
#' }
setMethod(
  f = "workflowClusters",
  signature = signature("ClusterExperiment"),
  definition = function(x,iteration=0) {
    ppIndex<-workflowClusterDetails(x)
    if(is.na(iteration)) iteration<-unique(ppIndex[,"iteration"])
    if(!is.null(ppIndex)){
      whIteration<-which(ppIndex[,"iteration"]%in%iteration)
      if(length(whIteration)>0){
        index<-ppIndex[whIteration,"index"]
        return(clusterMatrix(x)[,index,drop=FALSE])
      }
      else return(NULL)
    }
    else return(NULL)
  }
)


#' @rdname workflowClusters
#' @return \code{workflowClusterDetails} returns a \code{data.frame} with some
#'   details on the clusterings, such as the type (e.g., `clusterMany`,
#'   `makeConsensus`) and iteration.
#' @export
setMethod(
  f = "workflowClusterDetails",
  signature = signature("ClusterExperiment"),
  definition = function(x) {

    if(length(clusterTypes(x))!=NCOL(clusterMatrix(x))) stop("Invalid ClusterExperiment object")
    #check if old iterations already exist; note assumes won't have previous iteration unless have current one.
    existingOld<-lapply(.workflowValues,function(ch){
      regex<-paste(ch,".",sep="")
      grep(regex,clusterTypes(x))

    })
    st<-strsplit(clusterTypes(x)[unlist(existingOld)],"[.]")
    oldValues<-data.frame(index=unlist(existingOld),type=sapply(st,.subset2,1),iteration=as.numeric(sapply(st,.subset2,2)),stringsAsFactors=FALSE)

    wh<-which(clusterTypes(x) %in% .workflowValues) #current iteration
    if(length(wh)>0){
      existingValues<-data.frame(index=wh,type=clusterTypes(x)[wh], iteration=0,stringsAsFactors=FALSE) #0 indicates current iteration
      if(nrow(oldValues)>0) existingValues<-rbind(oldValues,existingValues)
    }
    else{
      if(nrow(oldValues)>0) existingValues<-oldValues
      else   return(NULL)
    }
    if(nrow(existingValues)>0){ #just to make sure
        existingValues$label=clusterLabels(x)[existingValues$index]
        existingValues<-existingValues[order(existingValues$index),]
    }
    rownames(existingValues)<-NULL
    return(existingValues)

  }
)
#' @rdname workflowClusters
#' @return \code{workflowClusterTable} returns a table of how many of the
#'   clusterings belong to each of the following possible values: `final`,
#'   `mergeClusters`, `makeConsensus` and `clusterMany`.
#' @export
setMethod(
  f = "workflowClusterTable",
  signature = signature("ClusterExperiment"),
  definition = function(x){
    ppIndex<-workflowClusterDetails(x)
    table(Type=factor(ppIndex[,"type"],levels=.workflowValues),Iteration=factor(ppIndex[,"iteration"]))
  }
)


#' @rdname workflowClusters
#' @inheritParams clusterMany
#' @inheritParams getClusterIndex
#' @return \code{setToCurrent} returns a \code{ClusterExperiment} object where
#'   the indicated cluster of \code{whichCluster} has been set to the most
#'   current iteration in the workflow. Pre-existing clusters are appropriately
#'   updated.
#' @export
#' @aliases setToCurrent
setMethod(
  f = "setToCurrent",
  signature = signature("ClusterExperiment"),
  definition = function(x,whichCluster,eraseOld=FALSE){
    whCl<-getSingleClusterIndex(x,whichCluster=whichCluster)
    type<-strsplit(clusterTypes(x)[whCl],"[.]")[[1]][1]
    if(!type %in% .workflowValues[-1]) stop("Input cluster is not a workflow cluster. Must be of clustType: ",paste(.workflowValues[-1],sep=","))
			#not sure here if should have argument newLabelToAdd
    newX<-.updateCurrentWorkflow(x,eraseOld=eraseOld,newTypeToAdd=type,newLabelToAdd=NULL)
		
    clusterTypes(newX)[whCl]<-type
    primaryClusterIndex(newX)<-whCl
    
    if(strsplit(clusterLabels(x)[whCl],"[.]")[[1]][1]==type){
      clusterLabels(newX)[whCl]<-type
    }
    return(newX)
  }
)

#' @rdname workflowClusters
#' @param clusterLabel optional string value to give to cluster set to be "final"
#' @return \code{setToFinal} returns a \code{ClusterExperiment} object where the
#'   indicated cluster of \code{whichCluster} has clusterType set to "final".
#'   The primaryClusterIndex is also set to this cluster, and the clusterLabel,
#'   if given.
#' @export
#' @aliases setToFinal
setMethod(
  f = "setToFinal",
  signature = signature("ClusterExperiment"),
  definition = function(x,whichCluster,clusterLabel){
    whCl<-getSingleClusterIndex(x,whichCluster=whichCluster)
    clusterTypes(x)[whCl]<-"final"
    if(!missing(clusterLabel)) clusterLabels(x)[whCl]<-clusterLabel
    primaryClusterIndex(x)<-whCl
    return(x)
  }
)
#change current workflow to old iteration
# add number to it if eraseOld=FALSE
# delete ALL workflow if eraseOld=TRUE (not just the current iteration)
.updateCurrentWorkflow<-function(object,eraseOld,newTypeToAdd,newLabelToAdd){
  
  ppIndex<-workflowClusterDetails(object)
  origLabels<-clusterLabels(object)
  origTypes<-clusterTypes(object)
  if(!any(newTypeToAdd %in% .workflowValues[-1])) stop("error in internal coding: newTypeToAdd must be one of .workflowValues. Contact mantainer.")
  whNew<-max(match(newTypeToAdd, .workflowValues))
  downstreamType<-.workflowValues[2:whNew]
  if(!is.null(ppIndex)){ #there are pre-existing workflow results
    curr<-ppIndex[ppIndex[,"iteration"]==0,]
    if(any(curr[,"type"] %in% downstreamType) || any(ppIndex[,"iteration"]!=0)){
      if(eraseOld){
        #removes all past iterations, not just current, except for current iteration that upstream of new one
        whRm<- union(curr[curr[,"type"] %in% downstreamType, "index"],ppIndex[ppIndex[,"iteration"]!=0,"index"])
        if(length(whRm)==nClusterings(object)) return(NULL)
        else object<-removeClusterings(object,whRm) 
      }
      else{
        #otherwise, only current downstream ones that exist get updated number
        if(any(curr[,"type"] %in% downstreamType)){
          whDown<-which(ppIndex[,"type"] %in% downstreamType)
          maxDownstream<-max(ppIndex[whDown,"iteration"])
          newIteration<-maxDownstream+1
          #check if any upstream have iteration > maxDownstream
          whUp<-which(!ppIndex[,"type"] %in% downstreamType)
          if(length(whUp)>0){
            maxUpstream<-max(ppIndex[whUp,"iteration"])
            if(maxUpstream>newIteration) newIteration<-maxUpstream
          }
          whFix<-curr[curr[,"type"] %in% downstreamType, "index"]
          
          updateCluster<-origTypes
          updateCluster[whFix]<-paste(updateCluster[whFix],newIteration,sep=".")
          clusterTypes(object)<-updateCluster
          if(any(origLabels[whFix]%in%.workflowValues) | any(origTypes[whFix]=="clusterMany")){ 
            #only change those labels that haven't been manually fixed by the user
            updateLabel<-origLabels
            if(any(origLabels[whFix]%in%.workflowValues)){
              whUnedited<-which(updateLabel[whFix]%in%.workflowValues)
              updateLabel[whFix[whUnedited]]<-paste(updateLabel[whFix[whUnedited]],newIteration,sep=".")
            }
            if(any(origTypes[whFix]=="clusterMany")){
              #always update the clusterMany labels because otherwise get repetitive. Mainly for test checks...
              #should always be different set than the ones above.
              whCM<-which(origTypes[whFix]=="clusterMany")
              updateLabel[whFix[whCM]]<-paste(updateLabel[whFix[whCM]],newIteration,sep=".")
            }
            clusterLabels(object)<-updateLabel
          }
          else if(!is.null(newLabelToAdd) && any(newLabelToAdd %in% origLabels[whFix])){
            updateLabel<-origLabels
            whDuplicated<-which(updateLabel[whFix]%in%newLabelToAdd)
            updateLabel[whFix[whDuplicated]]<-paste(updateLabel[whFix[whDuplicated]],newIteration,sep=".")
            clusterLabels(object)<-updateLabel
            
          }
          
        }
      }
    }
  }
  object<-.unnameClusterSlots(object) #just to make sure didn't have names on labels or types
  ch<-.checkClusterTypes(object)
  if(!is.logical(ch)) stop(ch)
  ch<-.checkClusterLabels(object)
  if(!is.logical(ch)) stop(ch)
  return(object)
}
