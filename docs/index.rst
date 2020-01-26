Introduction to jestercookiemsgs
==============================================================================
ver 1.0.0

This is a plugin for the nim web
framework `Jester <https://github.com/dom96/jester>`__. It enables easy
message passing between web pages using browser cookies.

HOW TO USE
==========

1. Include the plugin ``cookieMsgs()`` at the top of your main ``routes``
   or primary ``router``. This will enable the plugin for the whole web site.

2. Use the object variable created to access the ``say`` and related procedures.

3. Add the display of your messages to each web page should such a message
   be ready. (Again, using the object variable created.)

EXAMPLE
=======

.. code:: nim


    import htmlgen
    import strutils
    import jester
    import jestercookiemsgs


    const indexTemplate = """<html>
      <title>My Website</title>
      <body>
        <div class="header">
          <ul>
            $1
          </ul>
        </div>
        <p>
          $2
        </p>
        <form action="" method="POST">
          <input type="text" name="name" value="" />
          <button type="submit">Send Name</button>
        </form>
      </body>
    </html>
    """

    const helloTemplate = """<html>
      <title>My Website</title>
      <body>
        <div class="header">
          <ul>
            $1
          </ul>
        </div>
        <p>
          $2
        </p>
      </body>
    </html>
    """

    proc indexPage(cm: CookieObj): string =
      let messages = cm.htmlListItems()
      let main = "This is my Website"
      result = indexTemplate % [messages, main]


    proc helloPage(name: string, cm: CookieObj): string =
      let messages = cm.htmlListItems()
      let main = "Welcome, $1" % [name]
      result = helloTemplate % [messages, main]


    routes:
      plugin cm <- cookieMsgs()
      get "/":
        resp indexPage(cm)
      post "/":
        if request.params["name"] == "Joe":
          cm.say("success", "I like that name.")
          redirect "/hello/$1" % [request.params["name"]]
        else:
          cm.say("danger", "That isn't a name I like.")
          redirect "/"
      get "/hello/@name":
        resp helloPage(@"name", cm)


HOW IT WORKS
============

Whenever request is received by the Jester web server, the plugin first
checks for a cookie labeled "messages". If it finds that cookie, it decodes
the messages from the previous page and stores them in created variable as
part of the ``fromRequest`` array,.

Then the route runs as normally. If any new ``say`` procedures are run, those
new messages are stored in the ``fromRoute`` array.

When the route ends, if it terminates with:

*  **resp**, then it is assumed that your template displayed the routes and the
   plugin empties the contents of the "messages" cookie.

*  **redirect**, then all messages found in both ``fromRequest`` and ``fromRoute``
   are encoded by the plugin into a new "messages" cookie for the next page to find.
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
2. Appendices

    A. `jestercookiemsgs Reference <jestercookiemsgs-ref.rst>`__
