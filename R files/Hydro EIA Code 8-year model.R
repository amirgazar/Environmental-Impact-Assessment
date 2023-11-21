# Do electrical interties stimulate Canadian hydroelectric development? Using causal inference to scope environmental impact assessment in evolving sociotechnical systems
# Amir M. Gazar1,2,*, Mark E. Borsuk3, Ryan S.D. Calder1,2,3,4,5
# 1 Department of Population Health Sciences, Virginia Tech, Blacksburg, VA, 24061, USA
# 2 Global Change Center, Virginia Tech, Blacksburg, VA, 24061, USA
# 3 Department of Civil and Environmental Engineering, Duke University, Durham, NC, 27708, USA
# 4 Faculty of Health Sciences, Virginia Tech, Roanoke, VA, 24016, USA
# 5 Department of Civil and Environmental Engineering, Virginia Tech, Blacksburg, VA, 24061, USA

# *Contact: amirgazar@vt.edu.   
# All rights reserved under Creative Commons 4.0


# Install Rgraphviz from Bioconductor
#if (!requireNamespace("BiocManager", quietly = TRUE))
#  install.packages("BiocManager")
#BiocManager::install("Rgraphviz")

# List of other packages to install
#packages <- c("bnlearn", "gRain", "visNetwork", "ggplot2", "zoo", "scales", "gridExtra", "dplyr", "MASS","svglite", "tidyverse")

# Install packages
#install.packages(packages)

# Load all the required packages
invisible(lapply(c("Rgraphviz", "bnlearn", "gRain", "visNetwork", "ggplot2", 
                   "stats", "zoo", "scales", "gridExtra", "dplyr", "MASS","svglite","tidyverse"), library, character.only = TRUE))


# Set Working Directory (change for your setup)
setwd("/Users/amirgazar/Documents/Hydro EIA Code/data")

# Read the data-set
hydro.data <- read.csv("hydro_var_aug23.csv")

## Functions
# 1. DAG Visualizer
plot.network <- function(structure, ht = "400px", title){
  
  # Unique nodes from the arcs of the structure are identified.
  nodes.uniq <- unique(c(structure$arcs[,1], structure$arcs[,2]))
  
  # A data frame for nodes is created with attributes like id, label, color, and shadow.
  nodes <- data.frame(id = nodes.uniq,
                      label = nodes.uniq,
                      color = "maroon",
                      shadow = TRUE)
  
  # A data frame for edges is created with attributes like source, target, arrow direction, and other visual properties.
  edges <- data.frame(from = structure$arcs[,1],
                      to = structure$arcs[,2],
                      arrows = "to",
                      smooth = TRUE,
                      shadow = TRUE,
                      color = "black")
  
  # The network is visualized using the visNetwork function and returned.
  return(visNetwork(nodes, edges, height = ht, width = "100%"))
}
# 2. Box-Cox Transformer
transform_and_test <- function(df, non_gaussian_vars){
  
  # Lists to store variables that remain non-Gaussian after transformation and those that were successfully transformed.
  still_non_gaussian <- vector("list")
  transformed_vars <- vector("list")  
  df_new = df
  
  # Each non-Gaussian variable is processed.
  for (var in non_gaussian_vars) {
    
    # The minimum value of the variable is determined.
    min_value <- min(df[[var]], na.rm = TRUE)
    
    # If the minimum value is less than or equal to zero, a constant is added to make it positive.
    if (min_value <= 0) {
      constant <- abs(min_value) + 1
      df[[var]] <- df[[var]] + constant
    }
    
    # The Box-Cox transformation parameter (lambda) is estimated.
    bc <- boxcox(df[[var]] ~ 1, plotit = FALSE)
    lambda <- bc$x[which.max(bc$y)]
    
    # Depending on the value of lambda, the variable is transformed.
    if(abs(lambda) <= 1e-5){
      transformed_var <- log(df[[var]])
    } else {
      transformed_var <- (df[[var]]^lambda - 1) / lambda
    }
    
    # The transformed variable is tested for normality using the Shapiro-Wilk test.
    shapiro_test <- shapiro.test(transformed_var)
    
    # Based on the p-value, the variable is categorized as still non-Gaussian or successfully transformed.
    if (shapiro_test$p.value < 0.05) {
      still_non_gaussian <- c(still_non_gaussian, var)
    } else {
      df_new[[var]] <- transformed_var
      transformed_vars <- c(transformed_vars, var)  
    }
  }
  
  # The modified data frame, list of still non-Gaussian variables, and list of transformed variables are returned.
  list(df = df_new, still_non_gaussian = still_non_gaussian, transformed = transformed_vars)
}
# 3. Goodness of fit
evaluate_fit_continuous <- function(actual, predicted) {
  
  # An empty list for metrics is initialized.
  metrics <- list()
  
  # The r-squared metric is computed and stored in the metrics list.
  metrics$rsquared <- 1 - sum((predicted - actual)^2) / sum((actual - mean(actual))^2)
  
  # The metrics list is returned.
  return(metrics)
}
evaluate_fit_discrete <- function(actual, predicted) {
  
  # An empty list for metrics is initialized.
  metrics <- list()
  
  # The accuracy metric is computed and stored in the metrics list.
  metrics$accuracy <- sum(actual == predicted) / length(actual)
  
  # The metrics list is returned.
  return(metrics)
}
# 4. D-Separation

