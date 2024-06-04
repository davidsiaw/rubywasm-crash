
# Patch require_relative to load from remote
require 'js/require_remote'

module Kernel
  alias original_require_relative require_relative

  # The require_relative may be used in the embedded Gem.
  # First try to load from the built-in filesystem, and if that fails,
  # load from the URL.
  def require_relative(path)
    caller_path = caller_locations(1, 1).first.absolute_path || ''
    dir = File.dirname(caller_path)
    file = File.absolute_path(path, dir)

    original_require_relative(file)
  rescue LoadError
    JS::RequireRemote.instance.load(path)
  end

  def require_abs(path)
    caller_path = caller_locations(1, 1).first.absolute_path || ''
    file = File.absolute_path(path, 'src')

    original_require_relative(file)
  rescue LoadError
    JS::RequireRemote.instance.load(path)
  end
end

class String
  def camelize
    first_letter_in_uppercase = self[0].upcase == self[0]
    if first_letter_in_uppercase
      self.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
    else
      self.to_s[0].chr.downcase + camelize(self)[1..-1]
    end
  end

  def underscore
    word = self.to_s.dup
    word.gsub!(/::/, '/')
    word.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
    word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
    word.tr!("-", "_")
    word.downcase!
    word
  end
end

#DEBUG = 1

class Module
  def debuglog(str)
    return if !Kernel.const_defined?('DEBUG') || DEBUG != 1

    puts "[debug] #{str}"
  end

  def outername
    return @outer if @outer
    return '' if self.name == 'Object'

    self.name
  end

  def const_missing(name, outer = outername)
    key = [outer, name].select{|x| x.length>0}.join('::')
    dir = "#{key.underscore}"
    file = "#{dir}"

    debuglog "loading #{file}"

    begin
      require_abs(file)
      return const_get(key)
    rescue LoadError
      debuglog "failed to load #{file}"
    end

    if outer.rindex('::') != nil
      # go up one level
      debuglog "try to one level up"
      const_missing(name, outer[0...outer.rindex('::')])
    else
      debuglog "meke #{key}"

      cls = Module.new
      cls.instance_eval "@outer = '#{name}'"
      debuglog "made #{key}"
      const_set(key, cls)
    end
  end
end

require_relative 'src/main'
