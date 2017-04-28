DeviceDetector = require 'device-detector'
require './app/functions'
require './app/persons'
require './app/panel'


$(document).ready ->

  window.ua = DeviceDetector.parse(navigator.userAgent)
  $('body').addClass(ua.type + ' ' + ua.os + ' ' + ua.browser)

  if ua.type.toLowerCase() isnt 'desktop'
    $('#toggle-open').on 'click', ()->
      $('#panel').addClass('open')
    $('#toggle-close').on 'click', ()->
      $('#panel').removeClass('open')


  globalInit()

