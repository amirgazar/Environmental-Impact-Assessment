
# Does increased transborder transmission capacity stimulate Canadian hydroelectric development? 
# Using causal inference to scope environmental impact assessment in sociotechnical systems
# Amir Mortazavigazar1,2,*, Mark E. Borsuk3, Ryan S.D. Calder1,2,3,4,5
# 1 Department of Population Health Sciences, Virginia Tech, Blacksburg, VA, 24061, USA
# 2 Global Change Center, Virginia Tech, Blacksburg, VA, 24061, USA
# 3 Department of Civil and Environmental Engineering, Duke University, Durham, NC, 27708, USA
# 4 Faculty of Health Sciences, Virginia Tech, Roanoke, VA, 24016, USA
# 5 Department of Civil and Environmental Engineering, Virginia Tech, Blacksburg, VA, 24061, USA

# *Contact: amirgazar@vt.edu.   


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
setwd("/Users/amirgazar/Documents/GitHub/Hydro EIA Code")
rm(list=ls())
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
  for (node1 in nodes(dag)) {
    for (node2 in nodes(dag)) {
      if (!arc_exists(node1, node2, existing_arcs) && !arc_exists(node2, node1, existing_arcs) && node1 != node2) {
        non_adj_pairs <- append(non_adj_pairs, list(c(node1, node2)))
      }
    }
  }
  
  # A list for test results is initialized.
  results <- list()
  
  # D-separation tests are performed for each non-adjacent pair.
  for (pair in non_adj_pairs) {
    conditioning_set <- setdiff(unique(c(mb(dag, pair[1]), mb(dag, pair[2]))), pair)  # Combined Markov blanket excluding x and y
    test <- ci.test(pair[1], pair[2], conditioning_set, data = data)
    results[[paste0(pair[1], "_", pair[2])]] <- test$p.value
  }
  return(results)
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
  # Sum of new intertie capacity in preceding 5 years
  hydro.data$INTERTIE_5y = NA
  for(i in 5:nrow(hydro.data)){
    hydro.data$INTERTIE_5y[i] = sum(hydro.data$INTERTIE_new[(i-4):i],na.rm=T)
  }
  # Sum of new installed capacity in preceding 5 years
  hydro.data$INSTALLED_5y = NA
  for(i in 5:nrow(hydro.data)){
    hydro.data$INSTALLED_5y[i] = sum(hydro.data$INSTALLED_new[(i-4):i],na.rm=T)
    
  }
  # Sum of new installed capacity in preceding 5 years lagged by 5 years
  hydro.data$INSTALLED_5y_lag_5y = NA
  for(i in 10:nrow(hydro.data)){
    hydro.data$INSTALLED_5y_lag_5y[i] = hydro.data$INSTALLED_5y[i-5]
    
  }
  # Sum of new intertie capacity in preceding 5 years lagged by 5 years
  hydro.data$INTERTIE_5y_lag_5y = NA
  for(i in 10:nrow(hydro.data)){
    hydro.data$INTERTIE_5y_lag_5y[i] = hydro.data$INTERTIE_5y[i-5]
  }
  # Mean price difference in preceding 5 years
  hydro.data$PRICE_5y = NA
  for(i in 5:nrow(hydro.data)){
    hydro.data$PRICE_5y[i] = mean(hydro.data$PRICE[(i-4):i],na.rm=T)
    
  }
  # Sum of PRICE mean in preceding 5 years lagged by 5 years
  hydro.data$PRICE_5y_lag_5y = NA
  for(i in 10:nrow(hydro.data)){
    hydro.data$PRICE_5y_lag_5y[i] = hydro.data$PRICE_5y[i-5]
    
  }
  # Mean export in preceding 5 years
  hydro.data$EXPORTS_5y = NA
  for(i in 5:nrow(hydro.data)){
    hydro.data$EXPORTS_5y[i] = mean(hydro.data$EXPORTS[(i-4):i],na.rm=T)
  }
  # Mean QC demand in preceding 5 years
  hydro.data$DEMAND_QC_5y = NA
  for(i in 5:nrow(hydro.data)){
    hydro.data$DEMAND_QC_5y[i] = mean(hydro.data$DEMAND_QC[(i-4):i],na.rm=T)
  }
  
  # Mean QC demand in preceding 5 years lagged by 5 years
  hydro.data$DEMAND_QC_5y_lag_5y = NA
  for(i in 10:nrow(hydro.data)){
    hydro.data$DEMAND_QC_5y_lag_5y[i] = hydro.data$DEMAND_QC_5y[i-5]
  }
  # Mean US demand in preceding 5 years
  hydro.data$DEMAND_US_5y = NA
  for(i in 5:nrow(hydro.data)){
    hydro.data$DEMAND_US_5y[i] = mean(hydro.data$DEMAND_US[(i-4):i],na.rm=T)
  }
  
  # Mean US demand in preceding 5 years lagged by 5 years
  hydro.data$DEMAND_US_5y_lag_5y = NA
  for(i in 10:nrow(hydro.data)){
    hydro.data$DEMAND_US_5y_lag_5y[i] =
      hydro.data$DEMAND_US_5y[i-5]
    
  }
  # Mean investment in preceding 5 years
  hydro.data$INVESTMENT_5y = NA
  for(i in 5:nrow(hydro.data)){
    hydro.data$INVESTMENT_5y[i] = mean(hydro.data$INVESTMENT[(i-4):i],na.rm=T)
  }
  
  # Total investment in preceding 5 years
  hydro.data$INVESTMENT_total_5y = NA
  for(i in 5:nrow(hydro.data)){
    hydro.data$INVESTMENT_total_5y[i] = sum(hydro.data$INVESTMENT[(i-4):i],na.rm=T)
  }
}

