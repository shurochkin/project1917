# functions.coffee
window.$ = require 'jquery'
window.svgPanZoom = require 'svg-pan-zoom'
window.Hammer = require 'hammerjs'

window.url = document.location.href
#window.url = 'https://project1917.com/infographic'

window.lang = if window.serverlang? then window.serverlang else if document.location.hostname.search(/\.com/) is -1 then 'ru' else 'en'
#window.lang = 'ru'

if lang is 'en'
  src = $('#header img').attr 'src'
  $('#header img').attr 'src', src.replace('ru', 'en')
$('body').addClass(lang)
window.svgPath = '/infographic-static/img/export-scheme-' + lang + '.svg'
window.messages = require './../../data/messages.json'
window.flags = require './../../data/flags.json'
window.persons_data = require './../../data/persons.json'
window.interes_data = require './../../data/interes.json'
window.personSelected = null
window.personSelected2 = null
window.land = null
window.graph = {}
window.personLinks = []
window.name_id = 'name' + window.lang
window.title_id = 'title' + window.lang

# ==============================================


window.doShowName = (el, fs, y) ->
  if fs is '12'
#    console.log( 'rect y:', $(el).find('rect').attr('y', y-40))
#    console.log el, 'name', fs, y
    $(el).find('rect').attr('y', y - 40)

    if $(el).find('text[id="{' + name_id + '}"][font-size="12"] tspan').length > 1
      $(el).find('text[id="{' + name_id + '}"][font-size="12"] tspan').each ->
        y = $(@).attr('y')
        $(@).attr('y', y - 12)
      $(el).find('rect').attr('height', toInt($(el).find('rect').attr('height')) + 7)

    else
      $(el).find('text[id="{' + name_id + '}"][font-size="12"] tspan').attr('y', y - 25)

    $(el).find('text[id="{' + title_id + '}"] tspan').attr('y', y - 10)

    if $(el).find('text[id="{' + title_id + '}"] tspan').text().length > 0
      $(el).find('rect').attr('height', toInt($(el).find('rect').attr('height')) + 15)


  #    $(el).attr('y', y-20)
  return

# ==============================================

window.doShowTitle = (el, fs) ->
#  console.log el, 'title', fs
  return

# ==============================================

window.doShowDefault = (el, fs) ->
#  console.log el, 'default', fs
  return

# ==============================================

# Поиск пути от персоны id1 к персоне id2.
# 1. Обнуляем цвета у всех персон;
# 2. Помечаем начало пути цветом +1, конец цветом -1;
# 3. Составляем два списка. В первом изначально только id1, во втором id2;
# 4. Если среди родственников всех, кто в списке, найден кто-то с цветом противоположного знака,
#    то строим два отрезка: от того, у кого нашёлся антипод до id1 и от антипода до id2;
# 5. Если никто из родственников не антипод, то всех, кто ещё _не_был_ окрашен, добавляем в новый список.
# 6. Повторям пункты 4,5 пока не будет найден маршрут либо пока не окрасим всех.
#

window.findPath = (id1, id2) ->
# Self ref
  if id1 == id2
    return [id1]
  # Make sure that both persons are exist
  if !graph[id1] or !graph[id2]
    return
  # Reset Graph
  for id of graph
    graph[id].color = 0
  # Mark initail vertices
  graph[id1].color = +1
  graph[id2].color = -1
  # Start from single elemnt lists.
  pList = [id1]
  nList = [id2]
  ret = undefined
  step = 2
  while !ret and (pList.length or nList.length)
    pNext = []
    pList.find (p) ->
      graph[p].links.find (id) ->
        if graph[id].color < 0
          ret = mkPath(p).concat(mkPath(id))
          return true
        if graph[id].color == 0
          graph[id].color = step
          pNext.push id
        return
    pList = pNext
    if ret
      break
    nNext = []
    nList.find (n) ->
      graph[n].links.find (id) ->
        if graph[id].color > 0
          ret = mkPath(id).concat(mkPath(n))
          return true
        if graph[id].color == 0
          graph[id].color = -step
          nNext.push id
        return
    nList = nNext
    ++step
  ret

