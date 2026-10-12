# Intervalle de confiance (Clopper-Pearson) du win rate de plusieurs joueurs + graphique
# Usage : modifier le tableau `joueurs` ci-dessous, puis Ctrl+Shift+S (Source)

for (pkg in c("ggplot2", "scales")) {
  if (!requireNamespace(pkg, quietly = TRUE)) install.packages(pkg)
}
library(ggplot2)

# --- Valeurs d'entrée à modifier ---
joueurs <- data.frame(
  nom       = c("Mewtwo", "Lugia", "Zapdos", "Entei", "Articuno", "Suicune", "Moltres", "Raikou"),
  victoires = c(38, 20, 14, 25, 9, 30, 4, 52),
  matchs    = c(50, 30, 26, 48, 20, 70, 15, 80)
)
niveau    <- 0.95  # niveau de confiance
reference <- 0.5   # seuil de comparaison (pile ou face)

# --- Calcul ---
ic_clopper_pearson <- function(victoires, matchs, niveau = 0.95) {
  stopifnot(all(victoires >= 0), all(matchs > 0), all(victoires <= matchs))
  ic <- t(mapply(function(x, n) binom.test(x, n, conf.level = niveau)$conf.int,
                 victoires, matchs))
  data.frame(win_rate = victoires / matchs, borne_inf = ic[, 1], borne_sup = ic[, 2])
}

resultats <- cbind(joueurs, ic_clopper_pearson(joueurs$victoires, joueurs$matchs, niveau))
resultats <- resultats[order(resultats$win_rate, decreasing = TRUE), ]

# Format des pourcentages à l'anglaise (graphique en anglais : "50%", point décimal)
pct <- function(x, accuracy = 1) {
  scales::percent(x, accuracy = accuracy)
}

# Statut de chaque joueur par rapport au seuil de référence
lbl_ref  <- pct(reference)
statuts  <- c(paste("Above", lbl_ref), paste("Not distinguishable from", lbl_ref),
              paste("Below", lbl_ref))
resultats$statut <- factor(
  ifelse(resultats$borne_inf > reference, statuts[1],
         ifelse(resultats$borne_sup < reference, statuts[3], statuts[2])),
  levels = statuts
)

print(transform(resultats,
                win_rate  = round(win_rate, 3),
                borne_inf = round(borne_inf, 3),
                borne_sup = round(borne_sup, 3)), row.names = FALSE)

# --- Graphique ---
# Étiquettes d'axe : nom + taille d'échantillon (l'incertitude dépend de n)
resultats$etiquette <- paste0(resultats$nom, "\nn = ", resultats$matchs)
resultats$etiquette <- factor(resultats$etiquette, levels = resultats$etiquette)

# Palette Okabe-Ito (sûre pour les daltonismes), contraste >= 3:1 sur fond blanc,
# doublée par la forme du point pour ne pas reposer sur la couleur seule
couleurs <- setNames(c("#0072B2", "#6E6E6E", "#D55E00"), statuts)
formes   <- setNames(c(24, 21, 25), statuts)  # triangle haut, rond, triangle bas

texte_alt <- paste0(
  "Dot plot of the win rates of ", nrow(resultats), " players, sorted in descending order, ",
  "with ", niveau * 100, "% confidence intervals (Clopper-Pearson). ",
  paste(sprintf("%s: %s [%s; %s]", resultats$nom,
                pct(resultats$win_rate), pct(resultats$borne_inf), pct(resultats$borne_sup)),
        collapse = "; "), "."
)

graphique <- ggplot(resultats, aes(x = etiquette, y = win_rate,
                                   colour = statut, fill = statut, shape = statut)) +
  geom_hline(yintercept = reference, linetype = "dashed", colour = "grey40", linewidth = 0.5) +
  geom_errorbar(aes(ymin = borne_inf, ymax = borne_sup), width = 0.15, linewidth = 0.8) +
  geom_point(size = 3.5, stroke = 0.8) +
  # annotate() après les couches discrètes, sinon l'axe X devient continu
  annotate("text", x = 0.5, y = reference, label = paste(lbl_ref, "= chance level"),
           hjust = 0, vjust = -0.5, size = 3.5, colour = "grey30") +
  geom_text(aes(label = pct(win_rate)),
            nudge_x = 0.2, hjust = 0, size = 3.8, show.legend = FALSE) +
  scale_colour_manual(values = couleurs, name = NULL) +
  scale_fill_manual(values = couleurs, name = NULL) +
  scale_shape_manual(values = formes, name = NULL) +
  scale_y_continuous(labels = pct, limits = c(0, 1), breaks = seq(0, 1, 0.2),
                     expand = expansion(mult = c(0, 0.02))) +
  labs(
    title    = "Win rate by player",
    subtitle = paste0("Dot: observed win rate · Bar: ", niveau * 100,
                      "% confidence interval (Clopper-Pearson)"),
    caption  = "Overlapping bars do not prove the win rates are equal, nor that they differ.",
    x = NULL, y = "Win rate",
    alt = texte_alt
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

print(graphique)

# Export haute résolution (décommenter si besoin)
# ggsave("win_rates.png", graphique, width = 9, height = 5.5, dpi = 300, bg = "white")