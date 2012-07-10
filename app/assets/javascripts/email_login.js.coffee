(exports ? this).email_login = (elements)->
  $.ajax('/session/lookup', {
         data: {email: elements['email'].value},
      success: credentials
      })

credentials = (data)->
  console.log(data)
  if data.status == "EXISTS"
    if data.service == "facebook"
      window.location.href = "/auth/facebook?state="+window.location.href
    else
      $('#modal-signin').modal()
      $('#modal-signin input#email').val(data.email)
      $('#modal-signin input#password').focus()
  else
    $('#modal-signup').modal()
    $('#modal-signup input#email').val(data.email)
    $('#modal-signup input#username').focus()