# Creating _new 5 year averaged and lagged
lag_periods <- c(5)
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

# Subset of data with 5-yr avg/lag for everything
vars.exclude.5y = c(1:8,grep("_new$",colnames(hydro.data)))

hydro.data.subset.5y = 
  hydro.data[,setdiff(1:ncol(hydro.data),
                      vars.exclude.5y)]
# Ensuring that all variables are numeric
for(i in 1:ncol(hydro.data.subset.5y)){
  hydro.data.subset.5y[,i] = as.numeric(hydro.data.subset.5y[,i]) 
}

# Create new dataframe 
df.5y = hydro.data.subset.5y

# Creating new data frames with minimum number of rows cut off
lag.cols.5y = grep("lag",colnames(df.5y))
df.5y.no.lags = df.5y[,setdiff(1:ncol(df.5y),
                               lag.cols.5y)]
df.5y.rows.to.cut = which(apply(df.5y,1,function(x) sum(is.na(x))>0))
df.5y.no.lags.rows.to.cut = which(apply(df.5y.no.lags,1,function(x) sum(is.na(x))>0))
df.5y.with.lags.no.NA = df.5y[setdiff(1:nrow(df.5y),
                                      df.5y.rows.to.cut),]
# Check for gaussian distribution
significance_level <- 0.05
non_gaussian_5y_lag <- vector("list")
for (var in colnames(df.5y.with.lags.no.NA)) {
  # Shapiro-Wilk Test
  shapiro_test <- shapiro.test(df.5y.with.lags.no.NA[[var]])
  print(paste("Shapiro-Wilk Test for", var, "- p-value:", shapiro_test$p.value))
  
  if (shapiro_test$p.value < significance_level) {
    non_gaussian_5y_lag <- c(non_gaussian_5y_lag, var)
  }
}
# Box-Cox transformation for the non-gaussian variables and rechecking the gaussian distribution
result_5y_lag <- transform_and_test(df.5y.with.lags.no.NA, non_gaussian_5y_lag)
df.5y.with.lags.no.NA <- result_5y_lag$df
still_non_gaussian_5y_lag <- result_5y_lag$still_non_gaussian

## Discretising remaining variables that have significant SW test results or are zero-inflated 

