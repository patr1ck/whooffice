# Display the names of the people currently in the office
#
# who is around - Lists out everyone in the office
#

module.exports = (robot) ->
	robot.respond /who is around/i, (msg) ->
		msg.http("http://localhost:9292/in_office.json")
		.get() (err, res, body) ->
			inOffice = JSON.parse(body)
			message = "People in the office as of #{inOffice['time']}: "
			names = inOffice['in_office'] 
			message = message + ' ' + name for name in names 
			msg.send(message)
