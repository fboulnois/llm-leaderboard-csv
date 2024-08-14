FROM r-base:4.4.0 AS env-deploy

RUN apt-get update && apt-get install -y libssl-dev libcurl4-openssl-dev libxml2-dev

RUN install2.r --error data.table rvest stringr jsonlite

WORKDIR /home/docker

USER docker

COPY huggingface.R huggingface.R

CMD ["Rscript", "huggingface.R"]
