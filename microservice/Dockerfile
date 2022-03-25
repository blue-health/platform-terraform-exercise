# ---
# We begin with the `builder` step where you should
# build the application and obtain a single executable.
# ---

FROM golang:1.18-alpine AS builder

# ---
# 1. Please copy the source code and required files, build the Golang app.
# ---

FROM gcr.io/distroless/static:nonroot as runner

# ---
# 2. Please copy the built application from the previous step to the `runner`.
# ---

# ---
# 3. Please expose the port 8080, and set appropriate entrypoint.
# ---
