winston = require 'winston'

log = new winston.Logger
  levels: winston.config.syslog.levels
  transports: [
    new winston.transports.Console
      level: "debug" 
      colorize: on
    new winston.transports.File
       level: "error"
       filename: 'logs/error.log'
       colorize: on
  ]
module.exports = log
