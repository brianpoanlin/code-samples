/* custom Subber JS */



/* typed.js */

! function($) {

    "use strict";

    var Typed = function(el, options) {

        // chosen element to manipulate text
        this.el = $(el);

        // options
        this.options = $.extend({}, $.fn.typed.defaults, options);

        // attribute to type into
        this.isInput = this.el.is('input');
        this.attr = this.options.attr;

        // show cursor
        this.showCursor = this.isInput ? false : this.options.showCursor;

        // text content of element
        this.elContent = this.attr ? this.el.attr(this.attr) : this.el.text()

        // html or plain text
        this.contentType = this.options.contentType;

        // typing speed
        this.typeSpeed = this.options.typeSpeed;

        // add a delay before typing starts
        this.startDelay = this.options.startDelay;

        // backspacing speed
        this.backSpeed = this.options.backSpeed;

        // amount of time to wait before backspacing
        this.backDelay = this.options.backDelay;

        // div containing strings
        this.stringsElement = this.options.stringsElement;

        // input strings of text
        this.strings = this.options.strings;

        // character number position of current string
        this.strPos = 0;

        // current array position
        this.arrayPos = 0;

        // number to stop backspacing on.
        // default 0, can change depending on how many chars
        // you want to remove at the time
        this.stopNum = 0;

        // Looping logic
        this.loop = this.options.loop;
        this.loopCount = this.options.loopCount;
        this.curLoop = 0;

        // for stopping
        this.stop = false;

        // custom cursor
        this.cursorChar = this.options.cursorChar;

        // shuffle the strings
        this.shuffle = this.options.shuffle;
        // the order of strings
        this.sequence = [];

        // All systems go!
        this.build();
    };

    Typed.prototype = {

        constructor: Typed

        ,
        init: function() {
            // begin the loop w/ first current string (global self.strings)
            // current string will be passed as an argument each time after this
            var self = this;
            self.timeout = setTimeout(function() {
                for (var i=0;i<self.strings.length;++i) self.sequence[i]=i;

                // shuffle the array if true
                if(self.shuffle) self.sequence = self.shuffleArray(self.sequence);

                // Start typing
                self.typewrite(self.strings[self.sequence[self.arrayPos]], self.strPos);
            }, self.startDelay);
        }

        ,
        build: function() {
            var self = this;
            // Insert cursor
            if (this.showCursor === true) {
                this.cursor = $("<span class=\"typed-cursor\">" + this.cursorChar + "</span>");
                this.el.after(this.cursor);
            }
            if (this.stringsElement) {
                self.strings = [];
                this.stringsElement.hide();
                var strings = this.stringsElement.find('p');
                $.each(strings, function(key, value){
                    self.strings.push($(value).html());
                });
            }
            this.init();
        }

        // pass current string state to each function, types 1 char per call
        ,
        typewrite: function(curString, curStrPos) {
            // exit when stopped
            if (this.stop === true) {
                return;
            }

            // varying values for setTimeout during typing
            // can't be global since number changes each time loop is executed
            var humanize = Math.round(Math.random() * (100 - 30)) + this.typeSpeed;
            var self = this;

            // ------------- optional ------------- //
            // backpaces a certain string faster
            // ------------------------------------ //
            // if (self.arrayPos == 1){
            //  self.backDelay = 50;
            // }
            // else{ self.backDelay = 500; }

            // contain typing function in a timeout humanize'd delay
            self.timeout = setTimeout(function() {
                // check for an escape character before a pause value
                // format: \^\d+ .. eg: ^1000 .. should be able to print the ^ too using ^^
                // single ^ are removed from string
                var charPause = 0;
                var substr = curString.substr(curStrPos);
                if (substr.charAt(0) === '^') {
                    var skip = 1; // skip atleast 1
                    if (/^\^\d+/.test(substr)) {
                        substr = /\d+/.exec(substr)[0];
                        skip += substr.length;
                        charPause = parseInt(substr);
                    }

                    // strip out the escape character and pause value so they're not printed
                    curString = curString.substring(0, curStrPos) + curString.substring(curStrPos + skip);
                }

                if (self.contentType === 'html') {
                    // skip over html tags while typing
                    var curChar = curString.substr(curStrPos).charAt(0)
                    if (curChar === '<' || curChar === '&') {
                        var tag = '';
                        var endTag = '';
                        if (curChar === '<') {
                            endTag = '>'
                        } else {
                            endTag = ';'
                        }
                        while (curString.substr(curStrPos).charAt(0) !== endTag) {
                            tag += curString.substr(curStrPos).charAt(0);
                            curStrPos++;
                        }
                        curStrPos++;
                        tag += endTag;
                    }
                }

                // timeout for any pause after a character
                self.timeout = setTimeout(function() {
                    if (curStrPos === curString.length) {
                        // fires callback function
                        self.options.onStringTyped(self.arrayPos);

                        // is this the final string
                        if (self.arrayPos === self.strings.length - 1) {
                            // animation that occurs on the last typed string
                            self.options.callback();

                            self.curLoop++;

                            // quit if we wont loop back
                            if (self.loop === false || self.curLoop === self.loopCount)
                                return;
                        }

                        self.timeout = setTimeout(function() {
                            self.backspace(curString, curStrPos);
                        }, self.backDelay);
                    } else {

                        /* call before functions if applicable */
                        if (curStrPos === 0)
                            self.options.preStringTyped(self.arrayPos);

                        // start typing each new char into existing string
                        // curString: arg, self.el.html: original text inside element
                        var nextString = curString.substr(0, curStrPos + 1);
                        if (self.attr) {
                            self.el.attr(self.attr, nextString);
                        } else {
                            if (self.isInput) {
                                self.el.val(nextString);
                            } else if (self.contentType === 'html') {
                                self.el.html(nextString);
                            } else {
                                self.el.text(nextString);
                            }
                        }

                        // add characters one by one
                        curStrPos++;
                        // loop the function
                        self.typewrite(curString, curStrPos);
                    }
                    // end of character pause
                }, charPause);

                // humanized value for typing
            }, humanize);

        }

        ,
        backspace: function(curString, curStrPos) {
            // exit when stopped
            if (this.stop === true) {
                return;
            }

            // varying values for setTimeout during typing
            // can't be global since number changes each time loop is executed
            var humanize = Math.round(Math.random() * (100 - 30)) + this.backSpeed;
            var self = this;

            self.timeout = setTimeout(function() {

                // ----- this part is optional ----- //
                // check string array position
                // on the first string, only delete one word
                // the stopNum actually represents the amount of chars to
                // keep in the current string. In my case it's 14.
                // if (self.arrayPos == 1){
                //  self.stopNum = 14;
                // }
                //every other time, delete the whole typed string
                // else{
                //  self.stopNum = 0;
                // }

                if (self.contentType === 'html') {
                    // skip over html tags while backspacing
                    if (curString.substr(curStrPos).charAt(0) === '>') {
                        var tag = '';
                        while (curString.substr(curStrPos).charAt(0) !== '<') {
                            tag -= curString.substr(curStrPos).charAt(0);
                            curStrPos--;
                        }
                        curStrPos--;
                        tag += '<';
                    }
                }

                // ----- continue important stuff ----- //
                // replace text with base text + typed characters
                var nextString = curString.substr(0, curStrPos);
                if (self.attr) {
                    self.el.attr(self.attr, nextString);
                } else {
                    if (self.isInput) {
                        self.el.val(nextString);
                    } else if (self.contentType === 'html') {
                        self.el.html(nextString);
                    } else {
                        self.el.text(nextString);
                    }
                }

                // if the number (id of character in current string) is
                // less than the stop number, keep going
                if (curStrPos > self.stopNum) {
                    // subtract characters one by one
                    curStrPos--;
                    // loop the function
                    self.backspace(curString, curStrPos);
                }
                // if the stop number has been reached, increase
                // array position to next string
                else if (curStrPos <= self.stopNum) {
                    self.arrayPos++;

                    if (self.arrayPos === self.strings.length) {
                        self.arrayPos = 0;

                        // Shuffle sequence again
                        if(self.shuffle) self.sequence = self.shuffleArray(self.sequence);

                        self.init();
                    } else
                        self.typewrite(self.strings[self.sequence[self.arrayPos]], curStrPos);
                }

                // humanized value for typing
            }, humanize);

        }
        /**
         * Shuffles the numbers in the given array.
         * @param {Array} array
         * @returns {Array}
         */
        ,shuffleArray: function(array) {
            var tmp, current, top = array.length;
            if(top) while(--top) {
                current = Math.floor(Math.random() * (top + 1));
                tmp = array[current];
                array[current] = array[top];
                array[top] = tmp;
            }
            return array;
        }

        // Start & Stop currently not working

        // , stop: function() {
        //     var self = this;

        //     self.stop = true;
        //     clearInterval(self.timeout);
        // }

        // , start: function() {
        //     var self = this;
        //     if(self.stop === false)
        //        return;

        //     this.stop = false;
        //     this.init();
        // }

        // Reset and rebuild the element
        ,
        reset: function() {
            var self = this;
            clearInterval(self.timeout);
            var id = this.el.attr('id');
            this.el.after('<span id="' + id + '"/>')
            this.el.remove();
            if (typeof this.cursor !== 'undefined') {
                this.cursor.remove();
            }
            // Send the callback
            self.options.resetCallback();
        }

    };

    $.fn.typed = function(option) {
        return this.each(function() {
            var $this = $(this),
                data = $this.data('typed'),
                options = typeof option == 'object' && option;
            if (!data) $this.data('typed', (data = new Typed(this, options)));
            if (typeof option == 'string') data[option]();
        });
    };

    $.fn.typed.defaults = {
        strings: ["These are the default values...", "You know what you should do?", "Use your own!", "Have a great day!"],
        stringsElement: null,
        // typing speed
        typeSpeed: 0,
        // time before typing starts
        startDelay: 0,
        // backspacing speed
        backSpeed: 0,
        // shuffle the strings
        shuffle: false,
        // time before backspacing
        backDelay: 500,
        // loop
        loop: false,
        // false = infinite
        loopCount: false,
        // show cursor
        showCursor: true,
        // character for cursor
        cursorChar: "|",
        // attribute to type (null == text)
        attr: null,
        // either html or text
        contentType: 'html',
        // call when done callback function
        callback: function() {},
        // starting callback function before each string
        preStringTyped: function() {},
        //callback for every typed string
        onStringTyped: function() {},
        // callback for reset
        resetCallback: function() {}
    };


}(window.jQuery);


