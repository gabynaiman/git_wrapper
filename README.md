# GitWrapper

[![Build Status](https://travis-ci.org/gabynaiman/git_wrapper.png?branch=master)](https://travis-ci.org/gabynaiman/git_wrapper)
[![Coverage Status](https://coveralls.io/repos/gabynaiman/git_wrapper/badge.png?branch=master)](https://coveralls.io/r/gabynaiman/git_wrapper?branch=master)
[![Code Climate](https://codeclimate.com/github/gabynaiman/git_wrapper.png)](https://codeclimate.com/github/gabynaiman/git_wrapper)
[![Dependency Status](https://gemnasium.com/gabynaiman/git_wrapper.png)](https://gemnasium.com/gabynaiman/git_wrapper)

OO git command line wrapper

## Installation

Add this line to your application's Gemfile:

    gem 'git_wrapper'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install git_wrapper

## Requirments

    Git client must be installed and inculded in system path

## Usage

### Example

    repo = Repository.new(folder_name)

    repo.init
    # or
    repo.init_bare

    repo.add 'file_name'
    # or
    repo.add_all

    repo.status

    repo.commit 'message'

    repo.add_remote 'origin', 'git@localhost:repo.git'

    repo.push 'origin', 'master'

### Supported commands

- Add
- Branch
- Checkout
- Commit
- Config
- Diff
- Fecht
- Init
- Log
- Merge
- Pull
- Push
- Remote
- Remove
- Reset
- Revert
- Show
- Status
- Tag


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
