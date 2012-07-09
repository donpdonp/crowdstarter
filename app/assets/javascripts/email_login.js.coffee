(exports ? this).email_login = (elements)->
  $.ajax('/session/lookup', {
         data: {email: elements['email'].value},
      success: credentials
      })

credentials = (data)->
  if data.status == "EXISTS"
    if data.service == "facebook"

    else
      $('#modal-signin').modal()
  else
    $('#modal-signup').modal()
