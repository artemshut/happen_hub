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
          DEFAULT: '#E34717',        // primary
          dark: '#C03D14',           // hover / pressed
          light: '#F87549',          // subtle accents
          soft: '#FEEAE5',           // background or faded states
        },
        accent: {
          red: '#E34717',
          coral: '#FF744D',          // CTA accents or tags
          error: '#D72638',          // error states
          success: '#2ECC71',        // success states
          info: '#227C9D',           // info links
          danger: '#FFE4E6',
          warning: '#FEF3C7',
        },
        neutral: {
          text: '#1F2937',           // main text
          muted: '#6B7280',          // muted labels
          bg: '#FAFAFA',             // app background
          surface: '#FFFFFF',        // cards/panels
          border: '#E5E7EB',         // dividers, outlines
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
