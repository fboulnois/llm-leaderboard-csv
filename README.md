# LLM Leaderboard CSVs

Generates CSVs of the [LMArena Leaderboard](https://lmarena.ai/leaderboard) in Python.

The latest LMArena CSVs can be downloaded from the [Releases](https://github.com/fboulnois/llm-leaderboard-csv/releases) page.

Previously, CSVs were also generated for the v1 and v2 [Huggingface Open LLM Leaderboard](https://huggingface.co/spaces/open-llm-leaderboard/open_llm_leaderboard) in R but this leaderboard has been retired. The latest code and versions of those CSVs is in the [`v1.3.0` release](https://github.com/fboulnois/llm-leaderboard-csv/releases/v1.3.0).

## Run

> [!TIP]
> Delete the `csv` directory before running the code if you want to recreate the CSVs using the latest data.

### Run using Python

The code is in [`huggingface.py`](huggingface.py):

```sh
# run the code to generate the leaderboard data frames
uv run huggingface.py
```

### Run using Docker

A [`Dockerfile`](Dockerfile) is also provided to build and run the code using the official `uv` Docker image:

```bash
docker build . --tag llm-leaderboard-csv
docker run -v ./csv:/home/docker/csv --rm llm-leaderboard-csv
```
