

library(tidyverse)

# 1. Create a folder for the data
dir.create("data", showWarnings = FALSE)

# 2. Download the 2023-2024 season data
# MoneyPuck's file naming convention: shots_2023.zip covers the 2023-2024 season
url <- "https://peter-tanner.com/moneypuck/downloads/shots_2023.zip"
dest_file <- "data/shots_2023.zip"

if (!file.exists(dest_file)) {
  download.file(url, dest_file, mode = "wb")
}

# 3. Read the data directly
# We select the most interesting columns to keep it clean
shots_2023 <- read_csv(dest_file) |> 
  janitor::clean_names() |> 
  select(
    game_id,
    date = game_date,
    home_team = home_team_code,
    away_team = away_team_code,
    period,
    time,
    team = team_code,
    shooter = shooter_name,
    goalie = goalie_name_for_shot,
    x = x_cord,          # The X coordinate on the rink
    y = y_cord,          # The Y coordinate on the rink
    shot_type,
    is_goal = goal,      # 1 = Goal, 0 = No Goal
    xg = x_goal          # The Expected Goal value (Probability 0-1)
  )

# 4. Check it out
glimpse(shots_2023)