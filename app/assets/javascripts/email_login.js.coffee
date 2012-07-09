(exports ? this).email_login = (elements)->
  $.ajax('/session/lookup', {
         data: {email: elements['email'].value},
      success: credentials
      })

credentials = (data)->
  if data.status == "EXISTS"
    if data.service == "facebook"
      window.location.href = "/auth/facebook?state="+window.location.href
    else
      $('#modal-signin').modal()
  else
    $('#modal-signup').modal()
    $('input#email').val(data.email)
    $('input#username').focus()