/* index_timeline.js */
(function() {
  var cssSide, entry, entryCount, entrys, gap, i, idx, j, k, l, len, len1, len2, m, maxEntryHeight, minEntryHeight, ref, ref1, ref2, scroll, side, sign, subIdx, target, timelineEntrys, toggle, totalHeight;

  entryCount = 100;

  minEntryHeight = 100;

  maxEntryHeight = 500;

  gap = 20;

  timelineEntrys = [];

  for (i = j = 1, ref = entryCount; 1 <= ref ? j <= ref : j >= ref; i = 1 <= ref ? ++j : --j) {
    timelineEntrys.push(~~(minEntryHeight + Math.random() * (maxEntryHeight - minEntryHeight)));
  }

  entrys = [[], []];

  toggle = 0;

  for (k = 0, len = timelineEntrys.length; k < len; k++) {
    entry = timelineEntrys[k];
    target = entrys[toggle > 0 ? 1 : 0];
    sign = toggle > 0 ? 1 : -1;
    if (Math.abs(toggle) < 1) {
      toggle = 0;
    }
    target.push({
      height: entry,
      top: (((ref1 = _.last(target)) != null ? ref1.top : void 0) || 0) + (((ref2 = _.last(target)) != null ? ref2.height : void 0) || 0) + gap
    });
    if (Math.abs(toggle) < gap && entrys[0].length > 0 && entrys[1].length > 0) {
      entrys[0][entrys[0].length - 1].height += gap * 2;
      entrys[1][entrys[1].length - 1].height += gap * 2;
    }
    toggle -= (entry + gap) * sign;
  }

  for (idx = l = 0, len1 = entrys.length; l < len1; idx = ++l) {
    side = entrys[idx];
    cssSide = idx === 0 ? "left" : "right";
    for (subIdx = m = 0, len2 = side.length; m < len2; subIdx = ++m) {
      entry = side[subIdx];
      $("." + cssSide).append("<div class=\"entry hidden\" style=\"\n  height: " + (entry.height - 30) + "px;\n  top:    " + entry.top + "px;\n\">\n  <header></header>\n  <article></article>\n</div>");
      if (idx > 0 || subIdx > 0) {
        $(".line").append("<div class=\"dot hidden\" style=\"\n  top: " + entry.top + "px;\n\"></div>");
      }
    }
  }

  totalHeight = Math.max(_.last(entrys[0]).top + _.last(entrys[0]).height, _.last(entrys[1]).top + _.last(entrys[1]).height);

  $(".line").css({
    "height": totalHeight + "px"
  });

  scroll = function() {
    var $this, docBottom, docTop, elem, hit, hits, len3, len4, n, o, ref3, results;
    docTop = $(document).scrollTop();
    docBottom = docTop + window.innerHeight;
    hits = [];
    ref3 = $(".entry, .dot");
    for (n = 0, len3 = ref3.length; n < len3; n++) {
      elem = ref3[n];
      $this = $(elem);
      if ($this.offset().top <= docBottom) {
        $this.removeClass("hidden");
      }
      if ($this.offset().top + $this.height() <= docTop && !$this.hasClass("hidden")) {
        $this.addClass("hidden");
      }
      if ($this.offset().top > docBottom + gap && !$this.hasClass("hidden")) {
        $this.addClass("hidden");
      }
      if ($this.hasClass("dot") && $this.offset().top > docTop && $this.offset().top < docTop + 40) {
        hits.push($this);
      }
    }
    if (hits.length > 0 && (!$(".year").hasClass("hit"))) {
      $(".year").addClass("hit");
    } else if (hits.length === 0 && $(".year").hasClass("hit")) {
      $(".year").removeClass("hit");
    }
    results = [];
    for (o = 0, len4 = hits.length; o < len4; o++) {
      hit = hits[o];
      if (!hit.hasClass("hidden")) {
        results.push(hit.addClass("hidden"));
      } else {
        results.push(void 0);
      }
    }
    return results;
  };

  $(document).scroll(function() {
    return scroll();
  });

  scroll();

}).call(this);

