package.path = package.path .. ";?.lua"
local httpd = require 'httpd'
local cadet = require 'cadet'
local methods = {}

cadet.response.status = 501
cadet.before = function (cadet)
  if (cadet.response.status >= 400) then
    local view = {
        status = cadet.response.status,
        message = cadet.status_map[cadet.response.status],
    }
    cadet.render_file_write("example/error/error.html", view)
  end
end

methods.HEAD = function (cadet, env, headers, query)
	cadet.response.status = 200
end

methods.DELETE = function (cadet, env, headers, query)
	cadet.response.status = 405
end

function error(env, headers, query)
  local handler = methods[env.request_method] 
  if (handler ~= nil) then
    handler(cadet, env, headers, query)
  end
  return cadet.finish()
end

httpd.register_handler('index', error)
