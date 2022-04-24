## 
# Helps Manage Environment Replication for Vagrant VM Hosted Containers
# https://podman.readthedocs.io/
# https://www.vagrantup.com/docs/
#
# You do not need Ruby on the guest for this module.
# You should not need Ruby installed on the host, 
# aside from the runtime built into Vagrant
# see ../Vagrantfile for how this module is used
#

module Tm
    extend self

    require_relative 'tm/utils'
  
    ##
    # where Tm runs from and aquires global(for intneral)/external recipes
    # for an "internal" tm project build, my_path and active_path are the same
    @my_path = File.dirname(__FILE__)

    ##
    # default secret generation length
    @secret_length = 16

    ##
    # default characters for secret generation
    @secret_set = '0123456789abcedf'

    ##
    # storage for the local secret
    @secret_file = 'secret.txt'

    ##
    # local secret
    @my_secret = nil

    ##
    # config file path
    @config_path = ''

    ##
    # config files
    @config_files = []

    ##
    # project name
    @project = 'dev-container'

    ##
    # path to store temp/local project files between environments
    @project_path = nil

    ##
    # vm name
    @vm_name = '[project]_sandbox'

    ##
    # path for shell provisioners
    @shell_path = 'src/install/shell'

    ##
    #
    @sample_token = 'sample.'

    ##
    #
    @local_token = 'local-dev.'

    ##
    # auto running provisioners ('once')
    @auto = []
    
    ##
    # manually running provisioners ('never')
    @manual = []

    def self.init(config)
      self._config(config)
      @project_path = "#{@local_token}#{@project}"
      secret_path = "#{@my_path}/#{@project_path}/#{@secret_file}"
      TmUtils::assert_path("#{@my_path}/#{@project_path}")
      @my_secret = TmUtils::assert_secret(secret_path, @secret_length, @secret_set)
      @vm_name = TmUtils::name_safe(TmUtils::sub(@vm_name,self._vars()))
      #TmUtils::trace(@vm_name)
      TmUtils::assert_config_files(@config_files, @config_path, @sample_token)
    end
  
    def self.project
      return @project
    end

    def self.provision(p, vm)
      p.name = @vm_name
      TmUtils::bind(@auto, self._vars).each() {|a| self._add(vm, a, 'once')}
      TmUtils::bind(@manual, self._vars).each() {|m| self._add(vm, m)}
    end

    def self.path()
      @my_path
    end

    #################################################################
      private
    #################################################################
  
    def self._config(config)
      vars = self._vars()
      TmUtils.sym_keys(config).each() {|k,v| self._set(k,v,vars)}
    end

    def self._vars()
      { #NOTE to support :vars binding, longer strings have to precede shorter matches
        'project_path': @project_path,
        'project': @project,
        'secret': @my_secret,
      }
    end

    def self._set(key, value, vars = [])
      case key
      when :project
        @project = TmUtils::name_safe(value)
      when :manual_provisioners
        @manual = value
      when :auto_provisioners
        @auto = value
      when :shell_path
        @shell_path = TmUtils::name_safe(value, true)
      when :config_files
        @config_files = TmUtils::name_safe(value, true)
      when :secret_length
        @secret_length = value #TODO assert integer
      when :secret_set
        @secret_set = value
      when :secret_file
        @secret_file = TmUtils::name_safe(value, true)
      when :config_path
        @config_path = TmUtils::name_safe(value, true)
      when :config_files
        @config_files = value #TODO each
      when :vm_name
        @vm_name = TmUtils::name_safe(TmUtils::sub(value,vars))
        TmUtils::trace(@vm_name)
        TmUtils::shutdown('halting')
      when :sample_token
        @sample_token = TmUtils::name_safe(value)
      when :local_token
        @local_token = TmUtils::name_safe(value)
      end
    end

    def self._add(vm, params, run_when = 'never')
      params = [params] if params.is_a?(String) && params.length > 0
      return if !params || !params.is_a?(Array) || params.length < 1
      name = params[0]
      file_base = params.length > 1 && params[1].is_a?(String) ? params[1]: name
      arg_short = params.length > 1 && params[1].class.include?(Enumerable) ? 1 : false
      arg_index = params.length > 2 ? 2 : arg_short
      args = arg_index ? params[arg_index] : [@my_secret]
      file = "#{file_base}.sh"
      vm.provision name, type: 'shell', path: "#{@shell_path}/#{file}", args: args, run: run_when
    end
    
  end