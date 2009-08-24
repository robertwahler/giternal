require 'fileutils'

require 'term/ansicolor'
class String
  include Term::ANSIColor
end

module Giternal
  class Repository
    class << self
      attr_accessor :verbose
    end
    attr_accessor :verbose

    def initialize(base_dir, name, repo_url, rel_path)
      @base_dir = base_dir
      @name = name
      @repo_url = repo_url
      @rel_path = rel_path
      @verbose = self.class.verbose
    end

    def status
      # TODO: enable this when verbose is a command line option
      #puts "Getting status of #{@name}" if verbose
      if frozen?
        log = execute_on_frozen { `cd #{repo_path} && git log -1 --pretty=format:"Last commit %h was %cr" 2>&1` } 
        # TODO: sha = log.match("/Last commit (.*) was/")
        message = "#{@name} is frozen"
        message = "#{message}: #{log}" 
        puts message.cyan
      elsif checked_out?
        if !File.exist?(repo_path + '/.git')
          raise "Directory '#{@name}' exists but is not a git repository"
        else
          status = `cd #{repo_path} && git status 2>&1` 
          log = `cd #{repo_path} && git log -1 --pretty=format:"Last commit %h was %cr" 2>&1` 
          # check if clean, format one line if so
          if status.match(/nothing to commit/) then
            message = "#{@name} is clean"
            message = "#{message}: #{log}" 
            puts message
          else
            puts "#{@name} has changed".yellow
            puts status
            # todo colorize log
            puts log
          end
        end
      else
        puts "#{@name} does not exist, run update first".red
      end
      true
    end

    def update
      git_ignore_self

      if frozen?
        puts "#{@name} is frozen".cyan
        return true
      end

      FileUtils.mkdir_p checkout_path unless File.exist?(checkout_path)
      if checked_out?
        if !File.exist?(repo_path + '/.git')
          raise "Directory '#{@name}' exists but is not a git repository"
        else
          update_output { `cd #{repo_path} && git pull 2>&1` }
        end
      else
        update_output { `cd #{checkout_path} && git clone #{@repo_url} #{@name} 2>&1` }
      end
      true
    end

    def execute_on_frozen(&block)
      raise "execute_on_frozen called on unfrozen repo" unless frozen?
      result = ""
      
      # unpack repo temporarily
      Dir.chdir(repo_path) do
        `tar xzf .git.frozen.tgz`
        result = block.call
        # clean up
        FileUtils.rm_r('.git')
      end

      result
    end

    def freezify
      return true if frozen? || !checked_out?

      Dir.chdir(repo_path) do
        `tar czf .git.frozen.tgz .git`
        FileUtils.rm_r('.git')
      end
      `cd #{@base_dir} && git add -f #{rel_repo_path}`
      true
    end

    def unfreezify
      return true unless frozen?

      Dir.chdir(repo_path) do
        `tar xzf .git.frozen.tgz`
        FileUtils.rm('.git.frozen.tgz')
      end
      `cd #{@base_dir} && git rm -r --cached #{rel_repo_path}`
      true
    end

    def frozen?
      File.exist?(repo_path + '/.git.frozen.tgz')
    end

    def checked_out?
      File.exist?(repo_path)
    end

    def name
      @name
    end

    private
    def checkout_path
      File.expand_path(File.join(@base_dir, @rel_path))
    end

    def repo_path
      File.expand_path(checkout_path + '/' + @name)
    end

    def rel_repo_path
      @rel_path + '/' + @name
    end


    def status_output(&block)
      puts "Getting status of #{@name}" if verbose
      result = block.call
      puts result
    end

    def update_output(&block)
      puts "Updating #{@name}" if verbose
      result = block.call
      puts result if verbose
      puts " ..updated\n" if verbose
    end

    def git_ignore_self
      Dir.chdir(@base_dir) do
        unless File.exist?('.gitignore') && File.read('.gitignore').include?(rel_repo_path)
          `echo '#{rel_repo_path}' >> .gitignore`
        end
      end
    end
  end
end