arc_exists <- function(from, to, existing_arcs) {
  # The existence of the arc is checked and the result is returned.
  return(any(existing_arcs[existing_arcs[, "from"] == from, "to"] == to))
}
perform_dsep_tests <- function(dag, data) {
  # Existing arcs in the DAG are extracted.
  existing_arcs <- arcs(dag)
  
  # An internal function to check for arc existence is defined.
  arc_exists <- function(from, to, existing_arcs) {
    return(any(existing_arcs[existing_arcs[, "from"] == from, "to"] == to))
  }
  
  # A list for non-adjacent node pairs is initialized.
  non_adj_pairs <- list()
  
  # Non-adjacent node pairs are identified.
  for (node1 in node.ordering(dag)) {
    for (node2 in node.ordering(dag)) {
      if (!arc_exists(node1, node2, existing_arcs) && !arc_exists(node2, node1, existing_arcs) && node1 != node2) {
        non_adj_pairs <- append(non_adj_pairs, list(c(node1, node2)))
      }
    }
  }
  
  # A list for test results is initialized.
  results_parents <- list()
  results_nbr <- list()
  results_mb <- list()
  
  # D-separation tests are performed for each non-adjacent pair.
  for (pair in non_adj_pairs) {
    # Conditioning on parents of a node
    conditioning_set <- setdiff(unique(c(bnlearn::parents(dag, pair[1]), bnlearn::parents(dag, pair[2]))), pair)  # Combined Markov blanket excluding x and y
    test <- ci.test(pair[1], pair[2], conditioning_set, data = data)
    results_parents[[paste0(pair[1], "_", pair[2])]] <- test$p.value
    # Conditioning on immediate neighbors of a node
    conditioning_set <- setdiff(unique(c(nbr(dag, pair[1]), nbr(dag, pair[2]))), pair)  # Combined Markov blanket excluding x and y
    test <- ci.test(pair[1], pair[2], conditioning_set, data = data)
    results_nbr[[paste0(pair[1], "_", pair[2])]] <- test$p.value
    # Conditioning on Markov Blanket of a node
    conditioning_set <- setdiff(unique(c(mb(dag, pair[1]), mb(dag, pair[2]))), pair)  # Combined Markov blanket excluding x and y
    test <- ci.test(pair[1], pair[2], conditioning_set, data = data)
    results_mb[[paste0(pair[1], "_", pair[2])]] <- test$p.value
  }
  
  return(list(parents = results_parents, neighbors = results_nbr, markov_blanket = results_mb))
  
}
interpret_dsep_pvalues <- function(pvalues, threshold_low = 0.05, threshold_high = 0.95) {
  # P-values are categorized based on predefined thresholds.
  categories <- sapply(pvalues, function(p) {
    if (p > threshold_high) {
      return("Conditionally Independent")
    } else if (p < threshold_low) {
      return("Potential Missing Link")
    } else {
      return("Uncertain - Further Analysis Needed")
    }
  })
  return(categories)
}
interpret_print <- function(node1, node2, interpretations_list) {
  # Constructing the key string from the node names
  key <- paste0(node1, "_", node2)
  
  interpretations <- lapply(interpretations_list, function(interpretation) {
    interpretation[key]
  })
  
  names(interpretations) <- c("parents", "neighbors", "markov_blanket")
  
  # Printing the results
  cat("From", node1, "To", node2, ":\n")
  for (name in names(interpretations)) {
    cat("Results for", name, ":\n")
    cat(interpretations[[name]], "\n\n")  # Directly prints the value without the key
  }
}
dsep.dag <- function(dag, data, node_pairs) {
  # Performing D-separation tests
  dsep_results <- perform_dsep_tests(dag, data)
  
  # Translating the results
  interpretations_list <- lapply(dsep_results, interpret_dsep_pvalues)
  
  # Initializing a list to hold the interpreted results for each node pair
  interpreted_results <- list()
  
  for (node_pair in node_pairs) {
    key <- paste0(node_pair[1], "_", node_pair[2])
    interpret_print(node_pair[1], node_pair[2], interpretations_list)
    interpreted_results[[key]] <- lapply(interpretations_list, function(interpretation) interpretation[key])
  }
  
  # Returning the list of interpreted results
  return(interpreted_results)
}


