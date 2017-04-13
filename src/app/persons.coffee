# ===============================
# Парсим данные
window.parseData = (data) ->
  dom = $(data)
  persons = dom.find('svg > g:last-child > g:last-child #persons > g')

  $(persons).each ()->
    el = $(@)
    preparePerson(el)

  bindEvents(persons)


  return dom

# ===============================

window.showAllPersons = ()->
  $('#lines > g').show()
  $('g[id^="person-"]').show()


# ===============================
# Препарируем персону
window.preparePerson = (el)->
  title = {x: 0, y: 0, title: ''}

  text = el.find('text')
  transform = el.attr('transform')

  name_el = $(text[0])

  n_x = $($(name_el).html()).attr('x')
  n_y = $($(name_el).html()).attr('y')
  name  = {x: n_x, y: n_y, name: name_el.text().trim()}
  title_el = if text.length > 2 then $(text[1]) else null
  id = $(el).find('text:last-child > tspan').text().trim()

  # PERSON ID
  el.attr('id', 'person-'+id)
  flag = $(el).find('g[id^="flag"]').attr('id').split('/')
  el.addClass('person-'+flags[flag[1]].name)
  #    console.log 'flag', flags[flag[1]].name

  # Remove ID <text>
  $(el).find('text:last-child').remove()
  # Remove Mask <g>
  $(el).find('#Mask').remove()


  if title_el?
    title = {
      x: $($(title_el).html()).attr('x')
      y: $($(title_el).html()).attr('y')
      title: title_el.text().trim()
    }

  translate = (if transform? then transform else '').replace('translate(', '').replace(')', '').split(' ')
  person = {id: id, translate: translate, name: name, title: title}


  #   Replace ALL circles to mini/gray

  if $(el).find('g[id^="{img}"]').length is 0
    $(el).find('g#Oval-2').children().attr('xlink:href', '#path-person-mini')
    #    $(el).find('g#Oval-2 > use:last-child').attr('stroke', '#dedede')
    #    flag = $(el).find('g[id^="flag"]').attr('transform', 'translate(62, 40)')
    t = $(el).find('text')


    t.find('tspan').each ()->
      fs = $(@).parent().attr('font-size')
      type = $(@).parent().attr('id').replace('{', '').replace('}', '')


      #      console.log 'name:', name.name, '| title:', title.title, 'parent:', type, '| fs:', fs?, '| y:', $(@).attr('y')
      y = $(@).attr('y')

      switch type
        when 'name' then doShowName(el, fs, y)
        when 'title' then doShowTitle(el, fs)
        else doShowDefault(el, fs)
  else
    $(el).addClass('has-image')
    $(el).find('g[id="{img}"] > image').attr('xlink:href', 'img/'+id+'.png')
    $(el).find('g#Oval-2').children().attr('xlink:href', '#path-person-standard')



  #    console.log id, flag.html(), $(el).find('g#Oval-2').children()

  return person

# ===================================

window.bindEvents = (persons)->
  sdvig = 14


# ----------------
# Person onClick

  persons.on 'click', (e)->
    e.preventDefault()
    elem = $(e.currentTarget)
#    name = elem.find('text[id="{name}"] tspan').text().trim()
#    title = elem.find('text[id="{title}"] tspan').text().trim()
    pid = parseInt elem.attr('id').split('-')[1]
    #    console.log 'name: ', name, 'title: ', title

    if personSelected is pid then return
    window.personSelected = pid

    data = getPersonData(pid)

    hideDinastySelector()

    showPersonDescription(data)

    personMaximize()
    $('#lines > g').hide()


    #      $('g[id^="person-"]').hide()
    $('g[id^="person-"]').addClass('person-mini flag-0')
    $('g#person-'+pid).show().removeClass('person-mini flag-0')
    #    $('g.person-'+land).removeClass('flag-0')
    personMinimize()

    family = getPersonFamily(pid)
    console.log 'family:', family
    #    $('#lines > g[id^="' + land + '-"]').show()
    return

# ----------------
# Person hover

  persons.on 'mouseover', (e)->
    e.preventDefault()
    elem = $(e.currentTarget)
    if elem.hasClass('has-image')
      css = elem.css('transform').replace('matrix(', '').replace(')', '').split(', ')
      elem.css('transform', 'matrix(1.2, 0, 0, 1.2, '+(parseFloat(css[4])-sdvig)+', '+(parseFloat(css[5])-sdvig)+')')
    return


