# LibWebSocket [![](http://travis-ci.org/imanel/libwebsocket.png)](http://travis-ci.org/imanel/libwebsocket)

A WebSocket message parser/constructor. It is not a server and is not meant to
be one. It can be used in any server, event loop etc.

## Server handshake

    h = LibWebSocket::OpeningHandshake::Server.new

    # Parse client request
    h.parse \<<EOF
    GET /demo HTTP/1.1
    Upgrade: WebSocket
    Connection: Upgrade
    Host: example.com
    Origin: http://example.com
    Sec-WebSocket-Key1: 18x 6]8vM;54 *(5:  {   U1]8  z [  8
    Sec-WebSocket-Key2: 1_ tx7X d  <  nw  334J702) 7]o}` 0

    Tm[K T2u
    EOF

    h.error # Check if there were any errors
    h.done? # Returns true

    # Create response
    h.to_s # HTTP/1.1 101 WebSocket Protocol Handshake
           # Upgrade: WebSocket
           # Connection: Upgrade
           # Sec-WebSocket-Origin: http://example.com
           # Sec-WebSocket-Location: ws://example.com/demo
           #
           # fQJ,fN/4F4!~K~MH

## Client handshake

    h = LibWebSocket::OpeningHandshake::Client.new(url => 'ws://example.com')

    # Create request
    h.to_s # GET /demo HTTP/1.1
           # Upgrade: WebSocket
           # Connection: Upgrade
           # Host: example.com
           # Origin: http://example.com
           # Sec-WebSocket-Key1: 18x 6]8vM;54 *(5:  {   U1]8  z [  8
           # Sec-WebSocket-Key2: 1_ tx7X d  <  nw  334J702) 7]o}` 0
           #
           # Tm[K T2u

    # Parse server response
    h.parse \<<EOF
    HTTP/1.1 101 WebSocket Protocol Handshake
    Upgrade: WebSocket
    Connection: Upgrade
    Sec-WebSocket-Origin: http://example.com
    Sec-WebSocket-Location: ws://example.com/demo

    fQJ,fN/4F4!~K~MH
    EOF

    h.error # Check if there were any errors
    h.done? # Returns true

## Parsing and constructing frames

    # Create frame
    frame = LibWebSocket::Frame.new('123')
    frame.to_s # \x00123\xff

    # Parse frames
    frame = LibWebSocket::Frame.new
    frame.append("123\x00foo\xff56\x00bar\xff789")
    frame.next # foo
    frame.next # bar

## Examples

For examples on how to use LibWebSocket with various event loops see
examples directory in the repository.

## Copyright

Copyright (C) 2012, Bernard Potocki.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
