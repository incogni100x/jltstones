# 🚀 Deployment Guide - JLX Gemstone

Complete guide to deploying your project to Vercel with Supabase backend.

## 📋 Prerequisites

- [x] Supabase account and project
- [x] Vercel account
- [x] GitHub repository
- [x] Node.js installed locally

---

## 1️⃣ Supabase Setup

### Step 1: Create Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Click "New Project"
3. Fill in details and create
4. Save your credentials:
   - **Project URL**: `https://xxxxx.supabase.co`
   - **Anon/Public Key**: `eyJhbG...`

### Step 2: Run Database Schema

1. Go to **SQL Editor** in Supabase Dashboard
2. Run the SQL files in this order:
   ```sql
   -- 1. Run schema.sql (creates tables, RLS policies)
   -- 2. Run storage_setup.sql (creates storage bucket)
   ```

### Step 3: Create Storage Bucket

If not done via SQL:
1. Go to **Storage** → **Create Bucket**
2. Name: `order-images`
3. Public bucket: **Yes**
4. Run the RLS policies from `storage_setup.sql`

### Step 4: Create Admin User

1. Go to **Authentication** → **Users** → **Add User**
2. Create your admin account:
   - Email: `admin@jlxgemstone.com`
   - Password: `[secure-password]`
   - Email Confirm: **Yes**

---

## 2️⃣ Local Environment Setup

### Step 1: Update `.env` File

```bash
# Create .env file in project root
cp .env.example .env
```

Edit `.env`:
```env
VITE_SUPABASE_URL=https://xxxxx.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbG...
```

### Step 2: Test Locally

```bash
# Install dependencies
npm install

# Run dev server
npm run dev

# Visit http://localhost:5173
```

### Step 3: Test Admin Login

1. Go to `http://localhost:5173/admin-login.html`
2. Login with your Supabase admin credentials
3. Test creating an order
4. Test logout

---

## 3️⃣ Vercel Deployment

### Option A: Deploy via GitHub (Recommended)

1. **Push to GitHub**
   ```bash
   git add .
   git commit -m "Ready for deployment"
   git push origin main
   ```

2. **Connect to Vercel**
   - Go to [vercel.com](https://vercel.com)
   - Click "New Project"
   - Import your GitHub repository
   - **Framework Preset**: Vite
   - **Root Directory**: `./`
   - **Build Command**: `npm run build`
   - **Output Directory**: `dist`

3. **Add Environment Variables**
   
   In Vercel Project Settings → Environment Variables:
   ```
   VITE_SUPABASE_URL = https://xxxxx.supabase.co
   VITE_SUPABASE_ANON_KEY = eyJhbG...
   ```

4. **Deploy**
   - Click "Deploy"
   - Wait for build to complete
   - Visit your live site!

### Option B: Deploy via CLI

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel

# Set environment variables
vercel env add VITE_SUPABASE_URL
vercel env add VITE_SUPABASE_ANON_KEY

# Deploy to production
vercel --prod
```

---

## 4️⃣ (Optional) Edge Functions Setup

### If using Edge Functions approach:

1. **Install Supabase CLI**
   ```bash
   npm install -g supabase
   ```

2. **Login and Link**
   ```bash
   supabase login
   supabase link --project-ref your-project-ref
   ```

3. **Deploy Edge Function**
   ```bash
   supabase functions deploy create-order
   ```

4. **Update orderService.js**
   
   In `src/js/admin-form.js`, change line:
   ```javascript
   // FROM:
   const result = await createOrderDirect(formData);
   
   // TO:
   const result = await createOrderViaEdgeFunction(formData);
   ```

---

## 5️⃣ Post-Deployment Checklist

### Test Everything:

- [ ] Homepage loads correctly
- [ ] All images display (check `/images/` folder)
- [ ] Navigation works
- [ ] Admin login with Supabase credentials
- [ ] Admin can create orders
- [ ] Orders save to database
- [ ] Image upload works
- [ ] Order tracking page displays order
- [ ] Logout works correctly

### Verify Supabase:

- [ ] Check "Table Editor" → Orders table for data
- [ ] Check "Storage" → order-images for uploaded files
- [ ] Check "Authentication" → Users for admin
- [ ] Check "API Docs" → Auto-generated API

---

## 6️⃣ Custom Domain (Optional)

### In Vercel:

1. Go to Project Settings → Domains
2. Add your custom domain: `jlxgemstone.com`
3. Follow DNS instructions from your domain registrar
4. Wait for DNS propagation (5-30 minutes)

---

## 🔧 Troubleshooting

### Issue: "Invalid Supabase URL"

**Fix**: Check `.env` file and Vercel environment variables are set correctly.

### Issue: "Not authenticated"

**Fix**: 
1. Clear browser cache
2. Check admin user exists in Supabase Auth
3. Verify RLS policies are enabled

### Issue: Images not displaying

**Fix**: 
1. Check all images are in `/public/images/` folder
2. Rebuild and redeploy: `npm run build && vercel --prod`

### Issue: Form submission fails

**Fix**:
1. Check browser console for errors
2. Verify database schema is correct
3. Check RLS policies allow inserts for authenticated users

---

## 📊 Monitoring

### Vercel Dashboard:
- View deployment logs
- Monitor site performance
- Check analytics

### Supabase Dashboard:
- Monitor database usage
- Check storage usage
- View API logs
- Monitor authentication

---

## 🔐 Security Checklist

- [x] Environment variables in `.env` (not committed to git)
- [x] `.gitignore` includes `.env`
- [x] RLS policies enabled on all tables
- [x] Storage bucket has proper policies
- [x] Admin credentials are strong
- [x] HTTPS enabled (automatic on Vercel)
- [x] CORS configured correctly

---

## 📞 Support

- **Vercel Docs**: [vercel.com/docs](https://vercel.com/docs)
- **Supabase Docs**: [supabase.com/docs](https://supabase.com/docs)
- **Vite Docs**: [vitejs.dev](https://vitejs.dev)

---

## 🎉 You're Live!

Your site should now be deployed and fully functional!

**Production URLs:**
- Main Site: `https://your-project.vercel.app`
- Admin Login: `https://your-project.vercel.app/admin-login.html`
- Track Order: `https://your-project.vercel.app/order.html`

