# JLX Gemstone Website

A modern, responsive website for JLX Gemstones and Consultant, built with Vite and Tailwind CSS.

## Features

- Responsive design
- Homepage with hero, about, features, achievements, stones gallery, and contact sections
- Order tracking page
- Admin portal with login and dashboard
- Built with Vite for fast development and optimized production builds
- Tailwind CSS for styling

## Getting Started

### Prerequisites

- Node.js (v18 or higher recommended)
- npm or yarn

### Installation

1. Clone the repository:
```bash
git clone https://github.com/incogni100x/jltstones.git
cd jlxgemstone
```

2. Install dependencies:
```bash
npm install
```

3. Start the development server:
```bash
npm run dev
```

The site will be available at `http://localhost:3000`

### Building for Production

To create a production build:

```bash
npm run build
```

The built files will be in the `dist` directory.

### Preview Production Build

To preview the production build locally:

```bash
npm run preview
```

## Project Structure

```
jlxgemstone/
├── public/
│   └── images/            # All images (logo, hero, stones, etc.)
├── src/
│   └── style.css          # Tailwind CSS styles
├── index.html             # Homepage
├── order.html             # Order tracking page
├── admin.html             # Admin dashboard
├── admin-login.html       # Admin login page
├── vite.config.js         # Vite configuration
├── tailwind.config.js     # Tailwind CSS configuration
├── postcss.config.js      # PostCSS configuration
└── package.json           # Project dependencies
```

## Deployment

This project can be deployed to Vercel, Netlify, or any other static hosting service.

### Deploying to Vercel

1. Push your code to GitHub
2. Import the project on Vercel
3. Vercel will automatically detect Vite and use the correct build settings

## Admin Access

To access the admin portal, navigate to `/admin-login.html` and use any username/password combination (for development only - implement proper authentication in production).

## License

Copyright © 2025 JLX Gemstones and Consultant. All rights reserved.

