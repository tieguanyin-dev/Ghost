# Ghost Local Development Setup Guide

**Note**: This is Ghost version 2.21.1, which was designed for Node.js 6.9-10.13. If you're using a newer Node.js version (12+), some features like the admin client build may not work due to dependency compatibility. For a production-ready setup with the latest Ghost version, we recommend using the official [Ghost CLI](https://ghost.org/docs/ghost-cli/).

This guide is designed to help you get the Ghost **frontend and API** running locally for development and testing purposes.

---

## Prerequisites

Before you begin, ensure you have the following installed:

- **Node.js**: Version 6.9+, 8.9+, or 10.13+ (as specified in package.json)
  - Check your version: `node --version`
  - Download from: https://nodejs.org/
  - **Note**: If using Node.js 12+, you may encounter compatibility issues with SQLite3. It's recommended to use MySQL instead (see Database Setup section).
- **Yarn** or **npm**: Package manager
  - Check yarn version: `yarn --version`
  - Install yarn: `npm install -g yarn`
- **Git**: For cloning and managing the repository
  - Check version: `git --version`
- **MySQL** (optional but recommended for newer Node versions):
  - MySQL 5.7+ or 8.0+
  - Check version: `mysql --version`

## Quick Start

If you want to get Ghost running quickly without development setup, use the Ghost CLI:

```bash
npm install ghost-cli -g
ghost install local
```

For development work, continue with the steps below.

## Full Development Setup

### 1. Clone the Repository

If you haven't already cloned the repository:

```bash
git clone https://github.com/TryGhost/Ghost.git
cd Ghost
```

### 2. Initialize Git Submodules

Ghost uses git submodules for the admin client and themes. Initialize them:

```bash
git submodule update --init --recursive
```

This will download:
- `core/client` - Ghost Admin (the admin interface)
- `content/themes/casper` - Default Casper theme

### 3. Install Dependencies

Install all Node.js dependencies using yarn (recommended) or npm:

```bash
# Using yarn (recommended)
yarn install --ignore-engines

# OR using npm
npm install --ignore-engines
```

**Note**: The `--ignore-engines` flag is needed if you're using a newer Node.js version than specified in package.json. The newer versions are generally backward compatible.

This will:
- Install all dependencies listed in package.json
- Run the postinstall script to copy members-theme-bindings
- Optional dependencies (sqlite3, sharp) may fail to build - this is normal and can be safely ignored

### 4. Database Setup

Ghost supports both SQLite3 (for simple development) and MySQL (recommended for production and newer Node versions).

#### Option A: MySQL (Recommended for Node.js 12+)

If you're using a newer Node.js version, MySQL is the recommended database:

1. Install and start MySQL:
```bash
# On Ubuntu/Debian
sudo apt-get install mysql-server
sudo service mysql start

# On macOS with Homebrew
brew install mysql
brew services start mysql
```

2. Create a database and user:
```bash
# Login to MySQL (you may need sudo)
sudo mysql

# In MySQL prompt:
CREATE DATABASE ghost_dev;
CREATE USER 'ghost'@'localhost' IDENTIFIED BY 'ghostpass';
GRANT ALL PRIVILEGES ON ghost_dev.* TO 'ghost'@'localhost';

# For MySQL 8.0, use legacy authentication:
ALTER USER 'ghost'@'localhost' IDENTIFIED WITH mysql_native_password BY 'ghostpass';
FLUSH PRIVILEGES;
EXIT;
```

3. Create a local configuration file `config.local.json`:
```json
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
```

4. Initialize the database:
```bash
NODE_ENV=local npx knex-migrator init
```

#### Option B: SQLite3 (For Node.js 6-10 only)

For older Node.js versions, SQLite3 works out of the box:

```bash
# Initialize with default SQLite configuration
npx knex-migrator init
```

By default, Ghost uses SQLite3 for local development with the `config.development.json` configuration, so no additional database setup is required for older Node versions.

### 5. Build the Admin Client (Optional)

**Important Note**: The admin client build may fail on Node.js 12+ due to dependency compatibility issues with this version of Ghost (2.21.1). There are two options:

#### Option A: Use Ghost CLI (Recommended for Full Setup)

For a complete Ghost installation with a working admin panel, use the official Ghost CLI:

```bash
npm install ghost-cli -g
ghost install local
```

This will install a compatible version of Ghost with all dependencies properly configured.

#### Option B: Manual Build (Advanced - May Fail on Node.js 12+)

If you want to build the admin client manually for development:

```bash
cd core/client
yarn install --ignore-engines
yarn build
cd ../..
```

