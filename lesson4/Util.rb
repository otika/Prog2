class Util
  # Yes/No選択
  def self.yesno
    begin
      while true
        print "Input :Y[es]/N[o]?"
        ans = gets
        if (ans =~ /[Yy]|[Yy][Ee][Ss]/ )
          return true
        elsif (ans =~ /[Nn]|[Nn][Oo]/)
          return false
        end
      end
    rescue # StandardError (Interruptは拾わない)
      return false
    end
  end
end
