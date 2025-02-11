# src/storage.nim
import db_sqlite
import json
import times

type
  DataStorage = ref object
    db: DbConn

proc newDataStorage(): DataStorage =
  result = DataStorage(
    db: open("iot_data.db", "", "", "")
  )
  
  # Create tables if they don't exist
  result.db.exec(sql"""
    CREATE TABLE IF NOT EXISTS sensor_data (
      id INTEGER PRIMARY KEY,
      device_id TEXT NOT NULL,
      timestamp INTEGER NOT NULL,
      temperature REAL,
      humidity REAL,
      pressure REAL,
      battery INTEGER
    )
  """)

proc storeSensorData*(storage: DataStorage, data: SensorData) =
  storage.db.exec(sql"""
    INSERT INTO sensor_data (device_id, timestamp, temperature, humidity, pressure, battery)
    VALUES (?, ?, ?, ?, ?, ?)
  """, data.deviceId, data.timestamp, data.temperature, data.humidity, data.pressure, data.battery)