**Note**: If the build fails with errors related to workerpool or other dependencies, it's a known compatibility issue with newer Node versions. Consider using Node.js 10.13.0 with nvm:

```bash
nvm install 10.13.0
nvm use 10.13.0
# Then retry the build
```

For this walkthrough, we'll proceed without the admin client to demonstrate the Ghost API and frontend functionality.

### 6. Start the Development Server

You can start Ghost in development mode:

```bash
# If using MySQL with config.local.json:
NODE_ENV=local node index.js

# OR with development debugging (using default config.development.json):
yarn dev

# OR start normally:
yarn start
```

The development server will:
- Start Ghost on http://localhost:2368
- Enable auto-restart on file changes (when using `yarn dev`)
- Enable debug logging (when using `yarn dev`)

**Note**: When using MySQL with `config.local.json`, use `NODE_ENV=local` to load the correct configuration.

### 7. Access Ghost

Once the server is running, you can access:

- **Frontend**: http://localhost:2368
- **Admin Interface**: http://localhost:2368/ghost

On first launch, you'll be prompted to create an admin user account.

## Development Workflow

### Running in Development Mode

Use the `dev` command for active development:

```bash
yarn dev
```

This will:
- Start the server with auto-reload
- Enable debug logging
- Watch for file changes

### Running Tests

```bash
# Run all tests
yarn test

# Run linting
yarn lint

# Run server linting only
yarn lint:server

# Run test linting only
yarn lint:test
```

### Building for Production

```bash
grunt prod
```

## Common Issues & Troubleshooting

### Issue: "Module not found" errors

If you encounter module-related errors:

```bash
yarn fixmodulenotdefined
```

This will:
- Clean the yarn cache
- Remove and reinstall client dependencies

### Issue: Submodules not initialized

If `core/client` directory is empty:

```bash
git submodule update --init --recursive
```

### Issue: Database migration errors

Reset and reinitialize the database:

```bash
rm -rf content/data/*.db
npx knex-migrator init
```

### Issue: Port 2368 already in use

Either kill the process using port 2368 or set a custom port:

```bash
# Check what's using the port (Unix/Mac)
lsof -i :2368

# Or use a custom config
cp config.development.json config.local.json
# Edit config.local.json to change the port
```

### Issue: Node version incompatibility

Ghost requires specific Node.js versions. Check package.json `engines` field:
- Node.js ^6.9.0 || ^8.9.0 || ^10.13.0

Use a version manager like nvm to switch versions:

```bash
nvm install 10.13.0
nvm use 10.13.0
```

## Project Structure

```
Ghost/
├── config.development.json    # Development configuration
├── core/
│   ├── client/               # Ghost Admin (submodule)
│   ├── server/               # Ghost server code
│   └── test/                 # Test files
├── content/
│   ├── themes/               # Themes directory
│   │   └── casper/          # Default theme (submodule)
│   ├── data/                # Database files (SQLite)
│   ├── images/              # Uploaded images
│   └── apps/                # Ghost apps
├── Gruntfile.js             # Build configuration
├── package.json             # Dependencies and scripts
└── index.js                 # Application entry point
```

## Available Scripts

- `yarn start` - Start Ghost in production mode
- `yarn dev` - Start Ghost in development mode with debug logging
- `yarn test` - Run all tests and linting
- `yarn lint` - Run linting checks
- `yarn setup` - Complete setup (install, migrate, build)

## Configuration

Configuration files:
- `config.development.json` - Development environment config
- `config.production.json` - Production environment config (create if needed)

You can override settings by creating a `config.local.json` file.

## Next Steps

1. **Explore the codebase**: Start with `core/server/index.js` to understand the server structure
2. **Read the docs**: https://docs.ghost.org/
3. **Join the community**: https://forum.ghost.org/
4. **Check contributing guidelines**: See `.github/CONTRIBUTING.md`

## Useful Resources

- **Official Documentation**: https://docs.ghost.org/
- **Developer Docs**: https://docs.ghost.org/install/source/
- **API Documentation**: https://api.ghost.org/docs
- **Ghost Forum**: https://forum.ghost.org/
- **GitHub Repository**: https://github.com/TryGhost/Ghost
- **Admin Development**: https://github.com/TryGhost/Ghost-Admin

## Getting Help

If you encounter issues:

1. Check this setup guide for common issues
2. Search the [Ghost Forum](https://forum.ghost.org/)
3. Check [existing GitHub issues](https://github.com/TryGhost/Ghost/issues)
4. Ask for help on the forum

---

Happy developing! 👻
