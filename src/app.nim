# src/app.nim
import jester

routes:
  get "/":
    resp "Hello, Nim Web Server!"

echo "Server running on http://localhost:5000"
runForever()

# Run the server with a shutdown handler
# try:
#  runForever() or runForever(1)
# except:
#  when getCurrentException().name == "SIGINT":
#    echo "\nServer interrupted, shutting down..."
