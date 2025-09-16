const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}'
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
      colors: {
        brand: {
          DEFAULT: '#7C3AED',      // primary violet
          dark: '#6D28D9',         // hover / pressed violet
          light: '#A78BFA',        // subtle violet accents
          soft: '#F3E8FF',         // backgrounds or faded states
          gradientFrom: '#7C3AED', // violet-600
          gradientVia: '#C026D3',  // fuchsia-600
          gradientTo: '#EC4899',   // pink-500
        },
        accent: {
          pink: '#EC4899',         // vibrant pink for CTAs
          fuchsia: '#C026D3',      // strong accent for tags
          violet: '#8B5CF6',       // secondary accent, softer violet
          error: '#EF4444',        // red-500 for errors
          success: '#22C55E',      // green-500 for success
          info: '#3B82F6',         // blue-500 for info links
          warning: '#FACC15',      // yellow-400 for warnings
          danger: '#FEE2E2',       // soft red background
        },
        neutral: {
          text: '#1F2937',         // main text (gray-800)
          muted: '#6B7280',        // muted labels (gray-500)
          bg: '#FAFAFA',           // app background
          surface: '#FFFFFF',      // cards/panels
          border: '#E5E7EB',       // dividers, outlines
        },
      },
      
      animation: {
        fadeIn: "fadeIn 1s ease-in-out",
        slideUp: "slideUp 1s ease-in-out",
        glowPulse: "glowPulse 1.5s ease-in-out infinite",
        scaleUp: "scaleUp 0.4s ease-out",
      },
      keyframes: {
        fadeIn: {
          "0%": { opacity: 0 },
          "100%": { opacity: 1 },
        },
        slideUp: {
          "0%": { transform: "translateY(20px)", opacity: 0 },
          "100%": { transform: "translateY(0)", opacity: 1 },
        },
        glowPulse: {
          "0%, 100%": { boxShadow: "0 0 10px rgba(255, 85, 85, 0.8)" },
          "50%": { boxShadow: "0 0 20px rgba(255, 85, 85, 1)" },
        },
        scaleUp: {
          "0%": { transform: "scale(0.95)" },
          "100%": { transform: "scale(1)" },
        },
      },
    },
  },
  plugins: [
    // require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    // require('@tailwindcss/container-queries'),
  ]
}
