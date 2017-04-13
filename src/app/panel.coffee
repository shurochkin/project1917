
# Вешаем события на список династий
window.dinastyInit = () ->
  $('#panel input').each () ->
    $(this).on 'click', (el) ->
      hidePersonDescription()
      elem = $(el.target)
      land = elem[0].value
      #      console.log 'land:', land
      personMaximize()
      $('#lines > g').hide()

      #      $('g[id^="person-"]').hide()
      $('g[id^="person-"]').addClass('person-mini flag-0')
      $('g[class^="person-'+land+'"]').show().removeClass('person-mini flag-0')
      personMinimize()

      $('#lines > g[id^="' + land + '-"]').show()
      return
    return

# Сброс к начальному виду
window.resetInit = () ->
  $('#clear-selection').on 'click', () ->
    window.personSelected = null
    showAllPersons()
    showDinastySelector()
    personMaximize()
    hidePersonDescription()
  return

# Отображаем описание персоны
window.showPersonDescription = (data)->
  desc = $('#description')
  desc.find('.description').text('').text(data.description)
  desc.find('.name').text('').text(data.name)
  desc.find('.title').text('').text(data.title)
  desc.show()

# Скрываем и чистим описание персоны
window.hidePersonDescription = ->
  desc = $('#description')
  desc.find('p').text('')
  desc.hide()

# Показываем селектор династий
window.showDinastySelector = ()->
  $('#dinasty').show()

# Показываем селектор династий
window.hideDinastySelector = ()->
  $('#dinasty').hide()
