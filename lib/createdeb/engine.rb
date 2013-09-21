# This is free software released into the public domain (CC0 license).


require 'time'
require 'tmpdir'

require 'createdeb/debdesc'

module Createdeb; end

class Createdeb::Engine
	def initialize(options, log)
		@options = options
		@log = log

		@now = Time.now

		@pkg = @options[:input_file].split('/').last.sub('.debdesc', '')
		@orig_dir ||= @options[:input_file].sub('.debdesc', '')
	end

	def setup!
		@debdesc = Createdeb::Debdesc.new(@options[:input_file], @log)

		@tmp_dir = Dir.mktmpdir('createdeb-')
		@work_dir = @tmp_dir + "/" + source_pkg + '-' + version
		FileUtils.mkdir_p(@work_dir)
	end

	def tear_down!
		FileUtils.remove_entry_secure(@tmp_dir) unless @options[:debug]
	end

	def copy_files!
		FileUtils.mkdir_p("#{@work_dir}/files")

		@to_copy = @debdesc.fields('Copy')
		@to_copy.each do |field|
			file, dest = field.pair_value
			# TODO: test that different files with the same name do not get overwritten
			rel_dir = File.dirname(file)
			dest_dir = "#{@work_dir}/files/#{rel_dir}/"
			FileUtils.mkdir_p(dest_dir)
			FileUtils.cp("#{@orig_dir}/files/#{file}", dest_dir)
		end
	end

	def create_patches!
		@to_diff = @debdesc.fields('Diff')
		@to_diff.each do |field|
			file = field.simple_value
			diff_cmd = ["diff", "-u2", "#{@orig_dir}/diff/#{file}.orig", "#{@orig_dir}/diff/#{file}"]
			patch_path = "#{@work_dir}/patches/#{file}.diff"
			patch = ""
			IO.popen(diff_cmd.join(' ')) { |io| patch = io.read }

			patch.sub!("#{@pkg}/diff/", '').sub!("#{@pkg}/diff/", '')

			FileUtils.mkdir_p(File.dirname(patch_path))
			File.open(patch_path, "w") { |file| file << patch }
		end
	end

	def create_fixed_debian_files!
		deb_dir = @work_dir + '/debian'
		FileUtils.mkdir(deb_dir)

		FileUtils.mkdir(deb_dir + '/source')
		File.open(deb_dir + '/source' + '/format', 'w') { |f| f << "3.0 (native)\n" }

		File.open(deb_dir + '/compat', 'w') { |f| f << "9\n" }

		File.open(deb_dir + '/rules', 'w') do |f|
			f << "#!/usr/bin/make -f\n"
			f << "\n"
			f << "%:\n"
			f << "\tdh $@\n"

		end
		FileUtils.chmod(0o755, deb_dir + '/rules')
	end

	def create_maintscripts!
		# TODO: support for user-defined maintscript
		if @to_diff.empty?
			return
		end

		@debdesc.add_to_field_folded('Pre-Depends', 'patch', ',')

		maintscripts_dir = "#{@work_dir}/debian"

		FileUtils.mkdir_p(maintscripts_dir)

		File.open("#{maintscripts_dir}/postinst", "w") do |f|
			f << "#!/bin/sh\n"
			f << @to_diff.map { |d| "patch -p0 -i /usr/share/#{@pkg}/patches/#{d.simple_value}.diff\n" }
		end

		File.open("#{maintscripts_dir}/prerm", "w") do |f|
			f << "#!/bin/sh\n"
			f << @to_diff.map { |d| "patch -R -p0 -i /usr/share/#{@pkg}/patches/#{d.simple_value}.diff\n" }
		end
	end

	def create_install_file!
		File.open("#{@work_dir}/debian/install", "w") do |f|
			f << @to_copy.map { |c| val = c.pair_value; "files/#{val.first} #{val.last}\n" }
			f << @to_diff.map { |d| patch = "#{d.simple_value}.diff" ; "patches/#{patch} /usr/share/#{@pkg}/patches/#{File.dirname(patch)}\n" }
		end
	end

	def create_changelog!
		# TODO: create proper changelog
		File.open("#{@work_dir}/debian/changelog", "w") do |f|

			f << "#{@pkg} (#{version}) unstable; urgency=low\n"
			f << "\n"
			f << "  * Generated by createdeb\n"
			f << "\n"
			f << " -- #{maintainer}  #{@now.rfc2822}\n"
		end
	end

	def create_control!
		File.open("#{@work_dir}/debian/control", "w") do |f|
			f << "Source: #{@pkg}\n"
			f << "Section: misc\n"
			f << "Priority: optional\n"
			f << "Build-Depends: debhelper (>=9)\n"
			f << "Maintainer: #{maintainer}\n"
			f << "Standards-Version: 3.9.2\n"

			f << "\n"

			f << "Package: #{@pkg}\n"
			f << "Architecture: all\n"
			f << "Pre-Depends: #{@debdesc.field('Pre-Depends').folded_value}\n" unless @to_diff.empty?
			f << "Depends: #{@debdesc.field('Depends').folded_value}\n"
			f << "Description: #{description}\n"
		end
	end

	def build_package!
		opts = []

		opts << '-b' if !@options[:full]
		opts << '-F' if @options[:full]

		if !@options[:sign]
			opts << '-us'
			opts << '-uc'
		end

		Dir.chdir(@work_dir) do
			build_cmd = ['dpkg-buildpackage', '-rfakeroot'] + opts
			IO.popen(build_cmd.join(' ')) do |io|
				output = io.read
				# TODO: write in log
				@log.debug output
			end
		end

		if !$?.success?
			raise "Error during build, see log"
		end
	end

	def move_package!
		base_name = @pkg + '_' + version

		deb_name = "#{base_name}_#{target_arch}.deb"
		changes_name = "#{base_name}_#{build_arch}.changes"
		dsc_name = base_name + '.dsc'
		tar_name = base_name + '.tar.gz'

		files = [deb_name]
		files += [changes_name, dsc_name, tar_name] if @options[:full]

		files.each do |file|
			FileUtils.cp("#{@tmp_dir}/#{file}", Dir.pwd)
		end
	end

	def run!
		begin
			setup!

			copy_files!
			create_patches!

			create_fixed_debian_files!

			create_maintscripts!
			create_install_file!
			create_changelog!
			create_control!

			build_package!
			move_package!
		ensure
			tear_down!
		end
	end

	def source_pkg
		return @pkg
	end

	def version
		if @version.nil?
			@version = @debdesc.field('Version').simple_value || '1.0'

			prefix = "~dev" # TODO: make prefix configurable
			date = @now.strftime("%Y%m%d")
			time = @now.strftime("%H%M%S")

			@version += "#{prefix}#{date}.#{time}" if @options[:timestamp]
		end

		return @version
	end

	def maintainer
		return @debdesc.field('Maintainer').simple_value
	end

	def description
		return @debdesc.field('Description').multiline_value # FIXME: check with multiple lines
	end

	def target_arch
		return 'all'
	end

	def build_arch
		return `dpkg-architecture -qDEB_BUILD_ARCH`.strip
	end
end