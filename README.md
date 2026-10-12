# Intervalle de confiance du win rate (R)

Script R qui calcule le win rate de plusieurs joueurs avec son intervalle de confiance exact (méthode de Clopper-Pearson), puis le représente sur un graphique ggplot2.

Chaque joueur est classé en trois catégories selon la position de son intervalle par rapport à un seuil de référence (50 % par défaut) :

- **Above 50%** : l'intervalle entier est au-dessus du seuil.
- **Not distinguishable from 50%** : l'intervalle contient le seuil.
- **Below 50%** : l'intervalle entier est en dessous du seuil.

## Prérequis

- R (version 4.1 ou plus récente recommandée)
- Les packages `ggplot2` et `scales`, installés automatiquement au premier lancement s'ils sont absents

## Utilisation

1. Ouvrir `intervalle-confiance-winrate.R` dans RStudio.
2. Modifier les valeurs d'entrée (voir ci-dessous).
3. Lancer le script avec **Ctrl+Shift+S** (Source).

On peut aussi le lancer en ligne de commande :

```sh
Rscript intervalle-confiance-winrate.R
```

Le script affiche un tableau de résultats dans la console, puis le graphique.

## Modifier les variables d'entrée

Toutes les entrées se trouvent dans le bloc `# --- Valeurs d'entrée à modifier ---`, en haut du script.

### Le tableau `joueurs`

```r
joueurs <- data.frame(
  nom       = c("Mewtwo", "Lugia", "Zapdos"),
  victoires = c(38, 20, 14),
  matchs    = c(50, 30, 26)
)
```

| Colonne     | Contenu                       | Contraintes                       |
|-------------|-------------------------------|-----------------------------------|
| `nom`       | Nom affiché sur l'axe         | Texte, un nom unique par joueur   |
| `victoires` | Nombre de matchs gagnés       | Entier, `>= 0` et `<= matchs`     |
| `matchs`    | Nombre total de matchs joués  | Entier, `> 0`                     |

Les trois vecteurs doivent avoir **la même longueur** : la n-ième valeur de chaque colonne décrit le même joueur. Pour ajouter un joueur, ajoutez une valeur à chacun des trois vecteurs. Pour en retirer un, supprimez la valeur correspondante dans les trois.

Le nombre de joueurs n'est pas limité : le graphique s'adapte et trie les joueurs du win rate le plus élevé au plus bas.

Si une contrainte n'est pas respectée, par exemple plus de victoires que de matchs, le script s'arrête avec une erreur `stopifnot`.

### Le niveau de confiance `niveau`

```r
niveau <- 0.95
```

Valeur entre 0 et 1. Avec `0.90`, les intervalles sont plus étroits mais moins sûrs. Avec `0.99`, ils sont plus larges mais plus sûrs. Le sous-titre et le texte alternatif du graphique se mettent à jour automatiquement.

### Le seuil de comparaison `reference`

```r
reference <- 0.5
```

Valeur entre 0 et 1, représentée par la ligne pointillée. Elle détermine la catégorie (et donc la couleur et la forme du point) de chaque joueur. Par exemple, `0.55` permet de repérer les joueurs dont le win rate est significativement supérieur à 55 %.

## Exemple : utiliser vos propres données

```r
joueurs <- data.frame(
  nom       = c("Alice", "Bob", "Chloé", "David"),
  victoires = c(62, 45, 18, 7),
  matchs    = c(100, 90, 40, 12)
)
niveau    <- 0.95
reference <- 0.5
```

## Exporter le graphique

La dernière ligne du script est commentée. Décommentez-la pour enregistrer le graphique en PNG haute résolution dans le répertoire de travail :

```r
ggsave("win_rates.png", graphique, width = 9, height = 5.5, dpi = 300, bg = "white")
```

Ajustez `width` et `height` (en pouces) si vous avez beaucoup de joueurs.

## Lire le graphique

- **Point** : win rate observé (`victoires / matchs`).
- **Barre** : intervalle de confiance. Elle est plus large quand le nombre de matchs `n` (indiqué sous chaque nom) est faible.
- **Ligne pointillée** : seuil de référence.

Deux barres qui se chevauchent ne prouvent ni que les win rates sont égaux, ni qu'ils diffèrent. Pour comparer deux joueurs entre eux, il faut un test dédié, par exemple `prop.test`.

Les textes du graphique sont en anglais. Les commentaires du code et ce README sont en français.
