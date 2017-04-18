

# functions.coffee

window.svgPath = 'data/1917-work-default-5.svg'
#window.svgPath = 'data/1917-work-default-LAST_ORIG.svg'
window.flags = require './../../data/flags.json'
window.persons_data = require './../../data/persons.json'
window.personSelected = null
window.land = null

# ==============================================


window.doShowName = (el, fs, y) ->
  if fs is '12'
#    console.log( 'rect y:', $(el).find('rect').attr('y', y-40))
#    console.log el, 'name', fs, y
    $(el).find('rect').attr('y', y-40)

    if $(el).find('text[id="{name}"][font-size="12"] tspan').length > 1
      $(el).find('text[id="{name}"][font-size="12"] tspan').each ->
        y = $(@).attr('y')
        $(@).attr('y', y - 12)
      $(el).find('rect').attr('height', parseInt($(el).find('rect').attr('height')) + 7 )

    else
      $(el).find('text[id="{name}"][font-size="12"] tspan').attr('y', y-25)

    $(el).find('text[id="{title}"] tspan').attr('y', y-10)

    if $(el).find('text[id="{title}"] tspan').text().length > 0
      $(el).find('rect').attr('height', parseInt($(el).find('rect').attr('height'))+15 )


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


window.init = ->
  console.log 'init()'

  dinastyInit()
  resetInit()

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
      @hammer = Hammer(options.svgElement, inputClass: if Hammer.SUPPORT_POINTER_EVENTS then Hammer.PointerEventInput else Hammer.TouchInput)
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

