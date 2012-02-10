# Display the names of the people currently in the office
#
# who is around - Lists out everyone in the office
#

module.exports = (robot) ->
  robot.respond /who is around/i, (msg) ->
    search = escape(msg.match[1])
    