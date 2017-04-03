

# functions.coffee

flags = require './../../data/flags.json'

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
  console.log el, 'default', fs
  return

# ==========================

window.parseData = (data) ->
  dom = $(data)
  persons = dom.find('svg > g:last-child > g:last-child #persons > g')
#  console.log 'persons', persons

#  window.pers = persons.map (i, el) ->
  $(dom.find('svg > g:last-child > g:last-child #persons > g')).each ()->
    el = $(@)

#    el.find('rect').remove()
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


#
    title = {
      x: 0
      y: 0
      title: ''
    }
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
#    $(el).find('g[id^="{img}"]').hide()
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



#    console.log id, flag.html(), $(el).find('g#Oval-2').children()

    return person



  #  dom.find('svg > g:last-child > g:last-child #persons > g text:last-child').remove()


# Event onClick
  dom.find('svg > g:last-child > g:last-child #persons > g').on 'click', (e)->
    e.preventDefault()
    console.log $(e.currentTarget).html()
    return

# Event onHover
  dom.find('svg > g:last-child > g:last-child #persons > g').on 'mouseover', ()->
#    console.log $(@).html()

    return

#  dom.find('#persons').remove()

#  console.log pers
#  console.log p.html('')
  return dom

# ==============================================

window.parseSVG = (s) ->
  div = document.createElementNS('http://www.w3.org/1999/xhtml', 'div')
  div.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg">' + s + '</svg>'
  frag = document.createDocumentFragment()
  while div.firstChild.firstChild
    frag.appendChild div.firstChild.firstChild
  frag

# ==============================================

window.personMinimize = ->
  elem = $('[id^="person-"].person-mini.flag-0')

  elem.each ()->
    el = $(@)
#    console.log 'image', el.find('image').length


    if el.find('image').length > 0
      transform = el.find('g[id^="flag"]').attr('transform')
      translate = (if transform? then transform else '').replace('translate(', '').replace(')', '').split(' ')
      x = 62
      y = 41
      el.find('g[id^="flag"]').attr('transform', "translate(#{x} #{y})")
      w1 = el.find('[id="{name}"]').width()

      el.find('[id="{name}"]').attr('font-size', 10).attr('fill', '#4a4a4a')
      w2 = el.find('[id="{name}"]').width()

      delta = (w1-w2)/2
      el.find('[id="{name}"] > tspan').each ->
        el = $(@)
        el.attr('x', parseInt(el.attr('x')) + delta)
        el.attr('y', parseInt(el.attr('y')) - 24)
        return
      ut = el.find('#under-text')
      console.log if ut? and ut.length > 0 then ut.attr('y')
      ut.attr('y', parseInt(ut.attr('y')) - 12 )
#      el.find('[id="{name}"] > tspan').attr('y', '75')

      #      console.log 'text[id="{title}"]', el.find('text[id="{title}"]').length
    el.find('text[id="{title}"]').hide()





#    console.log 'translate', translate, x, y

  elem
    .find('g#Oval-2')
    .children()
    .attr('xlink:href', '#path-person-mini')
  #    .attr('transform', 'translate(62, 40)')
  return

# ==============================================

window.personMaximize = ->
  elem = $('.person-mini.flag-0')

  elem.each ()->
    el = $(@)
    el.removeClass('flag-0')
    console.log 'image', el.find('image').length


    if el.find('#img').length > 0
      el
        .removeClass('person-mini')
        .find('g#Oval-2')
        .children()
        .attr('xlink:href', '#path-person-standart')
      #    .attr('transform', 'translate(62, 40)')

      transform = el.find('g[id^="flag"]').attr('transform')
      translate = (if transform? then transform else '').replace('translate(', '').replace(')', '').split(', ')
      x = 31
      y = 9
      el.find('g[id^="flag"]').attr('transform', "translate(#{x}, #{y})")

      w1 = el.find('[id="{name}"]').width()
