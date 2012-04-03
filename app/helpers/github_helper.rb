module GithubHelper
  # Retrun a string describing the source code version being used, or false/nil if it can't figure out how to find the version.
  def self.source_code_version_raw
    begin
      $git_date ||= \
        if s = `git log -1 2>&1`
          if m = s.match(/^Date: (.+?)$/s)
            m[1]
          end
        end
    rescue Errno::ENOENT
      # Platform (e.g., Windows) has the checkout directory but not the command-line command to manipulate it.
      ""
    end
  end
end
