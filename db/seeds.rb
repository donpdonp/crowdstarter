# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Tag.create({name: "frontpage"})
client = SETTINGS[:payment_gateways][:wepay][:client]
Gateway.create({"provider"=>"wepay",
                "access_key"=>client[:id],
                "access_secret"=>client[:secret],
                "sandbox"=>true})
