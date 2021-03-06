jestercookiemsgs Reference
==============================================================================

The following are the references for jestercookiemsgs.



Types
=====



.. _CookieMsg.type:
CookieMsg
---------------------------------------------------------

    .. code:: nim

        CookieMsg* = object
          j*: string   # j = judgement; abbreviated to save json cookie space
          c*: string   # c = content; abbreviated to save json cookie space


    source line: `118 <../src/jestercookiemsgs.nim#L118>`__



.. _CookieObj.type:
CookieObj
---------------------------------------------------------

    .. code:: nim

        CookieObj* = object
          cookie: string
          fromRequest*: seq[CookieMsg]
          fromRoute*: seq[CookieMsg]


    source line: `121 <../src/jestercookiemsgs.nim#L121>`__







Procs, Methods, Iterators
=========================


.. _cookieMsgs.p:
cookieMsgs
---------------------------------------------------------

    .. code:: nim

        proc cookieMsgs*(request: Request, response: var ResponseData): CookieObj =

    source line: `145 <../src/jestercookiemsgs.nim#L145>`__

    This is the psuedo-procedure to invoke to enable the library plugin.
    
    Once placed on the main router or ``routes``, the plugin is active on
    all page routes.
    
    It creates a new object variable that is available to all routes including
    any ``extend``-ed subrouters.
    
    .. code:: nim
    
        routes:
          plugin cm <- cookieMsgs()
          get "/":
            cm.say("info", "AAA")
            redirect "/hello"
          get "/hello"
            cm.say("warning", "BBB")
            resp "hello. msg: " & cm.allMessages[0].c & cm.allMessages[1].c
            # when from /, will see: "hello. msg: AAABBB"
            # when direct, will see: "hello. msg: BBB"
    


.. _htmlDivs.p:
htmlDivs
---------------------------------------------------------

    .. code:: nim

        proc htmlDivs*(data: CookieObj): string =

    source line: `224 <../src/jestercookiemsgs.nim#L224>`__

    Generate an html string containing the message(s), each in contained
    in separate div in the form of:
    
    .. code:: html
    
        <div class="danger">Bad password</div>
        <div class="info">Please wait 4 minutes and try again.</div>


.. _htmlListItems.p:
htmlListItems
---------------------------------------------------------

    .. code:: nim

        proc htmlListItems*(data: CookieObj): string =

    source line: `237 <../src/jestercookiemsgs.nim#L237>`__

    Generate an html string containing the message(s), each in contained
    in separate list item in the form of:
    
    .. code:: html
    
        <li><span class="danger">Bad password</span></li>
        <li><span class="info">Please wait 4 minutes and try again.</span></li>
    
    note: the surrounding ``<ul>`` or ``<ol>`` elements are NOT generated.


.. _say.p:
say
---------------------------------------------------------

    .. code:: nim

        proc say*(data: var CookieObj, judgement: string, content: string) =

    source line: `188 <../src/jestercookiemsgs.nim#L188>`__

    This is the means of giving the plugin a messages.
    
    The ``judgement`` is simply a string variable and can contain anything. A common
    practice is to use the four strings standardized by `Bootstrap <https://getbootstrap.com/>`__ :
    
    * "success" - positive messages when something works as expected (green)
    * "warning" - cautionary messages (yellow)
    * "danger" - failure or negative messages, such as error messages (red)
    * "info" - purely informational messages (blue)
    
    The ``htmlDivs`` and ``htmlListItems`` output procs use the judgement as
    class names.
    
    The ``content`` string is the text message for display on the next page. It should
    support any legitimate UTF-8 string.


.. _toJson.p:
toJson
---------------------------------------------------------

    .. code:: nim

        proc toJson*(data: CookieObj): JsonNode =

    source line: `251 <../src/jestercookiemsgs.nim#L251>`__

    Generate JSON array of objects where each object has one message.
    
    Specifically, each object has a "judgement" and "text" field.







Table Of Contents
=================

1. `Introduction to jestercookiemsgs <https://github.com/JohnAD/jestercookiemsgs>`__
2. Appendices

    A. `jestercookiemsgs Reference <jestercookiemsgs-ref.rst>`__
