# Arguments
# ==========================================
# BUILD=prod  → runtime image (no dev deps) — use this to publish
# BUILD=dev   → includes black/isort/ty for local debugging
ARG BUILD=prod

# ==========================================
# STAGE 1: Builder
# ==========================================
FROM python:3.12-slim AS builder

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

ENV UV_PYTHON_PREFERENCE=system \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_PROJECT_ENVIRONMENT=/app/.venv

RUN apt-get update \
    && apt-get install -y --no-install-recommends git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY pyproject.toml uv.lock* ./

ARG BUILD
RUN if [ "$BUILD" = "prod" ]; then \
        EXTRA_FLAGS="--no-dev"; \
    elif [ "$BUILD" = "dev" ]; then \
        EXTRA_FLAGS=""; \
    else \
        echo "Invalid BUILD argument: $BUILD (use prod or dev)"; \
        exit 1; \
    fi; \
    uv sync --python /usr/local/bin/python --no-install-project $EXTRA_FLAGS

COPY pyproject.toml uv.lock* README.md ./
COPY cc/ ./cc/

ARG BUILD
RUN if [ "$BUILD" = "prod" ]; then \
        EXTRA_FLAGS="--no-dev"; \
    elif [ "$BUILD" = "dev" ]; then \
        EXTRA_FLAGS=""; \
    else \
        echo "Invalid BUILD argument: $BUILD (use prod or dev)"; \
        exit 1; \
    fi; \
    uv sync --python /usr/local/bin/python $EXTRA_FLAGS


# ==========================================
# STAGE 2: Runtime — pull & run on any server
# ==========================================
FROM python:3.12-slim

LABEL org.opencontainers.image.title="cc" \
      org.opencontainers.image.description="Cookiecutter CLI that generates projects from cc-templates Git branches" \
      org.opencontainers.image.source="https://github.com/gaurav-mistary/cc" \
      org.opencontainers.image.licenses="MIT"

# Cookiecutter clones template branches at runtime; git is required
RUN apt-get update \
    && apt-get install -y --no-install-recommends git ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /app /app

ENV PATH="/app/.venv/bin:$PATH" \
    PYTHONPATH=/app \
    # Default: pull templates from public cc-templates GitHub repo
    TEMPLATES_REPO_URL=https://github.com/gaurav-mistary/cc-templates.git \
    CC_REGISTRY=https://raw.githubusercontent.com/gaurav-mistary/cc-templates/main/registry.json \
    FACTORY_URL=https://github.com/gaurav-mistary/cc-templates.git

# Host mount point for generated projects (-v /host/path:/output)
VOLUME ["/output"]
WORKDIR /output

# Prefer installed console script; falls back via PYTHONPATH for python -m
ENTRYPOINT ["cc-cli"]
CMD ["--help"]
