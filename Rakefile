# encoding: utf-8

require 'bundler/setup'
require 'rspec/core/rake_task'
require 'tara'
require 'mime-types'
require 'github_api'

RSpec::Core::RakeTask.new(:spec) do |r|
  r.rspec_opts = '--tty'
end

namespace :gem do
  Bundler::GemHelper.install_tasks
end

namespace :archive do
  user, repo = 'mthssdrbrg', 'lester'

  def find_tag
    (ENV['tag'] || %x[git tag | tail -1]).strip
  end

  def build(args={})
    target = args.delete(:target) { 'linux-x86_64' }
    tag = args.delete(:tag) { find_tag }
    archiver = Tara::Archiver.new({
      target: target,
      traveling_ruby_version: '20150715',
      archive_name: sprintf('lester-%s-%s.tgz', tag, target),
    }.merge(args))
    archiver.create
  end

  desc 'Create a new archive'
  task :package do
    build
  end

  desc 'Upload archive to Github'
  task :release do
    if (oauth_token = ENV['GITHUB_OAUTH_TOKEN'])
      github = Github.new(oauth_token: oauth_token)
      assets = github.repos.releases.assets
      tag = find_tag
      release = github.repos.releases.create(user, repo, {
        tag_name: tag,
        name: tag,
        body: %x[git cat-file -p $(git rev-parse $(git tag -l #{tag} | tail -n 1)) | tail -n +6],
        prerelease: tag.split('.').last.include?('pre'),
      })
      %w[linux-x86_64 linux-x86 osx].each do |target|
        release_path = build(target: target, tag: tag)
        assets.upload(user, repo, release.id, release_path, {
          name: File.basename(release_path),
        })
      end
    else
      abort('Missing GITHUB_OAUTH_TOKEN env. variable')
    end
  end
end

desc 'Run tests and release a new gem & binary'
task :release => %w[spec gem:release binary:release]
