# Base image with uv + Python
FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim

# Create non-root user
RUN groupadd --system --gid 999 nonroot \
 && useradd --system --uid 999 --gid 999 --create-home nonroot

# Set working directory (this CREATES /app)
WORKDIR /app

# uv configuration
ENV UV_COMPILE_BYTECODE=1
ENV UV_LINK_MODE=copy
ENV UV_NO_DEV=1
ENV UV_TOOL_BIN_DIR=/usr/local/bin

# Copy dependency files FIRST (important)
COPY pyproject.toml uv.lock ./

# Install dependencies only
RUN uv sync --locked --no-install-project

# Copy the rest of the source code
COPY . .

# Install the project itself
RUN uv sync --locked

# Ensure venv binaries are used
ENV PATH="/app/.venv/bin:$PATH"

# Fix permissions for non-root user
RUN chown -R nonroot:nonroot /app

# Drop privileges
USER nonroot

# Do not force uv as entrypoint
ENTRYPOINT []

# Start FastAPI (dev mode)
CMD ["uv", "run", "fastapi", "dev", "--host", "0.0.0.0", "src/uv_docker_example"]
