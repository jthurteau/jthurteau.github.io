## 
# Util functions for Tm
#

module TmUtils
  extend self

  require 'pp'

  Tabs = '    '.freeze

  ##
  # 
  @features = {verbose: true, debug: true}

  def self.assert_secret(file, length = 16, set = '')
    secret = ''
    if !File.exist?(file)
      length.times {|n| secret += set[Random.rand(set.length)]}
      File.write(file, secret)
    else
      secret = File.read(file)
    end
    secret
  end

  def self.assert_config_files(files, path = '', sample_token = 'sample.')
    files.each() do |f|
      c_file = "#{path}/#{f}"
      FileUtils.cp("#{path}/#{sample_token}#{f}", c_file) if !File.exist?(c_file)
    end
  end

  def self.sym_keys(h) #NOTE workaround until Ruby 2.5? h = h.transform_keys(&:to_s)
    h.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
  end

  def self.enforce_enumerable(a, even_nil = true)
    return a.class.include?(Enumerable) ? a : (!even_nil && a.nil? ? a : [a])
  end

  def self.name_safe(f, traversable = false) 
    f
  end

  def self.sub(s,v)
    v.each() {|k,r| s = s.sub("[#{k}]", r)}
    s
  end

  def self.gen_trace(local = true)
    trace_stack = caller[1..-1]
    internal = trace_stack.find_index {|t| t.start_with?(Tm::path() + '/tm.rb')}
    internal = trace_stack.find_index {|t| t.start_with?(Tm::path() + '/tm/')} if !internal
    trace_end = local && internal ? (1 + internal) : -1
    return trace_stack[0..trace_end]
  end

  def self.trace(*s)
    c = self.caller_file(caller, :line)
    self.say("TRACE #{c} #{s.to_s}", @features[:verbose] ? :now : :debug)
  end

  def self.deep_trace(*s)
    c = self.enforce_enumerable(caller)
    self.say(["#{s.to_s}","TRACE - - - -"] + c + ["- - - - TRACE"], @features[:verbose] ? :now : :debug)
  end

  def self.caller_file(entries, options = nil)
    min = entries[0].index('/')
    max = entries[0].index(':', min)
    file = entries[0].slice(0, max)
    case options
    when :line
      next_max = entries[0].index(':', max + 1) - 1
      file += " #{entries[0].slice(max + 1, next_max - max)}"
    end
    file
  end

  def self.inspect(v, breakup = false)
    breakup ? v.pretty_inspect.split("\n") : v.pretty_inspect
  end

  def self.say(output, trigger = :now, formatting = true)
    trigger = :now if @features[:debug]
    if (output.class.include?(Enumerable))
      output.each do |o|
        self.say(o, trigger, formatting)
      end
    else
      supress_endline = formatting && (formatting.is_a?(FalseClass) || formatting == :no_end)
      suppress_linetab = formatting && (formatting.is_a?(FalseClass) || formatting == :no_indent)
      tab_multi = formatting && formatting.is_a?(Integer) ? formatting : 1
      end_line = supress_endline ? '' : "\n\r"
      line_tab = suppress_linetab ? '' : (Tabs * tab_multi)
      #full_output = VuppeteerUtils::filter_sensitive("#{line_tab}#{output}#{end_line}", @sensitive)
      full_output = "#{line_tab}#{output}#{end_line}"
      trigger = [trigger] if !trigger.is_a? Array
      trigger.each do |t|
        t.to_sym
        t == :now ? (print full_output) : self.store_say(full_output, t)
      end
    end
  end

  ##
  # exits with an error message an optional status code
  # status code e defaults to 1
  # if e is negative, a stack trace is printed before exiting with the absolute value of e
  def self.shutdown(s, e = 1)
    s[s.length() - 1] += ', shutting Down.' if s.is_a?(Array)
    self.say(s.is_a?(Array) ? s : (s + ', shutting Down.'))
    if e < 0
      self.say('Tm Shutdown Trace:')
      self.say(self.gen_trace(), :now, 2)
    end
    exit e.is_a?(Integer) ? e.abs : e
  end
  
end