## Variable Preparation
{
  # New intertie capacity in every year
  hydro.data$INTERTIE_new = NA
  for(i in 2:nrow(hydro.data)){
    hydro.data$INTERTIE_new[i] = hydro.data$INTERTIE[i] -
      hydro.data$INTERTIE[i-1]
  }
  # New installed capacity in every year
  hydro.data$INSTALLED_new = NA
  
  for(i in 2:nrow(hydro.data)){
    hydro.data$INSTALLED_new[i] = hydro.data$INSTALLED[i] -
      hydro.data$INSTALLED[i-1]
  }
  # New DEMAND_QC in every year
  hydro.data$DEMAND_QC_new = NA
  
  for(i in 2:nrow(hydro.data)){
    hydro.data$DEMAND_QC_new[i] = hydro.data$DEMAND_QC[i] -
      hydro.data$DEMAND_QC[i-1]
  }
  
  # New DEMAND_US in every year
  hydro.data$DEMAND_US_new = NA
  
  for(i in 2:nrow(hydro.data)){
    hydro.data$DEMAND_US_new[i] = hydro.data$DEMAND_US[i] -
      hydro.data$DEMAND_US[i-1]
  }
  # New INVESTMENT in every year
  hydro.data$INVESTMENT_new = NA
  
  for(i in 2:nrow(hydro.data)){
    hydro.data$INVESTMENT_new[i] = hydro.data$INVESTMENT[i] -
      hydro.data$INVESTMENT[i-1]
  }
  # New EXPORTS in every year
  hydro.data$EXPORTS_new = NA
  
  for(i in 2:nrow(hydro.data)){
    hydro.data$EXPORTS_new[i] = hydro.data$EXPORTS[i] -
      hydro.data$EXPORTS[i-1]
  }
  
  # New PRICE in every year
  hydro.data$PRICE_new = NA
  
  for(i in 2:nrow(hydro.data)){
    hydro.data$PRICE_new[i] = hydro.data$PRICE[i] -
      hydro.data$PRICE[i-1]
  }  
  # Sum of new intertie capacity in preceding 8 years
  hydro.data$INTERTIE_8y = NA
  for(i in 8:nrow(hydro.data)){
    hydro.data$INTERTIE_8y[i] = sum(hydro.data$INTERTIE_new[(i-7):i],na.rm=T)
  }
  # Sum of new installed capacity in preceding 8 years
  hydro.data$INSTALLED_8y = NA
  for(i in 8:nrow(hydro.data)){
    hydro.data$INSTALLED_8y[i] = sum(hydro.data$INSTALLED_new[(i-7):i],na.rm=T)
    
  }
  # Sum of new installed capacity in preceding 8 years lagged by 8 years
  hydro.data$INSTALLED_8y_lag_8y = NA
  for(i in 10:nrow(hydro.data)){
    hydro.data$INSTALLED_8y_lag_8y[i] = hydro.data$INSTALLED_8y[i-8]
    
  }
  # Sum of new intertie capacity in preceding 8 years lagged by 8 years
  hydro.data$INTERTIE_8y_lag_8y = NA
  for(i in 10:nrow(hydro.data)){
    hydro.data$INTERTIE_8y_lag_8y[i] = hydro.data$INTERTIE_8y[i-8]
  }
  # Mean price difference in preceding 8 years
  hydro.data$PRICE_8y = NA
  for(i in 8:nrow(hydro.data)){
    hydro.data$PRICE_8y[i] = mean(hydro.data$PRICE[(i-7):i],na.rm=T)
    
  }
  # Sum of PRICE mean in preceding 8 years lagged by 8 years
  hydro.data$PRICE_8y_lag_8y = NA
  for(i in 10:nrow(hydro.data)){
    hydro.data$PRICE_8y_lag_8y[i] = hydro.data$PRICE_8y[i-8]
    
  }
  # Mean export in preceding 8 years
  hydro.data$EXPORTS_8y = NA
  for(i in 8:nrow(hydro.data)){
    hydro.data$EXPORTS_8y[i] = mean(hydro.data$EXPORTS[(i-7):i],na.rm=T)
  }
  # Mean QC demand in preceding 8 years
  hydro.data$DEMAND_QC_8y = NA
  for(i in 8:nrow(hydro.data)){
    hydro.data$DEMAND_QC_8y[i] = mean(hydro.data$DEMAND_QC[(i-7):i],na.rm=T)
  }
  
  # Mean QC demand in preceding 8 years lagged by 8 years
  hydro.data$DEMAND_QC_8y_lag_8y = NA
  for(i in 10:nrow(hydro.data)){
    hydro.data$DEMAND_QC_8y_lag_8y[i] = hydro.data$DEMAND_QC_8y[i-8]
  }
  # Mean US demand in preceding 8 years
  hydro.data$DEMAND_US_8y = NA
  for(i in 8:nrow(hydro.data)){
    hydro.data$DEMAND_US_8y[i] = mean(hydro.data$DEMAND_US[(i-7):i],na.rm=T)
  }
  
  # Mean US demand in preceding 8 years lagged by 8 years
  hydro.data$DEMAND_US_8y_lag_8y = NA
  for(i in 10:nrow(hydro.data)){
    hydro.data$DEMAND_US_8y_lag_8y[i] =
      hydro.data$DEMAND_US_8y[i-8]
    
  }
  # Mean investment in preceding 8 years
  hydro.data$INVESTMENT_8y = NA
  for(i in 8:nrow(hydro.data)){
    hydro.data$INVESTMENT_8y[i] = mean(hydro.data$INVESTMENT[(i-7):i],na.rm=T)
  }
  
  # Total investment in preceding 8 years
  hydro.data$INVESTMENT_total_8y = NA
  for(i in 8:nrow(hydro.data)){
    hydro.data$INVESTMENT_total_8y[i] = sum(hydro.data$INVESTMENT[(i-7):i],na.rm=T)
  }
}

