(exports ? this).navbar_highlight = (controller_name, action_name)->
  $(".controller-"+controller_name).addClass('active')
  $(".action-"+controller_name+"-"+action_name).addClass('active')
