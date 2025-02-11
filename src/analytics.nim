# src/analytics.nim
import stats
import times

type
  DataAnalytics = ref object
    windowSize: int  # Time window in seconds
    
proc analyzeTemperature*(data: seq[SensorData], deviceId: string): tuple[avg, min, max: float] =
  var temps: seq[float] = @[]
  let currentTime = getTime().toUnix
  
  for d in data:
    if d.deviceId == deviceId and (currentTime - d.timestamp) <= 3600:
      temps.add(d.temperature)
  
  if temps.len > 0:
    result = (
      avg: mean(temps),
      min: min(temps),
      max: max(temps)
    )
  else:
    result = (avg: 0.0, min: 0.0, max: 0.0)

