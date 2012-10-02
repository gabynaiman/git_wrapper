module GitWrapper
  module Commands
    class Log < Git
      ATTRIBUTES = {
          :commit_hash => 'H',
          :abbreviated_commit_hash => 'h',
          :tree_hash => 'T',
          :abbreviated_tree_hash => 't',
          :parent_hashes => 'P',
          :abbreviated_parent_hashes => 'p',
          :author_name => 'an',
          :author_name_mailmap => 'aN',
          :author_email => 'ae',
          :author_email_mailmap => 'aE',
          :author_date => 'ad',
          :author_date_rfc2822 => 'aD',
          :author_date_relative => 'aR',
          :author_date_unix => 'at',
          :author_date_iso => 'ai',
          :commiter_name => 'cn',
          :commiter_name_mailmap => 'cN',
          :commiter_email => 'ce',
          :commiter_email_mailmap => 'cE',
          :commiter_date => 'cd',
          :commiter_date_rfc2822 => 'cD',
          :commiter_date_relative => 'cR',
          :commiter_date_unix => 'ct',
          :commiter_date_iso => 'ci',
          :ref_names => 'd',
          :encoding => 'e',
          :subject => 's',
          :sanitized_subject_line => 'f',
          :body => 'b',
          :raw_body => 'B',
          :commit_notes => 'N',
          :reflog_selector => 'gD',
          :shortened_reflog_selector => 'gd',
          :reflog_subject => 'gs'
      }

      def file(file_name)
        @file = to_relative_path(file_name)
        self
      end

      def commit(commit)
        @commit = commit
        self
      end

      def command
        command = "log --format=\"<log>#{xml_structure}</log>\""
        command += " #{@commit}" if @commit
        command += " \"#{@file}\"" if @file
        command
      end

      def result
        if output.nil?
          return nil if @commit
          return []
        end

        results = Nokogiri::XML("<logs>#{output}</logs>").xpath('logs/log').map do |element|
          Results::LogInfo.new(Hash[*element.children.map { |node| [node.name.to_sym, node.text] }.flatten])
        end

        return results.first if @commit
        results
      end

      private

      def xml_structure
        ATTRIBUTES.map { |attribute, placeholder|
          "<#{attribute}>%#{placeholder}</#{attribute}>"
        }.join
      end

    end
  end
end