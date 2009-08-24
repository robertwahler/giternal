module Giternal
  class App
    attr_accessor :config_update
    def initialize(base_dir)
      @base_dir = base_dir
    end

    def status(repos=[])
      # iterate over each repository in giternal.yml
      config.each_repo do |r| repos 
        unless repos.empty?
          # iterate over each of the repos specified on the commandline 
          # and see if it matches the current giternal repo name
          r.status if repos.find {|repo| r.name.match(/#{repo}/)}
        else
          r.status 
        end
        config.config_update(r.name, {"last_commit" => r.last_commit})
      end 
      save if config_update
    end

    def update(repos=[])
      config.each_repo do |r| repos 
        unless repos.empty?
          r.update if repos.find {|repo| r.name.match(/#{repo}/)}
        else
          r.update 
        end
      end 
    end

    def freezify(repos=[])
      config.each_repo do |r| repos 
        unless repos.empty?
          r.freezify if repos.find {|repo| r.name.match(/#{repo}/)}
        else
          r.freezify 
        end
      end 
    end

    def unfreezify(repos=[])
      config.each_repo do |r| repos 
        unless repos.empty?
          r.unfreezify if repos.find {|repo| r.name.match(/#{repo}/)}
        else
          r.unfreezify 
        end
      end 
    end

    def run(action, repos)
      case action
      when "freeze"
        freezify repos
      when "unfreeze"
        unfreezify repos
      else
        send(action, repos)
      end
    end

    def save
      @config.save(@config_file)
    end

    def config
      return @config if @config

      @config_file = ['config/giternal.yml', '.giternal.yml'].detect do |file|
        File.file? File.expand_path(@base_dir + '/' + file)
      end

      if @config_file.nil?
        $stderr.puts "config/giternal.yml is missing"
        exit 1
      end

      @config = YamlConfig.new(@base_dir, File.read(@config_file))
    end
  end
end