df.5y.with.lags.no.NA$INTERTIE_5y <- cut(df.5y.with.lags.no.NA$INTERTIE_5y , breaks = c(min(df.5y.with.lags.no.NA$INTERTIE_5y,na.rm=T ), 100, max(df.5y.with.lags.no.NA$INTERTIE_5y,na.rm=T )), labels = c("non-significant", "significant"), include.lowest = TRUE, ordered_result = TRUE)
df.5y.with.lags.no.NA$INTERTIE_5y_lag_5y <- cut(df.5y.with.lags.no.NA$INTERTIE_5y_lag_5y , breaks = c(min(df.5y.with.lags.no.NA$INTERTIE_5y_lag_5y,na.rm=T ), 100, max(df.5y.with.lags.no.NA$INTERTIE_5y_lag_5y,na.rm=T )), labels = c("non-significant", "significant"), include.lowest = TRUE, ordered_result = TRUE)
df.5y.with.lags.no.NA$DEMAND_QC_5y <- cut(df.5y.with.lags.no.NA$DEMAND_QC_5y, breaks = c(min(df.5y.with.lags.no.NA$DEMAND_QC_5y,na.rm=T), 120, 160, max(df.5y.with.lags.no.NA$DEMAND_QC_5y,na.rm=T)), labels = c("low", "medium", "high"), include.lowest = TRUE, ordered_result = TRUE)
df.5y.with.lags.no.NA$DEMAND_US_5y <- cut(df.5y.with.lags.no.NA$DEMAND_US_5y, breaks = c(min(df.5y.with.lags.no.NA$DEMAND_US_5y,na.rm=T), 230, 260, max(df.5y.with.lags.no.NA$DEMAND_US_5y,na.rm=T)), labels = c("low", "medium", "high"), include.lowest = TRUE, ordered_result = TRUE)
df.5y.with.lags.no.NA$DEMAND_QC_5y_lag_5y <- cut(df.5y.with.lags.no.NA$DEMAND_QC_5y_lag_5y, breaks = c(min(df.5y.with.lags.no.NA$DEMAND_QC_5y_lag_5y,na.rm=T), 120, 160, max(df.5y.with.lags.no.NA$DEMAND_QC_5y_lag_5y,na.rm=T)), labels = c("low", "medium", "high"), include.lowest = TRUE, ordered_result = TRUE)
df.5y.with.lags.no.NA$DEMAND_US_5y_lag_5y <- cut(df.5y.with.lags.no.NA$DEMAND_US_5y_lag_5y, breaks = c(min(df.5y.with.lags.no.NA$DEMAND_US_5y_lag_5y,na.rm=T), 230, 260, max(df.5y.with.lags.no.NA$DEMAND_US_5y_lag_5y,na.rm=T)), labels = c("low", "medium", "high"), include.lowest = TRUE, ordered_result = TRUE)
df.5y.with.lags.no.NA$INVESTMENT_5y <- cut(df.5y.with.lags.no.NA$INVESTMENT_5y, breaks = c(min(df.5y.with.lags.no.NA$INVESTMENT_5y,na.rm=T), 2500, 3500, max(df.5y.with.lags.no.NA$INVESTMENT_5y,na.rm=T)), labels = c("low", "medium", "high"), include.lowest = TRUE, ordered_result = TRUE)
df.5y.with.lags.no.NA$INVESTMENT_total_5y <- cut(df.5y.with.lags.no.NA$INVESTMENT_total_5y, breaks = c(min(df.5y.with.lags.no.NA$INVESTMENT_total_5y,na.rm=T), 12000, 18000, max(df.5y.with.lags.no.NA$INVESTMENT_total_5y,na.rm=T)), labels = c("low", "medium", "high"), include.lowest = TRUE, ordered_result = TRUE)
df.5y.with.lags.no.NA$INTERTIE_new_avg_5y <- cut(df.5y.with.lags.no.NA$INTERTIE_new_avg_5y, breaks = c(min(df.5y.with.lags.no.NA$INTERTIE_new_avg_5y,na.rm=T), 100, max(df.5y.with.lags.no.NA$INTERTIE_new_avg_5y,na.rm=T)), labels = c("non-significant", "significant"), include.lowest = TRUE, ordered_result = TRUE)
df.5y.with.lags.no.NA$INTERTIE_new_avg_5y_lag_5y <- cut(df.5y.with.lags.no.NA$INTERTIE_new_avg_5y_lag_5y, breaks = c(min(df.5y.with.lags.no.NA$INTERTIE_new_avg_5y_lag_5y,na.rm=T),100, max(df.5y.with.lags.no.NA$INTERTIE_new_avg_5y_lag_5y,na.rm=T)), labels = c("non-significant", "significant"), include.lowest = TRUE, ordered_result = TRUE)
df.5y.with.lags.no.NA$EXPORTS_new_avg_5y <- cut(df.5y.with.lags.no.NA$EXPORTS_new_avg_5y, breaks = c(min(df.5y.with.lags.no.NA$EXPORTS_new_avg_5y,na.rm=T), 0, max(df.5y.with.lags.no.NA$EXPORTS_new_avg_5y,na.rm=T)), labels = c("negative", "positive"), include.lowest = TRUE, ordered_result = TRUE)
df.5y.with.lags.no.NA$EXPORTS_new_avg_5y_lag_5y <- cut(df.5y.with.lags.no.NA$EXPORTS_new_avg_5y_lag_5y, breaks = c(min(df.5y.with.lags.no.NA$EXPORTS_new_avg_5y_lag_5y,na.rm=T), 0, max(df.5y.with.lags.no.NA$EXPORTS_new_avg_5y_lag_5y,na.rm=T)), labels = c("negative", "positive"), include.lowest = TRUE, ordered_result = TRUE)
df.5y.with.lags.no.NA$PRICE_new_avg_5y <- cut(df.5y.with.lags.no.NA$PRICE_new_avg_5y, breaks = c(min(df.5y.with.lags.no.NA$PRICE_new_avg_5y,na.rm=T), 0, max(df.5y.with.lags.no.NA$PRICE_new_avg_5y,na.rm=T)), labels = c("negative", "positive"), include.lowest = TRUE, ordered_result = TRUE)

