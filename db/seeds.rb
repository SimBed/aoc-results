# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

Player.create([{ first_name: 'Anne', last_name: 'Rosen' },
  { first_name: 'Catherine', last_name: 'Seale' },
  { first_name: 'Sheila', last_name: 'Mattison' },
  { first_name: 'Isobel', last_name: 'Vardy' }
  ])

Comp.create([{date:'2021-10-01'}, {date:'2021-10-02'}])

Pair.create(player1_id: Player.find_by(last_name:'Rosen').id, player2_id: Player.find_by(last_name:'Seale').id)
Pair.create(player1_id: Player.find_by(last_name:'Mattison').id, player2_id: Player.find_by(last_name:'Vardy').id)

RelPairComp.create(pair_id: Pair.find_by(player1_id: Player.find_by(last_name:'Rosen').id).id, comp_id: 1,score: 65)
RelPairComp.create(pair_id: Pair.find_by(player1_id: Player.find_by(last_name:'Mattison').id).id, comp_id: 1,score: 64)
