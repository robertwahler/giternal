require 'yaml'

# Modify hash class to emit key sorted yaml
class Hash
  def to_yaml( opts = {} )
    YAML::quick_emit( object_id, opts ) do |out|
      out.map( taguri, to_yaml_style ) do |map|
        sorted_keys = keys
        sorted_keys = begin
          sorted_keys.sort
        rescue
          sorted_keys.sort_by {|k| k.to_s} rescue sorted_keys
        end

        sorted_keys.each do |k|
          map.add( k, fetch(k) )
        end
      end
    end
  end
end

module Giternal
  class YamlConfig
    def initialize(base_dir, yaml_string)
      @base_dir = base_dir
      @config = YAML.load yaml_string
    end

    def each_repo
      repositories.each { |r| yield(r) if block_given? }
    end

    def config_update(repo, attribute_hash)
      @config = @config.merge(repo => @config[repo].merge(attribute_hash)) if @config[repo]
    end

    def save(config_file)
      # file gets closed after block executes
      File.open(config_file, 'w') do |out|
        YAML.dump(@config, out)
      end
    end

    private
    def repositories
      @config.sort.map do |name, attributes|
        options = attributes.dup
        Repository.new(@base_dir, name, options.delete("repo"), options.delete("path"), options)
      end
    end
  end
end
