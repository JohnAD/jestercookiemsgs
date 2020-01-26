import times
import base64
import strutils
import json

import
  jester

## This is a plugin for the nim web
## framework `Jester <https://github.com/dom96/jester>`__. It enables easy
## message passing between web pages using browser cookies.
##
## HOW TO USE
## ==========
##
## 1. Include the plugin ``cookieMsgs()`` at the top of your main ``routes``
##    or primary ``router``. This will enable the plugin for the whole web site.
##
## 2. Use the object variable created to access the ``say`` and related procedures.
##
## 3. Add the display of your messages to each web page should such a message
##    be ready. (Again, using the object variable created.)
##
## EXAMPLE
## =======
##
## .. code:: nim
##
##
##     import htmlgen
##     import strutils
##     import jester
##     import jestercookiemsgs
##     
##     
##     const indexTemplate = """<html>
##       <title>My Website</title>
##       <body>
##         <div class="header">
##           <ul>
##             $1
##           </ul>
##         </div>
##         <p>
##           $2
##         </p>
##         <form action="" method="POST">
##           <input type="text" name="name" value="" />
##           <button type="submit">Send Name</button>
##         </form>
##       </body>
##     </html>
##     """
##     
##     const helloTemplate = """<html>
##       <title>My Website</title>
##       <body>
##         <div class="header">
##           <ul>
##             $1
##           </ul>
##         </div>
##         <p>
##           $2
##         </p>
##       </body>
##     </html>
##     """
##     
##     proc indexPage(cm: CookieObj): string =
##       let messages = cm.htmlListItems()
##       let main = "This is my Website"
##       result = indexTemplate % [messages, main]
##     
##     
##     proc helloPage(name: string, cm: CookieObj): string =
##       let messages = cm.htmlListItems()
##       let main = "Welcome, $1" % [name]
##       result = helloTemplate % [messages, main]
##     
##     
##     routes:
##       plugin cm <- cookieMsgs()
##       get "/":
##         resp indexPage(cm)
##       post "/":
##         if request.params["name"] == "Joe":
##           cm.say("success", "I like that name.")
##           redirect "/hello/$1" % [request.params["name"]]
##         else:
##           cm.say("danger", "That isn't a name I like.")
##           redirect "/"
##       get "/hello/@name":
##         resp helloPage(@"name", cm)
##
##
## HOW IT WORKS
## ============
##
## Whenever request is received by the Jester web server, the plugin first
## checks for a cookie labeled "messages". If it finds that cookie, it decodes
## the messages from the previous page and stores them in created variable as
## part of the ``fromRequest`` array,.
##
## Then the route runs as normally. If any new ``say`` procedures are run, those
## new messages are stored in the ``fromRoute`` array.
##
## When the route ends, if it terminates with:
##
## *  **resp**, then it is assumed that your template displayed the routes and the
##    plugin empties the contents of the "messages" cookie.
##
## *  **redirect**, then all messages found in both ``fromRequest`` and ``fromRoute``
##    are encoded by the plugin into a new "messages" cookie for the next page to find.

type
  CookieMsg* = object
    j*: string   # j = judgement; abbreviated to save json cookie space
    c*: string   # c = content; abbreviated to save json cookie space
  CookieObj* = object
    cookie: string
    fromRequest*: seq[CookieMsg]
    fromRoute*: seq[CookieMsg]


proc decode_cookie(cookie: string): seq[CookieMsg] =
  # This function is designed to "always work" (crashing a page is never good.)
  # But, on a real failure, a message is printed on the terminal screen for diagnostics.
  try:
    let jsonText = decode(cookie)
    let jsonReal = parseJson(jsonText)
    for msgNode in jsonReal:
      try:
        var newMsg = CookieMsg()
        newMsg.j = msgNode["j"].getStr
        newMsg.c = msgNode["c"].getStr
        result.add newMsg
      except:
        echo "cookieMsgs ERROR: could not interpret $1 (msg $2)".format(cookie, $msgNode)
  except:
    echo "cookieMsgs ERROR: could not interpret $1".format(cookie)


