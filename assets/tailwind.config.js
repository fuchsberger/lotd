// const { colors } = require('tailwindcss/defaultTheme')

module.exports = {
  future: {
    // removeDeprecatedGapUtilities: true,
    // purgeLayersByDefault: true,
  },
  purge: [
    "../**/*.html.eex",
    "../**/*.html.leex",
    "../**/views/**/*.ex",
    "../**/live/**/*.ex",
    "./js/**/*.js"
  ],
  theme: {
    extend: {
      fontFamily: {
        'menu': ['Arial Black', 'Gadget', 'sans-serif']
      }
    }
  },
  variants: {},
  plugins: [],
}

/*
  Nexus Colors


  // gray: {
  //   100: '#e6e6e6',   // text-light
  //   700: '#3e3e3e',
  //   800: '#0e191a',   // dark
  //   900: '#1c1c1c'    // background
  // }
  --themed-link-color: #58acfa;
  --themed-alert-color--fadeout: rgba(232,26,63,0.15);
  --themed-alert-color--hover: #8e0e25;
  --text-color--light: #e6e6e6;
  --text-color--dark: #3a3a3a;
  --button-label--light: #fff;
  --button-label--dark: #0e191a;
  --themed-page-background--secondary: #3e3e3e;
  --themed-page-background--windows: #3e3e3e;
  --themed-text-color: #e6e6e6;
  --themed-text-color--hover: #b3b3b3;
  --themed-text-color--secondary: rgba(230,230,230,0.6);
  --themed-link-color--hover: #077ae5;
  --themed-link-color--fadeout: rgba(88,172,250,0.15);
  --themed-link-color--active: rgba(7,122,229,0.15);
  --themed-button-background--hover: #4f4f4f;
  --themed-border-color: #8e8e8e;
  --themed-overlay-color: rgba(255,255,255,0.5);
  --themed-window-box-shadow: 0 3px 12px 0 rgba(0,0,0,0.3);
*/
