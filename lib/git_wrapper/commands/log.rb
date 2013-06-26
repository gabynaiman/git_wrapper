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

      def files(files)
        @files = files.map{|f|to_relative_path(f)}
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

      def since(date)
        @since = date
        self
      end

      def until(date)
        @until = date
        self
      end

      def skip(skip)
        @skip = skip
        self
      end

      def max_count(max_count)
        @max_count = max_count
        self
      end

      def command
        command = "log -i --format=\"<log>#{xml_structure}</log>\""
        command += " #{@commit}" if @commit
        command += " --author \"#{@author}\"" if @author
        command += " --since \"#{@since}\"" if @since
        command += " --until \"#{@until}\"" if @until
        command += " --grep \"#{@grep}\"" if @grep
        command += " --skip #{@skip}" if @skip
        command += " --max-count \"#{@max_count}\"" if @max_count
        command += " #{@files.map{|f| "\"#{f}\"" }.join(' ')}" if @files
        command
      end

      def result
        return nil unless success?

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