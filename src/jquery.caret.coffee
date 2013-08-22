###
  Implement Github like autocomplete mentions
  http://ichord.github.com/At.js

  Copyright (c) 2013 chord.luo@gmail.com
  Licensed under the MIT license.
###

###
本插件操作 textarea 或者 input 内的插入符
只实现了获得插入符在文本框中的位置，我设置
插入符的位置.
###
( (factory) ->
  # Uses AMD or browser globals to create a jQuery plugin.
  # It does not try to register in a CommonJS environment since
  # jQuery is not likely to run in those environments.
  #
  # form [umd](https://github.com/umdjs/umd) project
  if typeof define is 'function' and define.amd
    # Register as an anonymous AMD module:
    define ['jquery'], factory
  else
    # Browser globals
    factory window.jQuery
) ($) ->

  "use strict";

  pluginName = 'caret'

  class Caret

    constructor: (@$inputor) ->
      @domInputor = @$inputor[0]

    getIEPos: ->
      # https://github.com/ichord/Caret.js/wiki/Get-pos-of-caret-in-IE
      inputor = @domInputor
      range = document.selection.createRange()
      pos = 0
      # selection should in the inputor.
      if range and range.parentElement() is inputor
        normalizedValue = inputor.value.replace /\r\n/g, "\n"
        len = normalizedValue.length
        textInputRange = inputor.createTextRange()
        textInputRange.moveToBookmark range.getBookmark()
        endRange = inputor.createTextRange()
        endRange.collapse false
        if textInputRange.compareEndPoints("StartToEnd", endRange) > -1
          pos = len
        else
          pos = -textInputRange.moveStart "character", -len
      pos

    getIEEditablePos: ->
      textRange = document.selection.createRange()
      preCaretTextRange = document.body.createTextRange()
      preCaretTextRange.moveToElementText(@domInputor)
      preCaretTextRange.setEndPoint("EndToEnd", textRange)
      preCaretTextRange.text.length

    getPos: ->
      inputor = @domInputor
      inputor.focus()
      pos = 0

      if this.contentEditable() and (range = this.range())
         clonedRange = range.cloneRange()
         clonedRange.selectNodeContents(inputor)
         clonedRange.setEnd(range.endContainer, range.endOffset)
         pos = clonedRange.toString().length
         clonedRange.detach()
      else if document.selection #IE
        pos = if this.contentEditable() then this.getIEEditablePos() else this.getIEPos()
      else
        pos = inputor.selectionStart

      return pos

    setPos: (pos) ->
      inputor = @domInputor
      if document.selection #IE
        range = inputor.createTextRange()
        range.move "character", pos
        range.select()
      else if inputor.setSelectionRange
        inputor.setSelectionRange pos, pos
      inputor

    getPosition: (pos)->
      $inputor = @$inputor
      format = (value) ->
        value.replace(/</g, '&lt')
        .replace(/>/g, '&gt')
        .replace(/`/g,'&#96')
        .replace(/"/g,'&quot')
        .replace(/\r\n|\r|\n/g,"<br />")

      pos = this.getPos() if pos is undefined
      start_range = $inputor.val().slice(0, pos)
      html = "<span>"+format(start_range)+"</span>"
      html += "<span id='caret'>|</span>"

      mirror = new Mirror($inputor)
      at_rect = mirror.create(html).rect()

    getOffset: (pos) ->
      $inputor = @$inputor
      offset = $inputor.offset()
      position = this.getPosition(pos)
      offset =
        left: offset.left + position.left
        top: offset.top + position.top
        height: position.height

    getEditableOffset: ->
      offset = null
      if window.getSelection and range = this.range()
        clonedRange = range.cloneRange()
        # NOTE: have to select a char to get the rect.
        clonedRange.setStart(range.endContainer, Math.max(1, range.endOffset) - 1)
        clonedRange.setEnd(range.endContainer, range.endOffset)
        rect = clonedRange.getBoundingClientRect()
        offset = { height: rect.height, left: rect.left + rect.width, top: rect.top }
        clonedRange.detach()
      else if document.selection # ie < 9
        range = document.selection.createRange().duplicate()
        range.moveStart "character", -1
        rect = range.getBoundingClientRect()
        offset = { height: rect.bottom - rect.top, left: rect.left, top: rect.top }

      return offset

    getIEPosition: (pos) ->
      offset = this.getIEOffset pos
      inputorOffset = @$inputor.offset()
      x = offset.left - inputorOffset.left
      y = offset.top - inputorOffset.top
      h = offset.height

      {left: x, top: y, height: h}

    getIEOffset: (pos) ->
      textRange = @domInputor.createTextRange()
      if pos
        textRange.move('character', pos)
      else
        range = document.selection.createRange()
        textRange.moveToBookmark range.getBookmark()

      x = textRange.boundingLeft
      y = textRange.boundingTop
      h = textRange.boundingHeight

      {left: x, top: y, height: h}

    range: ->
      return unless window.getSelection
      sel = window.getSelection()
      if sel.rangeCount > 0 then sel.getRangeAt(0) else null

    adjustOffset: (offset) ->
      offset.top += $(window).scrollTop() + @$inputor.scrollTop()
      offset.left += + $(window).scrollLeft() + @$inputor.scrollLeft()
      offset

    contentEditable: ->
      !!(@domInputor.contentEditable && @domInputor.contentEditable == 'true')


  # @example
  #   mirror = new Mirror($("textarea#inputor"))
  #   html = "<p>We will get the rect of <span>@</span>icho</p>"
  #   mirror.create(html).rect()
  class Mirror
    css_attr: [
      "overflowY", "height", "width", "paddingTop", "paddingLeft",
      "paddingRight", "paddingBottom", "marginTop", "marginLeft",
      "marginRight", "marginBottom","fontFamily", "borderStyle",
      "borderWidth","wordWrap", "fontSize", "lineHeight", "overflowX",
      "text-align",
    ]

    constructor: (@$inputor) ->

    mirrorCss: ->
      css =
        position: 'absolute'
        left: -9999
        top:0
        zIndex: -20000
        'white-space': 'pre-wrap'
      $.each @css_attr, (i,p) =>
        css[p] = @$inputor.css p
      css

    create: (html) ->
      @$mirror = $('<div></div>')
      @$mirror.css this.mirrorCss()
      @$mirror.html(html)
      @$inputor.after(@$mirror)
      this

    # 获得标记的位置
    #
    # @return [Object] 标记的坐标
    #   {left: 0, top: 0, bottom: 0}
    rect: ->
      $flag = @$mirror.find "#caret"
      pos = $flag.position()
      rect = {left: pos.left, top: pos.top, height: $flag.height() }
      @$mirror.remove()
      rect


  methods =
    pos: (pos) ->
      if pos then this.setPos(pos) else this.getPos()

    position: (pos) ->
      if document.selection # for IE full
        this.getIEPosition pos
      else
        this.getPosition pos

    offset: (pos) ->
      if this.contentEditable()
        this.adjustOffset this.getEditableOffset()
      else if document.selection # for IE full
        this.adjustOffset this.getIEOffset(pos)
      else
        this.getOffset pos


  $.fn.caret = (method) ->
    caret = new Caret this

    if methods[method]
      methods[method].apply caret, Array::slice.call(arguments, 1)
    else
      $.error "Method #{method} does not exist on jQuery.caret"
