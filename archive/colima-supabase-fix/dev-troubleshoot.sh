#!/bin/bash

# FinTrack Backend Development Troubleshooting Script
# This script helps diagnose and fix common development issues

set -e

echo "🔧 FinTrack Backend Development Troubleshooter"
echo "=============================================="
echo ""

# Check Node.js version
echo "📦 Checking Node.js version..."
if command -v node >/dev/null 2>&1; then
    NODE_VERSION=$(node --version)
    echo "✅ Node.js version: $NODE_VERSION"

    # Check if Node version is 24.x or higher
    NODE_MAJOR=$(echo $NODE_VERSION | cut -d'.' -f1 | sed 's/v//')
    if [ "$NODE_MAJOR" -ge 24 ]; then
        echo "✅ Node.js version is compatible (24.x or higher)"
    else
        echo "⚠️  Node.js version should be 24.x or higher for best compatibility"
    fi
else
    echo "❌ Node.js is not installed"
    exit 1
fi
echo ""

# Check npm version
echo "📦 Checking npm version..."
if command -v npm >/dev/null 2>&1; then
    NPM_VERSION=$(npm --version)
    echo "✅ npm version: $NPM_VERSION"
else
    echo "❌ npm is not installed"
    exit 1
fi
echo ""

# Check if .env file exists
echo "🔧 Checking environment configuration..."
if [ -f ".env" ]; then
    echo "✅ .env file exists"

    # Check if DATABASE_URL is set
    if grep -q "DATABASE_URL" .env; then
        echo "✅ DATABASE_URL is configured in .env"
    else
        echo "⚠️  DATABASE_URL not found in .env file"
        echo "   Add DATABASE_URL to your .env file:"
        echo "   DATABASE_URL=\"postgresql://username:password@localhost:5432/fintrack\""
    fi
else
    echo "⚠️  .env file not found"
    if [ -f ".env.example" ]; then
        echo "   Copy .env.example to .env and configure your database:"
        echo "   cp .env.example .env"
    else
        echo "   Create a .env file with:"
        echo "   DATABASE_URL=\"postgresql://username:password@localhost:5432/fintrack\""
    fi
fi
echo ""

# Check if node_modules exists
echo "📦 Checking dependencies..."
if [ -d "node_modules" ]; then
    echo "✅ node_modules directory exists"
else
    echo "⚠️  node_modules not found. Installing dependencies..."
    npm install
fi
echo ""

# Check if Prisma client is generated
echo "🗄️  Checking Prisma client..."
if [ -d "generated/prisma" ]; then
    echo "✅ Prisma client is generated"
else
    echo "⚠️  Prisma client not generated. Generating now..."
    npm run prisma:generate
fi
echo ""

# Test database connection (optional)
echo "🔍 Testing database connection..."
if command -v psql >/dev/null 2>&1; then
    echo "✅ PostgreSQL client (psql) is available"

    # Try to extract database info from .env
    if [ -f ".env" ] && grep -q "DATABASE_URL" .env; then
        echo "   Testing database connection..."
        if npm run prisma:validate >/dev/null 2>&1; then
            echo "✅ Database schema is valid"
        else
            echo "⚠️  Database schema validation failed"
            echo "   Run: npm run prisma:validate"
        fi
    fi
else
    echo "ℹ️  PostgreSQL client not found (optional for development)"
    echo "   Install PostgreSQL to test database connections"
fi
echo ""

# Check TypeScript compilation
echo "🔧 Checking TypeScript compilation..."
if npm run type-check >/dev/null 2>&1; then
    echo "✅ TypeScript compilation successful"
else
    echo "❌ TypeScript compilation failed"
    echo "   Run: npm run type-check"
    echo "   Fix any TypeScript errors before starting development"
fi
echo ""

# Check if build works
echo "🏗️  Testing build process..."
if npm run build >/dev/null 2>&1; then
    echo "✅ Build process successful"
else
    echo "❌ Build process failed"
    echo "   Run: npm run build"
    echo "   Check for compilation errors"
fi
echo ""

echo "🎯 Development Server Startup Commands:"
echo "   Basic startup:           npm run dev"
echo "   With Prisma generation:  npm run dev:setup"
echo "   View health status:      curl http://localhost:4000/health"
echo ""

echo "🔧 Common Troubleshooting Commands:"
echo "   Regenerate Prisma:       npm run prisma:generate"
echo "   Validate schema:         npm run prisma:validate"
echo "   Reset database:          npx prisma db push --force-reset"
echo "   Check types:             npm run type-check"
echo "   Run tests:               npm test"
echo ""

echo "📚 Development URLs (when server is running):"
echo "   Health check:            http://localhost:4000/health"
echo "   Ping endpoint:           http://localhost:4000/"
echo "   Entries API:             http://localhost:4000/entries"
echo ""

echo "✅ Troubleshooting complete!"
echo "   If you're still having issues:"
echo "   1. Check the console output when running 'npm run dev'"
echo "   2. Ensure PostgreSQL is running (if using a local database)"
echo "   3. Verify your .env file configuration"
echo "   4. Try running 'npm run dev:setup' instead of 'npm run dev'"