/* index.js */
$(".choose").click(function() {
  $(".choose").addClass("active");
  $(".choose > .icon").addClass("active");
  $(".pay").removeClass("active");
  $(".wrap").removeClass("active");
  $(".ship").removeClass("active");
  $(".pay > .icon").removeClass("active");
  $(".wrap > .icon").removeClass("active");
  $(".ship > .icon").removeClass("active");
  $("#line").addClass("one");
  $("#line").removeClass("two");
  $("#line").removeClass("three");
  $("#line").removeClass("four");
})

$(".pay").click(function() {
  $(".pay").addClass("active");
  $(".pay > .icon").addClass("active");
  $(".choose").removeClass("active");
  $(".wrap").removeClass("active");
  $(".ship").removeClass("active");
  $(".choose > .icon").removeClass("active");
  $(".wrap > .icon").removeClass("active");
  $(".ship > .icon").removeClass("active");
  $("#line").addClass("two");
  $("#line").removeClass("one");
  $("#line").removeClass("three");
  $("#line").removeClass("four");
})

$(".wrap").click(function() {
  $(".wrap").addClass("active");
  $(".wrap > .icon").addClass("active");
  $(".pay").removeClass("active");
  $(".choose").removeClass("active");
  $(".ship").removeClass("active");
  $(".pay > .icon").removeClass("active");
  $(".choose > .icon").removeClass("active");
  $(".ship > .icon").removeClass("active");
  $("#line").addClass("three");
  $("#line").removeClass("two");
  $("#line").removeClass("one");
  $("#line").removeClass("four");
})