# Creating _new 8 year averaged and lagged
lag_periods <- c(8)
new_vars <- c("INTERTIE", "INSTALLED", "DEMAND_QC", "DEMAND_US", "INVESTMENT", "EXPORTS", "PRICE")

for (var in new_vars) {
  var_new <- paste0(var, "_new")
  
  for (lag_period in lag_periods) {
    # moving average
    var_avg <- paste0(var_new, "_avg_", lag_period, "y")
    hydro.data[[var_avg]] <- zoo::rollapplyr(hydro.data[[var_new]], width = lag_period, FUN = mean, fill = NA)
    
    # lagged average
    var_lag_avg <- paste0(var_avg, "_lag_", lag_period, "y")
    hydro.data[[var_lag_avg]] <- dplyr::lag(hydro.data[[var_avg]], lag_period)
  }
}

# Subset of data with 8-yr avg/lag for everything
vars.exclude.8y = c(1:8,grep("_new$",colnames(hydro.data)))

hydro.data.subset.8y = 
  hydro.data[,setdiff(1:ncol(hydro.data),
                      vars.exclude.8y)]
# Ensuring that all variables are numeric
for(i in 1:ncol(hydro.data.subset.8y)){
  hydro.data.subset.8y[,i] = as.numeric(hydro.data.subset.8y[,i]) 
}

