module GitWrapper
  class Repository
    attr_reader :location
    attr_reader :log_output
    attr_reader :log_error

    def initialize(location)
      @location = location
      @log_output = []
      @log_error = []
    end

    def init
      FileUtils.mkpath(@location) unless Dir.exist?(@location)
      execute(Commands::Init.new(@location))
    end

    def init_bare
      FileUtils.mkpath(@location) unless Dir.exist?(@location)
      execute(Commands::Init.new(@location).bare)
    end

    def initialized?
      Dir.exist?("#{@location}/.git") || bare?
    end

    def bare?
      Dir.exist?("#{@location}/hooks") &&
          Dir.exist?("#{@location}/info") &&
          Dir.exist?("#{@location}/objects") &&
          Dir.exist?("#{@location}/refs")
    end

    def status
      execute(Commands::Status.new(@location))
    end

    def add(file_name)
      execute(Commands::Add.new(@location).file(file_name))
    end

    def add_all
      execute(Commands::Add.new(@location).all)
    end

    def commit(message, options={})
      command = Commands::Commit.new(@location).message(message)
      command.author(options[:author_name], options[:author_email]) if options[:author_name] && options[:author_email]
      execute(command)
    end

    def remove(file_name)
      execute(Commands::Remove.new(@location).file(file_name))
    end

    def remotes
      execute(Commands::Remote.new(@location).list)
    end

    def add_remote(name, url)
      execute(Commands::Remote.new(@location).name(name).add(url))
    end

    def remove_remote(name)
      execute(Commands::Remote.new(@location).name(name).remove)
    end

    def pull(remote='origin', branch='master')
      execute(Commands::Pull.new(@location).remote(remote).branch(branch))
    end

    def push(remote='origin', branch='master')
      execute(Commands::Push.new(@location).remote(remote).branch(branch))
    end

    def push_tags(remote='origin')
      execute(Commands::Push.new(@location).remote(remote).tags)
    end

    def show(file_name, commit=nil)
      command = Commands::Show.new(@location).file(file_name)
      command.commit(commit) unless commit.nil?
      execute(command)
    end

    def show_base(file_name)
      execute(Commands::Show.new(@location).file(file_name).base)
    end

    def show_mine(file_name)
      execute(Commands::Show.new(@location).file(file_name).mine)
    end

    def show_theirs(file_name)
      execute(Commands::Show.new(@location).file(file_name).theirs)
    end

    def log(options={})
      command = Commands::Log.new(@location)
      options.each do |option, value|
        command.send option, value
      end
      execute(command)
    end

    def branches
      execute(Commands::Branch.new(@location).list)
    end

    def current_branch
      branch = execute(Commands::Branch.new(@location).current)
      branch.nil? ? 'master' : branch
    end

    def branch(name, commit=nil)
      if commit.nil?
        execute(Commands::Branch.new(@location).create(name))
      else
        execute(Commands::Branch.new(@location).create(name).from(commit))
      end
    end

    def remove_branch(name, remote=nil)
      if remote.nil?
        execute(Commands::Branch.new(@location).remove(name))
      else
        execute(Commands::Branch.new(@location).remove(name).remote(remote))
      end
    end

    def checkout(commit, new_branch=nil)
      if commit.nil?
        execute(Commands::Checkout.new(@location).commit(commit))
      else
        execute(Commands::Checkout.new(@location).commit(commit).into(new_branch))
      end
    end

    def tags
      execute(Commands::Tag.new(@location).list)
    end

    def tag(name, commit=nil)
      if commit.nil?
        execute(Commands::Tag.new(@location).create(name))
      else
        execute(Commands::Tag.new(@location).create(name).from(commit))
      end
    end

    def remove_tag(name)
      execute(Commands::Tag.new(@location).remove(name))
    end

    def merge(commit)
      execute(Commands::Merge.new(@location).commit(commit))
    end

    def fetch(remote=nil)
      if remote.nil?
        execute(Commands::Fetch.new(@location).all)
      else
        execute(Commands::Fetch.new(@location).remote(remote))
      end
    end

    def diff(commit)
      execute(Commands::Diff.new(@location).with(commit))
    end

    def diff_reverse(commit)
      execute(Commands::Diff.new(@location).with(commit).reverse)
    end

    def diff_tree(commit)
      execute(Commands::DiffTree.new(@location).commit(commit))
    end

    def revert(commit)
      if log(:commit => commit).merge?
        execute(Commands::Revert.new(@location).merge(commit))
      else
        execute(Commands::Revert.new(@location).commit(commit))
      end
    end

    def reset(options={})
      command = Commands::Reset.new(@location)
      command.commit(options[:commit]) if options[:commit]
      command.send(options[:mode]) if options[:mode]
      execute(command)
    end

    def config(key=nil, value=nil)
      command = Commands::Config.new(@location)
      command.key(key) if key
      command.value(value) if value
      execute(command)
    end

    private

    def execute(command)
      result = command.execute
      @log_output << command.output
      @log_error << command.error
      result
    end

  end
end