require 'fileutils'
require 'term/ansicolor'
require 'git'

class String
  include Term::ANSIColor
end

module Giternal
  class Repository
    class << self
      attr_accessor :verbose
    end
    attr_accessor :verbose
    attr_accessor :last_commit

    def initialize(base_dir, name, repo_url, rel_path, attributes={})
      @base_dir = base_dir
      @name = name
      @repo_url = repo_url
      @rel_path = rel_path
      @verbose = self.class.verbose
      @last_commit = attributes.delete("last_commit")
    end

    def status
      log = nil
      actual_commit = nil

      puts "Getting status of #{@name}" if verbose
      if frozen?
        post_message = execute_on_frozen { detached? ? "[DETACHED]" : "" }
        log = execute_on_frozen { `cd #{repo_path} && git log -1 --pretty=format:"Last commit %h was %cr" 2>&1` } 
        actual_commit = log.gsub(/Last commit (.*) was(.*)/, '\1')
        message = "#{@name} is frozen"
        message = "#{message}: #{log}" 
        if ((actual_commit == @last_commit) || @last_commit.nil? )
          print message.cyan
          puts " " + post_message.black.on_yellow
        else
          message = "#{message}. Config last commit: #{@last_commit}" 
          print message.yellow.bold
          puts " " + post_message.black.on_yellow
        end
        @last_commit = actual_commit
      elsif checked_out?
        if !File.exist?(repo_path + '/.git')
          raise "Directory '#{@name}' exists but is not a git repository"
        else
          post_message = detached? ? "[DETACHED]" : ""
          status = `cd #{repo_path} && git status 2>&1`
          log = `cd #{repo_path} && git log -1 --pretty=format:"Last commit %h was %cr" 2>&1`
          actual_commit = log.gsub(/Last commit (.*) was(.*)/, '\1')
          # check if clean, format one line if so
          if status.match(/nothing to commit/) then
            message = "#{@name} is clean"
            message = "#{message}: #{log}" 
            if ((actual_commit == @last_commit) || @last_commit.nil? )
              print message
            else
              message = "#{message}. Config last commit: #{@last_commit}" 
              print message.yellow
            end
            puts " " + post_message.black.on_yellow
          else
            print "#{@name} has changed".yellow
            puts " " + post_message.black.on_yellow
            puts status
            puts log
          end
          @last_commit = actual_commit
        end
      else
        puts "#{@name} does not exist, run update first".red
      end
      true
    end

    def update(options={})
      git_ignore_self
      detach = options[:detach]

      if frozen?
        puts "#{@name} is frozen".cyan
        return true
      end

      FileUtils.mkdir_p checkout_path unless File.exist?(checkout_path)
      if checked_out?
        if !File.exist?(repo_path + '/.git')
          raise "Directory '#{@name}' exists but is not a git repository"
        else
          update_output { `cd #{repo_path} && git checkout master 2>&1 && git pull 2>&1` }
        end
      else
        update_output { `cd #{checkout_path} && git clone #{@repo_url} #{@name} 2>&1` }
      end

      # pin a repo by detaching it to the last_commit stored in giternal.yml
      if detach
        update_output { `cd #{repo_path} && git checkout #{@last_commit} 2>&1` }
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

    def detached?
      begin
        g = Git.open(repo_path)
        g.branch.current == false
      rescue ArgumentError
        false
      end
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
