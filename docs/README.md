# DirectApp Documentation

Complete documentation for DirectApp development, deployment, and operations.

**Last Updated:** 2025-10-21

---

## 📚 Quick Links

### Getting Started
- **[Environment Setup](./ENVIRONMENT_SETUP.md)** ⭐ Start here for configuration
- **[Development Workflow](./DEVELOPMENT_WORKFLOW.md)** ⭐ Day-to-day development
- **[DNS Setup](./DNS_SETUP.md)** - Cloudflare DNS configuration

### Deployment
- **[Dokploy Integration](./DOKPLOY_INTEGRATION_SUMMARY.md)** ⭐ Complete integration overview
- **[GitHub Secrets Setup](./GITHUB_SECRETS_SETUP.md)** - CI/CD configuration
- **[Environment Config Summary](./ENVIRONMENT_CONFIG_SUMMARY.md)** - Current status

### Legacy Docs (Superseded)
- ~~DOKPLOY_SETUP.md~~ → See [Environment Setup](./ENVIRONMENT_SETUP.md)
- ~~DOKPLOY_DEPLOYMENT_GUIDE.md~~ → See [Dokploy Integration](./DOKPLOY_INTEGRATION_SUMMARY.md)

---

## 📋 Documentation Index

### 1. Setup & Configuration

| Document | Purpose | Audience |
|----------|---------|----------|
| [Environment Setup](./ENVIRONMENT_SETUP.md) | Complete environment configuration guide | Developers, DevOps |
| [Environment Config Summary](./ENVIRONMENT_CONFIG_SUMMARY.md) | Current environment status & checklists | All |
| [DNS Setup](./DNS_SETUP.md) | Cloudflare DNS configuration | DevOps |
| [GitHub Secrets Setup](./GITHUB_SECRETS_SETUP.md) | CI/CD secrets configuration | DevOps |

### 2. Development

| Document | Purpose | Audience |
|----------|---------|----------|
| [Development Workflow](./DEVELOPMENT_WORKFLOW.md) | Complete development workflow | Developers |
| [Dokploy Integration Summary](./DOKPLOY_INTEGRATION_SUMMARY.md) | Deployment pipeline overview | All |

### 3. Architecture & Planning

| Document | Purpose | Audience |
|----------|---------|----------|
| [../GUMPEN_SYSTEM_DESIGN.md](../GUMPEN_SYSTEM_DESIGN.md) | System architecture | All |
| [../.claude/PRODUCTION_ROADMAP.md](../.claude/PRODUCTION_ROADMAP.md) | Development roadmap | Product, Dev |
| [../.claude/SCHEMA_ANALYSIS.md](../.claude/SCHEMA_ANALYSIS.md) | Database analysis | Developers |

### 4. Project Management

| Document | Purpose | Audience |
|----------|---------|----------|
| [../.claude/PROJECT_SETUP.md](../.claude/PROJECT_SETUP.md) | Workflow system setup | Developers |
| [../.claude/commands/README.md](../.claude/commands/README.md) | Available workflow commands | Developers |

---

## 🚀 Quick Start Guides

### For Developers (First Time)

```bash
# 1. Setup environment
cp .env.development.example .env

# 2. Start local development
pnpm dev

# 3. Access Directus
open http://localhost:8055/admin
# Login: admin@dev.local / DevPassword123!

# 4. Read the workflow guide
cat docs/DEVELOPMENT_WORKFLOW.md
```

**Next:** [Development Workflow](./DEVELOPMENT_WORKFLOW.md)

### For DevOps (First Time)

```bash
# 1. Review environment configuration
cat docs/ENVIRONMENT_SETUP.md

# 2. Configure GitHub secrets
cat docs/GITHUB_SECRETS_SETUP.md

# 3. Configure DNS
cat docs/DNS_SETUP.md

# 4. Deploy to staging
pnpm deploy:staging

# 5. Deploy to production
pnpm deploy:production
```

**Next:** [Environment Setup](./ENVIRONMENT_SETUP.md)

### For Product/Management

```bash
# Review system design
cat GUMPEN_SYSTEM_DESIGN.md

# Review development roadmap
cat .claude/PRODUCTION_ROADMAP.md

# Check current status
cat docs/ENVIRONMENT_CONFIG_SUMMARY.md
```

---

## 📖 Documentation Structure

```
directapp/
├── docs/                                   # Main documentation
│   ├── README.md                           # ⭐ This file (start here)
│   ├── ENVIRONMENT_SETUP.md                # ⭐ Environment configuration
│   ├── DEVELOPMENT_WORKFLOW.md             # ⭐ Development guide
│   ├── DOKPLOY_INTEGRATION_SUMMARY.md      # ⭐ Deployment overview
│   ├── ENVIRONMENT_CONFIG_SUMMARY.md       # Current config status
│   ├── GITHUB_SECRETS_SETUP.md             # CI/CD setup
│   └── DNS_SETUP.md                        # DNS configuration
│
├── .claude/                                # Project workflow system
│   ├── PRODUCTION_ROADMAP.md               # Development roadmap
│   ├── SCHEMA_ANALYSIS.md                  # Database analysis
│   ├── PROJECT_SETUP.md                    # Workflow setup
│   └── commands/                           # Workflow commands
│       ├── README.md                       # Command index
│       ├── deploy.md                       # /deploy command
│       └── sync-schema.md                  # /sync-schema command
│
├── GUMPEN_SYSTEM_DESIGN.md                 # System architecture
├── README.md                               # Main readme
└── DOKPLOY_*.md                            # ⚠️ Legacy (see docs/)
```

---

## 🔄 Documentation Updates

### Recent Changes (2025-10-21)

