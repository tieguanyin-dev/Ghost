#!/bin/bash

# Ghost Local Development Setup Script
# This script automates the setup of Ghost for local development

set -e

echo "=========================================="
echo "Ghost Local Development Setup"
echo "=========================================="
echo ""

# Check Node.js version
echo "Checking Node.js version..."
NODE_VERSION=$(node --version)
echo "✓ Node.js $NODE_VERSION detected"
echo ""

# Check if yarn is available
if command -v yarn &> /dev/null; then
    PKG_MANAGER="yarn"
    echo "✓ Using yarn as package manager"
else
    PKG_MANAGER="npm"
    echo "✓ Using npm as package manager"
fi
echo ""

# Initialize git submodules
echo "Step 1: Initializing git submodules..."
git submodule update --init --recursive
echo "✓ Submodules initialized"
echo ""

# Install dependencies
echo "Step 2: Installing dependencies..."
if [ "$PKG_MANAGER" = "yarn" ]; then
    yarn install --ignore-engines
else
    npm install --ignore-engines
fi
echo "✓ Dependencies installed"
echo ""

# Database setup
echo "Step 3: Database setup"
echo "Choose your database option:"
echo "  1) MySQL (recommended for Node.js 12+)"
echo "  2) SQLite3 (for Node.js 6-10 only)"
echo ""
read -p "Enter your choice (1 or 2): " DB_CHOICE

if [ "$DB_CHOICE" = "1" ]; then
    echo ""
    echo "Setting up MySQL database..."
    
    # Check if MySQL is available
    if ! command -v mysql &> /dev/null; then
        echo "❌ MySQL is not installed. Please install MySQL first."
        echo "   Ubuntu/Debian: sudo apt-get install mysql-server"
        echo "   macOS: brew install mysql"
        exit 1
    fi
    
    # Create database
    echo "Creating Ghost database..."
    read -p "MySQL root password (press Enter if none): " MYSQL_ROOT_PASS
    
    if [ -z "$MYSQL_ROOT_PASS" ]; then
        # Try without password first, then with sudo
        mysql -e "CREATE DATABASE IF NOT EXISTS ghost_dev;" 2>/dev/null || \
        sudo mysql -e "CREATE DATABASE IF NOT EXISTS ghost_dev; CREATE USER IF NOT EXISTS 'ghost'@'localhost' IDENTIFIED BY 'ghostpass'; GRANT ALL PRIVILEGES ON ghost_dev.* TO 'ghost'@'localhost'; ALTER USER 'ghost'@'localhost' IDENTIFIED WITH mysql_native_password BY 'ghostpass'; FLUSH PRIVILEGES;"
    else
        mysql -u root -p"$MYSQL_ROOT_PASS" -e "CREATE DATABASE IF NOT EXISTS ghost_dev; CREATE USER IF NOT EXISTS 'ghost'@'localhost' IDENTIFIED BY 'ghostpass'; GRANT ALL PRIVILEGES ON ghost_dev.* TO 'ghost'@'localhost'; ALTER USER 'ghost'@'localhost' IDENTIFIED WITH mysql_native_password BY 'ghostpass'; FLUSH PRIVILEGES;"
    fi
    
    # Create config.local.json
    echo "Creating config.local.json..."
    cat > config.local.json <<'EOF'
{
  "url": "http://localhost:2368",
  "server": {
    "port": 2368,
    "host": "127.0.0.1"
  },
  "database": {
    "client": "mysql",
    "connection": {
      "host": "localhost",
      "user": "ghost",
      "password": "ghostpass",
      "database": "ghost_dev"
    }
  },
  "mail": {
    "transport": "Direct"
  },
  "logging": {
    "transports": ["file", "stdout"]
  },
  "process": "local",
  "paths": {
    "contentPath": "content/"
  }
}
EOF
    
    echo "✓ MySQL database configured"
    echo ""
    
    # Initialize database
    echo "Initializing database..."
    NODE_ENV=local npx knex-migrator init
    echo "✓ Database initialized"
    echo ""
    
    echo "=========================================="
    echo "Setup Complete!"
    echo "=========================================="
    echo ""
    echo "To start Ghost, run:"
    echo "  NODE_ENV=local node index.js"
    echo ""
    echo "Then visit: http://localhost:2368"
    echo "Admin panel: http://localhost:2368/ghost"
    echo ""
    
elif [ "$DB_CHOICE" = "2" ]; then
    echo ""
    echo "Setting up SQLite3 database..."
    
    # Initialize database
    echo "Initializing database..."
    npx knex-migrator init
    echo "✓ Database initialized"
    echo ""
    
    echo "=========================================="
    echo "Setup Complete!"
    echo "=========================================="
    echo ""
    echo "To start Ghost, run:"
    echo "  yarn start"
    echo "  OR: node index.js"
    echo ""
    echo "Then visit: http://localhost:2368"
    echo "Admin panel: http://localhost:2368/ghost"
    echo ""
else
    echo "Invalid choice. Please run the script again."
    exit 1
fi
