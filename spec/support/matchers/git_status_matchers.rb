RSpec::Matchers.define :be_git_untracked do |expected_file_name|
  match do |actual|
    actual.file_name == expected_file_name &&
      actual.status == :untracked &&
      !actual.staged_for_commit
  end
end

RSpec::Matchers.define :be_git_new_file do |expected_file_name|
  match do |actual|
    actual.file_name == expected_file_name &&
      actual.status == :new_file &&
      actual.staged_for_commit
  end
end

RSpec::Matchers.define :be_git_deleted do |expected_file_name|
  match do |actual|
    actual.file_name == expected_file_name &&
      actual.status == :deleted &&
      actual.staged_for_commit
  end
end

RSpec::Matchers.define :be_git_merge_conflict do |expected_file_name|
  match do |actual|
    actual.file_name == expected_file_name &&
      actual.status == :merge_conflict &&
      !actual.staged_for_commit
  end
end