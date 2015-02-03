module Authentication
  class ErrorHandler
    def handle(_env, e)
      fail(e)
    end
  end
end