# ==============================================

#  Обратный путь.
#  Просто ищем среди членов семьи любого, у кого цвет равен цвету from минус шаг.
#  Запоминаем индекс. Продолжаем поиск с той персоны, которую нашли.
#  Если на входе graph[from].color == 4, то сначала ищем любого родственника с color == 3,
#  Затем у этого родственника ищем родственника с color == 2 и, наконец, с color == 1.
#  Это та персона, от которой нужно построить путь.
#
#  Если цвет отрицательный, то идём до -1 и оказываемся в персоне, к которой нужно строить путь.
#  Поскольку в обоих случаях путь собирается от середины к краю, то для положительного пути
#  его нужно развернуть, чтобы он был от начала до середины. Путь от середины до конца не меняем.


window.mkPath = (from) ->
  path = [from]
  step = if graph[from].color > 0 then +1 else -1
  while graph[from].color != step
    color = graph[from].color - step
    from = graph[from].links.find((id) ->
      graph[id].color == color
    )
    path.push from
  # Positive part must be in the reverse order.
  if step > 0 then path.reverse() else path


window.showPath = (path) ->
  if !path
    return

  console.log path

  showLine = (id1, id2) ->
    selector = '#lines > g[id$="-' + id1 + '-' + id2 + '"], #lines > g[id$="-' + id2 + '-' + id1 + '"]'
    #    console.log selector
    l = $(selector).show().length
    #    console.log 'showLine 1:', selector, l
    if l is 0
      selector = '#m-lines > g[id$="-' + id1 + '-' + id2 + '"], #m-lines > g[id$="-' + id2 + '-' + id1 + '"]'
      l2 = $(selector).show().length
      #      console.log 'showLine 2:', selector, l2
      return l2

    return l

  birthOrder = (a, b) ->
    a.posinbroz - (b.posinbroz)

  i = 1
  while i < path.length
    id1 = path[i]
    id2 = path[i - 1]
    # Если есть линия, соединяющая обе персоны, то ничего больше не нужно.
    if showLine(id1, id2)
      ++i
      continue
    p1 = getPersonData(id1)
    p2 = getPersonData(id2)
    extra = []
    if p1.father == id2 or p1.mother == id2
# Потомок и предок. Добавляем всех сиблингов от первого до нужного.
      console.log id1 + ' is ancestor of ' + id2
      extra = [p2].concat(persons_data.filter((e) ->
        (e.father == id2 or e.mother == id2) and e.posinbroz <= p1.posinbroz
      ).sort(birthOrder))
    else if p2.father == id1 or p2.mother == id1
# Предок и потомок. Аналогично предыдущему.
      console.log id2 + ' is ancestor of ' + id1
      extra = [p1].concat(persons_data.filter((e) ->
        (e.father == id1 or e.mother == id1) and e.posinbroz <= p2.posinbroz
      ).sort(birthOrder))
    else if p1.father > 0 and p1.father == p2.father or p1.mother > 0 and p1.mother == p2.mother
# Сиблинги. Берём этих двух и всех, кто между ними.
      console.log id1 + ' is sibling of ' + id2
      minPos = Math.min(p1.posinbroz, p2.posinbroz)
      maxPos = Math.max(p1.posinbroz, p2.posinbroz)
      extra = persons_data.filter((e) ->
        (e.father == p1.father or e.mother == p1.mother) and e.posinbroz >= minPos and e.posinbroz <= maxPos
      ).sort(birthOrder)
    else
# Тут не очень красивое соединение через первого ребёнка. Но непонятно, как сделать лучше.
      console.log id1 + ' is spouse of ' + id2
      #      console.log 'showLine:', showLine(id1, id2)
      showLine(id1, id2)

    #      extra = []
    #      extra = [ p1 ].concat(persons_data.filter((e) ->
    #        (e.father == id1 or e.mother == id1) and e.posinbroz == 0
    #      ), [ p2 ])
    e = 1
    while e < extra.length
      showLine extra[e - 1].id, extra[e].id
      $('g#person-' + extra[e - 1].id).show().removeClass('person-mini flag-0')
      $('g#person-' + extra[e].id).show().removeClass('person-mini flag-0')
      ++e
    ++i
  return

