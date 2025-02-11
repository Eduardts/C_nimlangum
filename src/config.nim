# src/config.nim
import parsecfg
import os

type
  ServerConfig = object
    port: int
    maxBufferSize: int
    dataRetentionDays: int
    alertThresholds: Table[string, float]

proc loadConfig*(): ServerConfig =
  let dict = loadConfig("config.ini")
  result = ServerConfig(
    port: dict.getSectionValue("Server", "port").parseInt,
    maxBufferSize: dict.getSectionValue("Data", "maxBufferSize").parseInt,
    dataRetentionDays: dict.getSectionValue("Data", "retentionDays").parseInt
  )

