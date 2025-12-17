# Base image with Python 3.12 and uv
FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim

# Create non-root user
RUN groupadd --system --gid 999 nonroot \
 && useradd --system --uid 999 --gid 999 --create-home nonroot

# Set working directory (creates /app)
WORKDIR /app

# uv configuration
ENV UV_COMPILE_BYTECODE=1
ENV UV_LINK_MODE=copy
ENV UV_NO_DEV=1
ENV UV_TOOL_BIN_DIR=/usr/local/bin

# Copy dependency files first
COPY pyproject.toml uv.lock ./

# Install dependencies only
RUN uv sync --locked --no-install-project

# Copy application source
COPY . .

# Install project
RUN uv sync --locked

# Use virtualenv binaries
ENV PATH="/app/.venv/bin:$PATH"

# Fix permissions
RUN chown -R nonroot:nonroot /app

# Switch to non-root user
USER nonroot

# Expose FastAPI port
EXPOSE 8000

# Reset entrypoint
ENTRYPOINT []

# Run FastAPI (dev mode)
CMD ["uv", "run", "fastapi", "dev", "--host", "0.0.0.0", "--port", "8000"]
