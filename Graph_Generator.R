## MUST RUN THE Hydro_Paper_BNLearn latest version first!!!

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

# 1. Conditional density

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

ggsave(filename = "fig_1.svg", plot = p, device = "svg")

# 2. Conditional probability table
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

ggsave(filename = "fig_2.svg", plot = plot_list[[1]], device = "svg")
ggsave(filename = "fig_3.svg", plot = plot_list[[2]], device = "svg")

# 3. Conditional probability table
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
ggsave(filename = "fig_5.svg", plot = p, device = "svg")
# 4. Conditional density
intercepts <- c(0.06873333, 0.10085000, 0.11086667)
std_devs <- c(0.004001666, 0.025626283, 0.021735956)

labels <- c("low", "medium", "high")

x <- seq(0, 0.2, length.out = 1000)

data <- data.frame()

for (i in 1:3) {
  y <- dnorm(x, mean = intercepts[i], sd = std_devs[i])
  
  temp_data <- data.frame(PRICE_5y = x, Probability_Density = y, DEMAND_US_5y = labels[i])
  
  data <- rbind(data, temp_data)
}
p <- ggplot(data, aes(x = PRICE_5y, y = Probability_Density, color = DEMAND_US_5y)) +
  geom_line() +
  labs(x = "PRICE",
       y = "Probability Density", color = "DEMAND_US") +
  scale_color_manual(values = palette) 
ggsave(filename = "fig_4.svg", plot = p, device = "svg")
# 5. Conditional density

df.expert.5y$EXPORTS_5y_pred = predict(model.expert.5y.emp, node = "EXPORTS_5y", data = df.expert.5y, method = "bayes-lw")

p<- ggplot(df.expert.5y, aes(x = PRICE_5y, y = INSTALLED_5y, size = EXPORTS_5y_pred, color = as.factor(INTERTIE_5y))) +
  geom_point() +
  labs(x = "PRICE",
       y = "INSTALLED",
       size = "Predicted EXPORTS",
       color = "INTERTIE") +
  scale_color_manual(values = palette)
ggsave(filename = "fig_5.svg", plot = p, device = "svg")

# BIC Model Results
# 1. INTERTIE | DEMAND, INSTALLED
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
palette <- c("non-significant" = "grey", "significant" = "black")

plot <- ggplot(line_data, aes(x = x, y = y, color = line)) +
  geom_line() +
  geom_point(data = df.expert.5y, aes(x = DEMAND_QC_new_avg_5y_lag_5y, y = INSTALLED_5y, color = INTERTIE_5y)) +
  labs(x = "DEMAND_QC", y = "INSTALLED") +
  scale_color_manual(name = "INTERTIE", values = palette) +
  theme_minimal() + 
  theme(
    axis.text.x = element_text(angle = 90, hjust = 1),
    axis.ticks.length = unit(0.2, "cm"),
    axis.ticks = element_line(colour = "black"),
    axis.line = element_line(colour = "black"),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()
  )

ggsave(filename = "fig_6.svg", plot = plot, device = "svg")
