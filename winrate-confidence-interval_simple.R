# 95% confidence interval (Clopper-Pearson) of a win rate
# Edit the two values below, then press Ctrl+Shift+S (Source)

wins    <- 547
matches <- 853

win_rate_ci <- function(wins, matches, level = 0.95) {
  ci <- binom.test(wins, matches, conf.level = level)$conf.int
  cat(sprintf("Lower bound: %.1f%%  |  Win rate: %.1f%%  |  Upper bound: %.1f%%\n",
              100 * ci[1], 100 * wins / matches, 100 * ci[2]))
}

win_rate_ci(wins, matches)