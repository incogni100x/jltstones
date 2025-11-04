/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./*.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        'jlx-green': '#009961',
      },
      fontFamily: {
        'instrument': ['Instrument Serif', 'serif'],
        'helvetica': ['Helvetica Neue', 'sans-serif'],
      },
    },
  },
  plugins: [],
}