# Create new dataframe 
df.8y = hydro.data.subset.8y

# Creating new data frames with minimum number of rows cut off
lag.cols.8y = grep("lag",colnames(df.8y))
df.8y.no.lags = df.8y[,setdiff(1:ncol(df.8y),
                               lag.cols.8y)]
df.8y.rows.to.cut = which(apply(df.8y,1,function(x) sum(is.na(x))>0))
df.8y.no.lags.rows.to.cut = which(apply(df.8y.no.lags,1,function(x) sum(is.na(x))>0))
df.8y.with.lags.no.NA = df.8y[setdiff(1:nrow(df.8y),
                                      df.8y.rows.to.cut),]
# Check for gaussian distribution
significance_level <- 0.05
non_gaussian_8y_lag <- vector("list")
for (var in colnames(df.8y.with.lags.no.NA)) {
  # Shapiro-Wilk Test
  shapiro_test <- shapiro.test(df.8y.with.lags.no.NA[[var]])
  print(paste("Shapiro-Wilk Test for", var, "- p-value:", shapiro_test$p.value))
  
  if (shapiro_test$p.value < significance_level) {
    non_gaussian_8y_lag <- c(non_gaussian_8y_lag, var)
  }
}
# Box-Cox transformation for the non-gaussian variables and rechecking the gaussian distribution
result_8y_lag <- transform_and_test(df.8y.with.lags.no.NA, non_gaussian_8y_lag)
df.8y.with.lags.no.NA <- result_8y_lag$df
still_non_gaussian_8y_lag <- result_8y_lag$still_non_gaussian

# We manually revert this var from box-cox transform to maintain consistancy with Price_8y var that was transfored by box-cox
bc <- boxcox(df.8y.with.lags.no.NA$PRICE_8y_lag_8y ~ 1, plotit = FALSE)
lambda <- bc$x[which.max(bc$y)]
df.8y.with.lags.no.NA$PRICE_8y_lag_8y <- (df.8y.with.lags.no.NA$PRICE_8y_lag_8y^lambda - 1) / lambda

