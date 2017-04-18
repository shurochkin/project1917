
# Вешаем события на список династий
window.dinastyInit = () ->
  $('#panel input').each () ->
    $(this).on 'click', (el) ->
      hidePersonDescription()
      elem = $(el.target)
      window.land = elem[0].value
      $('#panel li').removeClass('current')
      elem.parents('li').addClass('current')
      personMaximize()
      $('#lines > g').hide()

      #      $('g[id^="person-"]').hide()
      $('g[id^="person-"]').addClass('person-mini flag-0')
      prsns = $('g[class^="person-'+land+'"]')
#      console.log prsns
      prsnsIDs = prsns.map ()->
        parseInt($(@).attr('id').split('-')[1])

#      console.log 'prsnsIDs', prsnsIDs, 'prsns', prsns

      prsns.show().removeClass('person-mini flag-0')
      personMinimize()

      lines = $('#lines > g[id^="' + land + '-"]')
#      console.log lines
      lines.show()
      $(lines).each ()->
        id1 = parseInt($(@).attr('id').split('-')[1])
        id2 = parseInt($(@).attr('id').split('-')[2])
#        console.log @, 'id1: ', id1, $.inArray(id1, prsnsIDs), 'id2: ', id2, $.inArray(id2, prsnsIDs)
        if $.inArray(id1, prsnsIDs) isnt -1 # or $.inArray(id2, prsnsIDs) isnt -1
          $('#person-'+id1).show()
          if $.inArray(id2, prsnsIDs) is -1
            $('#person-'+id2).show().removeClass('person-mini flag-0').find()
            onePersonMaximize($('#person-'+id2))
#            console.log '+++++++++++   ' + $('#person-'+id2).attr('id') + ' / '+ $('#person-'+id2).attr('class')

        else
          $('#person-'+id1).show().removeClass('person-mini flag-0').find()
          onePersonMaximize($('#person-'+id1))
#          $('#person-'+id2).show().removeClass('person-mini flag-0').find()
#          onePersonMaximize($('#person-'+id2))

#          console.log '!!!!!!!!!!!!!!!!!!!    ' + $('#person-'+id1).attr('id') + ' / '+ $('#person-'+id1).attr('class')

#        if $.inArray(id2, prsnsIDs)
#          $('#person-'+id2).show()

    return

# Сброс к начальному виду
window.resetInit = () ->
  $('#clear-selection').on 'click', () ->
    window.land = null
    window.personSelected = null
    $('#panel li').removeClass('current')
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
  desc.find('.img').attr('src', data.image)
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
