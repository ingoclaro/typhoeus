require 'digest/sha2'
require 'typhoeus/utils'
require 'typhoeus/header'
require 'typhoeus/curl'
require 'typhoeus/easy'
require 'typhoeus/form'
require 'typhoeus/multi'
require 'typhoeus/filter'
require 'typhoeus/param_processor'
require 'typhoeus/remote'
require 'typhoeus/remote_proxy_object'
require 'typhoeus/response'
require 'typhoeus/request'
require 'typhoeus/hydra'
require 'typhoeus/hydra_mock'
require 'typhoeus/version'

module Typhoeus
  def self.easy_object_pool
    @easy_objects ||= []
  end

  def self.init_easy_object_pool
    20.times do
      easy_object_pool << Typhoeus::Easy.new
    end
  end

  def self.release_easy_object(easy)
    easy.reset
    easy_object_pool << easy
  end

  def self.get_easy_object
    if easy_object_pool.empty?
      Typhoeus::Easy.new
    else
      easy_object_pool.pop
    end
  end

  def self.add_easy_request(easy_object)
    Thread.current[:curl_multi] ||= Typhoeus::Multi.new
    Thread.current[:curl_multi].add(easy_object)
  end

  def self.perform_easy_requests
    multi = Thread.current[:curl_multi]
    start_time = Time.now
    multi.easy_handles.each do |easy|
      easy.start_time = start_time
    end
    multi.perform
  end
end