## Discretising remaining variables that have significant SW test results or are zero-inflated 
df.8y.with.lags.no.NA$INTERTIE_8y <- cut(df.8y.with.lags.no.NA$INTERTIE_8y , breaks = c(min(df.8y.with.lags.no.NA$INTERTIE_8y,na.rm=T ), 100, max(df.8y.with.lags.no.NA$INTERTIE_8y,na.rm=T )), labels = c("non-significant", "significant"), include.lowest = TRUE, ordered_result = TRUE)
df.8y.with.lags.no.NA$INTERTIE_8y_lag_8y <- cut(df.8y.with.lags.no.NA$INTERTIE_8y_lag_8y , breaks = c(min(df.8y.with.lags.no.NA$INTERTIE_8y_lag_8y,na.rm=T ), 100, max(df.8y.with.lags.no.NA$INTERTIE_8y_lag_8y,na.rm=T )), labels = c("non-significant", "significant"), include.lowest = TRUE, ordered_result = TRUE)
df.8y.with.lags.no.NA$DEMAND_QC_8y <- cut(df.8y.with.lags.no.NA$DEMAND_QC_8y, breaks = c(min(df.8y.with.lags.no.NA$DEMAND_QC_8y,na.rm=T), 120, 160, max(df.8y.with.lags.no.NA$DEMAND_QC_8y,na.rm=T)), labels = c("low", "medium", "high"), include.lowest = TRUE, ordered_result = TRUE)
df.8y.with.lags.no.NA$DEMAND_US_8y <- cut(df.8y.with.lags.no.NA$DEMAND_US_8y, breaks = c(min(df.8y.with.lags.no.NA$DEMAND_US_8y,na.rm=T), 240, 260, max(df.8y.with.lags.no.NA$DEMAND_US_8y,na.rm=T)), labels = c("low", "medium", "high"), include.lowest = TRUE, ordered_result = TRUE)
df.8y.with.lags.no.NA$INVESTMENT_8y <- cut(df.8y.with.lags.no.NA$INVESTMENT_8y, breaks = c(min(df.8y.with.lags.no.NA$INVESTMENT_8y,na.rm=T), 2800, 3400, max(df.8y.with.lags.no.NA$INVESTMENT_8y,na.rm=T)), labels = c("low", "medium", "high"), include.lowest = TRUE, ordered_result = TRUE)
df.8y.with.lags.no.NA$EXPORTS_new_avg_8y_lag_8y <- cut(df.8y.with.lags.no.NA$EXPORTS_new_avg_8y_lag_8y, breaks = c(min(df.8y.with.lags.no.NA$EXPORTS_new_avg_8y_lag_8y,na.rm=T), 0, max(df.8y.with.lags.no.NA$EXPORTS_new_avg_8y_lag_8y,na.rm=T)), labels = c("negative", "positive"), include.lowest = TRUE, ordered_result = TRUE)

# We manually revert this var from box-cox transform due to its histogram 
df.8y.with.lags.no.NA$INSTALLED_8y_lag_8y = hydro.data$INSTALLED_8y_lag_8y[17:nrow(hydro.data)]
df.8y.with.lags.no.NA$INSTALLED_8y_lag_8y <- cut(df.8y.with.lags.no.NA$INSTALLED_8y_lag_8y , breaks = c(min(df.8y.with.lags.no.NA$INSTALLED_8y_lag_8y,na.rm=T ), 3000, 5000, max(df.8y.with.lags.no.NA$INSTALLED_8y_lag_8y,na.rm=T )), labels = c("low", "medium", "high"), include.lowest = TRUE, ordered_result = TRUE)

# Selecting columns of interest
selected.columns <- c('INSTALLED_8y_lag_8y', 'INSTALLED_8y', 'DEMAND_QC_new_avg_8y_lag_8y', 'INVESTMENT_8y', 'PRICE_8y_lag_8y',
                      'INTERTIE_8y_lag_8y', 'INTERTIE_8y', 'DEMAND_US_new_avg_8y_lag_8y', 'PRICE_8y',
                      'EXPORTS_new_avg_8y_lag_8y', 'EXPORTS_8y', 'DEMAND_QC_8y', 'DEMAND_US_8y')

# Subsetting the dataframe and creating the final dataframe
df.expert.8y <- df.8y.with.lags.no.NA[, selected.columns]

## Creating the expert blacklist
# The allow list is initialized with specific variable pairs.
allow.list.expert =                               
  data.frame(matrix(c(
    
    # Investment --> Installed
    "INVESTMENT_8y","INSTALLED_8y", 
    
    # Installed --> Exports
    "INSTALLED_8y","EXPORTS_8y",          
    
    # QC demand lag --> Installed
    "DEMAND_QC_new_avg_8y_lag_8y","INSTALLED_8y",  
    
    # Price lag --> Installed
    "PRICE_8y_lag_8y","INSTALLED_8y",  
    
    # Intertie lag --> Installed
    "INTERTIE_8y_lag_8y","INSTALLED_8y", 
    
    # Installed --> Intertie
  #  "INSTALLED_8y","INTERTIE_8y", 
    "INSTALLED_8y_lag_8y", "INTERTIE_8y",
    
    # Investment --> Intertie
    "INVESTMENT_8y","INTERTIE_8y", 
    
    # US demand lag --> Intertie
    "DEMAND_US_new_avg_8y_lag_8y","INTERTIE_8y",
    
    # Price lag --> Intertie
    "PRICE_8y_lag_8y","INTERTIE_8y",  
    
    # QC demand lag --> Investment
    "DEMAND_QC_new_avg_8y_lag_8y","INVESTMENT_8y",
   
    # QC demand --> Price
    "DEMAND_QC_8y","PRICE_8y", 
    
    # Exports lag --> Investment
    "EXPORTS_new_avg_8y_lag_8y","INVESTMENT_8y",
    
    # Intertie --> Exports
    "INTERTIE_8y","EXPORTS_8y", 
    
    # Price --> Exports
    "PRICE_8y","EXPORTS_8y", 
    
    # US demand --> Price
    "DEMAND_US_8y","PRICE_8y"),
    ncol = 2,byrow=TRUE))

