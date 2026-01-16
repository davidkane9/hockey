library(tidyverse)

# 1. Load the data to find out which years we have
shots <- read_rds("clean_data.rds")
years <- unique(shots$season) |> sort()

# 2. Define the template
# ADDED: "title: 'Season {{year}} Analysis'" to fix the warning
qmd_template <- paste(
  "---",
  "title: 'Season {{year}} Analysis'",
  "format: html",
  "execute:", 
  "  echo: false",
  "  message: false",
  "  warning: false",
  "---",
  "",
  "```{r}",
  "library(tidyverse)",
  "library(plotly)",
  "",
  "# 1. Load the data",
  "shots <- read_rds('clean_data.rds')",
  "",
  "# 2. Prepare the data",
  "game_summary <- shots |>", 
  "  filter(season == {{year}}) |>", 
  "  summarize(",
  "    total_shots = n(),",
  "    avg_xg = mean(xg, na.rm = TRUE),",
  "    total_goals = sum(is_goal, na.rm = TRUE),",
  "    matchup = paste(first(home_team), 'vs', first(away_team)),",
  "    game_label = if('date' %in% names(shots)) as.character(first(date)) else paste('Game ID:', first(game_id)),",
  "    .by = game_id",
  "  )",
  "",
  "# 3. Create the ggplot",
  "p <- game_summary |>", 
  "  ggplot(aes(x = total_shots, y = avg_xg, color = total_goals)) +",
  "  geom_point(",
  "    aes(",
  "      text = paste0(",
  "        '<b>Matchup:</b> ', matchup, '<br>',",
  "        '<b>Date/ID:</b> ', game_label, '<br>',",
  "        '<b>Total Goals:</b> ', total_goals, '<br>',",
  "        '<b>Shots:</b> ', total_shots, '<br>',",
  "        '<b>Avg xG:</b> ', round(avg_xg, 3)",
  "      )",
  "    ),",
  "    alpha = 0.8,", 
  "    size = 3",
  "  ) +",
  "  scale_color_viridis_c(option = 'turbo', name = 'Goals') +",
  "  labs(",
  "    title = 'Game Quantity vs. Quality ({{year}} Season)',",
  "    x = 'Total Shots in Game',",
  "    y = 'Average xG per Shot'",
  "  ) +",
  "  theme_minimal()",
  "",
  "# 4. Render Interactive Plot",
  "ggplotly(p, tooltip = 'text')",
  "```",
  sep = "\n"
)

# 3. Loop through each year and write the file
for (yr in years) {
  
  # Replace the {{year}} placeholder in BOTH the Title and the Code
  file_content <- str_replace_all(qmd_template, "\\{\\{year\\}\\}", as.character(yr))
  
  file_name <- paste0(yr, ".qmd")
  writeLines(file_content, file_name)
  
  message(paste("Created:", file_name))
}