# ==============================================

window.VK = {
  Share:
    count: (value, count)->
      if count > 0
        $('#vk-counter').text(count).addClass('show')
}


window.init = ->
  console.log 'init()'

  helpInit()
  dinastyInit()
  interesInit()
  resetInit()

  $.ajax
    url: 'https://vk.com/share.php?act=count&index=0&url=' + encodeURIComponent(url)
    type: 'GET'
    dataType: "jsonp"
    crossDomain: true

  $.getJSON 'https://graph.facebook.com/' + url, (data)->
    if data.share.share_count > 0
      $('#fb-counter').text(data.share.share_count).addClass('show')

  persons_data.forEach (e) ->
    links = []

    # Parents
    e.father and links.push(getParent(e.father))
    e.mother and links.push(getParent(e.mother))
    # Spouse
    if e.couple > 0
      links.push e.couple
    else if typeof e.couple == 'string'
      links = links.concat(e.couple.split(/,/g).map(toInt)).filter((x) ->
        x
      )
    # Children
    children = persons_data.filter((child) ->
      getParent(child.father) == e.id or getParent(child.mother) == e.id
    ).map(getId)
    # Siblings
    siblings = persons_data.filter((child) ->
      child.id != e.id and (e.father > 0 and child.father == e.father or e.mother > 0 and child.mother == e.mother)
    ).map(getId)
    #    console.log e.id, e.nameru, siblings
    graph[e.id] =
      color: 0
      links: links.concat(children, siblings)
    #    console.log(e.id + " " + e.name + " " + graph[e.id].links + " children " + children + " siblings " + siblings);
    return

  # TEST
  #  '-1,0;1,1;1,2;1,3;2,3;3,4;1,29;45,2;50,114;38,92;92,65'.split(/;/g).forEach (pair) ->
  #    ids = pair.split(/,/)
  #    console.log 'Path ' + pair + ' [' + findPath(ids[0] * 1, ids[1] * 1) + ']'
  #    return

  #  console.log graph
  return

# ==============================================


window.globalInit = (data)->
  $.get svgPath, (data) ->
    dom = $(data)
    #    persons = dom.find('svg > g:last-child > g:last-child')

    data = dom.find('svg')
    data.attr('style', 'display: inline; width: inherit; min-width: inherit; max-width: inherit; height: inherit; min-height: inherit; max-height: inherit;')
    #    console.log $(data.children()[1]).children()

    #    console.log data, svg
    #    parseData(data)

    data = parseData(data)


    $('#mobile-div').append(data)

    initZoom()
  return

# ==============================================

window.beforePan = (oldPan, newPan) ->
  stopHorizontal = false
  stopVertical = false
  gutterWidth = 200
  gutterHeight = 200
  sizes = @getSizes()
  leftLimit = -((sizes.viewBox.x + sizes.viewBox.width) * sizes.realZoom) + gutterWidth
  rightLimit = sizes.width - gutterWidth - (sizes.viewBox.x * sizes.realZoom)
  topLimit = -((sizes.viewBox.y + sizes.viewBox.height) * sizes.realZoom) + gutterHeight
  bottomLimit = sizes.height - gutterHeight - (sizes.viewBox.y * sizes.realZoom)
  customPan = {}
  customPan.x = Math.max(leftLimit, Math.min(rightLimit, newPan.x))
  customPan.y = Math.max(topLimit, Math.min(bottomLimit, newPan.y))
  customPan

