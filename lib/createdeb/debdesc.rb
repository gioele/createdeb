# This is free software released into the public domain (CC0 license).


module Createdeb; end

class Createdeb::Debdesc
	def initialize(filename_or_content, log)
		if File.exists?(filename_or_content)
			@filename = filename_or_content
			@content = File.open(@filename).lines.to_a
		else
			@filename = nil
			@content = filename_or_content.split("\n")
		end

		@log = log

		@fields = []

		parse!
	end

	def parse!
		in_field = false
		name = nil
		prev_lines = []

		lines = @content + ["\n"]
		lines.each_with_index do |line, idx|
			first = line[0..0]

			if first == '#'
				@log.debug "skipping comment line #{idx}"

				next
			end

			if [' ', "\t"].include?(first)
				if !in_field
					raise "Parsing error on line #{idx}"
				end

				@log.debug "continuing previous line for #{name.inspect} with #{line.inspect}"

				prev_lines << line
				next
			end

			if in_field
				@log.debug "completed field #{name.inspect}"
				@fields << Field.new(name, prev_lines)

				in_field = false
				name = nil
				prev_lines = []
			end

			if first == "\n"
				next
			end

			name, value = line.split(':', 2)
			prev_lines = []
			prev_lines << value
			in_field = true

			@log.debug "starting new field #{name.inspect}"
		end
	end

	def has_field(field_name)
		return @fields.any? { |f| f.name == field_name }
	end

	def fields(field_name)
		return @fields.select { |f| f.name == field_name }
	end

	def field(field_name)
		fields = fields(field_name)

		if fields.empty?
			return Field.new(field_name, nil)
		end

		# TODO: check unique

		return fields.first
	end

	def add_to_field_folded(field_name, value, separator)
		if !has_field(field_name)
			@fields << Field.new(field_name, [value])
			return
		end

		f = field(field_name)
		f.lines << separator + "\n"
		f.lines << value
	end

	class Field
		def initialize(name, lines)
			@name = name
			@lines = lines
		end

		attr_reader :name
		attr_reader :lines

		def simple_value
			if lines.nil?
				return nil
			end

			# FIXME: check

			return lines.first.strip
		end

		def pair_value
			value = simple_value

			if value.nil?
				return [nil, nil]
			end

			return value.split(' ')
		end

		def folded_value
			if lines.nil?
				return nil
			end

			return lines.map { |l| l.strip }.join(' ')
		end

		def multiline_value
			first_line = lines.first.strip
			other_lines = lines[1..-1]

			content = other_lines.map { |l| l[1..-1] + "\n" }.join('')

			return [first_line, content]
		end
	end
end
