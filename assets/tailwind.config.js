const colors = require("tailwindcss/colors")
const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    "../lib/*_web/**/*.*ex",
    "./js/**/*.js"
    // We need to include the Petal dependency so the classes get picked up by JIT.
    // "../deps/petal_components/**/*.*ex"
  ],
  theme: {
    extend: {
      backgroundImage: theme => ({
        'd20': "url('/images/icons.svg#d20')"
      }),
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
