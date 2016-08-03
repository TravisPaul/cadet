-- httpd shim for testing
local httpd = {}

httpd.silent = false
httpd.buffer = ''

httpd.write = function (str)
  httpd.buffer = httpd.buffer .. str
  if httpd.silent ~= true then
    io.write(str)
  end
end

httpd.print = function (str)
  httpd.buffer = httpd.buffer .. str
  if httpd.silent ~= true then
    io.write(str .. "\r\n")
  end
end

httpd.register_handler = function (handler, fn)
  local env = {}
  local headers = {}
  local query = nil 
  local parts = {}
  local count = 0
  if httpd.mock_request ~= nil then
    env = mock_request.env
    header = mock_request.headers
    query = mock_request.query
    httpd.mock_request = nil
  else
    env.REQUEST_URI = os.getenv('REQUEST_URI')
    env.REQUEST_METHOD = os.getenv('REQUEST_METHOD')
  end
  if env.REQUEST_URI == nil then
    httpd.print("HTTP/1.1 500 Internal Server Error") 
    httpd.print("Content-Type: text/plain") 
    httpd.print("No REQUEST_URI provided") 
    return 1
  end
  for word in string.gmatch(env.REQUEST_URI, '([^/]+)') do
    parts[count] = word
    count = count + 1
  end
  if parts[1] == handler then 
    return fn(env, headers, query)
  end
  httpd.print("HTTP/1.1 404 Not Found") 
  httpd.print("Content-Type: text/plain") 
  httpd.print("REQUEST_URI doesn't match handler") 
  httpd.print("REQUEST_URI=" .. env.REQUEST_URI) 
  httpd.print("handler=" .. handler)
end

return httpd