**Added:**
- ✅ Complete Dokploy integration documentation
- ✅ Environment setup guide
- ✅ Development workflow guide
- ✅ GitHub secrets setup guide
- ✅ DNS configuration guide
- ✅ Environment configuration summary

**Superseded:**
- ⚠️ `DOKPLOY_SETUP.md` → Use `docs/ENVIRONMENT_SETUP.md`
- ⚠️ `DOKPLOY_DEPLOYMENT_GUIDE.md` → Use `docs/DOKPLOY_INTEGRATION_SUMMARY.md`

**Status:**
- Old docs remain for reference but marked as legacy
- All new docs in `docs/` directory
- Clear migration path documented

---

## 🎯 Common Tasks

### Development

| Task | Command | Documentation |
|------|---------|---------------|
| Start local dev | `pnpm dev` | [Development Workflow](./DEVELOPMENT_WORKFLOW.md) |
| Build extensions | `pnpm extensions:build` | [Development Workflow](./DEVELOPMENT_WORKFLOW.md) |
| Sync schema | `pnpm sync-schema local staging` | [Development Workflow](./DEVELOPMENT_WORKFLOW.md) |

### Deployment

| Task | Command | Documentation |
|------|---------|---------------|
| Deploy staging | `pnpm deploy:staging` | [Dokploy Integration](./DOKPLOY_INTEGRATION_SUMMARY.md) |
| Deploy production | `pnpm deploy:production` | [Dokploy Integration](./DOKPLOY_INTEGRATION_SUMMARY.md) |
| Seed staging | `pnpm seed:staging` | [Environment Setup](./ENVIRONMENT_SETUP.md) |

### Configuration

| Task | Guide | Documentation |
|------|-------|---------------|
| Setup environments | All environments | [Environment Setup](./ENVIRONMENT_SETUP.md) |
| Configure DNS | Cloudflare | [DNS Setup](./DNS_SETUP.md) |
| Setup CI/CD | GitHub Actions | [GitHub Secrets](./GITHUB_SECRETS_SETUP.md) |

---

## 🔍 Finding Documentation

### By Role

**Developer:**
1. [Development Workflow](./DEVELOPMENT_WORKFLOW.md)
2. [Environment Setup](./ENVIRONMENT_SETUP.md) (local section)
3. [../.claude/commands/README.md](../.claude/commands/README.md)

**DevOps:**
1. [Environment Setup](./ENVIRONMENT_SETUP.md)
2. [Dokploy Integration](./DOKPLOY_INTEGRATION_SUMMARY.md)
3. [DNS Setup](./DNS_SETUP.md)
4. [GitHub Secrets](./GITHUB_SECRETS_SETUP.md)

**Product Manager:**
1. [../GUMPEN_SYSTEM_DESIGN.md](../GUMPEN_SYSTEM_DESIGN.md)
2. [../.claude/PRODUCTION_ROADMAP.md](../.claude/PRODUCTION_ROADMAP.md)
3. [Environment Config Summary](./ENVIRONMENT_CONFIG_SUMMARY.md)

### By Topic

**Environments:**
- [Environment Setup](./ENVIRONMENT_SETUP.md)
- [Environment Config Summary](./ENVIRONMENT_CONFIG_SUMMARY.md)

**Deployment:**
- [Dokploy Integration Summary](./DOKPLOY_INTEGRATION_SUMMARY.md)
- [Development Workflow](./DEVELOPMENT_WORKFLOW.md#deployment-pipeline)

**Infrastructure:**
- [DNS Setup](./DNS_SETUP.md)
- [GitHub Secrets Setup](./GITHUB_SECRETS_SETUP.md)

**Development:**
- [Development Workflow](./DEVELOPMENT_WORKFLOW.md)
- [../.claude/commands/README.md](../.claude/commands/README.md)

---

## 💡 Tips

### Finding Information Fast

```bash
# Search all docs for a keyword
grep -r "keyword" docs/

# List all markdown files
find docs/ -name "*.md"

# View documentation index
cat docs/README.md
```

### Keeping Docs Updated

- Update docs when making changes
- Mark old docs as superseded (don't delete immediately)
- Keep this index updated
- Use clear file names
- Link between related docs

### Contributing to Docs

1. Follow existing structure
2. Use clear headings
3. Include examples
4. Link to related docs
5. Update this index when adding new docs

---

## 📞 Support

### Documentation Issues

- Missing documentation: Create issue
- Outdated information: Create PR
- Unclear instructions: Create issue
- Suggestions: Create issue

### Getting Help

- Create issue: https://github.com/gumpen-app/directapp/issues
- Check `.claude/` directory for project-specific docs
- Review workflow commands: `cat .claude/commands/README.md`

---

## ✅ Checklist for New Team Members

### First Day

- [ ] Read [README.md](../README.md)
- [ ] Read [Development Workflow](./DEVELOPMENT_WORKFLOW.md)
- [ ] Set up local environment: [Environment Setup](./ENVIRONMENT_SETUP.md)
- [ ] Access staging environment
- [ ] Join GitHub repository

### First Week

- [ ] Review [System Design](../GUMPEN_SYSTEM_DESIGN.md)
- [ ] Review [Production Roadmap](../.claude/PRODUCTION_ROADMAP.md)
- [ ] Learn workflow commands: [Commands README](../.claude/commands/README.md)
- [ ] Make first contribution
- [ ] Test deployment to staging

### First Month

- [ ] Understand full deployment pipeline
- [ ] Configure DNS (if DevOps)
- [ ] Set up monitoring
- [ ] Review security practices
- [ ] Contribute to documentation

---

**Questions?** Start with the [Environment Setup Guide](./ENVIRONMENT_SETUP.md) or create an [issue](https://github.com/gumpen-app/directapp/issues).
