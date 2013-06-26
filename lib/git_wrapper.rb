require 'logger'
require 'nokogiri'
require 'open3'
require 'pathname'

require 'git_wrapper/version'

require 'git_wrapper/repository'

require 'git_wrapper/commands/shell'
require 'git_wrapper/commands/git'
require 'git_wrapper/commands/init'
require 'git_wrapper/commands/status'
require 'git_wrapper/commands/add'
require 'git_wrapper/commands/commit'
require 'git_wrapper/commands/remove'
require 'git_wrapper/commands/remote'
require 'git_wrapper/commands/pull'
require 'git_wrapper/commands/push'
require 'git_wrapper/commands/show'
require 'git_wrapper/commands/log'
require 'git_wrapper/commands/branch'
require 'git_wrapper/commands/checkout'
require 'git_wrapper/commands/tag'
require 'git_wrapper/commands/merge'
require 'git_wrapper/commands/fetch'
require 'git_wrapper/commands/diff'
require 'git_wrapper/commands/diff_tree'
require 'git_wrapper/commands/revert'
require 'git_wrapper/commands/reset'
require 'git_wrapper/commands/config'
require 'git_wrapper/commands/rev_list'

require 'git_wrapper/results/file_status'
require 'git_wrapper/results/status_porcelain'
require 'git_wrapper/results/log_info'
require 'git_wrapper/results/diff_name_status'

module GitWrapper

  def self.logger
    @@logger ||= Logger.new($stdout)
  end

  def self.logger=(logger)
    @@logger = logger
  end

end