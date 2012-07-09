(exports ? this).email_login = (elements)->
    console.log(elements)
    $.ajax('/session/lookup', {
        data: {email: elements['email'].value},
        success: credentials
        })

credentials = (data)->
    console.log(data)
    if data.status == "EXISTS"
        console.log("OK")
    else
