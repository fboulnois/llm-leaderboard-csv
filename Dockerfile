FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim AS env-deploy

RUN apt-get update && apt-get install -y git git-lfs && useradd -m uv

WORKDIR /home/uv

USER uv

COPY --chown=uv:uv huggingface.py /home/uv/

ENTRYPOINT ["uv", "run", "huggingface.py"]
