// Simple method to generate a standard UUID used as a request ID.
const uuidv4 = () => (
  'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, c => {
    var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16)
  })
)

export default () => {

  const socket = new WebSocket("wss://sso.nexusmods.com")

  // Connect to SSO service
  socket.onopen = () => {
    const uuid = uuidv4()

    // Send the SSO request
    socket.send(JSON.stringify({ id: uuid, token: null, protocol: 2 }))

    // Once the request is active, we can send the user to the site to authorise the SSO, passing an identifier for an application.
    window.open(`https://www.nexusmods.com/sso?id=${uuid}&application=lotd-inventory-manager`)
  }

  // When the client receives a message
  socket.onmessage = e => {
    // pass all messages back to the client by using the format type:value
    const res = JSON.parse(e.data)

    if (res && res.success){

      // If the response is valid, check the data for the api_key
      if (res.data.hasOwnProperty('api_key')){

        // Send API key to webserver that will then try to connect with it and authenticate
        document.getElementById("login-form_api_key").value = res.data.api_key
        document.getElementById("login-form").submit()

        // close right away
        socket.close()
      }
    }
    // The SSO  will return an error attribute that can be used for error reporting
    else console.error("Nexus Error: " + res.error)
  }
}
