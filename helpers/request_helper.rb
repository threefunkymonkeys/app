require "macaroons"

module BaseApp
  module Helpers
    def authorize_request(key)
      token = req.env["HTTP_AUTHORIZATION"]

      json_unauthorized unless token && token.strip.length > 0

      begin
        macaroon = Macaroon.from_binary(token)
        verifier = Macaroon::Verifier.new

        verifier.satisfy_general(method(:_check_user))

        verifier.verify(macaroon: macaroon, key: key)
      rescue => e
        logger.error(e.message)
        json_unauthorized
      end
    end

    def require_admin(key)
      token = req.env["HTTP_AUTHORIZATION"]

      json_unauthorized unless token && token.strip.length > 0

      begin
        macaroon = Macaroon.from_binary(token)
        verifier = Macaroon::Verifier.new

        verifier.satisfy_general(method(:_check_admin))

        verifier.verify(macaroon: macaroon, key: key)
      rescue => e
        logger.error(e.message)
        json_unauthorized
      end
    end

    def parse_params(body)
      begin
        Oj.load(body, mode: :compat)
      rescue
        json_bad_request(message: "Invalid JSON body")
      end
    end

    def current_user
      req.env["authenticated_user"]
    end

    def _check_user(caveat)
      property, value = caveat.split("=")

      case property.strip
      when "id"
        @user = User.find(email: value)

        return false unless @user

        if @roles
          @roles == @user.roles.join(",")
        end

        req.env["authenticated_user"] = @user

        !@user.nil?
      when "roles"
        if @user
          value == @user.roles.join(",")
        else
          @roles = value
        end
      end
    end

    def _check_admin(caveat)
      property, value = caveat.split("=")

      case property.strip
      when "id"
        @user = User.find(email: value)

        return false unless @user && @user.is_admin

        if @roles
          @roles == @user.roles.join(",")
        end

        req.env["authenticated_user"] = @user

        !@user.nil?
      when "roles"
        if @user
          @user.is_admin
        else
          @roles = value
        end
      end
    end

    def authenticated_user
      req.env.get("authenticated_user")
    end
  end
end

