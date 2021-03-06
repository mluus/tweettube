# Meteor.publish "onlineusers", (options) ->
#   Meteor.users.find()

Meteor.publish "onlineusers", (isOnline, programId) ->
  Meteor.users.find()


Meteor.methods
  UserUpsert: (id, programId) ->
  #  console.log "upsert: " + id + " " + programId
    timestamp = (new Date()).getTime()
    Meteor.users.upsert({_id: id}, {$set: {lastseen: timestamp, lastroom: programId, online: true}})

helper = ->
    checkTime = ->
      onlineusers = Meteor.users.find().fetch()
      for m in onlineusers
        if !m.lastseen?
          time = parseInt((new Date()).getTime())
        else
          time = parseInt((new Date()).getTime() - m.lastseen)
        #console.log  "id: "+ m._id + ", time lapse: "+ time
        if (time < 10000)
          Meteor.users.upsert({_id:m._id}, {$set: {online:true}})
        else
          Meteor.users.upsert({_id:m._id}, {$set: {online:false}})          


    Fiber = Npm.require('fibers')
    Fiber(-> checkTime()).run()
    console.log "reached helper"



Meteor.onConnection ->

  console.log "new connection"
  setInterval (-> helper()), 10000
  console.log "passed setinterval"
