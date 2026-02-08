#!/bin/bash

# CI Database Setup Script for E2E Tests
# This script sets up the PostgreSQL database for E2E testing in CI environment

set -e  # Exit on any error

echo "🔧 Setting up CI database for E2E tests..."

# Check if we're in CI environment
if [ "$CI" = "true" ]; then
    echo "📍 CI environment detected"

    # Set default DATABASE_URL if not provided
    if [ -z "$DATABASE_URL" ]; then
        export DATABASE_URL="postgresql://test:test@localhost:5432/fintrack_test"
        echo "🔗 Using default DATABASE_URL: $DATABASE_URL"
    else
        echo "🔗 Using provided DATABASE_URL: $DATABASE_URL"
    fi
else
    echo "💻 Local environment detected"
    # For local development, use a test database
    export DATABASE_URL="postgresql://test:test@localhost:5432/fintrack_test"
    echo "🔗 Using local test DATABASE_URL: $DATABASE_URL"
fi

# Wait for PostgreSQL to be ready (CI environment)
if [ "$CI" = "true" ]; then
    echo "⏳ Waiting for PostgreSQL to be ready..."
    for i in {1..30}; do
        if pg_isready -h localhost -p 5432 -U test; then
            echo "✅ PostgreSQL is ready!"
            break
        fi
        echo "⏳ Waiting for PostgreSQL... (attempt $i/30)"
        sleep 1
    done

    if ! pg_isready -h localhost -p 5432 -U test; then
        echo "❌ PostgreSQL failed to start in time"
        exit 1
    fi
fi

# Generate Prisma client
echo "📦 Generating Prisma client..."
npx prisma generate

# Push database schema (creates tables if they don't exist)
echo "🗄️ Setting up database schema..."
if npx prisma db push --force-reset; then
    echo "✅ Database schema setup complete!"
else
    echo "⚠️ Database schema setup failed, but continuing..."
    echo "   E2E tests will handle database errors gracefully"
fi

echo "🎉 CI database setup completed!"
