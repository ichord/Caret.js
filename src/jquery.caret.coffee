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
    getCaretPos = (inputor) ->
      if document.selection #IE
        # reference: http://tinyurl.com/86pyc4s

        ###
        #assume we select "HATE" in the inputor such as textarea -> { }.
         *               start end-point.
         *              /
         * <  I really [HATE] IE   > between the brackets is the selection range.
         *                   \
         *                    end end-point.
         ###

        range = document.selection.createRange()
        pos = 0
        # selection should in the inputor.
        if range and range.parentElement() is inputor
          normalizedValue = inputor.value.replace /\r\n/g, "\n"
          ### SOMETIME !!!
           "/r/n" is counted as two char.
            one line is two, two will be four. balalala.
            so we have to using the normalized one's length.;
          ###
          len = normalizedValue.length
          ###
             <[  I really HATE IE   ]>:
              the whole content in the inputor will be the textInputRange.
          ###
          textInputRange = inputor.createTextRange()
          ###                 _here must be the position of bookmark.
                           /
             <[  I really [HATE] IE   ]>
              [---------->[           ] : this is what moveToBookmark do.
             <   I really [[HATE] IE   ]> : here is result.
                            \ two brackets in should be in line.
          ###
          textInputRange.moveToBookmark range.getBookmark()
          endRange = inputor.createTextRange()
          ###  [--------------------->[] : if set false all end-point goto end.
            <  I really [[HATE] IE  []]>
          ###
          endRange.collapse false
          ###
                          ___VS____
                         /         \
           <   I really [[HATE] IE []]>
                                    \_endRange end-point.

          " > -1" mean the start end-point will be the same or right to the end end-point
         * simplelly, all in the end.
          ####
          if textInputRange.compareEndPoints("StartToEnd", endRange) > -1
            #TextRange object will miss "\r\n". So, we count it ourself.
            start = end = len
          else
            ###
                    I really |HATE] IE   ]>
                           <-|
                  I really[ [HATE] IE   ]>
                        <-[
                I reall[y  [HATE] IE   ]>

              will return how many unit have moved.
            ###
            start = -textInputRange.moveStart "character", -len
            end = -textInputRange.moveEnd "character", -len

      else
        start = inputor.selectionStart
      return start

    setCaretPos = (inputor, pos) ->
      if document.selection #IE
        range = inputor.createTextRange()
        range.move "character", pos
        range.select()
      else
        inputor.setSelectionRange pos, pos

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

      # @param $inputor [Object] 输入框的 jQuery 对象
      constructor: (@$inputor) ->

      # 克隆输入框的样式
      #
      # @return [Object] 返回克隆得到样式
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

      # 在页面中创建克隆后的镜像.
      #
      # @param html [String] 将输入框内容转换成 html 后的内容.
      #   主要是为了给 `flag` (@, etc.) 打上标记
      #
      # @return [Object] 返回当前对象
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
        $flag = @$mirror.find "span#flag"
        pos = $flag.position()
        rect = {left: pos.left, top: pos.top, bottom: $flag.height() + pos.top}
        @$mirror.remove()
        rect

      @offset: ($inputor, html) ->
        this.constructor $inputor
        this.create(html).rect()


    position = ($inputor) ->
      ### 克隆完inputor后将原来的文本内容根据
        @的位置进行分块,以获取@块在inputor(输入框)里的position
      ###
      format = (value) ->
        value.replace(/</g, '&lt')
        .replace(/>/g, '&gt')
        .replace(/`/g,'&#96')
        .replace(/"/g,'&quot')
        .replace(/\r\n|\r|\n/g,"<br />")

      pos = getCaretPos $inputor[0]
      start_range = $inputor.val().slice(0, pos)
      html = "<span>"+format(start_range)+"</span>"
      html += "<span id='flag'>?</span>"

      ###
        将inputor的 offset(相对于document)
        和@在inputor里的position相加
        就得到了@相对于document的offset.
        当然,还要加上行高和滚动条的偏移量.
      ###
      at_rect = Mirror.offset($inputor, html)

      x = offset.left + at_rect.left - $inputor.scrollLeft()
      y = at_rect.top - $inputor.scrollTop()
      h = y + at_rect.bottom
      return {left: x, top: y, height: h}

    offset = ($inputor) ->
      offset = $inputor.offset()
      pos = position($inputor)

      x = offset.left + pos.left
      y = offset.top + pos.top
      h = pos.height

      return {left: x, top: y, height: h}

    offset_for_ie = ->
      Sel = document.selection.createRange()
      x = Sel.boundingLeft + $inputor.scrollLeft()
      y = Sel.boundingTop + $(window).scrollTop() + $inputor.scrollTop()
      bottom = y + Sel.boundingHeight
      return {left: x, top: y,  bottom:bottom}


    methods =
      pos: (pos) ->
        inputor = this[0]
        inputor.focus()
        if pos
          setCaretPos(inputor, pos)
        else
          getCaretPos(inputor)

      position: ->
        position this

      offset: ->
        if document.selection # for IE full
          offset_for_ie()
        else
          offset this


    $.fn.caret = (method) ->
      if methods[method]
        methods[method].apply this, Array::slice.call(arguments, 1)
      # else if typeof method is 'object' || !method
      #   methods.init.apply this, arguments
      else
        $.error "Method #{method} does not exist on jQuery.caret"



