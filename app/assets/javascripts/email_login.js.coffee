(exports ? this).email_login = (form_elements)->
  $.ajax('/session/lookup', {
         data: {email: form_elements['email'].value},
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
    if data.email.length > 0
      $('#modal-signup input#email').val(data.email)
      $('#modal-signup input#username').focus()
    else
      $('#modal-signup input#email').focus()

(exports ? this).password_login = (form_elements)->
  $('#modal-signin fieldset#password').removeClass('error')
  $('#modal-signin fieldset#password span').html("")
  data = {email: form_elements['email'].value, password: form_elements['password'].value}
  $.ajax('/session/login', {
         data: data,
         type: 'post',
      success: do_login
      })

do_login = (data)->
  if data.status == "OK"
    window.location.href = "/"
  else
    $('#modal-signin fieldset#password-group').addClass('error')
    $('#modal-signin fieldset#password-group span').html("Incorrect password")

(exports ? this).user_create = (form_elements)->
  data = {
           email: form_elements['email'].value,
           username: form_elements['username'].value,
           password: form_elements['password'].value }
  $.ajax('/users', {
         data: data,
         type: 'post',
      success: do_create
      })

do_create = (data)->
  if data.status == "OK"
    window.location.href = "/"
  if data.status == "BADPASS"
    $('#modal-signup #password-group').addClass('error')
    $('#modal-signup #password-help').html("Invalid password")
