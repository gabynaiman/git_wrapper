require 'spec_helper'

describe GitWrapper, '-> Status porcelain parser' do

  it 'Untracked file' do
    text = '?? file.txt'
    file_status = StatusPorcelain.parse(text)

    file_status.file_name.should eq('file.txt')
    file_status.status.should be(:untracked)
    file_status.staged_for_commit.should be_false
  end

  it 'New file' do
    text = 'A  file.txt'
    file_status = StatusPorcelain.parse(text)

    file_status.file_name.should eq('file.txt')
    file_status.status.should be(:new_file)
    file_status.staged_for_commit.should be_true
  end

  it 'Modified' do
    text = ' M file.txt'
    file_status = StatusPorcelain.parse(text)

    file_status.file_name.should eq('file.txt')
    file_status.status.should be(:modified)
    file_status.staged_for_commit.should be_false
  end

  it 'Modified and staged for commit' do
    text = 'M  file.txt'
    file_status = StatusPorcelain.parse(text)

    file_status.file_name.should eq('file.txt')
    file_status.status.should be(:modified)
    file_status.staged_for_commit.should be_true
  end

  it 'Deleted' do
    text = ' D file.txt'
    file_status = StatusPorcelain.parse(text)

    file_status.file_name.should eq('file.txt')
    file_status.status.should be(:deleted)
    file_status.staged_for_commit.should be_false
  end

  it 'Deleted and staged for commit' do
    text = 'D  file.txt'
    file_status = StatusPorcelain.parse(text)

    file_status.file_name.should eq('file.txt')
    file_status.status.should be(:deleted)
    file_status.staged_for_commit.should be_true
  end

  it 'Merge conflict (UU)' do
    text = 'UU file.txt'
    file_status = StatusPorcelain.parse(text)

    file_status.file_name.should eq('file.txt')
    file_status.status.should be(:merge_conflict)
    file_status.staged_for_commit.should be_false
  end

  it 'Merge conflict (AA)' do
    text = 'AA file.txt'
    file_status = StatusPorcelain.parse(text)

    file_status.file_name.should eq('file.txt')
    file_status.status.should be(:merge_conflict)
    file_status.staged_for_commit.should be_false
  end

  it 'Renamed' do
    text = 'R  file.txt -> new_file.txt'
    file_status = StatusPorcelain.parse(text)

    file_status.file_name.should eq('new_file.txt')
    file_status.original_file_name.should eq('file.txt')
    file_status.status.should be(:renamed)
    file_status.staged_for_commit.should be_true
  end

end