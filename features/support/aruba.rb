require 'aruba'
require 'fileutils'

APP_BIN_PATH = File.expand_path(File.dirname(__FILE__) + '/../../bin/giternal')

module Aruba
  module Api

    # override aruba to change command and don't change folder
    def run(cmd, fail_on_error=true)
      
      # run development version in verbose mode
      cmd = cmd.gsub(/^giternal/, "#{APP_BIN_PATH} --verbose")

      cmd = detect_ruby_script(cmd)
      cmd = detect_ruby(cmd)

      announce("$ #{cmd}") if @announce_cmd

      stderr_file = Tempfile.new('cucumber')
      stderr_file.close

      mode = RUBY_VERSION =~ /^1\.9/ ? {:external_encoding=>"UTF-8"} : 'r'
      IO.popen("#{cmd} 2> #{stderr_file.path}", mode) do |io|
        @last_stdout = io.read

        announce(@last_stdout) if @announce_stdout
      end

      @last_exit_status = $?.exitstatus

      @last_stderr = IO.read(stderr_file.path)

      announce(@last_stderr) if @announce_stderr

      if(@last_exit_status != 0 && fail_on_error)
        fail("Exit status was #{@last_exit_status}. Output:\n#{combined_output}")
      end

      @last_stderr

    end
  end
end
