library(data.table)
library(rvest)
library(stringr)
library(jsonlite)

set_working_directory <- function() {
  cwd <- getSrcDirectory(function(x){x})
  if (length(cwd) == 0) {
    fp <- str_match(commandArgs(), "--file=(.*)")[,2]
    cwd <- dirname(fp[!is.na(fp)])
  }
  setwd(cwd)
}

# implement extract2 from magrittr
extract2 <- .Primitive("[[")

# extract json from script elements
json_from_html <- function(url) {
  html <- read_html(url, options = "HUGE")
  json <- html |>
    html_elements("script") |>
    html_text() |>
    extract2(2) |>
    str_replace("^window.gradio_config = ", "") |>
    str_replace(";$", "")
  len <- str_length(json)
  stopifnot(len > 1e4)
  fromJSON(json)
}

find_column_index <- function(json, column_name) {
  headers <- json$components$props$headers
  has_column_name <- function(header){
    any(str_detect(header, column_name))
  }
  which(vapply(headers, has_column_name, logical(1)))
}

normalize_json_headers_hg <- function(json, idx) {
  headers <- json$components$props$value[[idx]]$headers
  headers[str_detect(headers, "Average ⬆️")] <- "Average"
  headers[str_detect(headers, "Hub ❤️")] <- "Hub Hearts"
  headers[str_detect(headers, "#Params \\(B\\)")] <- "Params B"
  headers <- str_replace_all(headers, " ", "_")
  tolower(headers)
}

normalize_json_headers_lm <- function(json, idx) {
  headers <- json$components$props$value[[idx]]$headers
  headers <- str_trim(str_replace_all(headers, "\\W+", " "))
  headers[str_detect(headers, "Rank UB")] <- "Rank"
  headers[str_detect(headers, "95 CI")] <- "95 Pct CI"
  headers[str_detect(headers, "Votes")] <- "Votes"
  headers <- str_replace_all(headers, " ", "_")
  tolower(headers)
}

dt_from_json_index <- function(json, idx) {
  data <- json$components$props$value[[idx]]$data
  as.data.table(data)
}

model_name_and_url <- function(model) {
  html <- read_html(model)
  a <- html |>
    html_element("a")
  model <- a |>
    html_text()
  url <- a |>
    html_attr("href")
  list(model = model, url = url)
}

add_model_url_columns <- function(dt) {
  dt[, c("model", "url") := model_name_and_url(model), by = .I]
}

set_numeric_columns_hg <- function(dt) {
  numeric_cols <- c("average", "arc", "hellaswag", "mmlu", "truthfulqa", "winogrande", "gsm8k", "params_b", "hub_hearts")
  dt[, (numeric_cols) := lapply(.SD, as.numeric), .SDcols = numeric_cols]
}

set_numeric_columns_lm <- function(dt) {
  numeric_cols <- c("rank", "arena_elo", "votes")
  dt[, (numeric_cols) := lapply(.SD, as.numeric), .SDcols = numeric_cols]
}

set_logical_columns_hg <- function(dt) {
  logical_cols <- c("merged", "available_on_the_hub", "flagged", "moe")
  dt[, (logical_cols) := lapply(.SD, as.logical), .SDcols = logical_cols]
}

set_dt_types_hg <- function(dt) {
  set_numeric_columns_hg(dt)
  set_logical_columns_hg(dt)
}

set_dt_types_lm <- function(dt) {
  set_numeric_columns_lm(dt)
}

dt_from_json_hg <- function(json) {
  idx <- find_column_index(json, "^Hub ❤️")
  headers <- normalize_json_headers_hg(json, idx)
  dt <- dt_from_json_index(json, idx)
  setnames(dt, headers)
  add_model_url_columns(dt)
  set_dt_types_hg(dt)
}

dt_from_json_lm <- function(json) {
  idx <- find_column_index(json, "^Knowledge Cutoff")
  headers <- normalize_json_headers_lm(json, idx)
  dt <- dt_from_json_index(json, idx)
  setnames(dt, headers)
  add_model_url_columns(dt)
  set_dt_types_lm(dt)
}

dt_from_html_hg <- function(url) {
  json <- json_from_html(url)
  dt_from_json_hg(json)
}

dt_from_html_lm <- function(url) {
  json <- json_from_html(url)
  dt_from_json_lm(json)
}

dt_merge_tables <- function(dt1, dt2) {
  dt1[, key := tolower(str_split_i(model, "/", 2))]
  dt2[, key := tolower(model)]
  merge(dt1, dt2, by = "key")
}

# read data.table from csv or calculate it
dt_if_missing <- function(file, fn, ...) {
  csv <- file.path("csv", file)
  if(file.exists(csv)) {
    dt <- fread(csv)
  } else {
    dt <- do.call(fn, list(...))
    fwrite(dt, csv)
    dt
  }
}

set_working_directory()

url <- "https://open-llm-leaderboard-old-open-llm-leaderboard.hf.space/"
file <- "huggingface.csv"
dt1 <- dt_if_missing(file, dt_from_html_hg, url)

url <- "https://lmsys-chatbot-arena-leaderboard.hf.space/"
file <- "lmsys.csv"
dt2 <- dt_if_missing(file, dt_from_html_lm, url)

file <- "merged.csv"
merged <- dt_if_missing(file, dt_merge_tables, dt1, dt2)
