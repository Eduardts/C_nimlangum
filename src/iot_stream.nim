# src/iot_stream.nim
import jester
import asyncdispatch
import json
import streams
import tables
import times
import chronicles
import websocket

type
  SensorData = object
    deviceId: string
    timestamp: int64
    temperature: float
    humidity: float
    pressure: float
    battery: int

  DataStream = ref object
    buffer: seq[SensorData]
    maxSize: int

# Initialize data stream handler
var dataStream = DataStream(
  buffer: @[],
  maxSize: 1000
)

# Data processing pipeline
proc processSensorData(data: SensorData): JsonNode =
  result = %*{
    "deviceId": data.deviceId,
    "timestamp": data.timestamp,
    "temperature": data.temperature,
    "humidity": data.humidity,
    "pressure": data.pressure,
    "battery": data.battery,
    "processed_at": getTime().toUnix
  }

# WebSocket handler for real-time data streaming
proc handleWebSocket(ws: WebSocket) {.async.} =
  while ws.readyState == Open:
    try:
      let msg = await ws.receiveStrPacket()
      let data = parseJson(msg)
      let sensorData = SensorData(
        deviceId: data["deviceId"].getStr,
        timestamp: getTime().toUnix,
        temperature: data["temperature"].getFloat,
        humidity: data["humidity"].getFloat,
        pressure: data["pressure"].getFloat,
        battery: data["battery"].getInt
      )
      
      # Process data
      let processedData = processSensorData(sensorData)
      
      # Store in buffer
      if dataStream.buffer.len >= dataStream.maxSize:
        dataStream.buffer.delete(0)
      dataStream.buffer.add(sensorData)
      
      # Send processed data back
      await ws.send($processedData)
    except:
      error "WebSocket error: ", getCurrentExceptionMsg()
      break

# REST API routes
routes:
  get "/":
    resp "IoT Data Streaming Service"

  get "/ws":
    try:
      var ws = await newWebSocket(request)
      await handleWebSocket(ws)
    except:
      error "WebSocket connection error: ", getCurrentExceptionMsg()
      resp Http500, "WebSocket connection failed"

  get "/api/data":
    let data = %* dataStream.buffer
    resp Http200, $data

  post "/api/data":
    try:
      let data = parseJson(request.body)
      let sensorData = SensorData(
        deviceId: data["deviceId"].getStr,
        timestamp: getTime().toUnix,
        temperature: data["temperature"].getFloat,
        humidity: data["humidity"].getFloat,
        pressure: data["pressure"].getFloat,
        battery: data["battery"].getInt
      )
      
      # Process and store data
      let processedData = processSensorData(sensorData)
      if dataStream.buffer.len >= dataStream.maxSize:
        dataStream.buffer.delete(0)
      dataStream.buffer.add(sensorData)
      
      resp Http200, $processedData
    except:
      error "Data processing error: ", getCurrentExceptionMsg()
      resp Http400, "Invalid data format"

