## MUST RUN THE Hydro_Paper_BNLearn latest version first!!!
# Do electrical interties stimulate Canadian hydroelectric development? Using causal inference to identify second-order impacts in evolving sociotechnical systems
# Amir M. Gazar1,2,*, Mark E. Borsuk3, Ryan S.D. Calder1,2,3,4,5
# 1 Department of Population Health Sciences, Virginia Tech, Blacksburg, VA, 24061, USA
# 2 Global Change Center, Virginia Tech, Blacksburg, VA, 24061, USA
# 3 Department of Civil and Environmental Engineering, Duke University, Durham, NC, 27708, USA
# 4 Faculty of Health Sciences, Virginia Tech, Roanoke, VA, 24016, USA
# 5 Department of Civil and Environmental Engineering, Virginia Tech, Blacksburg, VA, 24061, USA

# *Contact: amirgazar@vt.edu.   
# All rights reserved under Creative Commons 4.0

# Set the directory to save the figures if needed
#setwd("/Users/amirgazar/Documents/")
# Set the theme for all plots
theme_set(theme_minimal(base_family = "Times New Roman") + 
            theme(axis.text = element_text(color = "black"),
                  axis.line = element_line(color = "black"),
                  axis.ticks.length = unit(0.2, "cm"),
                  axis.ticks = element_line(colour = "black"),
                  panel.grid.major = element_blank(),
                  panel.grid.minor = element_blank(),
                  plot.title = element_blank()))

palette <- c("black", "darkgray", "gray", "lightgray")

# 1. Conditional density for INSTALLED_5y

df.expert.5y$INSTALLED_5y_pred = predict(model.expert.5y.emp, node = "INSTALLED_5y", data = df.expert.5y, method = "bayes-lw")
split_data <- split(df.expert.5y, df.expert.5y$INVESTMENT_5y)

long_data <- bind_rows(split_data, .id = "group")

n <- length(split_data)
colors <- gray(seq(0, 1, length.out = n))


p <- ggplot(long_data, aes(x = DEMAND_QC_new_avg_5y_lag_5y, 
                           y = PRICE_5y_lag_5y, 
                           size = INSTALLED_5y_pred, 
                           color = group)) +
  geom_point(shape = 16) +  # Using shape 16, which is a circle
  labs(x = "DEMAND_QC", y = "PRICE", size = "Predicted INSTALLED", color = "INVESTMENT") +
  scale_color_manual(values = colors)

ggsave(filename = "SI_Figure_S5.svg", plot = p, device = "svg")

# 2. Conditional probability table for INVESTMENT_5y (discrete therefore we use CPT directly)
EXPORTS_new_avg_5y_lag_5y <- list(
  negative = c(0.0000000, 0.3636364, 0.6363636),
  positive = c(0.3636364, 0.2272727, 0.4090909)
)
investment_levels <- c('low', 'medium', 'high')

df <- data.frame(
  EXPORTS_new_avg_5y_lag_5y = rep(names(EXPORTS_new_avg_5y_lag_5y), each = length(investment_levels)),
  INVESTMENT_5y = rep(investment_levels, times = length(EXPORTS_new_avg_5y_lag_5y)),
  Probability = c(EXPORTS_new_avg_5y_lag_5y$negative, EXPORTS_new_avg_5y_lag_5y$positive)
)

plot_list <- list()
for (level in names(EXPORTS_new_avg_5y_lag_5y)) {
  pie_data <- df[df$EXPORTS_new_avg_5y_lag_5y == level,]
  
  p <- ggplot(pie_data, aes(x = "", y = Probability, fill = INVESTMENT_5y)) +
    geom_bar(width = 1, stat = "identity") +
    coord_polar(theta = "y") +
    scale_fill_manual(values = palette) +
    labs(fill = "INVESTMENT") +
    theme(
      axis.title.x = element_blank(), 
      axis.text.x = element_blank(), 
      axis.ticks.x = element_blank(),
      axis.title.y = element_blank(),
      axis.text.y = element_blank(), 
      axis.ticks.y = element_blank(),
      axis.line = element_blank()
    )
  
  plot_list[[level]] <- p
}

ggsave(filename = "SI_Figure_S8A.svg", plot = plot_list[[1]], device = "svg")
ggsave(filename = "SI_Figure_S8B.svg", plot = plot_list[[2]], device = "svg")