# ----------------
# Person out

  persons.on 'mouseout', (e)->
    e.preventDefault()
    elem = $(e.currentTarget)
    if elem.hasClass('has-image')
      css = elem.css('transform').replace('matrix(', '').replace(')', '').split(', ')
      elem.css('transform', 'matrix(1, 0, 0, 1, '+(parseFloat(css[4])+sdvig)+', '+(parseFloat(css[5])+sdvig)+')')
    return

# ==============================================

# Уменьшааем персоны

window.personMinimize = ->
  elem = $('[id^="person-"].person-mini')

  elem.each ()->
    el = $(@)

    if el.find('image').length > 0
      transform = el.find('g[id^="flag"]').attr('transform')
      translate = (if transform? then transform else '').replace('translate(', '').replace(')', '').split(' ')
      x = 62
      y = 41
      el.find('g[id^="flag"]').attr('transform', "translate(#{x} #{y})")

      rect = el.find('rect')
      y1 = parseInt(rect.attr('y'))
      rect.attr('y', y1 - 20)


      el.find('[id="{name}"]').attr('font-size', 10).attr('fill', '#4a4a4a')

      el.find('[id="{name}"] > tspan').each ->
        e = $(@)
        e.attr('x', parseInt(e.attr('x')) + 7)
        e.attr('y', parseInt(e.attr('y')) - 24)
        return

    t = el.find('[id="{title}"]')
    t.hide()

  elem
    .find('g#Oval-2')
    .children()
    .attr('xlink:href', '#path-person-mini')
  return

# ==============================================

# Увеличиваем персоны
window.personMaximize = ->
  elem = $('.person-mini')

  elem.each ()->
    el = $(@)
    el.removeClass('flag-0')
    #    console.log 'image', el.find('image').length


    if el.find('#img').length > 0
      el
        .removeClass('person-mini')
        .find('g#Oval-2')
        .children()
        .attr('xlink:href', '#path-person-standard')
      #    .attr('transform', 'translate(62, 40)')

      transform = el.find('g[id^="flag"]').attr('transform')
      translate = (if transform? then transform else '').replace('translate(', '').replace(')', '').split(', ')
      x = 31
      y = 9
      el.find('g[id^="flag"]').attr('transform', "translate(#{x}, #{y})")

      rect = el.find('rect')
      y1 = parseInt(rect.attr('y'))
      rect.attr('y', y1 + 20)

      el.find('[id="{name}"]').attr('font-size', 12).attr('fill', '#4a4a4a')

      el.find('[id="{name}"] > tspan').each ->
        e = $(@)
        e.attr('x', parseInt(e.attr('x')) - 7)
        e.attr('y', parseInt(e.attr('y')) + 24)
        return
      el.find('[id="{title}"]').show()


  #    console.log 'translate', translate, x, y

  return

# ==============================================

window.getPersonChildren = (pid)->
  res =  persons_data.filter (e)->
    parent = if e.mother is parseInt(pid) then e.mother else if e.father is parseInt(pid) then e.father else 0
    return if parent > 0 then true else false
  return res.map (p)->
    return p.id



# ==============================================

window.getPersonFatherLine = (pid)->
  id = parseInt(pid)
  line = []
  cur = getPersonData(id)
  if cur.father > 0
    if cur.mother
      line.push cur.mother
      showDownLine(cur.mother)
    if cur.father then line.push cur.father


    line = line.concat getPersonFatherLine(cur.father)


  return line

# ==============================================

window.getPersonFamily = (pid)->
  p = getPersonData(pid)
  children = getPersonChildren(p.id)
  parents = getPersonFatherLine(p.id)
  console.log 'person: ', p, children, parents

  window.personLinks = [].concat(children, parents)
  if p.couple > 0 then window.personLinks.push p.couple


  console.log 'personLinks: ', personLinks

  $(personLinks).each ->
    $('#person-'+@).show().removeClass('flag-0')
#    $('#lines > g[id^="' + getFlag(p).name + '-"]').show()
    showLine(@)


  return



window.getPersonData = (pid)->
  return persons_data.find (e)->
    return if e.id is parseInt(pid) then true else false

window.getFlag = (data)->
  return flags.find (e)->
    return if e.id is parseInt(data.family) then true else false

window.showLine = (id1, id2 = null) ->
  if id2 is null
    showUpLine(id1)
#    showDownLine(id1)
  else
    $('#lines > g[id*="-' + id1 + '-' + id2 + '"], #lines > g[id*="-' + id2 + '-' + id1 + '"]').show()

window.showUpLine = (id)->
  $('#lines > g[id$="-' + id + '"]').show()

window.showDownLine = (id)->
  $('#lines > g[id*="-' + id + '-"]').show()
