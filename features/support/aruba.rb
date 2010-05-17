require 'aruba'
require 'fileutils'

APP_BIN_PATH = File.expand_path(File.dirname(__FILE__) + '/../../bin/giternal')

module Aruba
  module Api

    alias_method :old_run, :run

    # for test readability, override aruba to change path
    def run(cmd, fail_on_error=true)
      
      # run development version in verbose mode
      cmd = cmd.gsub(/^giternal/, "#{APP_BIN_PATH} --verbose")
      
      # run original aruba 'run' 
      old_run(cmd, fail_on_error)

    end
  end
end
