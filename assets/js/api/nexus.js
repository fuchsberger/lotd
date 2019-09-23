// This can be edited to identify your registered app.
const APPLICATION_SLUG = "lotd-inventory-manager"

// Simple method to generate a UUID used as a request ID.
// ID's should ideally be in a standard UUID format
const uuidv4 = () => (
  'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, c => {
    var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  })
)

// Temporarily connects to nexus api to retrieve api-key token
export const connect = () => {
  window.socket = new WebSocket("wss://sso.nexusmods.com");

  // Connect to SSO service
  socket.onopen = () => {

    // Generate or retrieve a request ID and connection token (if we are reconnecting)
    var uuid = null
    var token = null
    uuid = sessionStorage.getItem("uuid")
    token = sessionStorage.getItem("connection_token")

    if (uuid == null) {
      uuid = uuidv4();
      sessionStorage.setItem('uuid', uuid);
    }

    if (uuid !== null) {
      var data = {
        id: uuid,
        token: token,
        protocol: 2
      }

      // Send the SSO request
      socket.send(JSON.stringify(data))

      // Once the request is active, we can send the user to the site to authorise the SSO, passing an identifier for an application.
      window.open("https://www.nexusmods.com/sso?id="+uuid+"&application="+APPLICATION_SLUG);
    }
    else
      console.error("ID was not calculated correctly.")
  }

  // When the client receives a message
  socket.onmessage = e => {
    // All messages from protocol > 2 pass all messages back to the client by using the format type:value
    var response = JSON.parse(e.data);
    if (response && response.success)
    {
      // If the response is valid, the data array will be available. Now we can check for what type of data is being returned.
      if (response.data.hasOwnProperty('api_key')){

        // This is received when the user has approved the SSO request and the SSO is now returning with that user's API key
        console.log("API Key Received: " + response.data.api_key)

        // TODO: send it to server for authentication

        // close right away
        window.socket.close()
      }
    }

    // The SSO  will return an error attribute that can be used for error reporting
    else console.error("Something went wrong! " + response.error)
  }
}
