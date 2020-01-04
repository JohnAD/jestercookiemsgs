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


    source line: `117 <../src/jestercookiemsgs.nim#L117>`__



.. _CookieObj.type:
CookieObj
---------------------------------------------------------

    .. code:: nim

        CookieObj* = object
          cookie: string
          fromRequest*: seq[CookieMsg]
          fromRoute*: seq[CookieMsg]


    source line: `120 <../src/jestercookiemsgs.nim#L120>`__







Procs, Methods, Iterators
=========================


.. _htmlDivs.p:
htmlDivs
---------------------------------------------------------

    .. code:: nim

        proc htmlDivs*(data: CookieObj): string =

    source line: `201 <../src/jestercookiemsgs.nim#L201>`__

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

    source line: `214 <../src/jestercookiemsgs.nim#L214>`__

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

    source line: `166 <../src/jestercookiemsgs.nim#L166>`__

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







Table Of Contents
=================

1. `Introduction to jestercookiemsgs <https://github.com/JohnAD/jestercookiemsgs>`__
2. `plugin Reference <plugin-ref.rst>`__
3. Appendices

    A. `jestercookiemsgs Reference <jestercookiemsgs-ref.rst>`__
