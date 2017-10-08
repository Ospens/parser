$(document).on "turbolinks:load", ->
	$("#spinner").hide()
	$(".form-group").on("ajax:beforeSend", (e) ->
	    $("#spinner").show())
	$(".form-group").on("ajax:success", (e) ->
	    $("#spinner").hide())