# Description:
#   Notifies about actions on Trello board
#
# Dependencies:
#   node-trello
#
# Configuration:
#   HUBOT_TRELLO_KEY
#   HUBOT_TRELLO_TOKEN
#   HUBOT_TRELLO_BOARDS (separated by comma)
#   HUBOT_TRELLO_NOTIFY_ROOM (optional)
#
# Commands:
#
# Author:
#   Wojciech Wnętrzak

Trello = require "node-trello"
feedFrequency = 60000

# Trello
key    = process.env.HUBOT_TRELLO_KEY
token  = process.env.HUBOT_TRELLO_TOKEN
boards = process.env.HUBOT_TRELLO_BOARDS

# Notify room. Defaults to Campfire
notifyRoom = process.env.HUBOT_TRELLO_NOTIFY_ROOM || process.env.HUBOT_CAMPFIRE_ROOMS.split(",")[0]

trello = new Trello(key, token)

module.exports = (robot) ->
  formattedAction = (action) ->
    entities = action.entities.map(formattedEntity)
    ["[Trello]"].concat(entities).join(" ")

  formattedEntity = (entity) ->
    if entity.type in ["card", "checkItem"]
      # Display card title in quotes
      "\"#{entity.text}\""
    else if entity.type == "comment"
      # Display comment content in new line
      "\n#{entity.text}"
    else
      entity.text

  # https://trello.com/docs/api/board/index.html#get-1-boards-board-id-actions
  actionFilter =
    "addAttachmentToCard,addMemberToBoard,addMemberToCard,commentCard,createCard,moveCardFromBoard,moveListFromBoard,moveCardToBoard,moveListToBoard,updateCard,updateCheckItemStateOnCard"

  storeLastActionDate = (board, date) ->
    robot.brain.data.trello_last_action_dates[board] = date

  lastActionDate = (board) ->
    robot.brain.data.trello_last_action_dates ||= {}
    robot.brain.data.trello_last_action_dates[board] ||= (new Date()).toISOString()

  getFeed = (board) ->
    trello.get "/1/boards/#{board}/actions", {filter: actionFilter, entities: true, fields: "date", since: lastActionDate(board)}, (error, data) ->
      if data.length
        storeLastActionDate(board, data[0].date)
        messages = data.reverse().map(formattedAction)
        robot.messageRoom(notifyRoom, messages.join("\n"))

  subscribe = ->
    boards.split(",").forEach(getFeed)

    setTimeout (->
      subscribe()
    ), feedFrequency

  subscribe()
