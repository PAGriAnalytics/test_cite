# Base image
FROM python:3.8-slim as builder

# Set working directory
WORKDIR /app

# Copy backend files
COPY ./backend/ ./backend/

# Install backend dependencies
RUN pip install --no-cache-dir -r ./backend/requirements.txt

# Build frontend
FROM node:14-alpine as frontend-builder
WORKDIR /app/frontend
COPY ./frontend/ ./frontend/
RUN npm ci && npm run build

# Final image
FROM python:3.8-slim

# Set environment variables
ENV FLASK_APP=backend/app.py
ENV FLASK_ENV=production

# Copy backend files
COPY --from=builder /app/backend /app/backend

# Copy compiled frontend files
COPY --from=frontend-builder /app/frontend/.next /app/backend/.next
COPY --from=frontend-builder /app/frontend/out /app/backend/out

# Expose port
EXPOSE 5000

# Run the Flask app
CMD ["flask", "run", "--host=0.0.0.0"]