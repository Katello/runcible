module Runcible
  class Logger
    attr_accessor :message
    alias_method :debug, :message=
    alias_method :error, :message=
  end
end
