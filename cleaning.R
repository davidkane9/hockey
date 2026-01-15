library(tidyverse)
library(janitor)

# 1. Get a list of all the zip files in your data folder
file_paths <- list.files("data", pattern = "shots_.*\\.zip", full.names = TRUE)

# 2. Define a function to read and clean one file
read_season_shots <- function(path) {
  
  # Extract year from filename (e.g., "data/shots_2007.zip" -> "2007")
  # This serves as our ID since we are reading many files
  year_id <- str_extract(path, "\\d{4}")
  
  read_csv(path, show_col_types = FALSE) |> 
    clean_names() |> 
    # Select strictly to ensure columns match across 16+ years of files
    # and to keep memory usage manageable (~3-4GB total loaded)
    select(
      game_id,
      home_team = home_team_code,
      away_team = away_team_code,
      period,
      time,
      team = team_code,
      shooter = shooter_name,
      goalie = goalie_name_for_shot,
      x = x_cord,
      y = y_cord,
      shot_type,
      is_goal = goal,
      xg = x_goal
    ) |> 
    mutate(season = year_id) # Add the year so you know which season it is
}

# 3. Map over the files and combine
# This will show a progress bar if you use map vs plain lapply
all_shots <- map(file_paths, read_season_shots, .progress = TRUE) |> 
  list_rbind()

# 4. Save results
write_rds(all_shots, "clean_data.rds")