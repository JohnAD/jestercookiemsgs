plugin Reference
==============================================================================

The following are the references for JesterCookieMsgs plugin.



Plugins
=======


.. _cookieMsgs.plugin:
cookieMsgs
---------------------------------------------------------

    .. code:: nim

        cookieMsgs*(): CookieObj =

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




Table Of Contents
=================

1. `Introduction to jestercookiemsgs <https://github.com/JohnAD/jestercookiemsgs>`__
2. `plugin Reference <plugin-ref.rst>`__
3. Appendices

    A. `jestercookiemsgs Reference <jestercookiemsgs-ref.rst>`__
