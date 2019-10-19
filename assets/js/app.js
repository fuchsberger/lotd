import CSS from '../css/app.scss'

import $ from 'jquery'
import 'bootstrap'
import 'datatables.net'
import 'datatables.net-responsive'
import 'timeago'
import "phoenix_html"
import { join_public_channel } from './api'
import { Menu } from './utils'

// Executed when page is loaded
$( document ).ready(function() {

  // enable menu functionality
  Menu.enable()

  // set up and connect channels
  join_public_channel()
})