#
      el.find('[id="{name}"]').attr('font-size', 12).attr('fill', '#000000')
      w2 = el.find('[id="{name}"]').width()
      delta = (w2-w1)/2

      el.find('[id="{name}"] > tspan').each ->
        el = $(@)
        el.attr('x', parseInt(el.attr('x')) - delta)
        el.attr('y', parseInt(el.attr('y')) + 24)
        return
      el.find('[id="{title}"]').show()


#    console.log 'translate', translate, x, y

  return

# ==============================================

window.init = ->
  console.log 'init()'
  $('#panel input').each (e, i) ->
    $(this).on 'click', (el) ->
      elem = $(el.target)
      land = elem[0].value
      console.log 'land:', land
      personMaximize()
      $('#lines > g').hide()

#      $('g[id^="person-"]').hide()
      $('g[id^="person-"]').addClass('person-mini flag-0')
      $('g[class^="person-'+land+'"]').show().removeClass('person-mini flag-0')
      personMinimize()

      $('#lines > g[id^="' + land + '-"]').show()
      return
    return
  $('#clear-selection').on 'click', (e) ->
    $('#lines > g').show()
    $('g[id^="person-"]').show()
    personMaximize()
    return
  return

# ==============================================

#window.getJson = ->
#  $.get 'true.json', (data) ->
#    window.pers = data
#    #        $('#debug').text(window.pers);
#    #        console.log(pers);
#    $(pers).each (i, item) ->
##      console.log item
#      g = $(parseSVG('<defs><circle id="path-' + item.ind + '" cx="33" cy="33" r="33"></circle>            <rect x="-3" y="-2" width="70" height="70" id="rect-' + item.ind + '"></rect>            <pattern id="pattern-' + item.ind + '" patternUnits="objectBoundingBox" x="100%" width="100%" height="100%">            <use xlink:href="#image-' + item.ind + '" transform="scale(0,0)"></use>            </pattern>            <image id="image-' + item.ind + '" width="0" height="0"></image>            </defs>            <g  id="person-' + item.ind + '" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd" transform="translate(0, ' + item.ind + 10 + ')">            <rect id="under-text" fill="#FFFFFF" x="0" y="' + item.ind + 10 + '" width="18" height="21"></rect>            <g id="img" opacity="0.745527627" transform="translate(39.000000, 17.000000)">            <mask id="mask-' + item.ind + '" fill="white">                <use xlink:href="#path-' + item.ind + '"></use>            </mask>            <g id="Mask"></g>            <g id="img-' + item.ind + '" mask="url(#mask-' + item.ind + ')">            <image x="' + item.ind + '" y="' + item.ind + '" width="70" height="70" xlink:href="http://localhost:63342/1917/src/' + item.img + '"></image>            <use fill="url(#pattern-' + item.ind + ')" fill-rule="evenodd" xlink:href="#rect-' + item.ind + '"></use>            </g>            </g><text id="person-' + item.ind + '-name" font-family="Helvetica" font-size="12" font-weight="normal" fill="#000000">            <tspan x="0" y="' + item.ind + 100 + '">' + item.name + '</tspan>            </text>            <text id="person-' + item.ind + '-title" font-family="Helvetica" font-size="10" font-weight="normal" fill="#4A4A4A">            <tspan x="0" y="' + item.ind + 120 + '">' + item.title + '</tspan>            </text></g>'))
#      $('#persons').append g
#      init()
#      return
#    return
#  return

# ==============================================

window.getSvg = (data)->
  $.get 'data/1917-work-default-5.svg', (data) ->
    dom = $(data)
    persons = dom.find('svg > g:last-child > g:last-child')

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
    fit: false
    contain: true
    center: 1
    customEventsHandler: eventsHandler
    minZoom: .6
    maxZoom: 3
  )
  panZoom.zoom 1

  init()
  $('#preloader').hide()

  return

