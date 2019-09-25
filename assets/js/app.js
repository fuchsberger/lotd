import CSS from '../css/app.css'

import "phoenix_html"

import $ from 'jquery'
import Turbolinks from 'turbolinks'
import loadView from './views/loader'

document.addEventListener("turbolinks:load", () => {
  if(window.currentView) window.currentView.unmount()
  const view = loadView($('body').data('view'))
  view.mount()
  window.currentView = view
})

Turbolinks.start()
