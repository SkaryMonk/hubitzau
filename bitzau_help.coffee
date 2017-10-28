# Description:
#   Generates help commands for Hubot.
#
# Commands:
#   hubot help - Displays all of the help commands that this bot knows about.
#   hubot help <query> - Displays all help commands that match <query>.
#
# URLS:
#   /hubot/help
#
# Configuration:
#   HUBOT_HELP_REPLY_IN_PRIVATE - if set to any avlue, all `hubot help` replies are sent in private
#   HUBOT_HELP_HIDDEN_COMMANDS - comma-separated list of commands that will not be displayed in help
#
# Notes:
#   These commands are grabbed from comment blocks at the top of each file.

module.exports = (robot) ->

  robot.respond /hilfe(?:\s+(.*))?$/i, (msg) ->
    cmds = getHelpCommands(robot)
    filter = msg.match[1]

    if filter
      cmds = cmds.filter (cmd) ->
        cmd.match new RegExp(filter, 'i')
      if cmds.length is 0
        msg.send "Der er slet ikke nogen kommando ved navn #{filter}!"
        return

    emit = cmds.join '\n'

    if process.env.HUBOT_HELP_REPLY_IN_PRIVATE and msg.message?.user?.name?
      msg.reply 'svarede i privaten!'
      robot.send { room: msg.message?.user?.name }, emit
    else
      msg.emote "letter på hatten."
      msg.send "Goddag. Jeg hedder Bitzau, og jeg er jo heller ikke ægte butler.\nJeg er søn af en sværdkæmper og har endnu ikke taget mig en uddannelse (eller klippet mit hår).\nMine tjenester inkluderer:"
      msg.send emit

getHelpCommands = (robot) ->
  help_commands = robot.helpCommands()

  robot_name = robot.alias or robot.name

  if hiddenCommandsPattern()
    help_commands = help_commands.filter (command) ->
      not hiddenCommandsPattern().test(command)

  help_commands = help_commands.map (command) ->
    if robot_name.length is 1
      command.replace /^hubot\s*/i, robot_name
    else
      command.replace /^hubot/i, robot_name

  help_commands.sort()

hiddenCommandsPattern = ->
  hiddenCommands = process.env.HUBOT_HELP_HIDDEN_COMMANDS?.split ','
  new RegExp "^hubot (?:#{hiddenCommands?.join '|'}) - " if hiddenCommands
