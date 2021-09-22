module BaseApp
  module Helpers
    def json_response(object, headers = {}, status = 200)
      headers.each do |k,v|
        res.headers[k.to_s] = v.to_s
      end

      res["Content-type"] = "application/json; encoding=utf-8"

      res.status = status

      res.write Oj.dump(object, mode: :compat)
      halt res.finish
    end

    def json_ok(object, headers = {})
      json_response(object, headers, 200)
    end

    def json_created(object, headers = {})
      json_response(object, headers, 201)
    end

    def json_error(body = {}, headers = {})
      body = { error: "Internal Server Error" } unless body.any?
      json_response(body, headers, 500)
    end

    def json_not_found
      json_response({ error: "Resource not found" }, {}, 404)
    end

    def json_bad_request(object = { error: "Bad request" })
      json_response(object, {}, 400)
    end

    def json_unauthorized
      json_response({ error: "Unauthorized" }, {},  401)
    end

    def no_content
      res.status = 204
      halt res.finish
    end
  end
end
