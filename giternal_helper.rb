require 'aruba/api'

class GiternalHelper
  extend Aruba::Api

  @@giternal_base = File.expand_path(File.dirname(__FILE__))

  def self.create_main_repo
    FileUtils.mkdir_p tmp_path
    Dir.chdir(tmp_path) do
      FileUtils.mkdir "main_repo"
      Dir.chdir('main_repo') do
        `git init`
        `echo 'first content' > starter_repo`
        `git add starter_repo`
        `git commit -m "starter repo"`
      end
    end
  end

  def self.wipe_repos
    FileUtils.rm_r(tmp_path) if File.directory?(tmp_path)
  end

  def self.tmp_path
    current_dir
  end

  def self.giternal_base
    @@giternal_base
  end

  def self.base_project_dir
    tmp_path + '/main_repo' 
  end

  def self.create_repo(repo_name)
    Dir.chdir(tmp_path) do
      FileUtils.mkdir_p "externals/#{repo_name}"
      `cd externals/#{repo_name} && git init`
    end
    add_content repo_name
    add_to_config_file repo_name
  end

  def self.add_to_config_file(repo_name)
    config_dir = tmp_path + '/main_repo/config'
    repo_path = external_path(repo_name) 
    FileUtils.mkdir(config_dir) unless File.directory?(config_dir)
    Dir.chdir(config_dir) do
      `echo #{repo_name}: >> giternal.yml`
      `echo '  repo: #{repo_path}' >> giternal.yml`
      `echo '  path: dependencies' >> giternal.yml`
    end
  end

  def self.add_content(repo_name, content=repo_name)
    Dir.chdir(tmp_path + "/externals/#{repo_name}") do
      `echo #{content} >> #{content} && git add #{content}`
      `git commit #{content} -m "added content to #{content}"`
    end
  end

  def self.external_path(repo_name)
    File.expand_path(tmp_path + "/externals/#{repo_name}")
  end

  def self.checked_out_path(repo_name)
    File.expand_path(tmp_path + "/main_repo/dependencies/#{repo_name}")
  end

  
  def self.repo_contents(path)
    Dir.chdir(path) do
      contents = `git cat-file -p HEAD`
      unless contents.include?('tree') && contents.include?('author')
        raise "something is wrong with the repo, output doesn't contain expected git elements:\n\n #{contents}"
      end
      contents
    end
  end

  def self.add_external_to_ignore(repo_name)
    Dir.chdir(tmp_path + '/main_repo') do
      `echo 'dependencies/#{repo_name}' >> .gitignore`
    end
  end
end
