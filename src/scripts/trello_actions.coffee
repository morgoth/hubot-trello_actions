# Description:
#   Notifies about actions on Trello board
#
# Dependencies:
#   node-trello
#
# Configuration:
#   HUBOT_TRELLO_KEY
#   HUBOT_TRELLO_TOKEN
#   HUBOT_TRELLO_BOARD
#   HUBOT_TRELLO_NOTIFY_ROOM (optional)
#
# Commands:
#
# Author:
#   Wojciech Wnętrzak

Trello = require "node-trello"
feedFrequency = 60000

# Trello
key     = process.env.HUBOT_TRELLO_KEY
token   = process.env.HUBOT_TRELLO_TOKEN
boardId = process.env.HUBOT_TRELLO_BOARD

# Notify room. Defaults to Campfire
notifyRoom = process.env.HUBOT_TRELLO_NOTIFY_ROOM || process.env.HUBOT_CAMPFIRE_ROOMS.split(",")[0]

trello = new Trello(key, token)

module.exports = (robot) ->
  formattedAction = (action) ->
    parts = ["[Trello]"]
    action.entities.forEach (entity) ->
      parts.push entity.text
    parts.join(" ")

  # https://trello.com/docs/api/board/index.html#get-1-boards-board-id-actions
  actionFilter =
    # "all"
    "addAttachmentToCard,addMemberToBoard,commentCard,createCard,moveCardFromBoard,moveListFromBoard,moveCardToBoard,moveListToBoard,updateCard,updateCheckItemStateOnCard"

  storeLastActionDate = (date) ->
    robot.brain.data.trello_last_action_date = date

  lastActionDate = ->
    robot.brain.data.trello_last_action_date ||= (new Date()).toISOString()

  getFeed = ->
    trello.get "/1/boards/#{boardId}/actions", {filter: actionFilter, entities: true, fields: "date", since: lastActionDate()}, (error, data) ->
      if data.length
        messages = []
        storeLastActionDate(data[0].date)
        data.forEach (action) ->
          messages.push formattedAction(action)
        robot.messageRoom(notifyRoom, messages.join("\n"))

  subscribe = ->
    getFeed()

    setTimeout (->
      subscribe()
    ), feedFrequency

  subscribe()
