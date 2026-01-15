library(tidyverse)
library(janitor)

# 1. Create directory
dir.create("data", showWarnings = FALSE)

# 2. Define the seasons (MoneyPuck data starts at 2007)
# 2007 represents the 2007-2008 season
years <- 2007:2023 

# 3. Define a function to process one year at a time
get_season_data <- function(year) {
  
  # Construct the URL and filename dynamically
  url <- paste0("https://peter-tanner.com/moneypuck/downloads/shots_", year, ".zip")
  dest_file <- paste0("data/shots_", year, ".zip")
  
  # Only download if we don't have it yet (saves bandwidth)
  if (!file.exists(dest_file)) {
    message(paste("Downloading", year, "..."))
    tryCatch(
      download.file(url, dest_file, mode = "wb"),
      error = function(e) message(paste("Could not download", year))
    )
  }
  
  # Read, clean, and select columns immediately to save RAM
  # We wrap this in tryCatch in case a specific year file is corrupt or missing
  tryCatch({
    read_csv(dest_file, show_col_types = FALSE) |> 
      clean_names() |> 
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
      mutate(season = as.character(year)) # Add season column so we know the year
  }, error = function(e) return(NULL)) # Return NULL if file fails to read
}


