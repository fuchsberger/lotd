import CSS from '../css/app.scss'

import $ from 'jquery'
import 'bootstrap'
import 'datatables.net'
import 'datatables.net-bs4'
import 'datatables.net-scroller'
import "phoenix_html"

import loadView from './views/loader'

// Executed when page is loaded
$(document).ready(() => {
  const viewName = $('body').data('view')
  const view = loadView(viewName)
  view.mount()
  window.currentView = view
})

$(window).on('unload', () => {
  window.currentView.unmount();
})
