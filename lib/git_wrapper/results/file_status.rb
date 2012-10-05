module GitWrapper
  module Results
    module FileStatus
      STATUSES = {
          'A' => :new_file,
          'M' => :modified,
          'D' => :deleted,
          'R' => :renamed,
          'UU' => :merge_conflict,
          'AA' => :merge_conflict,
          'C' => :copied,
          'T' => :type_changed,
          'X' => :unknown
      }

      def self.value_of(char)
        return :untracked unless STATUSES.key?(char)
        STATUSES[char]
      end
    end
  end
end