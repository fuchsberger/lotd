import * as Nexus from './nexus'
import socket from './socket'
import admin from './admin_channel'
import item from './item_channel'
import location from './location_channel'
// import join_public_channel from './public_channel'
// import join_user_channel from './user_channel'
// import join_moderator_channel from './moderator_channel'

const Channel = {
  admin,
  item,
  location
}

export {
  Channel,
  Nexus,
  socket
}