# We manullay revert this var from box-cox transform due to its histogram 
df.5y.with.lags.no.NA$INSTALLED_5y_lag_5y = hydro.data$INSTALLED_5y_lag_5y[11:nrow(hydro.data)]
df.5y.with.lags.no.NA$INSTALLED_5y_lag_5y <- cut(df.5y.with.lags.no.NA$INSTALLED_5y_lag_5y , breaks = c(min(df.5y.with.lags.no.NA$INSTALLED_5y_lag_5y,na.rm=T ), 2000, 4000, max(df.5y.with.lags.no.NA$INSTALLED_5y_lag_5y,na.rm=T )), labels = c("low", "medium", "high"), include.lowest = TRUE, ordered_result = TRUE)

# Drop the variables
var.drop = c("INSTALLED_new_avg_5y", "INTERTIE_new_avg_5y","INSTALLED_new_avg_5y_lag_5y", "INTERTIE_new_avg_5y_lag_5y", "INSTALLED_lag_5y", "INTERTIE_lag_5y")
# Subset the dataset             
df.5y.with.lags.no.NA = 
  df.5y.with.lags.no.NA[,setdiff(1:ncol(df.5y.with.lags.no.NA),
                                 match(var.drop,colnames(df.5y.with.lags.no.NA)))]

# Selecting columns of interest
selected.columns <- c('INSTALLED_5y_lag_5y', 'INSTALLED_5y', 'DEMAND_QC_new_avg_5y_lag_5y', 'INVESTMENT_5y', 'PRICE_5y_lag_5y',
                      'INTERTIE_5y_lag_5y', 'INTERTIE_5y', 'DEMAND_US_new_avg_5y_lag_5y', 'PRICE_5y',
                      'EXPORTS_new_avg_5y_lag_5y', 'EXPORTS_5y', 'DEMAND_QC_5y', 'DEMAND_US_5y')

# Subsetting the dataframe and creating the final dataframe
df.expert.5y <- df.5y.with.lags.no.NA[, selected.columns]

## Creating the expert blacklist
# The allow list is initialized with specific variable pairs.
allow.list.expert =                               
  data.frame(matrix(c(
    
    # Investment --> Installed
    "INVESTMENT_5y","INSTALLED_5y", 
    
    # Installed --> Exports
    "INSTALLED_5y","EXPORTS_5y",          
    
    # QC demand lag --> Installed
    "DEMAND_QC_new_avg_5y_lag_5y","INSTALLED_5y",  
    
    # Price lag --> Installed
    "PRICE_5y_lag_5y","INSTALLED_5y",  
    
    # Intertie lag --> Installed
    "INTERTIE_5y_lag_5y","INSTALLED_5y", 
    
    # Installed --> Intertie
    "INSTALLED_5y","INTERTIE_5y", 
    "INSTALLED_5y_lag_5y", "INTERTIE_5y",
    
    # Investment --> Intertie
    "INVESTMENT_5y","INTERTIE_5y", 
    
    # US demand lag --> Intertie
    "DEMAND_US_new_avg_5y_lag_5y","INTERTIE_5y",
    
    # Price --> Intertie
    "PRICE_5y","INTERTIE_5y", 
    
    # QC demand lag --> Investment
    "DEMAND_QC_new_avg_5y_lag_5y","INVESTMENT_5y",
    
    # Exports lag --> Investment
    "EXPORTS_new_avg_5y_lag_5y","INVESTMENT_5y",
    
    # Intertie --> Exports
    "INTERTIE_5y","EXPORTS_5y", 
    
    # Installed --> Exports
    "INSTALLED_5y","EXPORTS_5y", 
    
    # Price --> Exports
    "PRICE_5y","EXPORTS_5y", 
    
    # QC demand --> Price
    "DEMAND_QC_5y","PRICE_5y", 
    
    # US demand --> Price
    "DEMAND_US_5y","PRICE_5y"),
    ncol = 2,byrow=TRUE))

