#!/usr/bin/env ruby

require 'optparse'
require 'logger'

require 'createdeb/engine'

module Createdeb; end

class Createdeb::CLI
	def initialize(params, log)
		@log = log

		@options = {}

		parse!(params)
		check_options!
		setup_options!
	end

	def parse!(params)
		OptionParser.new do |opts|
			opts.banner = "Usage: createdeb [options] FILE"

			opts.on('-b', '--binary', "Perform only a binary build (default)") do
				@options[:full] = false
			end

			opts.on('-f', '--full', "Perform a full build (build both binary and source packages)") do
				@options[:full] = true
			end

			opts.on('-s', '--sign', "Sign package") do
				@options[:sign] = true
			end

			opts.on('-d', '--debug', "Show debug output") do
				@options[:debug] = true
			end

			opts.on('-t', '--timestamp-version', "Add timestamp to the version number") do
				@options[:timestamp] = true
			end

			opts.on_tail('-h', '--help', "Display help text and usage") { puts opts; exit }

			opts.parse!

			if ARGV.empty?
				puts opts
				exit
			end
		end

		@options[:input_file] = ARGV.first
	end

	def check_options!
	end

	def setup_options!
		if @options[:debug]
			@log.level = Logger::DEBUG
		end
	end

	def run!
		engine = Createdeb::Engine.new(@options, @log)
		engine.run!
	end
end
