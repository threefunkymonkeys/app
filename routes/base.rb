module Routes
  class Base < Cuba
    define do
      on get, root do
        res.write view("pages/home", {}, "layout/home")
      end
    end
  end
end
