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
        primary: '#ffffff',
        accent: {
          red: '#ff4d4d',
          black: '#333333',
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