$(".ship").click(function() {
  $(".ship").addClass("active");
  $(".ship > .icon").addClass("active");
  $(".pay").removeClass("active");
  $(".wrap").removeClass("active");
  $(".choose").removeClass("active");
  $(".pay > .icon").removeClass("active");
  $(".wrap > .icon").removeClass("active");
  $(".choose > .icon").removeClass("active");
  $("#line").addClass("four");
  $("#line").removeClass("two");
  $("#line").removeClass("three");
  $("#line").removeClass("one");
})

$(".choose").click(function() {
  $("#first").addClass("active");
  $("#second").removeClass("active");
  $("#third").removeClass("active");
  $("#fourth").removeClass("active");
})

$(".pay").click(function() {
  $("#first").removeClass("active");
  $("#second").addClass("active");
  $("#third").removeClass("active");
  $("#fourth").removeClass("active");
})

$(".wrap").click(function() {
  $("#first").removeClass("active");
  $("#second").removeClass("active");
  $("#third").addClass("active");
  $("#fourth").removeClass("active");
})

$(".ship").click(function() {
  $("#first").removeClass("active");
  $("#second").removeClass("active");
  $("#third").removeClass("active");
  $("#fourth").addClass("active");
})

/* index.js */
$(".choose").click(function() {
  $(".choose").addClass("active");
  $(".choose > .icon").addClass("active");
  $(".pay").removeClass("active");
  $(".wrap").removeClass("active");
  $(".ship").removeClass("active");
  $(".pay > .icon").removeClass("active");
  $(".wrap > .icon").removeClass("active");
  $(".ship > .icon").removeClass("active");
  $("#line").addClass("one");
  $("#line").removeClass("two");
  $("#line").removeClass("three");
  $("#line").removeClass("four");
})

