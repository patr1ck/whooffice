whooffice
=========

Whooffice is a very bare-bones set of tools which you can use to have Hubot tell you who is current in your office. It works based on network presence: if someone who owns a particular device (phone, laptop, etc) is visible on the network, they are considered present.

It has 3 components:

whoofficed
----------
A Mac OS X daemon app that polls mDNS at set intervals to see who is around, and submits the data to a server.

whooffice-web
-------------
A activerecord using sinatra app which logs all the submissions from whoofficed, and can vend information about who is currently around.

whooffice-hubot
---------------
The hubot plugin which talks to whooffice-web for data and tells you about it.