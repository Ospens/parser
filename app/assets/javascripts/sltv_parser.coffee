$(document).on "turbolinks:load", ->
  $("#copy_table").hide()
  $(".form-group").on("ajax:success", (e) ->
    $("#copy_table").show())
  $('#copy_table').click ->
    el = document.getElementById('teams_sltv')
    body = document.body
    range = undefined
    sel = undefined
    if document.createRange and window.getSelection
      range = document.createRange()
      sel = window.getSelection()
      sel.removeAllRanges()
      try
        range.selectNodeContents el
        sel.addRange range
      catch e
        range.selectNode el
        sel.addRange range
    else if body.createTextRange
      range = body.createTextRange()
      range.moveToElementText el
      range.select()
    document.execCommand 'Copy'
