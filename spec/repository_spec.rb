require 'spec_helper'

describe GitWrapper, '-> Repository' do

  before(:each) do
    @file_helper = FileHelper.new
  end

  after(:each) do
    @file_helper.remove_temp_folders
  end

  it 'Init repo' do
    repo = Repository.new(@file_helper.create_temp_folder)
    repo.init.should be_true
    repo.log_output.last.should eq("Initialized empty Git repository in #{repo.location}/.git/\n")
  end

  it 'Init bare repo' do
    repo = Repository.new(@file_helper.create_temp_folder)
    repo.init_bare.should be_true
    repo.log_output.last.should eq("Initialized empty Git repository in #{repo.location}/\n")
  end

  it 'Init repo in new folder' do
    folder_name = @file_helper.create_temp_folder
    repo = Repository.new(folder_name)
    repo.init.should be_true
    repo.location.should eq(folder_name)
    Dir.exists?(repo.location).should be_true
    FileUtils.rm_rf repo.location
  end

  it 'Is initialized repo' do
    repo = Repository.new(@file_helper.create_temp_folder)
    repo.initialized?.should be_false
    repo.init
    repo.initialized?.should be_true
    repo.bare?.should be_false
  end

  it 'Is initialized bare repo' do
    repo = Repository.new(@file_helper.create_temp_folder)
    repo.initialized?.should be_false
    repo.init_bare
    repo.initialized?.should be_true
    repo.bare?.should be_true
  end

  it 'Status into new repo' do
    repo = Repository.new(@file_helper.create_temp_folder)
    repo.init
    repo.status.should be_empty
  end

  it 'Add one file into repo' do
    repo = Repository.new(@file_helper.create_temp_folder)
    repo.init

    file1 = @file_helper.create_temp_file(repo.location, 'test')
    file2 = @file_helper.create_temp_file(repo.location, 'test')

    initial_status = repo.status
    initial_status.should have(2).items
    initial_status[0].should be_git_untracked(File.basename(file1))
    initial_status[1].should be_git_untracked(File.basename(file2))

    repo.add(file1).should be_true
    repo.add('0123456.789').should be_false

    final_status = repo.status
    final_status.should have(2).items
    final_status[0].should be_git_new_file(File.basename(file1))
    final_status[1].should be_git_untracked(File.basename(file2))
  end

  it 'Add all files into repo' do
    repo = Repository.new(@file_helper.create_temp_folder)
    repo.init

    file1 = @file_helper.create_temp_file(repo.location, 'test')
    file2 = @file_helper.create_temp_file(repo.location, 'test')

    initial_status = repo.status
    initial_status.should have(2).items
    initial_status[0].should be_git_untracked(File.basename(file1))
    initial_status[1].should be_git_untracked(File.basename(file2))

    repo.add_all.should be_true

    final_status = repo.status
    final_status.should have(2).items
    final_status[0].should be_git_new_file(File.basename(file1))
    final_status[1].should be_git_new_file(File.basename(file2))
  end

  it 'Commit repo' do
    repo = Repository.new(@file_helper.create_temp_folder)
    repo.init

    file = @file_helper.create_temp_file(repo.location, 'test')

    repo.status.first.should be_git_untracked(File.basename(file))
    repo.add_all
    repo.status.first.should be_git_new_file(File.basename(file))

    repo.commit('comment').should be_true
    repo.commit('comment').should be_false

    repo.status.should be_empty
  end

  it 'Commit clean directory' do
    repo = Repository.new(@file_helper.create_temp_folder)
    repo.init

    repo.commit('comment').should be_false
  end

  it 'Commt in name of another user' do
    repo = Repository.new(@file_helper.create_temp_folder)
    repo.init
    @file_helper.create_temp_file(repo.location, 'test')
    repo.add_all
    repo.commit('first_commit', :author_name => 'another_author', :author_email => 'another_author@mail.com').should be_true

    log = repo.log.first
    log.author_name.should eq 'another_author'
  end

  it 'Delete file' do
    repo = Repository.new(@file_helper.create_temp_folder)
    repo.init

    file = @file_helper.create_temp_file(repo.location, 'test')

    repo.add_all
    repo.commit('comments')
    repo.status.should be_empty

    repo.remove(File.basename(file)).should be_true
    repo.status.first.should be_git_deleted(File.basename(file))

    repo.remove('0123456.789').should be_false
  end

  it 'Add remote to repo' do
    repo = Repository.new(@file_helper.create_temp_folder)
    repo.init

    repo.remotes.should be_empty

    repo.add_remote('origin', @file_helper.create_temp_folder).should be_true
    repo.add_remote('origin', '0123456789').should be_false

    repo.remotes.should have(1).items
    repo.remotes.first.should eq('origin')
  end

  it 'Remove remote from repo' do
    repo = Repository.new(@file_helper.create_temp_folder)
    repo.init

    repo.remotes.should be_empty

    repo.add_remote('origin', @file_helper.create_temp_folder)

    repo.remotes.first.should eq('origin')

    repo.remove_remote('origin').should be_true
    repo.remove_remote('origin').should be_false

    repo.remotes.should be_empty
  end

  it 'Pull from another repo' do
    repo1 = Repository.new(@file_helper.create_temp_folder)
    file_name1 = @file_helper.create_temp_file(repo1.location, 'test')
    repo1.init
    repo1.add_all
    repo1.commit('...')

    repo2 = Repository.new(@file_helper.create_temp_folder)
    repo2.init
    repo2.add_remote('origin', repo1.location)

    file_name2 = "#{repo2.location}/#{File.basename(file_name1)}"

    File.exist?(file_name2).should be_false

    repo2.pull('origin').should be_true
    repo2.pull('origin_2').should be_false

    File.exist?(file_name2).should be_true
  end

  it 'Push into bare repo' do
    repo1 = Repository.new(@file_helper.create_temp_folder)
    repo1.init_bare

    repo2 = Repository.new(@file_helper.create_temp_folder)
    repo2.init
    file_name1 = @file_helper.create_temp_file(repo2.location, 'test')

    repo2.add_remote('origin', repo1.location)
    repo2.add_all
    repo2.commit('...')
    repo2.push('origin').should be_true
    repo2.push('origin_2').should be_false

    repo3 = Repository.new(@file_helper.create_temp_folder)
    repo3.init
    repo3.add_remote('origin', repo1.location)

    file_name2 = "#{repo3.location}/#{File.basename(file_name1)}"

    File.exist?(file_name2).should be_false

    repo3.pull('origin')

    File.exist?(file_name2).should be_true
  end

  it 'Show base, mine and theirs version of a file' do
    master_repo = Repository.new(@file_helper.create_temp_folder)
    master_repo.init_bare

    my_repo = Repository.new(@file_helper.create_temp_folder)
    my_repo.init
    my_repo.add_remote('origin', master_repo.location)
    my_file = @file_helper.create_temp_file(my_repo.location, 'version base')
    my_repo.add_all
    my_repo.commit('base commit')
    my_repo.push

    their_repo = Repository.new(@file_helper.create_temp_folder)
    their_repo.init
    their_repo.add_remote('origin', master_repo.location)
    their_repo.pull
    their_file = "#{their_repo.location}/#{File.basename(my_file)}"
    File.open(their_file, 'w') { |f| f.puts 'version theirs' }
    their_repo.add_all
    their_repo.commit('theris commit')
    their_repo.push

    File.open(my_file, 'w') { |f| f.puts 'version mine' }
    my_repo.add_all
    my_repo.commit('mine commit')

    my_repo.pull.should be_false
    my_repo.status.first.should be_git_merge_conflict(File.basename(my_file))

    my_repo.show_base(File.basename(my_file)).should eq("version base\n")
    my_repo.show_mine(File.basename(my_file)).should eq("version mine\n")
    my_repo.show_theirs(File.basename(my_file)).should eq("version theirs\n")
  end

  it 'Show file from differente versions' do
    repo = Repository.new(@file_helper.create_temp_folder)
    repo.init

    file_name = @file_helper.create_temp_file(repo.location, 'version 1')
    repo.add_all
    repo.commit 'first commit'

    repo.checkout 'master', 'test'

    File.open(file_name, 'w') { |f| f.puts 'version 2' }
    repo.add_all
    repo.commit 'seccond_commit'

    repo.checkout 'master'

    repo.show(File.basename(file_name)).should eq "version 1\n"
    repo.show(File.basename(file_name), 'test').should eq "version 2\n"
  end

  it 'Show commit logs' do
    repo = Repository.new(@file_helper.create_temp_folder)
    repo.init

    file_name1 = @file_helper.create_temp_file(repo.location, 'test')
    file_name2 = @file_helper.create_temp_file(repo.location, 'test')

    repo.add_all

    repo.commit('first commit')

    log = repo.log

    log.should have(1).items
    log.first.subject.should eq('first commit')
    log.first.parents.should be_empty
    log.first.merge?.should be_false

    File.open(file_name1, 'w') { |f| f.puts 'test 2' }

    repo.add_all
    repo.commit('second commit')

    repo.log(:file_name => File.basename(file_name1)).should have(2).items
    repo.log(:file_name => File.basename(file_name2)).should have(1).items
  end

  it 'Show merge logs' do
    repo = Repository.new(@file_helper.create_temp_folder)
    repo.init

    @file_helper.create_temp_file(repo.location, 'file1')
    repo.add_all
    repo.commit 'first commit'

    repo.checkout 'master', 'test'

    @file_helper.create_temp_file(repo.location, 'file2')
    repo.add_all
    repo.commit 'second commit'
    second_commit = repo.log.first

    repo.checkout 'master'

    @file_helper.create_temp_file(repo.location, 'file2')
    repo.add_all
    repo.commit 'third commit'
    third_commit = repo.log.first

    repo.merge 'test'

    log = repo.log.first
    log.subject.should eq "Merge branch 'test'"
    log.merge?.should be_true
    log.parents.first.should eq third_commit.commit_hash
    log.parents.last.should eq second_commit.commit_hash
  end

  it 'Show commit logs by author' do
    repo = Repository.new(@file_helper.create_temp_folder)
    repo.init

    @file_helper.create_temp_file(repo.location, 'test')
    @file_helper.create_temp_file(repo.location, 'test')

    repo.add_all

    repo.commit('first_commit', :author_name => 'another_author', :author_email => 'another_author@mail.com')

    repo.log(:author => 'another_name').should have(0).items
    repo.log(:author => 'Another_author').should have(1).items
    repo.log(:author => 'another_author@mail.com').should have(1).items
  end

  it 'Show commit logs by until' do
    repo = Repository.new(@file_helper.create_temp_folder)
    repo.init

    @file_helper.create_temp_file(repo.location, 'test')
    @file_helper.create_temp_file(repo.location, 'test')

    repo.add_all

    repo.commit 'first_commit'

    repo.log(:until => yesterday).should have(0).items
    repo.log(:until => tomorrow).should have(1).items
  end

  it 'Show commit logs by since' do
    repo = Repository.new(@file_helper.create_temp_folder)
    repo.init

    @file_helper.create_temp_file(repo.location, 'test')
    @file_helper.create_temp_file(repo.location, 'test')

    repo.add_all

    repo.commit 'first_commit'

    repo.log(:since => tomorrow).should have(0).items
    repo.log(:since => yesterday).should have(1).items
  end

  it 'Show commit logs by grep' do
    repo = Repository.new(@file_helper.create_temp_folder)
    repo.init

    @file_helper.create_temp_file(repo.location, 'test')
    @file_helper.create_temp_file(repo.location, 'test')

    repo.add_all

    repo.commit 'first_commit'

    repo.log(:grep => 'second_commit').should have(0).items
    repo.log(:grep => 'FirsT_commit').should have(1).items
    repo.log(:grep => 'first').should have(1).items
  end

  it 'Show commit logs by author since until grep' do
    repo = Repository.new(@file_helper.create_temp_folder)
    repo.init

    @file_helper.create_temp_file(repo.location, 'test')
    @file_helper.create_temp_file(repo.location, 'test')

    repo.add_all

    repo.commit('first_commit', :author_name => 'another_author', :author_email => 'another_author@mail.com')

    repo.log(:author => 'another_author', :since => yesterday, :until => yesterday, :grep => 'first_commit' ).should have(0).items
    repo.log(:author => 'another_author', :since => yesterday, :until => tomorrow, :grep => 'first_commit' ).should have(1).items
  end

  it 'Show existent branches' do
    origin = Repository.new(@file_helper.create_temp_folder)
    origin.init_bare

    repo = Repository.new(@file_helper.create_temp_folder)
    repo.init
    repo.add_remote 'origin', origin.location
    @file_helper.create_temp_file(repo.location, 'test')

    repo.branches.should be_empty

    repo.add_all
    repo.commit('first commit')
    repo.push

    branches = repo.branches
    branches.should have(2).items
    branches.should include('master')
    branches.should include('remotes/origin/master')
  end

  it 'Create a new branch' do
    repo = Repository.new(@file_helper.create_temp_folder)
    repo.init
    @file_helper.create_temp_file(repo.location, 'test')
    repo.add_all
    repo.commit('first commit')

    repo.branch("branch1").should be_true

    repo.branches.should include('branch1')
  end

  it 'Remove an existing branch' do
    repo = Repository.new(@file_helper.create_temp_folder)
    repo.init
    @file_helper.create_temp_file(repo.location, 'test')
    repo.add_all
    repo.commit('first commit')

    repo.branch("branch1")

    repo.branches.should include('branch1')

    repo.remove_branch('branch1').should be_true
    repo.remove_branch('branch1').should be_false

    repo.branches.should_not include('branch1')
  end

  it 'Get a current branch' do
    repo = Repository.new(@file_helper.create_temp_folder)
    repo.init

    repo.current_branch.should eq('master')

    @file_helper.create_temp_file(repo.location, 'test')
    repo.add_all
    repo.commit('first commit')

    repo.current_branch.should eq('master')

    repo.branch("branch1")

    repo.current_branch.should eq('master')

    repo.checkout('branch1')

    repo.current_branch.should eq('branch1')
  end

  it 'Branch an existing commit' do
    repo = Repository.new(@file_helper.create_temp_folder)
    repo.init
    file_name = @file_helper.create_temp_file(repo.location, 'version master')
    repo.add_all
    repo.commit('first commit')

    repo.checkout("master", "branch1");

    File.open(file_name, 'w') { |f| f.puts 'version branch1' }

    repo.add_all
    repo.commit('version branch1')

    repo.checkout('master')

    File.open(file_name, 'r') do |f|
      f.gets.should eq("version master\n")
    end

    repo.branch('branch2', 'branch1')
    repo.checkout('branch2')

    File.open(file_name, 'r') do |f|
      f.gets.should eq("version branch1\n")
    end
  end

  it 'Checkout an existing branch' do
    repo = Repository.new(@file_helper.create_temp_folder)
    repo.init
    file_name = @file_helper.create_temp_file(repo.location, 'version master')
    repo.add_all
    repo.commit('commit master')

    repo.current_branch.should eq('master')

    repo.branch('branch1')
    repo.checkout('branch1').should be_true
    repo.checkout('0123456789').should be_false

    repo.current_branch.should eq('branch1')
    File.open(file_name, 'r') do |f|
      f.gets.should eq("version master\n")
    end

    File.open(file_name, 'w') { |f| f.puts 'version branch1' }
    repo.add_all
    repo.commit('commit branch1')

    repo.checkout('master')
    repo.current_branch.should eq('master')
    File.open(file_name, 'r') do |f|
      f.gets.should eq("version master\n")
    end

    repo.checkout('branch1')
    repo.current_branch.should eq('branch1')
    File.open(file_name, 'r') do |f|
      f.gets.should eq("version branch1\n")
    end
  end

  it 'Checkout into a new branch' do
    repo = Repository.new(@file_helper.create_temp_folder)
    repo.init
    @file_helper.create_temp_file(repo.location, 'version master')
    repo.add_all
    repo.commit('commit master')

    repo.checkout('master', 'branch1').should be_true

    repo.current_branch.should eq('branch1')
  end

  it 'Create a new tag' do
    repo = Repository.new(@file_helper.create_temp_folder)
    repo.init
    @file_helper.create_temp_file(repo.location, 'test')
    repo.add_all
    repo.commit('first commit')

    repo.tag('tag1').should be_true

    repo.tags.should include('tag1')
  end

  it 'Remove an existing tag' do
    repo = Repository.new(@file_helper.create_temp_folder)
    repo.init
    @file_helper.create_temp_file(repo.location, 'test')
    repo.add_all
    repo.commit('first commit')

    repo.tag('tag1')

    repo.tags.should include('tag1')

    repo.remove_tag('tag1').should be_true
    repo.remove_tag('tag1').should be_false

    repo.tags.should_not include('tag1')
  end

  it 'Create a new tag from existing commit' do
    repo = Repository.new(@file_helper.create_temp_folder)
    repo.init
    file_name = @file_helper.create_temp_file(repo.location, 'version master')
    repo.add_all
    repo.commit('commit master')

    repo.checkout('master', 'branch1')

    File.open(file_name, 'w') { |f| f.puts 'version branch1' }

    repo.add_all
    repo.commit('version branch1')

    repo.tag('tag1', 'master').should be_true

    repo.checkout('tag1', 'branch2')

    File.open(file_name, 'r') do |f|
      f.gets.should eq("version master\n")
    end

    repo.checkout('branch1')

    File.open(file_name, 'r') do |f|
      f.gets.should eq("version branch1\n")
    end
  end

  it 'Merge two branches' do
    repo = Repository.new(@file_helper.create_temp_folder)
    repo.init
    file_name1 = @file_helper.create_temp_file(repo.location, 'version master')
    repo.add_all
    repo.commit('commit master')

    repo.checkout('master', 'branch1')

    file_name2 = @file_helper.create_temp_file(repo.location, 'version branch1')

    repo.add_all
    repo.commit("commit branch 1")

    repo.checkout("master")

    File.exists?(file_name1).should be_true
    File.exists?(file_name2).should be_false

    repo.merge('branch1').should be_true

    File.exists?(file_name1).should be_true
    File.exists?(file_name2).should be_true
  end

  it 'Merge with conflicts' do
    master_repo = Repository.new(@file_helper.create_temp_folder)
    master_repo.init_bare

    my_repo = Repository.new(@file_helper.create_temp_folder)
    my_repo.init
    my_repo.add_remote('origin', master_repo.location)
    my_file = @file_helper.create_temp_file(my_repo.location, 'version base')
    my_repo.add_all
    my_repo.commit('base commit')
    my_repo.push

    their_repo = Repository.new(@file_helper.create_temp_folder)
    their_repo.init
    their_repo.add_remote('origin', master_repo.location)
    their_repo.pull
    their_file = "#{their_repo.location}/#{File.basename(my_file)}"
    File.open(their_file, 'w') { |f| f.puts 'version theirs' }
    their_repo.add_all
    their_repo.commit('theris commit')
    their_repo.push

    File.open(my_file, 'w') { |f| f.puts 'version mine' }
    my_repo.add_all
    my_repo.commit('mine commit')

    my_repo.fetch
    my_repo.merge('origin/master').should be_false
    my_repo.status.first.should be_git_merge_conflict(File.basename(my_file))

    my_repo.show_base(File.basename(my_file)).should eq("version base\n")
    my_repo.show_mine(File.basename(my_file)).should eq("version mine\n")
    my_repo.show_theirs(File.basename(my_file)).should eq("version theirs\n")
  end

  it 'Fetch from remote' do
    remote_repo = Repository.new(@file_helper.create_temp_folder)
    remote_repo.init_bare

    repo1 = Repository.new(@file_helper.create_temp_folder)
    repo1.init
    repo1.add_remote('origin', remote_repo.location)
    @file_helper.create_temp_file(repo1.location, 'file 1')
    repo1.add_all
    repo1.commit('first commit')
    repo1.push

    repo2 = Repository.new(@file_helper.create_temp_folder)
    repo2.init
    repo2.add_remote('origin', remote_repo.location)
    repo2.branches.should be_empty

    repo2.fetch.should be_true

    repo2.branches.should have(1).items
    repo2.branches.should include('remotes/origin/master')
  end

  it 'Show diff file status between working tree and remote branch' do
    remote_repo = Repository.new(@file_helper.create_temp_folder)
    remote_repo.init_bare

    repo1 = Repository.new(@file_helper.create_temp_folder)
    repo1.init
    repo1.add_remote('origin', remote_repo.location)
    file1 = @file_helper.create_temp_file(repo1.location, 'file 1')
    file2 = @file_helper.create_temp_file(repo1.location, 'file 2')
    file3 = @file_helper.create_temp_file(repo1.location, 'file 3')
    repo1.add_all
    repo1.commit('first commit')
    repo1.push

    repo2 = Repository.new(@file_helper.create_temp_folder)
    repo2.init
    repo2.add_remote('origin', remote_repo.location)
    repo2.pull

    repo1.remove file1
    File.open(file2, 'w') { |f| f.puts 'file 2 v.2' }
    file4 = @file_helper.create_temp_file(repo1.location, 'file 3')
    repo1.add_all
    repo1.commit('second commit')
    repo1.push

    repo2.fetch.should be_true

    diff = repo2.diff('origin/master')
    diff.should have(3).items
    diff.select { |d| d.file_name == File.basename(file1) }.first.status.should be(:new_file)
    diff.select { |d| d.file_name == File.basename(file2) }.first.status.should be(:modified)
    diff.select { |d| d.file_name == File.basename(file3) }.should be_empty
    diff.select { |d| d.file_name == File.basename(file4) }.first.status.should be(:deleted)

    diff_reverse = repo2.diff_reverse('origin/master')
    diff_reverse.should have(3).items
    diff_reverse.select { |d| d.file_name == File.basename(file1) }.first.status.should be(:deleted)
    diff_reverse.select { |d| d.file_name == File.basename(file2) }.first.status.should be(:modified)
    diff_reverse.select { |d| d.file_name == File.basename(file3) }.should be_empty
    diff_reverse.select { |d| d.file_name == File.basename(file4) }.first.status.should be(:new_file)
  end

  it 'Diff tree file status for commits' do
    repo = Repository.new(@file_helper.create_temp_folder)
    repo.init

    file_name1 = @file_helper.create_temp_file(repo.location, 'test')
    file_name2 = @file_helper.create_temp_file(repo.location, 'test')

    repo.add_all
    repo.commit('first_commit', :author_name => 'another_author', :author_email => 'another_author@mail.com')

    File.open(file_name1, 'w') { |f| f.puts 'test 2' }
    File.open(file_name2, 'w') { |f| f.puts 'test 2' }

    repo.add_all
    repo.commit('second commit', :author_name => 'another_author', :author_email => 'another_author@mail.com')

    File.open(file_name1, 'w') { |f| f.puts 'test 3' }
    File.delete file_name2
    file_name3 = @file_helper.create_temp_file(repo.location, 'test')

    repo.add_all
    repo.commit('third commit', :author_name => 'another_author', :author_email => 'another_author@mail.com')

    log = repo.log(:author => 'another_author')

    diff = repo.diff_tree log[0].commit_hash
    diff.should have(3).items
    diff.select { |d| d.file_name == File.basename(file_name1) }.first.status.should be :modified
    diff.select { |d| d.file_name == File.basename(file_name2) }.first.status.should be :deleted
    diff.select { |d| d.file_name == File.basename(file_name3) }.first.status.should be :new_file

    diff = repo.diff_tree log[1].commit_hash
    diff.should have(2).items
    diff.select { |d| d.file_name == File.basename(file_name1) }.first.status.should be :modified
    diff.select { |d| d.file_name == File.basename(file_name2) }.first.status.should be :modified
    diff.select { |d| d.file_name == File.basename(file_name3) }.should be_empty

    diff = repo.diff_tree log[2].commit_hash
    diff.should have(0).items
  end

  it 'Revert a specific commit' do
    repo = Repository.new(@file_helper.create_temp_folder)
    repo.init

    file1 = @file_helper.create_temp_file(repo.location, 'file_1')
    file2 = @file_helper.create_temp_file(repo.location, 'file_2')

    repo.add_all
    repo.commit 'first commit'

    file3 = @file_helper.create_temp_file(repo.location, 'file_3')
    repo.remove file2

    repo.add_all
    repo.commit 'second commit'

    File.exist?(file1).should be_true
    File.exist?(file2).should be_false
    File.exist?(file3).should be_true

    last_log = repo.log.first
    last_log.subject.should eq 'second commit'

    repo.revert(last_log.commit_hash).should be_true

    File.exist?(file1).should be_true
    File.exist?(file2).should be_true
    File.exist?(file3).should be_false
  end

  it 'Revert a specific merge' do
    repo = Repository.new(@file_helper.create_temp_folder)
    repo.init

    file1 = @file_helper.create_temp_file(repo.location, 'file_1')
    repo.add_all
    repo.commit 'first commit'

    repo.branch 'test'

    file2 = @file_helper.create_temp_file(repo.location, 'file_2')
    repo.add_all
    repo.commit 'second commit'

    repo.checkout 'test'

    file3 = @file_helper.create_temp_file(repo.location, 'file_3')
    repo.add_all
    repo.commit 'third commit'

    File.exist?(file1).should be_true
    File.exist?(file2).should be_false
    File.exist?(file3).should be_true

    repo.checkout 'master'

    File.exist?(file1).should be_true
    File.exist?(file2).should be_true
    File.exist?(file3).should be_false

    repo.merge 'test'

    File.exist?(file1).should be_true
    File.exist?(file2).should be_true
    File.exist?(file3).should be_true

    last_log = repo.log.first
    last_log.subject.should eq "Merge branch 'test'"

    repo.revert(last_log.commit_hash).should be_true

    File.exist?(file1).should be_true
    File.exist?(file2).should be_true
    File.exist?(file3).should be_false
  end

  it 'Reset index only' do
    repo = Repository.new(@file_helper.create_temp_folder)
    repo.init

    file1 = @file_helper.create_temp_file(repo.location, 'file_1')
    repo.add_all
    repo.commit 'first commit'

    file2 = @file_helper.create_temp_file(repo.location, 'file_2')
    repo.add_all

    File.exist?(file1).should be_true
    File.exist?(file2).should be_true
    repo.status.should have(1).items
    repo.status.first.should be_git_new_file(File.basename(file2))

    repo.reset.should be_true

    File.exist?(file1).should be_true
    File.exist?(file2).should be_true
    repo.status.should have(1).items
    repo.status.first.should be_git_untracked(File.basename(file2))
  end

  it 'Reset index and working tree (hard)' do
    repo = Repository.new(@file_helper.create_temp_folder)
    repo.init

    file1 = @file_helper.create_temp_file(repo.location, 'file_1')
    repo.add_all
    repo.commit 'first commit'

    file2 = @file_helper.create_temp_file(repo.location, 'file_2')
    repo.add_all

    File.exist?(file1).should be_true
    File.exist?(file2).should be_true
    repo.status.should have(1).items
    repo.status.first.should be_git_new_file(File.basename(file2))

    repo.reset(:mode => :hard).should be_true

    File.exist?(file1).should be_true
    File.exist?(file2).should be_false
    repo.status.should be_empty
  end

  it 'Reset index only to specific commit' do
    repo = Repository.new(@file_helper.create_temp_folder)
    repo.init

    file1 = @file_helper.create_temp_file(repo.location, 'file_1')
    repo.add_all
    repo.commit 'first commit'

    file2 = @file_helper.create_temp_file(repo.location, 'file_2')
    repo.add_all
    repo.commit 'second commit'

    file3 = @file_helper.create_temp_file(repo.location, 'file_2')
    repo.add_all

    File.exist?(file1).should be_true
    File.exist?(file2).should be_true
    File.exist?(file3).should be_true

    repo.status.should have(1).items
    repo.status.first.should be_git_new_file(File.basename(file3))

    repo.log.should have(2).items
    repo.log.first.subject.should eq 'second commit'

    repo.reset(:commit => repo.log.last.commit_hash).should be_true

    File.exist?(file1).should be_true
    File.exist?(file2).should be_true
    File.exist?(file3).should be_true

    repo.status.should have(2).items
    repo.status.first.should be_git_untracked(File.basename(file2))
    repo.status.last.should be_git_untracked(File.basename(file3))

    repo.log.should have(1).items
    repo.log.first.subject.should eq 'first commit'
  end

  it 'Reset index and working tree (hard) to specific commit' do
    repo = Repository.new(@file_helper.create_temp_folder)
    repo.init

    file1 = @file_helper.create_temp_file(repo.location, 'file_1')
    repo.add_all
    repo.commit 'first commit'

    file2 = @file_helper.create_temp_file(repo.location, 'file_2')
    repo.add_all
    repo.commit 'second commit'

    file3 = @file_helper.create_temp_file(repo.location, 'file_2')
    repo.add_all

    File.exist?(file1).should be_true
    File.exist?(file2).should be_true
    File.exist?(file3).should be_true

    repo.status.should have(1).items
    repo.status.first.should be_git_new_file(File.basename(file3))

    repo.log.should have(2).items
    repo.log.first.subject.should eq 'second commit'

    repo.reset(:mode => :hard, :commit => repo.log.last.commit_hash).should be_true

    File.exist?(file1).should be_true
    File.exist?(file2).should be_false
    File.exist?(file3).should be_false

    repo.status.should be_empty

    repo.log.should have(1).items
    repo.log.first.subject.should eq 'first commit'
  end

  it 'Config user and email' do
    repo = Repository.new(@file_helper.create_temp_folder)
    repo.init

    repo.config('user.name', 'user_test').should be_true
    repo.config('user.email', 'user_test@mail.com').should be_true

    repo.config('user.name').should eq 'user_test'
    repo.config('user.email').should eq 'user_test@mail.com'
  end

  it 'Log specific user on commit' do
    repo = Repository.new(@file_helper.create_temp_folder)
    repo.init

    repo.config('user.name', 'user_test').should be_true

    @file_helper.create_temp_file(repo.location, 'file')
    repo.add_all
    repo.commit 'test'

    repo.log.first.commiter_name.should eq 'user_test'
  end

end