$(".pay").click(function() {
  $(".pay").addClass("active");
  $(".pay > .icon").addClass("active");
  $(".choose").removeClass("active");
  $(".wrap").removeClass("active");
  $(".ship").removeClass("active");
  $(".choose > .icon").removeClass("active");
  $(".wrap > .icon").removeClass("active");
  $(".ship > .icon").removeClass("active");
  $("#line").addClass("two");
  $("#line").removeClass("one");
  $("#line").removeClass("three");
  $("#line").removeClass("four");
})

$(".wrap").click(function() {
  $(".wrap").addClass("active");
  $(".wrap > .icon").addClass("active");
  $(".pay").removeClass("active");
  $(".choose").removeClass("active");
  $(".ship").removeClass("active");
  $(".pay > .icon").removeClass("active");
  $(".choose > .icon").removeClass("active");
  $(".ship > .icon").removeClass("active");
  $("#line").addClass("three");
  $("#line").removeClass("two");
  $("#line").removeClass("one");
  $("#line").removeClass("four");
})

$(".ship").click(function() {
  $(".ship").addClass("active");
  $(".ship > .icon").addClass("active");
  $(".pay").removeClass("active");
  $(".wrap").removeClass("active");
  $(".choose").removeClass("active");
  $(".pay > .icon").removeClass("active");
  $(".wrap > .icon").removeClass("active");
  $(".choose > .icon").removeClass("active");
  $("#line").addClass("four");
  $("#line").removeClass("two");
  $("#line").removeClass("three");
  $("#line").removeClass("one");
})

$(".choose").click(function() {
  $("#first").addClass("active");
  $("#second").removeClass("active");
  $("#third").removeClass("active");
  $("#fourth").removeClass("active");
})

$(".pay").click(function() {
  $("#first").removeClass("active");
  $("#second").addClass("active");
  $("#third").removeClass("active");
  $("#fourth").removeClass("active");
})

$(".wrap").click(function() {
  $("#first").removeClass("active");
  $("#second").removeClass("active");
  $("#third").addClass("active");
  $("#fourth").removeClass("active");
})

$(".ship").click(function() {
  $("#first").removeClass("active");
  $("#second").removeClass("active");
  $("#third").removeClass("active");
  $("#fourth").addClass("active");
})

