class BaseRoutes < Cuba
  define do
    on get, root do
      res.write view("pages/home", {}, "layout/home")
    end
  end
end
