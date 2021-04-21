require_relative 'web-api'
require_relative 'helpers'
#
# Class for wrapping the all the actions associated with a node (eg. geth, prysm)
#

class Node

  include GithubApi

  def initialize(name,checklist,interface=nil,service=nil)
    @name = name
    @checklist = checklist
    @interface = interface
    @service = service
  end

  attr_reader :name
  attr_accessor :checklist, :interface, :service

  # def self.owner(dir)
  #   checklist.users.find_by_id(File.stat(dir).uid)
  # end

  def set_interface(interface)
    @interface = interface
    interface.node = self
  end


  def config_dir
    checklist.config[:directories][name]
  end

  def installation_directory
    dir = config_dir
    return nil unless dir
    Dir.exists?(dir) ? Dir.entries(dir) : nil
  end

  def install_dir_owner
    dir = checklist.config[:directories][name]
    dir && checklist.users.owner(dir)
  end

  def owner_correct?
    return false unless (user = checklist.config[:users][name])
    install_dir_owner == user
  end

  def latest_version
    get_latest_version(checklist.config[:github][name])
  end

  def current_version
    ""
  end

  def current_version_is_latest?
    return false unless latest_version && current_version
    latest_version.scan(/\d+/) == current_version.scan(/\d+/)
  end

end


class GethNode < Node

  def version_check
    response = %x|geth version-check|
    !!(response =~ /no\s+vulnerabilities\s+found/i)
  end

  def current_version
    response = %x|geth version|
    version = response.scan /^Version:\s+(.*)$/
    version.trample[0]
  end

end
