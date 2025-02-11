# mynimapp.nimble
version       = "0.1.0"
author        = "Eduard"
description   = "IoT Data Streaming Service"
license       = "MIT"
srcDir        = "src"
bin           = @["app"]

requires "nim >= 2.2.0", "jester"


# bin           = @["iot_stream"]

requires "nim >= 1.6.0"
# requires "jester >= 0.5.0"
requires "websocket >= 0.4.1"
requires "chronicles >= 0.10.2"
requires "serialport >= 1.1.4"
