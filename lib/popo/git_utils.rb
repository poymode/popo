module Popo
  module GitUtils
    include Constants

    def self.git_clone(repo, clone_path, branch)
      clone_path ||= nil
      branch = 'master' if branch.nil?

      if clone_path.nil?
        cmd = "#{GIT_CMD} clone -b #{branch} #{repo}"
      else
        cmd = "#{GIT_CMD} clone -b #{branch} #{repo} #{clone_path}"
      end

      clone_msg = "Cloning branch #{branch} from #{repo}" +
                  " to #{clone_path}"

      Utils.say_with_time clone_msg do
       `#{cmd}`
      end
    end

    def self.git_update(repo, branch)
      Utils.say_with_time "Updating #{repo}" do
        Dir.chdir(repo) do
          `#{GIT_CMD} fetch`
        end
      end

      git_checkout(repo, branch)
      git_reset(repo, branch)
    end

    def self.git_stash(repo)
      Utils.say_with_time "Stashing changes for #{repo}" do
        Dir.chdir(repo) do
          `#{GIT_CMD} stash`
        end
      end
    end

    def self.git_reset(repo, branch)
      Utils.say_with_time "Doing a hard reset for #{repo}" do
        Dir.chdir(repo) do
          `#{GIT_CMD} reset --hard origin/#{branch}`
        end
      end
    end

    def self.git_checkout(repo, branch)
      Utils.say_with_time "Switching to #{branch} branch" do
        Dir.chdir(repo) do
          `#{GIT_CMD} checkout #{branch}`
        end
      end
    end

    def self.branch_diff(cwd, branches = ['master', 'development'])
      if is_git?(cwd)
        diff_msg = `#{GIT_CMD} log --abbrev-commit --format=short \
                   origin/#{branches[0]}..origin/#{branches[1]}`

        parsed = diff_msg.scan(/(commit [0-9a-f]+)\n+(.*?)\n+(.*?)(?:\n|$)/)

        Utils.say "#{File.basename(cwd).capitalize}"

        parsed.each do |p|
          commit_id = p[0].gsub(/commit/,'').strip
          author = p[1].scan(/Author: (.*) <.*>/)
          commit_msg = p[2].strip

          Utils.say "#{commit_id} \<#{author}\> #{commit_msg}", true
        end
      else
        repos = Dir.entries(cwd) - [ '.', '..' ]

        repos.each do |r|
          if File.directory?(r)
            FileUtils.cd(r) { branch_diff(File.join(cwd, r)) }
          end
        end
      end

    end

    def self.is_git?(cwd)
      File.exists?(File.join(cwd, '.git'))
    end
  end
end