# Column names for the allow list are assigned.
colnames(allow.list.expert) = c("From","To")

# The black list is initialized with a placeholder value.
black.list.expert = NA

# For each pair of variables in the final data-frame, a check is performed.
# If the pair is not found in the allow list, it is added to the black list.
for(i in 1:ncol(df.expert.8y)){
  for(j in 1:ncol(df.expert.8y)){
    from.test = colnames(df.expert.8y)[i]
    to.test = colnames(df.expert.8y)[j]
    
    if(length(which(allow.list.expert$From==from.test&
                    allow.list.expert$To==to.test))==0){
      black.list.expert = 
        rbind(black.list.expert,c(from.test,to.test))
    }
  }
}

# Column names for the black list are assigned.
colnames(black.list.expert) = c("From","To")

# The placeholder value in the black list is removed.
black.list.expert = black.list.expert[2:nrow(black.list.expert),]

## Visualizing the expert DAG
# A DAG is constructed using expert knowledge.
dag.expert.8y <- model2network("[INSTALLED_8y_lag_8y][DEMAND_QC_new_avg_8y_lag_8y][PRICE_8y_lag_8y][INTERTIE_8y_lag_8y][DEMAND_US_new_avg_8y_lag_8y][EXPORTS_new_avg_8y_lag_8y][DEMAND_QC_8y][DEMAND_US_8y][INSTALLED_8y|DEMAND_QC_new_avg_8y_lag_8y:INVESTMENT_8y:PRICE_8y_lag_8y:INTERTIE_8y_lag_8y][INTERTIE_8y|INSTALLED_8y_lag_8y:INVESTMENT_8y:DEMAND_US_new_avg_8y_lag_8y:PRICE_8y_lag_8y][INVESTMENT_8y|DEMAND_QC_new_avg_8y_lag_8y:EXPORTS_new_avg_8y_lag_8y][EXPORTS_8y|INTERTIE_8y:INSTALLED_8y:PRICE_8y][PRICE_8y|DEMAND_QC_8y:DEMAND_US_8y]")

# The constructed DAG is visualized with a specified height.
plot.network(dag.expert.8y, ht = "600px")

## Creating Score-Based DAGs
# DAG created using the loglik-cg score function and HC algorithm
dag.expert.8y.emp <- hc(df.expert.8y, score = "loglik-cg", blacklist = black.list.expert, debug = FALSE)
par(mar=c(1,1,1,1))
# Fitting the model 
model.expert.8y.emp = bn.fit(dag.expert.8y.emp, df.expert.8y)
#Visualizing model's conditional probabilities using the graphviz.chart
graphviz.chart(model.expert.8y.emp,  type = "barprob", grid = TRUE, bar.col = "darkgreen",
               strip.bg = "lightskyblue")
dev.off()
# Network visualized using plot.network
plot.network(dag.expert.8y.emp, ht = "600px")

# DAG created using the aic-cg score function and HC algorithm
dag.expert.8y.emp.aic <- hc(df.expert.8y, score = "aic-cg", blacklist = black.list.expert)
plot.network(dag.expert.8y.emp.aic, ht = "600px")
par(mar=c(1,1,1,1))
model.expert.8y.emp.aic = bn.fit(dag.expert.8y.emp.aic, df.expert.8y)
graphviz.chart(model.expert.8y.emp.aic,  type = "barprob", grid = TRUE, bar.col = "darkgreen",
               strip.bg = "lightskyblue")
