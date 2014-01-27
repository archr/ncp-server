_ = require 'underscore'

animals = require('./dictionary').animals
people = require('./dictionary').people
verbs = require('./dictionary').verbs

nouns = _.union(animals, people)

exports.new = ->
  mazoNouns = _.shuffle(nouns)
  mazoVerbs = _.shuffle(verbs)

  desafiante = [mazoNouns[0], mazoVerbs[0], mazoNouns[1]]
  retador = [mazoNouns[2], mazoVerbs[1], mazoNouns[3]]

  return {
    desafiante: desafiante
    retador: retador
    cartas: {
      animals: animals
      people: people
      verbs: verbs
    }
  }


