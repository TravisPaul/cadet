-- httpd shim for testing
-- example usage:
--   REQUEST_URI=/webhook/github lua ../src/webhook.lua

local httpd = {}
	
httpd.write = function (str)
  io.write(str)
end

httpd.print = function (str)
  io.write(str .. "\r\n")
end

httpd.register_handler = function (handler, fn)
  local env = {}
  local headers = {}
  local query = nil 
  local parts = {}
  local count = 0
  local request = nil
  local request_payload = os.getenv('REQUEST_PAYLOAD')
  if request_payload ~= nil then
    request = require(request_payload)
    env = request.env
    header = request.headers
    query = request.query
  else
    env.request_uri = os.getenv('REQUEST_URI')
    env.request_method = os.getenv('REQUEST_METHOD')
  end
  if env.request_uri == nil then
    httpd.print("HTTP/1.1 500 Internal Server Error") 
    httpd.print("Content-Type: text/plain") 
    httpd.print("No REQUEST_URI provided") 
    return 1
  end
  for word in string.gmatch(env.request_uri, '([^/]+)') do
    parts[count] = word
    count = count + 1
  end
  if parts[1] == handler then 
    return fn(env, headers, query)
  end
  httpd.print("HTTP/1.1 404 Not Found") 
  httpd.print("Content-Type: text/plain") 
  httpd.print("REQUEST_URI doesn't match handler") 
  httpd.print("REQUEST_URI=" .. env.request_uri) 
  httpd.print("handler=" .. handler)
end

return httpd