dev.off()

# DAG created using the bic-cg score function and HC algorithm
dag.expert.8y.emp.bic <- hc(df.expert.8y, score = "bic-cg", blacklist = black.list.expert)
plot.network(dag.expert.8y.emp.bic, ht = "600px")
par(mar=c(1,1,1,1))
model.expert.8y.emp.bic = bn.fit(dag.expert.8y.emp.bic, df.expert.8y)
graphviz.chart(model.expert.8y.emp.bic,  type = "barprob", grid = TRUE, bar.col = "darkgreen",
               strip.bg = "lightskyblue")
dev.off()

## rmse, MSE, MAE and Rsquared for each node
# Loglik model
df.expert.8y <- df.8y.with.lags.no.NA[, selected.columns]

results_loglik <- list()
discrete_vars <- c("INTERTIE_8y", "INVESTMENT_8y")
continuous_vars <- setdiff(colnames(df.expert.8y), c(discrete_vars, grep("_pred$", colnames(df.expert.8y), value = TRUE)))

for (var in colnames(df.expert.8y)) {
  if (!grepl("_pred$", var)) {
    pred_column <- paste(var, "pred", sep = "_")
    df.expert.8y[[pred_column]] <- predict(model.expert.8y.emp, node = var, data = df.expert.8y, method = "bayes-lw")
    actual_values <- df.expert.8y[[var]]
    predicted_values <- df.expert.8y[[pred_column]]
    
    if (var %in% continuous_vars) {
      results_loglik[[var]] <- evaluate_fit_continuous(actual_values, predicted_values)
    } else if (var %in% discrete_vars) {
      results_loglik[[var]] <- evaluate_fit_discrete(actual_values, predicted_values)
    }
  }
}

# AIC model
results_AIC <- list()

for (var in colnames(df.expert.8y)) {
  if (!grepl("_pred$", var)) {
    pred_column <- paste(var, "pred", sep = "_")
    df.expert.8y[[pred_column]] <- predict(model.expert.8y.emp.aic, node = var, data = df.expert.8y, method = "bayes-lw")
    actual_values <- df.expert.8y[[var]]
    predicted_values <- df.expert.8y[[pred_column]]
    
    if (var %in% continuous_vars) {
      results_AIC[[var]] <- evaluate_fit_continuous(actual_values, predicted_values)
    } else if (var %in% discrete_vars) {
      results_AIC[[var]] <- evaluate_fit_discrete(actual_values, predicted_values)
    }
  }
}

# BIC model
results_BIC <- list()

for (var in colnames(df.expert.8y)) {
  if (!grepl("_pred$", var)) {
    pred_column <- paste(var, "pred", sep = "_")
    df.expert.8y[[pred_column]] <- predict(model.expert.8y.emp.bic, node = var, data = df.expert.8y, method = "bayes-lw")
    actual_values <- df.expert.8y[[var]]
    predicted_values <- df.expert.8y[[pred_column]]
    
    if (var %in% continuous_vars) {
      results_BIC[[var]] <- evaluate_fit_continuous(actual_values, predicted_values)
    } else if (var %in% discrete_vars) {
      results_BIC[[var]] <- evaluate_fit_discrete(actual_values, predicted_values)
    }
  }
}
# Using the dsep.dag function to calculate conditional dependency for each pair 

# Defining the node_pairs list to identify nodes of interest where we want to perform d-separation. Note that this list contains node in a "from", "to" format.
different_edges <- compare(dag.expert.8y.emp, dag.expert.8y, arcs = TRUE)
node_pairs <- different_edges$fp
print(node_pairs)
node_pairs <- lapply(seq_len(nrow(node_pairs)), function(i) as.character(node_pairs[i, ]))

# Using the dsep.dag function to calculate conditional dependency for each pair 
dsep_log <- dsep.dag(dag.expert.8y.emp, df.expert.8y, node_pairs)

