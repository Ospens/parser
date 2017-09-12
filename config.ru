# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'
		require 'rubygems'
		require 'open-uri'
		require 'nokogiri'
		require 'json'
		require 'mechanize'		
		require 'date'

run Rails.application
