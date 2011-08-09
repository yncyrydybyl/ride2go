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
      level: "notice" 
      colorize: on
    new winston.transports.File
       level: "error"
       filename: 'logs/error.log'
       colorize: on
  ]
module.exports = log
