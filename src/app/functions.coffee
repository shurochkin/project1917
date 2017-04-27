# functions.coffee
window.$ = require 'jquery'
window.svgPanZoom = require 'svg-pan-zoom'
window.Hammer = require 'hammerjs'


window.lang = 'ru'
#window.lang = 'en'
window.svgPath = 'data/1917-work-default-5.svg'
#window.svgPath = 'data/1917-work-default-LAST_ORIG.svg'
window.flags = require './../../data/flags.json'
window.persons_data = require './../../data/persons.json'
window.interes_data = require './../../data/interes.json'
window.personSelected = null
window.personSelected2 = null
window.land = null
window.graph = {}
window.personLinks = []

# ==============================================


window.doShowName = (el, fs, y) ->
  if fs is '12'
#    console.log( 'rect y:', $(el).find('rect').attr('y', y-40))
#    console.log el, 'name', fs, y
    $(el).find('rect').attr('y', y - 40)

    if $(el).find('text[id="{name}"][font-size="12"] tspan').length > 1
      $(el).find('text[id="{name}"][font-size="12"] tspan').each ->
        y = $(@).attr('y')
        $(@).attr('y', y - 12)
      $(el).find('rect').attr('height', parseInt($(el).find('rect').attr('height')) + 7)

    else
      $(el).find('text[id="{name}"][font-size="12"] tspan').attr('y', y - 25)

    $(el).find('text[id="{title}"] tspan').attr('y', y - 10)

    if $(el).find('text[id="{title}"] tspan').text().length > 0
      $(el).find('rect').attr('height', parseInt($(el).find('rect').attr('height')) + 15)


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


window.init = ->
  console.log 'init()'

  dinastyInit()
  interesInit()
  resetInit()


  persons_data.forEach (e) ->
    links = []

    toInt = (s) ->
      parseInt s

    getParent = (s) ->
      if typeof s == 'string' then toInt(s.replace(/~/g, '')) else s

    getId = (p) ->
      p.id

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
    controlIconsEnabled: true
    fit: true
    contain: true
    center: 1
    customEventsHandler: eventsHandler
    minZoom: 1
    maxZoom: 3
  )
  panZoom.zoom 1

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