window.initZoom = ->
#  console.log svgPanZoom, Hammer
  eventsHandler =
    haltEventListeners: [
      'touchstart'
      'touchend'
      'touchmove'
      'touchleave'
      'touchcancel'
    ]
    init: (options) ->
      instance = options.instance
      initialScale = 1
      pannedX = 0
      pannedY = 0
      # Init Hammer
      # Listen only for pointer and touch events
      @hammer = Hammer(options.svgElement,
        inputClass: if Hammer.SUPPORT_POINTER_EVENTS then Hammer.PointerEventInput else Hammer.TouchInput)
      # Enable pinch
      @hammer.get('pinch').set enable: true
      # Handle double tap
      @hammer.on 'doubletap', (ev) ->
        instance.zoomIn()
        return
      # Handle pan
      @hammer.on 'panstart panmove', (ev) ->
# On pan start reset panned variables
        if ev.type == 'panstart'
          pannedX = 0
          pannedY = 0
        # Pan only the difference
        instance.panBy
          x: ev.deltaX - pannedX
          y: ev.deltaY - pannedY
        pannedX = ev.deltaX
        pannedY = ev.deltaY
        return
      # Handle pinch
      @hammer.on 'pinchstart pinchmove', (ev) ->
# On pinch start remember initial zoom
        if ev.type == 'pinchstart'
          initialScale = instance.getZoom()
          instance.zoom initialScale * ev.scale
        instance.zoom initialScale * ev.scale
        return
      # Prevent moving the page on some devices when panning over SVG
      options.svgElement.addEventListener 'touchmove', (e) ->
        e.preventDefault()
        return
      return
    destroy: ->
      @hammer.destroy()
      return
  # Expose to window namespace for testing purposes
  window.panZoom = svgPanZoom('#mobile-div > svg',
    zoomEnabled: true
    controlIconsEnabled: false
    fit: true
    contain: true
    zoomScaleSensitivity: 0.5
    center: 1
    customEventsHandler: eventsHandler
    minZoom: 1
    maxZoom: 5
    beforePan: beforePan
  )
  panZoom.zoom 1

  $(window).resize ()->
    panZoom.resize()
    panZoom.fit()
    panZoom.center()

  $('#zoom-in').on 'click', (ev)->
    ev.preventDefault()
    panZoom.zoomIn()


  $('#zoom-out').on 'click', (ev)->
    ev.preventDefault()
    panZoom.zoomOut()

  $('#zoom-reset').on 'click', (ev)->
    ev.preventDefault()
    panZoom.resetZoom()

  $('[id^="zoom-"]').on 'click', ()->
    $('#panel').removeClass('open')

  $('#share-social > div').each ()->
    id = $(@).attr('id')
    url = document.location.href
    title = messages['Title'][window.lang]
    text = messages['Description'][window.lang]
    image = messages['image'][window.lang]
    $(@).on 'click', ()->
      switch id
        when 'vk'
          vkc = $('#vk-counter').text()
          vk = if vkc isnt '' then toInt(vkc) else 0
          $('#vk-counter').text(vk + 1)
          window.open 'https://vk.com/share.php?url=' + url + '&title=' + title + '&description=' + text + '&image=' + image, '_blank'
        when 'fb'
          fbc = $('#fb-counter').text()
          vk = if fbc isnt '' then toInt(fbc) else 0
          $('#fb-counter').text(vk + 1)
          window.open 'https://www.facebook.com/sharer.php?src=sp&u=' + url + '&r=' + Math.random(), '_blank'
        when 'tw'
          window.open 'http://twitter.com/share?&url=' + url, '_blank'
        else
          return false


  init()
  $('#preloader').hide()

  return

# ==============================================

window.parseSVG = (s) ->
  div = document.createElementNS('http://www.w3.org/1999/xhtml', 'div')
  div.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg">' + s + '</svg>'
  frag = document.createDocumentFragment()
  while div.firstChild.firstChild
    frag.appendChild div.firstChild.firstChild
  frag

# ==============================================

window.toInt = (s) ->
  parseInt s

# ==============================================

window.getParent = (s) ->
  if typeof s == 'string' then toInt(s.replace(/~/g, '')) else s

# ==============================================

window.getId = (p) ->
  p.id
