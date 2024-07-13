# LLM Leaderboard CSVs

Code to generate CSVs of the [Huggingface Open LLM Leaderboard](https://huggingface.co/spaces/open-llm-leaderboard/open_llm_leaderboard) (v1 and v2)
and the [LMSYS Chatbot Arena Leaderboard](https://chat.lmsys.org/?leaderboard)
in R. The code also generates a CSV of the merged leaderboard.

The resulting CSVs are in the [`csv`](csv) directory.

## Run

> [!TIP]
> Delete the CSVs in the `csv` directory before running the code if you want to
regenerate them using the latest data.

### Run using R or RStudio

The code is in [`huggingface.R`](huggingface.R):

```R
# install the required dependencies
install.packages(c("data.table", "rvest", "stringr", "jsonlite"))

# run the code to generate the leaderboard data.tables
source("huggingface.R")
```

### Run using Docker

A [`Dockerfile`](Dockerfile) is also provided to build and run the code using
the official `r-base` Docker image:

```bash
docker build . --tag llm-leaderboard-csv
docker run -v ./csv:/home/docker/csv --rm llm-leaderboard-csv
```
