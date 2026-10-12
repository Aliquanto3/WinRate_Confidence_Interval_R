# Confidence interval (Clopper-Pearson) of several players' win rates + chart
# Usage: edit the `players` table below, then Ctrl+Shift+S (Source)

for (pkg in c("ggplot2", "scales")) {
  if (!requireNamespace(pkg, quietly = TRUE)) install.packages(pkg)
}
library(ggplot2)

# --- Input values to edit ---
players <- data.frame(
  name  = c("Mewtwo", "Lugia", "Zapdos", "Entei", "Articuno", "Suicune", "Moltres", "Raikou"),
  wins  = c(38, 20, 14, 25, 9, 30, 4, 52),
  games = c(50, 30, 26, 48, 20, 70, 15, 80)
)
conf_level <- 0.95  # confidence level
reference  <- 0.5   # comparison threshold (coin flip)

# --- Computation ---
clopper_pearson_ci <- function(wins, games, conf_level = 0.95) {
  stopifnot(all(wins >= 0), all(games > 0), all(wins <= games))
  ci <- t(mapply(function(x, n) binom.test(x, n, conf.level = conf_level)$conf.int,
                 wins, games))
  data.frame(win_rate = wins / games, lower = ci[, 1], upper = ci[, 2])
}

results <- cbind(players, clopper_pearson_ci(players$wins, players$games, conf_level))
results <- results[order(results$win_rate, decreasing = TRUE), ]

# Percentage format ("50%", decimal point)
pct <- function(x, accuracy = 1) {
  scales::percent(x, accuracy = accuracy)
}

# Status of each player relative to the reference threshold
ref_label <- pct(reference)
statuses  <- c(paste("Above", ref_label), paste("Not distinguishable from", ref_label),
               paste("Below", ref_label))
results$status <- factor(
  ifelse(results$lower > reference, statuses[1],
         ifelse(results$upper < reference, statuses[3], statuses[2])),
  levels = statuses
)

print(transform(results,
                win_rate = round(win_rate, 3),
                lower    = round(lower, 3),
                upper    = round(upper, 3)), row.names = FALSE)

# --- Chart ---
# Axis labels: name + sample size (uncertainty depends on n)
results$axis_label <- paste0(results$name, "\nn = ", results$games)
results$axis_label <- factor(results$axis_label, levels = results$axis_label)

# Okabe-Ito palette (colour-blind safe), contrast >= 3:1 on white,
# doubled by point shape so as not to rely on colour alone
colours <- setNames(c("#0072B2", "#6E6E6E", "#D55E00"), statuses)
shapes  <- setNames(c(24, 21, 25), statuses)  # triangle up, circle, triangle down

alt_text <- paste0(
  "Dot plot of the win rates of ", nrow(results), " players, sorted in descending order, ",
  "with ", conf_level * 100, "% confidence intervals (Clopper-Pearson). ",
  paste(sprintf("%s: %s [%s; %s]", results$name,
                pct(results$win_rate), pct(results$lower), pct(results$upper)),
        collapse = "; "), "."
)

chart <- ggplot(results, aes(x = axis_label, y = win_rate,
                             colour = status, fill = status, shape = status)) +
  geom_hline(yintercept = reference, linetype = "dashed", colour = "grey40", linewidth = 0.5) +
  geom_errorbar(aes(ymin = lower, ymax = upper), width = 0.15, linewidth = 0.8) +
  geom_point(size = 3.5, stroke = 0.8) +
  # annotate() after the discrete layers, otherwise the X axis becomes continuous
  annotate("text", x = 0.5, y = reference, label = paste(ref_label, "= chance level"),
           hjust = 0, vjust = -0.5, size = 3.5, colour = "grey30") +
  geom_text(aes(label = pct(win_rate)),
            nudge_x = 0.2, hjust = 0, size = 3.8, show.legend = FALSE) +
  scale_colour_manual(values = colours, name = NULL) +
  scale_fill_manual(values = colours, name = NULL) +
  scale_shape_manual(values = shapes, name = NULL) +
  scale_y_continuous(labels = pct, limits = c(0, 1), breaks = seq(0, 1, 0.2),
                     expand = expansion(mult = c(0, 0.02))) +
  labs(
    title    = "Win rate by player",
    subtitle = paste0("Dot: observed win rate · Bar: ", conf_level * 100,
                      "% confidence interval (Clopper-Pearson)"),
    caption  = "Overlapping bars do not prove the win rates are equal, nor that they differ.",
    x = NULL, y = "Win rate",
    alt = alt_text
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title.position = "plot",
    plot.title          = element_text(face = "bold"),
    plot.subtitle       = element_text(colour = "grey25"),
    plot.caption        = element_text(colour = "grey30", hjust = 0),
    axis.text           = element_text(colour = "grey15"),
    panel.grid.major.x  = element_blank(),
    panel.grid.minor    = element_blank(),
    legend.position     = "top",
    legend.justification = "left"
  )

print(chart)

# High-resolution export (uncomment if needed)
# ggsave("win_rates.png", chart, width = 9, height = 5.5, dpi = 300, bg = "white")
