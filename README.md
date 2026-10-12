# Win rate confidence intervals (R)

R script that computes several players' win rates with their exact confidence interval (Clopper-Pearson method), then plots them with ggplot2.

Each player falls into one of three categories, depending on where their interval sits relative to a reference threshold (50% by default):

- **Above 50%**: the whole interval is above the threshold.
- **Not distinguishable from 50%**: the interval contains the threshold.
- **Below 50%**: the whole interval is below the threshold.

## Requirements

- R (version 4.1 or later recommended)
- The `ggplot2` and `scales` packages, installed automatically on first run if missing

## Usage

1. Open `winrate-confidence-interval.R` in RStudio.
2. Edit the input values (see below).
3. Run the script with **Ctrl+Shift+S** (Source).

You can also run it from the command line:

```sh
Rscript winrate-confidence-interval.R
```

The script prints a results table to the console, then displays the chart.

## Editing the input variables

All inputs are in the `# --- Input values to edit ---` block at the top of the script.

### The `players` table

```r
players <- data.frame(
  name  = c("Mewtwo", "Lugia", "Zapdos"),
  wins  = c(38, 20, 14),
  games = c(50, 30, 26)
)
```

| Column  | Content                    | Constraints                     |
|---------|----------------------------|---------------------------------|
| `name`  | Name shown on the axis     | Text, one unique name per player |
| `wins`  | Number of games won        | Integer, `>= 0` and `<= games`  |
| `games` | Total number of games played | Integer, `> 0`                |

The three vectors must have **the same length**: the n-th value of each column describes the same player. To add a player, append one value to each of the three vectors. To remove one, delete the matching value from all three.

There is no limit on the number of players: the chart adapts and sorts players from highest to lowest win rate.

If a constraint is violated, for example more wins than games, the script stops with a `stopifnot` error.

### The confidence level `conf_level`

```r
conf_level <- 0.95
```

A value between 0 and 1. With `0.90`, intervals are narrower but less reliable. With `0.99`, they are wider but more reliable. The chart subtitle and alt text update automatically.

### The comparison threshold `reference`

```r
reference <- 0.5
```

A value between 0 and 1, drawn as the dashed line. It sets each player's category, and therefore the colour and shape of their point. For example, `0.55` highlights players whose win rate is significantly above 55%.

## Example: using your own data

```r
players <- data.frame(
  name  = c("Alice", "Bob", "Chloe", "David"),
  wins  = c(62, 45, 18, 7),
  games = c(100, 90, 40, 12)
)
conf_level <- 0.95
reference  <- 0.5
```

## Exporting the chart

The last line of the script is commented out. Uncomment it to save the chart as a high-resolution PNG in the working directory:

```r
ggsave("win_rates.png", chart, width = 9, height = 5.5, dpi = 300, bg = "white")
```

Adjust `width` and `height` (in inches) if you have many players.

## Reading the chart

- **Dot**: observed win rate (`wins / games`).
- **Bar**: confidence interval. It is wider when the number of games `n` (shown under each name) is small.
- **Dashed line**: reference threshold.

Two overlapping bars prove neither that the win rates are equal nor that they differ. To compare two players with each other, use a dedicated test such as `prop.test`.
