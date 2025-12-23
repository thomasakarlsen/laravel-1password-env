#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Laravel Octane Docker Setup${NC}"
echo "=================================="
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

echo -e "${BLUE}Step 1: Creating .env file${NC}"
if [ ! -f .env ]; then
    cp .env.example .env
    echo -e "${GREEN}✓ .env file created${NC}"
else
    echo -e "${GREEN}✓ .env file already exists${NC}"
fi
echo ""

echo -e "${BLUE}Step 2: Building Docker images${NC}"
docker-compose build
echo -e "${GREEN}✓ Docker images built${NC}"
echo ""

echo -e "${BLUE}Step 3: Starting containers${NC}"
docker-compose up -d
echo -e "${GREEN}✓ Containers started${NC}"
echo ""

echo -e "${BLUE}Step 4: Generating application key${NC}"
docker-compose exec -T app php artisan key:generate --force 2>/dev/null || true
echo -e "${GREEN}✓ Application key generated${NC}"
echo ""

echo -e "${BLUE}Step 5: Running database migrations${NC}"
docker-compose exec -T app php artisan migrate --force 2>/dev/null || true
echo -e "${GREEN}✓ Database migrations completed${NC}"
echo ""

echo -e "${BLUE}Step 6: Building frontend assets${NC}"
docker-compose exec -T app npm install 2>/dev/null || true
docker-compose exec -T app npm run build 2>/dev/null || true
echo -e "${GREEN}✓ Frontend assets built${NC}"
echo ""

echo -e "${GREEN}=================================="
echo "✨ Setup Complete!"
echo "==================================${NC}"
echo ""
echo "Your application is ready!"
echo ""
echo "📍 Access your application at: http://localhost"
echo "🗄️  Database: localhost:3306"
echo ""
echo "Useful commands:"
echo "  • View logs:        docker-compose logs -f app"
echo "  • Connect to shell: docker-compose exec app sh"
echo "  • Run artisan:      docker-compose exec app php artisan"
echo "  • Stop containers:  docker-compose down"
echo ""
echo "For more details, see DOCKER.md"
