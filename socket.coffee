_ = require 'underscore'
coupier = require './coupier'

io = io
handlers = {}
namesUsed = []
lobby = []
rooms = []
users = {}

handlers['addUser'] = (socket) ->
  socket.on 'addUser', (e) ->
    nickname = e.nickname

    if ~namesUsed.indexOf(nickname)
      socket.emit 'nameResult',
        success:false
        message: 'Usuario existente'
      return

    namesUsed.push(nickname)
    users[socket.id] =
      nickname: nickname
      room: null

    if _.isEmpty(lobby)
      lobby.push(socket.id)

      socket.emit 'nameResult',
        success:true
        message: 'Buscando oponente'

      return

    retador = lobby.shift()
    desafiante = socket.id
    room = "#{retador}_#{desafiante}"
    mazo = coupier.new()

    socket.join(room)
    rooms[room] =
      retador: retador
      desafiante: desafiante
      mazo: coupier.new()

    io.sockets.socket(retador).join(room)
    users[retador].room = room


    users[desafiante] =
      nickname: nickname
      room: room

    io.sockets.socket(retador).emit 'reta',
      message: "Ya tienes reta contra #{retador}"
      data:
        oponente:
          id: retador
          name: nickname
          mano: mazo.desafiante
          cartas: mazo.cartas
        start: false


    socket.emit 'reta',
      message: "Ya tienes reta contra #{desafiante}"
      data:
        oponente:
          id: desafiante
          name: users[desafiante].nickname
          mano: mazo.retador
          cartas: mazo.cartas
        start: true

    usersInRoom = io.sockets.clients(room)
    console.log(usersInRoom)

    return

handlers['question'] = (socket) ->
  socket.on 'question', (e) ->
    user = users[socket.id]
    socket.broadcast.to(user.room).emit 'question', e

handlers['answer'] = (socket) ->
  socket.on 'answer', (e) ->
    user = users[socket.id]
    data = continue: true
    if e.key is '2'
      data.continue = false

    socket.broadcast.to(user.room).emit 'answer', data


exports.listen = (IO) ->
  io = IO
  io.on 'connection', (socket) ->
    _.each handlers, (handler) ->
      handler(socket)
      return