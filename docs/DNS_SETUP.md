# DirectApp - DNS Setup Guide

Complete guide for configuring DNS with Cloudflare for `gapp.coms.no` domain.

**Last Updated:** 2025-10-21

---

## Overview

DirectApp uses the following domain structure:

| Environment | URL | Purpose |
|------------|-----|---------|
| **Production** | `gapp.coms.no` | Live environment |
| **Staging** | `staging-gapp.coms.no` | Testing environment |
| **Local** | `localhost:8055` | Development (no DNS) |

---

## Prerequisites

- Domain: `coms.no` (owned and configured in Cloudflare)
- Dokploy server IP address
- Cloudflare account with access to `coms.no` zone

---

## Step 1: Get Dokploy Server IP

Find your Dokploy server's public IP address:

```bash
# From Dokploy server
curl ifconfig.me

# Or from Dokploy dashboard
# Settings → Server Info → Public IP
```

**Example IP:** `123.45.67.89`

---

## Step 2: Configure DNS in Cloudflare

### Login to Cloudflare

1. Go to https://dash.cloudflare.com
2. Select the `coms.no` zone
3. Click "DNS" in the left sidebar

### Add DNS Records

Add the following A records:

#### Production Record

| Type | Name | Content | Proxy Status | TTL |
|------|------|---------|--------------|-----|
| A | `gapp` | `123.45.67.89` | DNS only (grey cloud) | Auto |

**Result:** `gapp.coms.no` → Dokploy server

#### Staging Record

| Type | Name | Content | Proxy Status | TTL |
|------|------|---------|--------------|-----|
| A | `staging-gapp` | `123.45.67.89` | DNS only (grey cloud) | Auto |

**Result:** `staging-gapp.coms.no` → Dokploy server

### Important: Proxy Status

**Use "DNS only" (grey cloud), NOT "Proxied" (orange cloud)**

Why:
- Traefik handles SSL certificates
- Dokploy manages HTTPS
- Proxied mode interferes with Let's Encrypt

---

## Step 3: Verify DNS Configuration

### Command Line Verification

```bash
# Check production DNS
nslookup gapp.coms.no

# Expected output:
# Name:    gapp.coms.no
# Address: 123.45.67.89

# Check staging DNS
nslookup staging-gapp.coms.no

# Expected output:
# Name:    staging-gapp.coms.no
# Address: 123.45.67.89
```

### Online Verification

Use https://dnschecker.org to verify globally:
- Enter: `gapp.coms.no`
- Type: A
- Check: Should show your server IP worldwide

**Note:** DNS propagation can take up to 24-48 hours, but usually completes in 5-10 minutes.

---

## Step 4: Configure Dokploy

Once DNS is verified, configure domains in Dokploy:

### Production

