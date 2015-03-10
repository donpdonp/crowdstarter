function time_fixups() {
  $('time').each(function(){
    var datetime = new XDate($(this).attr('datetime'))
    var formatted = datetime.toString($(this).attr('data-format'))
    $(this).html(formatted)
  })
}