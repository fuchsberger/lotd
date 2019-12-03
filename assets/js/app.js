import CSS from '../css/app.scss'

import $ from 'jquery'
import 'bootstrap'
import 'datatables.net'
import 'datatables.net-responsive'
import 'timeago'
import "phoenix_html"
import { Channel } from './api'
import { Menu } from './utils'

// Executed when page is loaded
$( document ).ready(function() {

  // enable menu functionality
  Menu.enable()

  // // set up and connect channels
  // Channel.item()

  // join_public_channel()
})
