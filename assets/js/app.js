import CSS from '../css/app.css'

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

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
// import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"

// Simple method to generate a UUID used as a request ID. ID's should ideally be in a standard UUID format
// function uuidv4() {
//   return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
//       var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
//       return v.toString(16);
//   });
// }

// // This can be edited to identify your registered app.
// var application_slug = "Vortex";

// function connect() {
//     window.socket = new WebSocket("wss://sso.nexusmods.com");
//     // Connect to SSO service
//     socket.onopen = function (event) {
//         console.log("CONNECTION TO SSO OPEN;");
//         // Generate or retrieve a request ID and connection token (if we are reconnecting)
//         var uuid = null;
//         var token = null;
//         uuid = sessionStorage.getItem("uuid");
//         token = sessionStorage.getItem("connection_token");
//         if (uuid == null) {
//             uuid = uuidv4();
//             sessionStorage.setItem('uuid', uuid);
//         }
//         if (uuid !== null) {
//             var data = {
//                 id: uuid,
//                 token: token,
//                 protocol: 2
//             };
//             // Send the SSO request
//             socket.send(JSON.stringify(data));
//             // Once the request is active, we can send the user to the site to authorise the SSO, passing an
//             // identifier for an application.
//             window.open("https://www.nexusmods.com/sso?id="+uuid+"&application="+application_slug);
//         }
//         else
//             console.error("ID was not calculated correctly.")
//     };
//     // When the client is closed, attempt to reconnect - this will use the same connection token as the initial request
//     socket.onclose = function(event) {
//         console.log("CONNECTION CLOSED;")
//         setTimeout(connect(), 5000);
//     }
//     // When the client receives a message
//     socket.onmessage = function(event) {
//         // All messages from protocol > 2 pass all messages back to the client by using the format type:value
//         var response = JSON.parse(event.data);
//         if (response && response.success)
//         {
//             // If the response is valid, the data array will be available. Now we can check for what type of data is being returned.
//             if (response.data.hasOwnProperty('connection_token'))
//             {
//                 // store the connection token in case we need to reconnect
//                 sessionStorage.setItem('connection_token', response.data.connection_token);
//             }
//             else if (response.data.hasOwnProperty('api_key'))
//             {
//                 // This is received when the user has approved the SSO request and the SSO is now returning with that user's API key
//                 console.log("API Key Received: " + response.data.api_key);
//             }
//         }
//         else
//         {
//             // The SSO  will return an error attribute that can be used for error reporting
//             console.error("Something went wrong! " + response.error)
//         }
//     }
// }
// connect();
