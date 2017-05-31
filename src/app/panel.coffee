window.getDinastyListItem = (code, mess) ->
  input = $('<input>').attr('type', 'radio').attr('name', 'radio').attr('value', code)
  label = $('<label>').text(' ' + messages[mess][window.lang]).prepend(input)
  li = $('<li>').addClass(code).append(label)
  return li


# Вешаем события на список династий
window.dinastyInit = () ->
  $dinasty = $('<div>').attr('id', 'dinasty')


  $ul = $('<ul>').attr('id', 'land-switcher')
  $ul.append(getDinastyListItem('en', 'GreatBritain'))
  $ul.append(getDinastyListItem('de', 'Germany'))
  $ul.append(getDinastyListItem('ru', 'Russia'))
  $ul.append(getDinastyListItem('gr', 'DenmarkGreece'))

  $description = $('<div>').attr('id', 'description')
  $description.append($('<h3>').text(messages['Description'][window.lang]))
  $description.append($('<div>').attr('id', 'person1'))
  $description.append($('<div>').attr('id', 'person2'))
  $description.append($('<div>').attr('id', 'pair-desc'))

  $button = $('<button>').attr('id', 'clear-selection').attr('type', 'reset').text(messages['Clear'][window.lang])
  $dinasty.append $('<h3>').text(messages['Dynasties'][window.lang]).append($ul)


  $('#panel form').append($dinasty).append($description).append($button)


  $('#dinasty input').each () ->
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
      prsns = $('g[class^="person-' + land + '"]')
      #      console.log prsns
      prsnsIDs = prsns.map ()->
        toInt($(@).attr('id').split('-')[1])

      #      console.log 'prsnsIDs', prsnsIDs, 'prsns', prsns

      prsns.show().removeClass('person-mini flag-0')
      personMinimize()

      lines = $('#lines > g[id^="' + land + '-"]')
      #      console.log lines
      lines.show()
      $(lines).each ()->
        id1 = toInt($(@).attr('id').split('-')[1])
        id2 = toInt($(@).attr('id').split('-')[2])
        #        console.log @, 'id1: ', id1, $.inArray(id1, prsnsIDs), 'id2: ', id2, $.inArray(id2, prsnsIDs)
        if $.inArray(id1, prsnsIDs) isnt -1 # or $.inArray(id2, prsnsIDs) isnt -1
          $('#person-' + id1).show()
          if $.inArray(id2, prsnsIDs) is -1
            $('#person-' + id2).show().removeClass('person-mini flag-0').find()
            onePersonMaximize($('#person-' + id2))
#            console.log '+++++++++++   ' + $('#person-'+id2).attr('id') + ' / '+ $('#person-'+id2).attr('class')

        else
          $('#person-' + id1).show().removeClass('person-mini flag-0').find()
          onePersonMaximize($('#person-' + id1))
      #          $('#person-'+id2).show().removeClass('person-mini flag-0').find()
      #          onePersonMaximize($('#person-'+id2))

      #          console.log '!!!!!!!!!!!!!!!!!!!    ' + $('#person-'+id1).attr('id') + ' / '+ $('#person-'+id1).attr('class')

      #        if $.inArray(id2, prsnsIDs)
      #          $('#person-'+id2).show()
      setTimeout () ->
        $('#panel').removeClass('open')
      , 300
      panZoom.resetZoom()

    return

window.interesInit = ()->
  int = $('#interes')
  int.append($('<h4>').text(messages['MostInteresting'][window.lang]))
  interes_data.forEach (i)->
    if i.show?
      data1 = getPersonData(i.id1)
      data2 = getPersonData(i.id2)
      #      console.log data1, data2
      pair = $('<div>').addClass('pair')
      pair.append(showOnePerson(data1))
      pair.append(showOnePerson(data2))
      pair.on 'click', ()->
        window.personSelected = window.personSelected2 = null
        $('#person-' + i.id1).trigger('click')
        $('#person-' + i.id2).trigger('click')
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

  pers1.append(showOnePerson(data1, true))

  if data2
    pers2.append(showOnePerson(data2, true))
    desc.addClass('show-link')
  else
    pers2.text(data1['description'+window.lang])
    note = $('<p>').addClass('note').text(messages['NowYouSee'][window.lang])
    pair.append(note)


  if data1 and data2
    int_data = interes_data.find (item)->
      if item.id1 is data1.id and item.id2 is data2.id then true else false
    if int_data
      pair.text(int_data['description'+window.lang])

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

window.showOnePerson = (data, desc = false)->
  flag = getFlag(data)

  name = data['name'+window.lang]
  title = data['title'+window.lang]
  description = data['description'+window.lang]

  has_profile = false
  if data['profile'+window.lang]? and desc
    has_profile = true
    name = '<a href="' + data['profile'+window.lang] + '" target="_blank">' + name + '</a>'

  img_src = if data.img then '/infographic-static/' + data.img else '/infographic-static/img/def-' + (if data.sex is 0 then 'wo' else '') + 'man.png'
  person = $('<div>').addClass('person')
  person.append($('<div>').addClass('img ' + flag.name).append($('<img>').attr('src', img_src)))
  person.append($('<p>').addClass('name').html(name))
  if title
    person.append($('<p>').addClass('title').text(title))
  #    $('#description.show-link:before').css('height','38px')
  if has_profile
    person.append($('<a>').addClass('profile-link').attr('href', data['profile'+window.lang]).attr('target', '_blank').text(messages['Profile'][window.lang]))
  #  person.append($('<p>').addClass('title').text(description))

  #  desc.find('.description').text('').text(data.description)
  #  desc.find('.name').text('').text(data.name)
  #  desc.find('.title').text('').text(data.title)
  #  desc.find('.img').attr('src', data.image)
  person