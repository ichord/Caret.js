describe('jquery.caret', function() {
  var $inputor;
  $inputor = null;
  var fixPos = 0;

  describe('InputCaret', function() {
    beforeEach(function() {
      var html = ''
        + '<textarea id="inputor" name="at" rows="8" cols="40">'
        + '  Stay Foolish, Stay Hungry. @Jobs'
        + '</textarea>';

      var fixture = setFixtures(html);
      $inputor = fixture.find('#inputor');

      var fixPos = 20;
    });

    it('Set/Get caret pos', function() {
      $inputor.caret('pos', 15);
      expect($inputor.caret('pos')).toBe(15);
    });

    // TODO: I don't know how to test this functions yet. = =.
    // it("Set/Get caret position", function() {
    //   $inputor.caret('position', 20);
    //   pos = $inputor.caret('position'); // => {left: 15, top: 30, height: 20}
    //   expect(pos).toBe({ left : 2, top : 2, height : 17 });
    // });

    // $('#inputor').caret('offset'); // => {left: 300, top: 400, height: 20}
    // $('#inputor').caret('offset', fixPos);
  });

  describe('EditableCaret', function() {
    beforeEach(function() {
      var contentEditable = ''
        + '<div id="inputor" contentEditable="true">'
        + 'Hello '
        + '<span id="test">World</span>'
        + '! '
        + '<div><br></div>'
        + '<div>'
        + '<ul>'
        + '<li>Testing 1</li>'
        + '<li>Testin 2</li>'
        + '</ul>'
        + '<div>--</div>'
        + '</div>'
        + '<div><br></div>'
        + '</div>';

      var fixture = setFixtures(contentEditable);
      $inputor = fixture.find('#inputor');
    });

    it('sets the caret position at the top-level', function() {
      $inputor.caret('pos', 3);
      var selection = window.getSelection();
      expect(selection.anchorNode.nodeValue).toBe('Hello ');
      expect(selection.anchorOffset).toBe(3);
      expect($inputor.caret('pos')).toBe(3);
    });

    it('sets the caret position in a span', function() {
      $inputor.caret('pos', 8);
      var selection = window.getSelection();
      expect(selection.anchorNode.nodeValue).toBe('World');
      expect(selection.anchorOffset).toBe(2);
      expect($inputor.caret('pos')).toBe(8);
    });

    it('sets the caret position in a list item', function() {
      $inputor.caret('pos', 16);
      var selection = window.getSelection();
      expect(selection.anchorNode.nodeValue).toBe('Testing 1');
      expect(selection.anchorOffset).toBe(3);
      expect($inputor.caret('pos')).toBe(16);
    });

    it('sets the caret position at the end of a list item', function() {
      $inputor.caret('pos', 30);
      var selection = window.getSelection();
      expect(selection.anchorNode.nodeValue).toBe('Testin 2');
      expect(selection.anchorOffset).toBe(8);
      expect($inputor.caret('pos')).toBe(30);
    });

    describe('Edge case from Gmail', function() {
      beforeEach(function() {
        var content = ''
          + '<div id="inputor" contenteditable="true">'
          + 'Hello '
          + '<span>just</span> want'
          + '<ul><li>Hi</li></ul>'
          + '<div>---</div>'
          + '</div>';
        var fixture = setFixtures(content);
        $inputor = fixture.find('#inputor');
      });

      it('sets the caret position when two child nodes match the condition', function() {
        $inputor.caret('pos', 16);
        var selection = window.getSelection();
        expect(selection.anchorNode.nodeValue).toBe('Hi');
        expect(selection.anchorOffset).toBe(1);
        expect($inputor.caret('pos')).toBe(16);
      });
    });
  });
});
