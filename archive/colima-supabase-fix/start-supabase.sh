#!/bin/bash

# Supabase Startup Helper for Colima
# This script ensures proper environment before starting Supabase

set -e

echo "🚀 Starting Supabase with Colima..."

# Ensure Colima is running
colima_check=$(colima status 2>&1 || echo "not running")
if [[ $colima_check != *"running"* ]]; then
    echo "Starting Colima..."
    colima start
fi

# Set Docker context
docker context use colima > /dev/null 2>&1

# Set environment variables
export DOCKER_HOST="unix:///var/run/docker.sock"
export DOCKER_CONTEXT="colima"

# Start Supabase
echo "Starting Supabase services..."
supabase start "$@"

echo "✅ Supabase is now running!"
echo "📊 Studio URL: http://localhost:54323"
echo "🗄️  Database URL: postgresql://postgres:postgres@localhost:54322/postgres"
echo "🔌 API URL: http://localhost:54321"
