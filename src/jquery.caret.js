//@ sourceMappingURL=jquery.caret.map
/*
  Implement Github like autocomplete mentions
  http://ichord.github.com/At.js

  Copyright (c) 2013 chord.luo@gmail.com
  Licensed under the MIT license.
*/


/*
本插件操作 textarea 或者 input 内的插入符
只实现了获得插入符在文本框中的位置，我设置
插入符的位置.
*/


(function() {
  (function(factory) {
    if (typeof define === 'function' && define.amd) {
      return define(['jquery'], factory);
    } else {
      return factory(window.jQuery);
    }
  })(function($) {
    "use strict";
    var Caret, Mirror, methods, pluginName;

    pluginName = 'caret';
    Caret = (function() {
      function Caret($inputor) {
        this.$inputor = $inputor;
        this.domInputor = this.$inputor[0];
      }

      Caret.prototype.getIEPos = function() {
        var endRange, inputor, len, normalizedValue, pos, range, textInputRange;

        inputor = this.domInputor;
        range = document.selection.createRange();
        pos = 0;
        if (range && range.parentElement() === inputor) {
          normalizedValue = inputor.value.replace(/\r\n/g, "\n");
          len = normalizedValue.length;
          textInputRange = inputor.createTextRange();
          textInputRange.moveToBookmark(range.getBookmark());
          endRange = inputor.createTextRange();
          endRange.collapse(false);
          if (textInputRange.compareEndPoints("StartToEnd", endRange) > -1) {
            pos = len;
          } else {
            pos = -textInputRange.moveStart("character", -len);
          }
        }
        return pos;
      };

      Caret.prototype.getIEEditablePos = function() {
        var preCaretTextRange, textRange;

        textRange = document.selection.createRange();
        preCaretTextRange = document.body.createTextRange();
        preCaretTextRange.moveToElementText(this.domInputor);
        preCaretTextRange.setEndPoint("EndToEnd", textRange);
        return preCaretTextRange.text.length;
      };

      Caret.prototype.getPos = function() {
        var clonedRange, inputor, pos, range;

        inputor = this.domInputor;
        inputor.focus();
        pos = 0;
        if (this.contentEditable() && (range = this.range())) {
          clonedRange = range.cloneRange();
          clonedRange.selectNodeContents(inputor);
          clonedRange.setEnd(range.endContainer, range.endOffset);
          pos = clonedRange.toString().length;
          clonedRange.detach();
        } else if (document.selection) {
          pos = this.contentEditable() ? this.getIEEditablePos() : this.getIEPos();
        } else {
          pos = inputor.selectionStart;
        }
        return pos;
      };

      Caret.prototype.setPos = function(pos) {
        var inputor, range;

        inputor = this.domInputor;
        if (document.selection) {
          range = inputor.createTextRange();
          range.move("character", pos);
          range.select();
        } else if (inputor.setSelectionRange) {
          inputor.setSelectionRange(pos, pos);
        }
        return inputor;
      };

      Caret.prototype.getPosition = function(pos) {
        var $inputor, at_rect, format, html, mirror, start_range;

        $inputor = this.$inputor;
        format = function(value) {
          return value.replace(/</g, '&lt').replace(/>/g, '&gt').replace(/`/g, '&#96').replace(/"/g, '&quot').replace(/\r\n|\r|\n/g, "<br />");
        };
        if (pos === void 0) {
          pos = this.getPos();
        }
        start_range = $inputor.val().slice(0, pos);
        html = "<span>" + format(start_range) + "</span>";
        html += "<span id='caret'>|</span>";
        mirror = new Mirror($inputor);
        return at_rect = mirror.create(html).rect();
      };

      Caret.prototype.getOffset = function(pos) {
        var $inputor, offset, position;

        $inputor = this.$inputor;
        offset = $inputor.offset();
        position = this.getPosition(pos);
        return offset = {
          left: offset.left + position.left,
          top: offset.top + position.top,
          height: position.height
        };
      };

      Caret.prototype.getEditableOffset = function() {
        var clonedRange, offset, range, rect;

        offset = null;
        if (window.getSelection && (range = this.range())) {
          clonedRange = range.cloneRange();
          clonedRange.setStart(range.endContainer, Math.max(1, range.endOffset) - 1);
          clonedRange.setEnd(range.endContainer, range.endOffset);
          rect = clonedRange.getBoundingClientRect();
          offset = {
            height: rect.height,
            left: rect.left + rect.width,
            top: rect.top
          };
          clonedRange.detach();
        } else if (document.selection) {
          range = document.selection.createRange().duplicate();
          range.moveStart("character", -1);
          rect = range.getBoundingClientRect();
          offset = {
            height: rect.bottom - rect.top,
            left: rect.left,
            top: rect.top
          };
        }
        return offset;
      };

      Caret.prototype.getIEPosition = function(pos) {
        var h, inputorOffset, offset, x, y;

        offset = this.getIEOffset(pos);
        inputorOffset = this.$inputor.offset();
        x = offset.left - inputorOffset.left;
        y = offset.top - inputorOffset.top;
        h = offset.height;
        return {
          left: x,
          top: y,
          height: h
        };
      };

      Caret.prototype.getIEOffset = function(pos) {
        var h, range, textRange, x, y;

        textRange = this.domInputor.createTextRange();
        if (pos) {
          textRange.move('character', pos);
        } else {
          range = document.selection.createRange();
          textRange.moveToBookmark(range.getBookmark());
        }
        x = textRange.boundingLeft;
        y = textRange.boundingTop;
        h = textRange.boundingHeight;
        return {
          left: x,
          top: y,
          height: h
        };
      };

      Caret.prototype.range = function() {
        var sel;

        if (!window.getSelection) {
          return;
        }
        sel = window.getSelection();
        if (sel.rangeCount > 0) {
          return sel.getRangeAt(0);
        } else {
          return null;
        }
      };

      Caret.prototype.adjustOffset = function(offset) {
        offset.top += $(window).scrollTop() + this.$inputor.scrollTop();
        offset.left += +$(window).scrollLeft() + this.$inputor.scrollLeft();
        return offset;
      };

      Caret.prototype.contentEditable = function() {
        return !!(this.domInputor.contentEditable && this.domInputor.contentEditable === 'true');
      };

      return Caret;

    })();
    Mirror = (function() {
      Mirror.prototype.css_attr = ["overflowY", "height", "width", "paddingTop", "paddingLeft", "paddingRight", "paddingBottom", "marginTop", "marginLeft", "marginRight", "marginBottom", "fontFamily", "borderStyle", "borderWidth", "wordWrap", "fontSize", "lineHeight", "overflowX", "text-align"];

      function Mirror($inputor) {
        this.$inputor = $inputor;
      }

      Mirror.prototype.mirrorCss = function() {
        var css,
          _this = this;

        css = {
          position: 'absolute',
          left: -9999,
          top: 0,
          zIndex: -20000,
          'white-space': 'pre-wrap'
        };
        $.each(this.css_attr, function(i, p) {
          return css[p] = _this.$inputor.css(p);
        });
        return css;
      };

      Mirror.prototype.create = function(html) {
        this.$mirror = $('<div></div>');
        this.$mirror.css(this.mirrorCss());
        this.$mirror.html(html);
        this.$inputor.after(this.$mirror);
        return this;
      };

      Mirror.prototype.rect = function() {
        var $flag, pos, rect;

        $flag = this.$mirror.find("#caret");
        pos = $flag.position();
        rect = {
          left: pos.left,
          top: pos.top,
          height: $flag.height()
        };
        this.$mirror.remove();
        return rect;
      };

      return Mirror;

    })();
    methods = {
      pos: function(pos) {
        if (pos) {
          return this.setPos(pos);
        } else {
          return this.getPos();
        }
      },
      position: function(pos) {
        if (document.selection) {
          return this.getIEPosition(pos);
        } else {
          return this.getPosition(pos);
        }
      },
      offset: function(pos) {
        if (this.contentEditable()) {
          return this.adjustOffset(this.getEditableOffset());
        } else if (document.selection) {
          return this.adjustOffset(this.getIEOffset(pos));
        } else {
          return this.getOffset(pos);
        }
      }
    };
    return $.fn.caret = function(method) {
      var caret;

      caret = new Caret(this);
      if (methods[method]) {
        return methods[method].apply(caret, Array.prototype.slice.call(arguments, 1));
      } else {
        return $.error("Method " + method + " does not exist on jQuery.caret");
      }
    };
  });

}).call(this);
