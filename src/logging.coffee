winston = require 'winston'

#  debug: 0
#  info: 1
#  notice: 2
#  warning: 3
#  error: 4
#  crit: 5
#  alert: 6
#  emerg: 7 

log = new winston.Logger
  levels: winston.config.syslog.levels
  transports: [
    new winston.transports.Console
      level: "debug"
      colorize: on
#    new winston.transports.File
 #     level: "error"
  #    filename: 'logs/error.log'
   #   colorize: on
#    new winston.transports.File
 #     level: "info"
  #    colorize: off
   #   filename: 'logs/server.log'
  ]
module.exports = log
