import CSS from '../css/app.scss'

import $ from 'jquery'
import 'bootstrap'
import Turbolinks from 'turbolinks'
import "phoenix_html"
import socket from './api/socket'
import loadView from './views/loader'

document.addEventListener("turbolinks:load", () => {

  const viewName = $('body').data('view')

  if(window.currentView){

    // unmount previous view
    window.currentView.unmount()

    // if same view is loaded, restore original scroll position
    if(viewName == sessionStorage.lastView) $(window).scrollTop(sessionStorage.scrollTop)
  }

  // load new view
  const view = loadView(viewName)
  view.mount()
  window.currentView = view
})

Turbolinks.start()
