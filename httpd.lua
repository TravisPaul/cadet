-- httpd shim for testing
-- example usage:
--   REQUEST_URI=/greetings/index lua example/greetings/greetings.lua
local httpd = {}
	
httpd.write = function (str)
    io.write(str)
end

httpd.register_handler = function (handler, fn)
    local request_uri = os.getenv('REQUEST_URI')
    local parts = {}
    local count = 0
    if (request_uri == nil) then
        httpd.write("HTTP/1.1 500 Internal Server Error\r\n") 
        httpd.write("Content-Type: text/plain\r\n") 
        httpd.write("Content-Length: 23\r\n\r\n") 
        httpd.write("No REQUEST_URI provided") 
        return 1
    end
    for word in string.gmatch(request_uri, '([^/]+)') do
        parts[count] = word
        count = count + 1
    end
    if (parts[1] == handler) then 
        return fn({},{},{})
    end
    httpd.write("HTTP/1.1 404 Not Found\r\n") 
    httpd.write("Content-Type: text/plain\r\n") 
    httpd.write("Content-Length: 33\r\n\r\n") 
    httpd.write("REQUEST_URI doesn't match handler") 
end

return httpd