# Column names for the allow list are assigned.
colnames(allow.list.expert) = c("From","To")

# The black list is initialized with a placeholder value.
black.list.expert = NA

# For each pair of variables in the final data-frame, a check is performed.
# If the pair is not found in the allow list, it is added to the black list.
for(i in 1:ncol(df.expert.5y)){
  for(j in 1:ncol(df.expert.5y)){
    from.test = colnames(df.expert.5y)[i]
    to.test = colnames(df.expert.5y)[j]
    
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
dag.expert.5y <- model2network("[INSTALLED_5y_lag_5y][DEMAND_QC_new_avg_5y_lag_5y][PRICE_5y_lag_5y][INTERTIE_5y_lag_5y][DEMAND_US_new_avg_5y_lag_5y][EXPORTS_new_avg_5y_lag_5y][DEMAND_QC_5y][DEMAND_US_5y][INSTALLED_5y|DEMAND_QC_new_avg_5y_lag_5y:INVESTMENT_5y:PRICE_5y_lag_5y:INTERTIE_5y_lag_5y][INTERTIE_5y|INSTALLED_5y_lag_5y:INVESTMENT_5y:DEMAND_US_new_avg_5y_lag_5y:PRICE_5y][INVESTMENT_5y|DEMAND_QC_new_avg_5y_lag_5y:EXPORTS_new_avg_5y_lag_5y][EXPORTS_5y|INTERTIE_5y:INSTALLED_5y:PRICE_5y][PRICE_5y|DEMAND_QC_5y:DEMAND_US_5y]")

# The constructed DAG is visualized with a specified height.
plot.network(dag.expert.5y, ht = "600px")

## Creating Score-Based DAGs
# DAG created using the loglik-cg score function and HC algorithm
dag.expert.5y.emp <- hc(df.expert.5y, score = "loglik-cg", blacklist = black.list.expert, debug = FALSE)
par(mar=c(1,1,1,1))
# Fitting the model 
model.expert.5y.emp = bn.fit(dag.expert.5y.emp, df.expert.5y)
#Visualizing model's conditional probabilities using the graphviz.chart
graphviz.chart(model.expert.5y.emp,  type = "barprob", grid = TRUE, bar.col = "darkgreen",
               strip.bg = "lightskyblue")
dev.off()
# Network visualized using plot.network
plot.network(dag.expert.5y.emp, ht = "600px")

# DAG created using the aic-cg score function and HC algorithm
dag.expert.5y.emp.aic <- hc(df.expert.5y, score = "aic-cg", blacklist = black.list.expert)
plot.network(dag.expert.5y.emp.aic, ht = "600px")
par(mar=c(1,1,1,1))
model.expert.5y.emp.aic = bn.fit(dag.expert.5y.emp.aic, df.expert.5y)
graphviz.chart(model.expert.5y.emp.aic,  type = "barprob", grid = TRUE, bar.col = "darkgreen",
               strip.bg = "lightskyblue")
dev.off()

# DAG created using the bic-cg score function and HC algorithm
dag.expert.5y.emp.bic <- hc(df.expert.5y, score = "bic-cg", blacklist = black.list.expert)
plot.network(dag.expert.5y.emp.bic, ht = "600px")
par(mar=c(1,1,1,1))
model.expert.5y.emp.bic = bn.fit(dag.expert.5y.emp.bic, df.expert.5y)
graphviz.chart(model.expert.5y.emp.bic,  type = "barprob", grid = TRUE, bar.col = "darkgreen",
               strip.bg = "lightskyblue")
dev.off()

# Run the Graph_Generator code to save the conditional depenency graphs automatically

source("Graph_Generator.R")