1. Go to Dokploy dashboard
2. Select `G-app` project
3. Select production compose service
4. Click "Domains" tab
5. Add domain: `gapp.coms.no`
6. Enable "Auto SSL" (Let's Encrypt)
7. Save

### Staging

1. Same project: `G-app`
2. Select staging compose service
3. Click "Domains" tab
4. Add domain: `staging-gapp.coms.no`
5. Enable "Auto SSL"
6. Save

---

## Step 5: SSL Certificate Generation

Dokploy + Traefik will automatically:
1. Request SSL certificate from Let's Encrypt
2. Verify domain ownership (HTTP challenge)
3. Install certificate
4. Enable HTTPS

**Wait time:** 2-5 minutes per domain

### Verify SSL

```bash
# Check production SSL
curl -I https://gapp.coms.no

# Should return:
# HTTP/2 200
# (SSL certificate valid)

# Check staging SSL
curl -I https://staging-gapp.coms.no

# Should return:
# HTTP/2 200
```

---

## Troubleshooting

### DNS Not Resolving

**Problem:** `nslookup gapp.coms.no` returns error

**Solutions:**
1. Check DNS record exists in Cloudflare
2. Verify server IP is correct
3. Wait for propagation (5-10 minutes)
4. Clear local DNS cache:
   ```bash
   sudo systemd-resolve --flush-caches
   ```

### SSL Certificate Not Issued

**Problem:** HTTPS doesn't work after 5 minutes

**Solutions:**

1. **Check proxy status in Cloudflare**
   - Must be "DNS only" (grey cloud)
   - Proxied mode breaks Let's Encrypt

2. **Check ports are open**
   ```bash
   # From another machine
   nc -zv your-server-ip 80
   nc -zv your-server-ip 443
   ```

3. **Check Traefik logs**
   ```bash
   docker logs traefik
   # Look for Let's Encrypt errors
   ```

4. **Verify domain in Dokploy**
   - Check spelling is exact
   - No trailing dots
   - No www prefix

### "Connection Refused" Error

**Problem:** `curl https://gapp.coms.no` returns connection refused

**Solutions:**
1. Check Directus container is running:
   ```bash
   docker ps | grep directapp
   ```

2. Check Traefik is running:
   ```bash
   docker ps | grep traefik
   ```

3. Check container labels in docker-compose:
   ```yaml
   labels:
     - "traefik.enable=true"
     - "traefik.http.routers.directapp.rule=Host(`gapp.coms.no`)"
   ```

### Mixed Content Warnings

**Problem:** Browser shows "Not secure" despite HTTPS

**Solution:** Check `PUBLIC_URL` in environment variables:
```env
PUBLIC_URL=https://gapp.coms.no  # ← Must use https://
```

Redeploy after changing.

---

## DNS Record Summary

Final DNS configuration in Cloudflare:

```
coms.no DNS Records:
┌──────────────────────┬──────┬────────────────┬──────────────┐
│ Name                 │ Type │ Content        │ Proxy Status │
├──────────────────────┼──────┼────────────────┼──────────────┤
│ gapp                 │ A    │ 123.45.67.89   │ DNS only     │
│ staging-gapp         │ A    │ 123.45.67.89   │ DNS only     │
└──────────────────────┴──────┴────────────────┴──────────────┘
```

---

## Optional: WWW Redirect

If you want `www.gapp.coms.no` to redirect to `gapp.coms.no`:

### Add CNAME Record

| Type | Name | Content | Proxy Status | TTL |
|------|------|---------|--------------|-----|
| CNAME | `www.gapp` | `gapp.coms.no` | Proxied (orange) | Auto |

### Add Redirect Rule in Cloudflare

1. Go to "Rules" → "Page Rules"
2. Create rule:
   - URL: `www.gapp.coms.no/*`
   - Setting: Forwarding URL (301)
   - Destination: `https://gapp.coms.no/$1`

---

## Security Best Practices

### Cloudflare Security Features

**Recommended settings:**

1. **SSL/TLS Mode:** Full (strict)
   - Go to SSL/TLS → Overview → Full (strict)

2. **Always Use HTTPS:** On
   - Go to SSL/TLS → Edge Certificates → Always Use HTTPS

3. **Automatic HTTPS Rewrites:** On
   - Same section → Automatic HTTPS Rewrites

4. **Minimum TLS Version:** 1.2
   - Same section → Minimum TLS Version

### Firewall Rules

Consider adding firewall rules:

1. **Rate limiting**
   - Limit: 100 requests per minute per IP
   - Action: Challenge (CAPTCHA)

2. **Geographic blocking** (optional)
   - Block countries based on your requirements

3. **Bot protection**
   - Challenge mode for known bots
   - Allow good bots (Google, etc.)

---

## Maintenance

### Regular Tasks

**Monthly:**
- Verify DNS records are correct
- Check SSL certificates are renewing (auto-renewal at 60 days)
- Review Cloudflare analytics

**Quarterly:**
- Review firewall rules
- Update rate limits if needed
- Check for unused DNS records

### DNS Changes

When changing DNS:
1. Lower TTL to 300 (5 minutes) 24 hours before change
2. Make the change
3. Verify propagation globally
4. Raise TTL back to Auto after 24 hours

---

## Support Resources

### Cloudflare

- **Docs:** https://developers.cloudflare.com/dns/
- **Support:** https://dash.cloudflare.com/support
- **Community:** https://community.cloudflare.com/

### Dokploy

- **Docs:** https://docs.dokploy.com/docs/core/domains
- **GitHub:** https://github.com/Dokploy/dokploy/issues

### Let's Encrypt

- **Docs:** https://letsencrypt.org/docs/
- **Rate limits:** https://letsencrypt.org/docs/rate-limits/
- **Status:** https://letsencrypt.status.io/

---

## Checklist

Before going live, verify:

- [ ] DNS A records created for both domains
- [ ] Proxy status is "DNS only" (grey cloud)
- [ ] DNS resolves globally (check with dnschecker.org)
- [ ] Domains added in Dokploy
- [ ] Auto SSL enabled in Dokploy
- [ ] SSL certificates issued (HTTPS works)
- [ ] PUBLIC_URL uses https:// in environment variables
- [ ] No mixed content warnings
- [ ] Firewall rules configured
- [ ] Cloudflare SSL mode set to "Full (strict)"

---

**Questions?** Check the [Dokploy Deployment Guide](../DOKPLOY_DEPLOYMENT_GUIDE.md) or create an [issue](https://github.com/gumpen-app/directapp/issues).
