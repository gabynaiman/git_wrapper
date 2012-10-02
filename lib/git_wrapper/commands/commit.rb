module GitWrapper
  module Commands
    class Commit < Git

      def message(message)
        @message = message
        self
      end

      def author(name, email)
        @author = "#{name} <#{email}>"
        self
      end

      def command
        "commit -m \"#{@message}\" #{@author ? "--author \"#{@author}\"" : ''}"
      end

    end
  end
end