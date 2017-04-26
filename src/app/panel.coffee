
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

window.interesInit = ()->
  int = $('#interes')
  interes_data.forEach (i)->
    data1 = getPersonData(i.id1)
    data2 = getPersonData(i.id2)
#    console.log i, data1, data2
    pair = $('<div>').addClass('pair')
    pair.append(showOnePerson(data1))
    pair.append(showOnePerson(data2))
    pair.on 'click', ()->
      window.personSelected = window.personSelected2 = null
      $('#person-'+i.id1).trigger('click')
      $('#person-'+i.id2).trigger('click')
    int.append(pair)


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
window.showPersonDescription = (data1, data2)->
#  console.log 'showPersonDescription: '
#  console.log 'data1:', data1
#  console.log 'data2:', data2
  desc = $('#description').removeClass('show-link')
  pair = $('#pair-desc').text('')
  pers1 = $('#person1').html('')
  pers2 = $('#person2').html('')

  pers1.append(showOnePerson(data1))

  if data2
    pers2.append(showOnePerson(data2))
    desc.addClass('show-link')
  else
    pair.text(if lang is 'ru' then data1.descriptionru else data1.descriptionen)


  if data1 and data2
    int_data = interes_data.find (item)->
      if item.id1 is data1.id and item.id1 is data1.id then true else false
    if int_data
      pair.text(int_data.description)

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

window.showOnePerson = (data)->
  flag = getFlag(data)

  if lang is 'ru'
    name = data.nameru
    title = data.titleru
    description = data.descriptionru
  else
    name = data.nameen
    title = data.titleen
    description = data.descriptionen

  img_src = if data.img then data.img else 'img/def-'+ (if data.sex is 0 then 'wo' else '') + 'man.png'
  person = $('<div>').addClass('person')
  person.append($('<div>').addClass('img '+flag.name).append($('<img>').attr('src', img_src)))
  person.append($('<p>').addClass('name').text(name))
  person.append($('<p>').addClass('title').text(title))
  #  person.append($('<p>').addClass('title').text(description))

  #  desc.find('.description').text('').text(data.description)
  #  desc.find('.name').text('').text(data.name)
  #  desc.find('.title').text('').text(data.title)
  #  desc.find('.img').attr('src', data.image)
  person