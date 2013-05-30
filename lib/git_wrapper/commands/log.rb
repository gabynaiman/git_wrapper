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

      def file_name(file_name)
        @file_name = to_relative_path(file_name)
        self
      end

      def commit(commit)
        @commit = commit
        self
      end

      def author(author)
        @author = author
        self
      end

      def grep(grep)
        @grep = grep
        self
      end

      def since(since)
        @since = since
        self
      end

      def until(until_par)
        @until = until_par
        self
      end

      def command
        command = "log -i --format=\"<log>#{xml_structure}</log>\""
        command += " #{@commit}" if @commit
        command += " \"#{@file_name}\"" if @file_name
        command += " --author \"#{@author}\"" if @author
        command += " --since \"#{@since}\"" if @since
        command += " --until \"#{@until}\"" if @until
        command += " --grep \"#{@grep}\"" if @grep
        command
      end

      def result
        results = []
        if output
          results = Nokogiri::XML("<logs>#{output}</logs>").xpath('logs/log').map do |element|
            Results::LogInfo.new(Hash[*element.children.flat_map { |node| [node.name.to_sym, node.text] }])
          end
        end
        @commit ? results.first : results
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