# 3. Conditional probability table for INTERTIE_5y (discrete therefore we use CPT directly)
data <- data.frame(
  INVESTMENT_5y = c(rep('low', 6), rep('medium', 6), rep('high', 6)),
  INSTALLED_5y_lag_5y = rep(c('low', 'medium', 'high'), 6)[1:18],
  INTERTIE_5y = rep(rep(c('non-significant', 'significant'), each = 3), 4)[1:18],
  value = c(1, 1, 0.6, 0, 0, 0.4,
            1, 0.5, 0.67, 0, 0.5, 0.33,
            0.63, 0.63,0, 0.38, 0.38,0)
)

data$INSTALLED_5y_lag_5y <- factor(data$INSTALLED_5y_lag_5y, levels = c("low", "medium", "high"), ordered = TRUE)
data$INVESTMENT_5y <- factor(data$INVESTMENT_5y, levels = c("low", "medium", "high"), ordered = TRUE)

p<- ggplot(data, aes(x = INSTALLED_5y_lag_5y, y = value, fill = INTERTIE_5y)) +
  geom_bar(stat = "identity", position = "dodge") +
  facet_wrap(~INVESTMENT_5y, nrow = 1) +
  labs(y = "Probability", x = "INSTALLED", fill = "INTERTIE") +
  scale_fill_manual(values = palette) 
ggsave(filename = "SI_Figure_S6.svg", plot = p, device = "svg")

# 4. Conditional density for PRICE_5y
df.expert.5y$PRICE_5y_pred = predict(model.expert.5y.emp, node = "PRICE_5y", data = df.expert.5y, method = "bayes-lw")

p <- ggplot(df.expert.5y, aes(x = DEMAND_US_5y, y = PRICE_5y_pred)) +
  geom_jitter(aes(color = DEMAND_US_5y), size = 2, width = 0.2) +
  scale_color_manual(values = c("black", "darkblue", "lightgray")) +
  labs(x = "DEMAND_US", y = "PRICE", title = "Your Title Here") +
  theme(legend.position = "none")
ggsave(filename = "SI_Figure_S7.svg", plot = p, device = "svg")

# 5. Conditional density for EXPORTS_5y
df.expert.5y$EXPORTS_5y_pred = predict(model.expert.5y.emp, node = "EXPORTS_5y", data = df.expert.5y, method = "bayes-lw")

p<- ggplot(df.expert.5y, aes(x = PRICE_5y, y = INSTALLED_5y, size = EXPORTS_5y_pred, color = as.factor(INTERTIE_5y))) +
  geom_point() +
  labs(x = "PRICE",
       y = "INSTALLED",
       size = "Predicted EXPORTS",
       color = "INTERTIE") +
  scale_color_manual(values = c("black", "darkgray", "lightgray"))
ggsave(filename = "SI_Figure_S9.svg", plot = p, device = "svg")

# BIC Model Results
# 1. INTERTIE child of  DEMAND, INSTALLED (discrete therefore we use CPT directly)
data <- data.frame(
  INTERTIE = c(0, 1),
  Intercept = c(42.667839, 28.176351),
  DEMAND_QC_new_avg_5y_lag_5y = c(4.008358, 6.429567)
)

x_values <- seq(from = -2.5, to = 7.5, length.out = 100)
y_values_0 <- data$Intercept[1] + data$DEMAND_QC_new_avg_5y_lag_5y[1] * x_values
y_values_1 <- data$Intercept[2] + data$DEMAND_QC_new_avg_5y_lag_5y[2] * x_values

line_data <- data.frame(
  x = c(x_values, x_values),
  y = c(y_values_0, y_values_1),
  line = factor(rep(c("non-significant", "significant"), each = 100))
)

p <- ggplot(line_data, aes(x = x, y = y, color = line)) +
  geom_line() +
  geom_point(data = df.expert.5y, aes(x = DEMAND_QC_new_avg_5y_lag_5y, y = INSTALLED_5y, color = INTERTIE_5y)) +
  labs(x = "DEMAND_QC", y = "INSTALLED") +
  scale_color_manual(name = "INTERTIE", values = palette) 

ggsave(filename = "SI_Figure_S10.svg", plot = p, device = "svg")
