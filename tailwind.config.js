module.exports = {
  content: [
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js'
  ],
  theme: {
    extend: {
      colors: {
        brand: '#9333EA',
        'brand-light': '#C084FC',
        'brand-dark': '#7C3AED',
        'brand-soft': '#EDE9FE',
        'brand-gradientFrom': '#9333EA',
        'brand-gradientVia': '#A855F7',
        'brand-gradientTo': '#EC4899',
        neutral: {
          bg: '#F8FAFC',
          surface: '#FFFFFF',
          text: '#1F2937',
          muted: '#64748B',
          border: '#E2E8F0'
        }
      }
    }
  }
}
