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

  id = $(el).find('text:last-child > tspan').text().trim()
  n_x = $($(name_el).html()).attr('x')
  n_y = $($(name_el).html()).attr('y')
  name  = {
    x: n_x,
    y: n_y,
    name: getPersonName(id)
  } # name_el.text().trim()
  nspan = name_el.find('tspan')
  if nspan.length > 1
    io = name.name.split(' ')
    $(nspan[0]).text(io[0])
    $(nspan[1]).text(io[1])
  else
    $(nspan).text(name.name)
# TODO: доделать правильное позиционирование, для англ языка

#  console.log name, name_el, name_el.attr('x'), name_el.attr('y')

  title_el = if text.length > 2 then $(text[1]) else null

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
    title_el.find('tspan').text(getPersonTitle(id))


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
    personLinks = []
    $('#panel').scrollTop(0)


    #    console.log 'start:', 'id:', pid, personSelected, personSelected2
    if personSelected isnt null and personSelected2 isnt null
      window.personSelected = window.personSelected2 = null


    if personSelected isnt null and personSelected is pid and personSelected2 is null then return

    if personSelected is null
      window.personSelected = pid
      window.personSelected2 = null

    if personSelected isnt null and personSelected isnt pid
      window.personSelected2 = pid



    data1 = getPersonData(personSelected)
    data2 = getPersonData(personSelected2)
#    console.log 'data1: ', data1
#    console.log 'data2: ', data2

    hideDinastySelector()

    showPersonDescription(data1, data2)

    personMaximize()
    $('#lines > g').hide()


    #      $('g[id^="person-"]').hide()
    $('g[id^="person-"]').addClass('person-mini flag-0')
    $('g#person-'+personSelected).show().removeClass('person-mini flag-0')
    $('g#person-'+personSelected2).show().removeClass('person-mini flag-0')
    #    $('g.person-'+land).removeClass('flag-0')
    personMinimize()

#    family = getPersonFamily(personSelected)
    links = findPath(personSelected, personSelected2)

#    console.log 'links', links

    if links isnt undefined
      showLine links[i], links[i+1] for link, i in links


#    console.log 'family', family
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
    onePersonMinimize(@)

  return

window.onePersonMinimize = (e)->
  if !e? then return
  el = $(e)
  t = el.find('[id="{title}"]')
  t.hide()
  el
    .find('g#Oval-2')
    .children()
    .attr('xlink:href', '#path-person-mini')
  if el.find('image').length > 0
#    console.log getPersonName(el.attr('id').split('-')[1])
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



# ==============================================

# Увеличиваем персоны
window.personMaximize = ->
  elem = $('.person-mini')

  elem.each ()->
    onePersonMaximize(@)
  return

window.onePersonMaximize = (e) ->
  if !e? then return
  el = $(e)
  el.removeClass('flag-0')

  if el.find('#img').length > 0
    el
      .removeClass('person-mini')
      .find('g#Oval-2')
      .children()
      .attr('xlink:href', '#path-person-standard')
    #    .attr('transform', 'translate(62, 40)')
#    console.log getPersonName(el.attr('id').split('-')[1]), el.attr('class'), window.land

    transform = el.find('g[id^="flag"]').attr('transform')
    translate = (if transform? then transform else '').replace('translate(', '').replace(')', '').split(', ')
    x = 31
    y = 9
    el.find('g[id^="flag"]').attr('transform', "translate(#{x}, #{y})")

    rect = el.find('rect')
    y1 = parseInt(rect.attr('y'))
    rect.attr('y', y1 + 20)

    el.find('[id="{name}"]').attr('font-size', 12).attr('fill', '#4a4a4a')

#    if !el.hasClass('person-'+land)
    el.find('[id="{name}"] > tspan').each ->
      e = $(@)
      e.attr('x', parseInt(e.attr('x')) - 7)
      e.attr('y', parseInt(e.attr('y')) + 24)
      return
    el.find('[id="{title}"]').show()


  #    console.log 'translate', translate, x, y


# ==============================================

window.getPersonChildren = (pid)->
  res =  persons_data.filter (e)->
    parent = if e.mother is parseInt(pid) then e.mother else if e.father is parseInt(pid) then e.father else 0
    return if parent > 0 then true else false
  return res.map (p)->
    return p.id



# ==============================================

# Получаем ID-шники по отцовской линии, кого надо показывать
window.getPersonFatherLine = (pid, recurs = false) ->
  id = parseInt(pid)
  line = [id]
  cur = getPersonData(id)
  if recurs is false
    brozters = getPersonBrozters(id, false)
    line = line.concat(brozters)



  if cur.father > 0
    if cur.mother and pid is line[0]
      line.push cur.mother
#      showDownLine(cur.mother)
    if cur.father then line.push cur.father

    if recurs is false
      line = line.concat getPersonFatherLine(cur.father, true)
    line = line.concat getPersonBrozters(id, true)


#  text = 'Мама: '+ getPersonName(cur.mother)+'<br>'
#  text += 'Папа: '+ getPersonName(cur.father)+'<br>'

#  console.log 'getPersonFatherLine broz', broz
#  $('#debug').html(text)
  return line

# ==============================================

# Получаем ID-шники братьев/сестер, если older == true, то только страших
window.getPersonBrozters = (pid, older = false, rec = false) ->
  id = parseInt(pid)
  line = [id]
  cur = getPersonData(id)
  cid = cur.id
#  curname = if lang is 'ru' then cur.nameru else cur.nameen
  console.log 'getPersonBrozters', cur, cur.id, older, rec

  broztersObj = persons_data.filter (e)->
    if e.mother > 0 and e.father > 0 and e.id isnt cid
      if e.mother is parseInt(cur.mother) and e.father is parseInt(cur.father) # then true else false
        if older is true
