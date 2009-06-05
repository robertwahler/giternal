module Giternal
  class App
    def initialize(base_dir)
      @base_dir = base_dir
    end

    def status(repos=[])
      config.each_repo do |r| repos 
        unless repos.empty?
          r.status if repos.include?(r.name)
        else
          r.status 
        end
      end 
    end

    def update(repos=[])
      config.each_repo do |r| repos 
        unless repos.empty?
          r.update if repos.include?(r.name)
        else
          r.update 
        end
      end 
    end

    def freezify(repos=[])
      config.each_repo do |r| repos 
        unless repos.empty?
          r.freezify if repos.include?(r.name)
        else
          r.freezify 
        end
      end 
    end

    def unfreezify(repos=[])
      config.each_repo do |r| repos 
        unless repos.empty?
          r.unfreezify if repos.include?(r.name)
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

    def config
      return @config if @config

      config_file = ['config/giternal.yml', '.giternal.yml'].detect do |file|
        File.file? File.expand_path(@base_dir + '/' + file)
      end

      if config_file.nil?
        $stderr.puts "config/giternal.yml is missing"
        exit 1
      end

      @config = YamlConfig.new(@base_dir, File.read(config_file))
    end
  end
end
