# Optimising Supercereal Allocation to Flood-Affected Wards — Nepal

A linear programming approach to allocating a fixed supply of fortified blended food across flood-affected wards in Nepal in 2019.

Available supercereal tonnage was fixed and insufficient to cover all affected wards at full ration. Wards differ in the number of people exposed, severity of exposure, and nutritional need. Allocating by need alone spreads the commodity too thinly to matter anywhere; allocating by severity alone strands populations in moderately affected wards. Framing the decision as a linear program makes that trade-off explicit: maximise coverage of the priority population subject to total tonnage, minimum viable ration size, and ward-level exposure ranking.

The more useful output is actually the sensitivity around the optimum rather than the optimum itself. Changing the minimum viable ration or total available tonnage moves the ward set substantially. That tells you which wards are marginal under any reasonable set of assumptions, which is where the real allocation decision sits.

Rendered write-up: [moctaraboubacar.github.io/nutrition_programming](https://moctaraboubacar.github.io/nutrition_programming/)

## Methods

Linear programming (`lpSolve`), constrained optimisation, scenario comparison across tonnage and ration assumptions.

## Files

| File | Purpose |
|---|---|
| `Ward BSFM LP.R` | Sets up and solves the allocation program |
| `index.Rmd` | Write-up with method, results and scenario comparison |
| `index.html` | Rendered output |
| `1 Wards by MT.png`, `2 District Comparison.png`, `3 Percentage Affected.png` | Result figures |

## Data

The ward-level exposure ranking is not redistributed here. To run the code, place it in `data/`:

| File | Description |
|---|---|
| `Ward Exposure rank v1.csv` | Ward-level flood exposure, affected population, and ranking |

## Reproducing

Paths resolve from the repository root through the `here` package.

```r
install.packages(c("lpSolve", "tidyverse", "directlabels", "here"))

source("Ward BSFM LP.R")
# or render the full write-up
rmarkdown::render("index.Rmd")
```

## License

MIT — see [LICENSE](LICENSE).