proc cookieMsgs*(request: Request, response: var ResponseData): CookieObj =  #SKIP!
  ## This is the psuedo-procedure to invoke to enable the library plugin.
  ## 
  ## Once placed on the main router or ``routes``, the plugin is active on
  ## all page routes.
  ## 
  ## It creates a new object variable that is available to all routes including
  ## any ``extend``-ed subrouters.
  ##   
  ## .. code:: nim
  ##  
  ##     routes:
  ##       plugin cm <- cookieMsgs()
  ##       get "/":
  ##         cm.say("info", "AAA")
  ##         redirect "/hello"
  ##       get "/hello"
  ##         cm.say("warning", "BBB")
  ##         resp "hello. msg: " & cm.allMessages[0].c & cm.allMessages[1].c
  ##         # when from /, will see: "hello. msg: AAABBB"
  ##         # when direct, will see: "hello. msg: BBB"
  ## 
  # This is the "before" portion of the plugin. Do not run
  # this procedure directly, it is used by the plugin itself.
  if request.cookies.hasKey("messages"):
    result.cookie = request.cookies["messages"]
    result.fromRequest = decode_cookie(result.cookie)


proc cookieMsgs_after*(request: Request, response: var ResponseData, data: CookieObj) = #SKIP!
  # This is the "after" portion of the plugin. Do not run
  # this procedure directly, it is used by the plugin itself.
  case response.action:
  of TCActionSend:
    let allMsgs = %*(data.fromRoute)
    var jsonText = ""
    toUgly(jsonText, allMsgs)
    jsonText = encode(jsonText)
    response.setCookieResponse("messages", jsonText, daysForward(1), path="/")
  else:
    response.setCookieResponse("messages", "", parse("1970-01-01", "yyyy-MM-dd"), path="/")


proc say*(data: var CookieObj, judgement: string, content: string) =
  ## This is the means of giving the plugin a messages.
  ##
  ## The ``judgement`` is simply a string variable and can contain anything. A common
  ## practice is to use the four strings standardized by `Bootstrap <https://getbootstrap.com/>`__ :
  ##
  ## * "success" - positive messages when something works as expected (green)
  ## * "warning" - cautionary messages (yellow)
  ## * "danger" - failure or negative messages, such as error messages (red)
  ## * "info" - purely informational messages (blue)
  ##
  ## The ``htmlDivs`` and ``htmlListItems`` output procs use the judgement as
  ## class names.
  ##
  ## The ``content`` string is the text message for display on the next page. It should
  ## support any legitimate UTF-8 string.
  var newMsg = CookieMsg()
  newMsg.j = judgement
  newMsg.c = content
  data.fromRoute.add newMsg


proc allMessages(data: CookieObj): seq[CookieMsg] =
  ## Return a sequence of messages that includes both the messages from the
  ## previous page as well as any messages generated by the current page. The
  ## messages from the previous page are first. Otherwise, order is preserved.
  ##
  ## Each message has a ``.j`` attribute for the ``judgement`` of the message,
  ## and a ``.c`` attribute for the message itself. Both are strings.
  result = @[]
  for cm in data.fromRequest:
    result.add cm
  for cm in data.fromRoute:
    result.add cm


proc htmlDivs*(data: CookieObj): string =
  ## Generate an html string containing the message(s), each in contained
  ## in separate div in the form of:
  ##
  ## .. code:: html
  ##
  ##     <div class="danger">Bad password</div>
  ##     <div class="info">Please wait 4 minutes and try again.</div>
  result = ""
  for msg in data.allMessages():
    result &= "<div class=\"$1\">$2</div>\n".format(msg.j, msg.c)


proc htmlListItems*(data: CookieObj): string =
  ## Generate an html string containing the message(s), each in contained
  ## in separate list item in the form of:
  ##
  ## .. code:: html
  ##
  ##     <li><span class="danger">Bad password</span></li>
  ##     <li><span class="info">Please wait 4 minutes and try again.</span></li>
  ##
  ## note: the surrounding ``<ul>`` or ``<ol>`` elements are NOT generated.
  result = ""
  for msg in data.allMessages():
    result &= "<li><span class=\"$1\">$2</span></li>\n".format(msg.j, msg.c)
