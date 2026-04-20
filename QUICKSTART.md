# Quick Start - Local Development

This guide helps you quickly set up Ghost for local development.

## Automated Setup (Recommended)

Use the automated setup script:

```bash
./setup-local.sh
```

This script will:
1. Initialize git submodules (admin client and theme)
2. Install all dependencies
3. Set up your database (MySQL or SQLite3)
4. Initialize the database schema
5. Provide instructions to start the server

## Manual Setup

If you prefer manual setup, see the comprehensive [SETUP.md](SETUP.md) guide.

## Quick Commands

```bash
# Start Ghost with MySQL (after running setup script with MySQL option)
NODE_ENV=local node index.js

# Start Ghost with SQLite3 (default)
node index.js
# OR
yarn start

# Start in development mode with auto-reload
yarn dev
```

## What Works

✅ **Frontend Blog**: http://localhost:2368
- Fully functional blog interface
- Default Casper theme
- Sample posts and content
- RSS feeds
- Tag and author pages

✅ **Ghost API**
- Content API for reading published content
- Admin API (authentication required)

⚠️ **Admin Panel**: May not work on Node.js 12+ due to build compatibility issues
- For full admin functionality, use [Ghost CLI](https://ghost.org/docs/ghost-cli/) or Node.js 10.13

## Accessing Ghost

Once running:
- **Blog Homepage**: http://localhost:2368
- **Admin Panel**: http://localhost:2368/ghost (if admin client is built)
- **API Documentation**: https://ghost.org/docs/api/

## Version Note

This is Ghost 2.21.1, designed for Node.js 6.9-10.13. For the latest Ghost with full compatibility on modern Node.js versions:

```bash
npm install ghost-cli -g
ghost install local
```

## Troubleshooting

See [SETUP.md](SETUP.md) for detailed troubleshooting steps.

## Next Steps

1. **Explore the blog**: Visit http://localhost:2368
2. **Read the documentation**: Check out [SETUP.md](SETUP.md) for detailed configuration
3. **Customize themes**: Edit files in `content/themes/casper/`
4. **Learn the API**: https://ghost.org/docs/api/
5. **Join the community**: https://forum.ghost.org/

---

For more information, see:
- [SETUP.md](SETUP.md) - Comprehensive setup guide
- [README.md](README.md) - Ghost project information
- [CONTRIBUTING.md](.github/CONTRIBUTING.md) - Contribution guidelines
