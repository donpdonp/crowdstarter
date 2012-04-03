module GithubHelper
  # Retrun a string describing the source code version being used, or false/nil if it can't figure out how to find the version.
  def self.source_code_version_raw
    begin
      if File.directory?(Rails.root.join(".svn"))
        $svn_revision ||= \
          if s = `svn info 2>&1`
            if m = s.match(/^Revision: (\d+)/s)
              " - SVN revision: #{m[1]}"
            end
          end
      elsif File.directory?(Rails.root.join(".git"))
        $git_date ||= \
          if s = `git log -1 2>&1`
            if m = s.match(/^Date: (.+?)$/s)
              " - Git timestamp: #{m[1]}"
            end
          end
      elsif File.directory?(Rails.root.join(".hg"))
        $git_date ||= \
          if s = `hg id -nibt 2>&1`
            " - Mercurial revision: #{s}"
        end
      end
    rescue Errno::ENOENT
      # Platform (e.g., Windows) has the checkout directory but not the command-line command to manipulate it.
      ""
    end
  end
end
