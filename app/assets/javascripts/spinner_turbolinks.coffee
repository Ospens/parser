$(document).on "turbolinks:load", ->
	$("#spinner").hide()
	$(".form-group").on("ajax:beforeSend", (e) ->
	    $("#spinner").show())
	$(".form-group").on("ajax:success", (e) ->
	    $("#spinner").hide())
	$(".form-group").on("ajax:error", (e) ->
	    $("#spinner").hide()
	    alert('Ошибка. Что-то пошло не так'))