#          console.log 'older is true', e
          if cur.posinbroz > e.posinbroz then return true
        else
#          console.log 'older is false', e
          return true

#  console.log 'getPersonBrozters('+cur.name+', older = ', older, ')-> brozters: ',  broztersObj

#  broztersNames = broztersObj.map (el)->
#    return el.name

  broztersIDs = broztersObj.map (el)->
    return el.id

#  console.log broztersIDs

  showParentsRelations(broztersIDs)

#  showParentsLinks()
  #  console.log curLinks



  return broztersIDs




  return "#{cur.name}, #{if cur.sex then 'son' else 'daughter'} of (#{getPersonName(cur.mother)} and #{getPersonName(cur.father)}),  #{ft}, #{mt} have #{brozters.length} brozters (#{broztersNames}), children (#{childrenNames})"

# ==============================================

window. showParentsRelations = (id1, id2)->
#  $('#lines > g[id*="-' + id1 + '-' + id2 + '"], #lines > g[id*="-' + id1 + '-' + id2 + '"]').show()
#  $('#lines > g[id*="-' + id2 + '-' + id1 + '"], #lines > g[id*="-' + id2 + '-' + id1 + '"]').show()


# ==============================================

window.getPersonFamily = (pid)->
  p = getPersonData(pid)
  children = getPersonChildren(p.id)
  parents = getPersonFatherLine(p.id)
  brozters = getPersonBrozters(p.id)

  window.personLinks = [].concat(children, parents)

  if typeof p.couple is 'string'
    couples = p.couple.split(',')
    console.log couples
    $(couples).each ()->
      window.personLinks.push parseInt(@)
  else
    window.personLinks.push parseInt(p.couple)


  console.log 'personLinks: ', personLinks.map (i)->
    if i isnt NaN
      getPersonName(i)

#  $(personLinks).each ()->
##    console.log @
#    $('#person-'+@).show().removeClass('flag-0')
##    $('#lines > g[id^="' + getFlag(p).name + '-"]').show()
#    showLine(@, null, personLinks)


  return


# ==============================================

window.getPersonData = (pid)->
  if pid is undefined or pid is null then return false
#  console.log 'getPersonData', pid
  return persons_data.find (e)->
    return if e.id is parseInt(pid) then true else false
# ==============================================

window.getPersonName = (pid)->
#  console.log 'getPersonName', pid
  if pid is 0 then return null
  p = getPersonData(pid)
  return if lang is 'ru' then p.nameru else p.nameen
# ==============================================

window.getPersonTitle = (pid)->
  p = getPersonData(pid)
  return if lang is 'ru' then p.titleru else p.titleen
# ==============================================

window.getPersonDescription = (pid)->
  p = getPersonData(pid)
  return if lang is 'ru' then p.descriptionru else p.descriptionen
# ==============================================

window.getPersonID = (pid)->
  p = getPersonData(pid)
  return p.id
# ==============================================

window.getFlag = (data)->
  return flags.find (e)->
    return if e.id is parseInt(data.family) then true else false
# ==============================================

window.showLine = (id1, id2 = null, brozt = []) ->
#  console.log('showLine', id1, id2)

  if id1 is null and id2 is null
    $('#lines > g[id*="' + id1 + '-' + id2 + '"], #lines > g[id*="' + id2 + '-' + id1 + '"]').show()


  if id2 is null
#    console.log('showUpLine', id1, id2, brozt.length)
    showUpLine(id1, brozt)
#    showDownLine(id1)

# ==============================================

window.showUpLine = (id, brozters)->
  els = $('#lines > g[id$="-' + id + '"]')
#  console.log 'showUpLine brozters:', brozters
  if els?
    if els.length is 1
      showSegment(els, brozters)
    else if els.length > 1
      els.each ()->
#        console.log 'each showSegment: ', @
        showSegment($(@), brozters)
# ==============================================

window.showDownLine = (id)->
  $('#lines > g[id*="'+land+'-' + id + '-"]').show()
# ==============================================

window.showParentsLinks = (broz)->
  $(broz).each ()->
    id = @.id
    $('#lines > g[id*="'+ land +'-' + id + '-' + cur.father + '"], #lines > g[id*="'+ land +'-' + id + '-' + cur.mother + '"]').show()
    $('#lines > g[id*="'+ land +'-' + cur.father + '-' + id + '"], #lines > g[id*="'+ land +'-' + cur.mother + '-' + id + '"]')
# ==============================================


window.showSegment = (els, broz)->
  elems = $(els).attr('id')
  elements = elems.split('-')
#  console.log elems, elements, elements[1], broz
  ret = $.inArray(parseInt(elements[1]), broz)
#  console.log ret
  if ret isnt -1 then $(els).show()




#  children = getPersonChildren(cid)
#  console.log 'children', children
#
#  childrenNames = children.map (id)->
#    name = getPersonName(id)
#    return name
#
#  fatherOf = persons_data.filter (e)->
#    if e.father is parseInt(cur.id)  then true else false
#
#  fatherOfNames = fatherOf.map (el)->
#    return el.name
#
#  motherOf = persons_data.filter (e)->
#    if e.mother is parseInt(cur.id)  then true else false
#
#  motherOfNames = motherOf.map (el)->
#    return el.name
#
#  ft = if fatherOfNames.length > 0 then "father of (#{fatherOfNames})" else '';
#  mt = if motherOfNames.length > 0 then "mother of (#{motherOfNames})" else '';
#
