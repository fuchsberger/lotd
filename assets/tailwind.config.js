const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    "../lib/*_web/**/*.*ex",
    "./js/**/*.js"
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter', ...defaultTheme.fontFamily.sans],
      }
    }
  },
  variants: {},
  plugins: [
    require('@tailwindcss/forms')
  ]
};
