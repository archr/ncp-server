app = require('express')()
http = require('http')
server = http.createServer(app)
io = require('socket.io').listen(server)
socket = require('./socket').listen(io)

server.listen(5000)

app.get '/ping', 
	(req, res) -> res.send('Ok')

io.on 'connection', (socket) ->
	socket.emit 'init',
		success:true

	socket.on 'joinUser', (e)->
		console.log 'joinUser', e
		socket.broadcast.emit('newUser')


