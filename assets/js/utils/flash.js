import $ from 'jquery'

const container = (msg, color) => {
  $('div.alert').remove()
  $('main').before(
    `<div class="alert alert-${color} alert-dismissible fade show" role="alert">
      ${msg}
      <button type="button" class="close" data-dismiss="alert" aria-label="Close">
        <span aria-hidden="true">&times;</span>
      </button>
    </div>`
  )
}

const error = msg => container(msg, 'danger')
const info = msg => container(msg, 'info')

export {
  error,
  info
}
