require 'spec_helper'

describe Createdeb::Debdesc do
	it "parses simple fields" do
		content = "A: a\nB: b"
		d = Createdeb::Debdesc.new(content, Logger.new("/dev/null"))

		expect(d.field('A').simple_value).to eq('a')
		expect(d.field('B').simple_value).to eq('b')
	end

	it "parses folded fields" do
		content = "A: a\n  b\n c\nB: d"
		d = Createdeb::Debdesc.new(content, Logger.new("/dev/null"))

		expect(d.field('A').folded_value).to eq("a b c")
		expect(d.field('B').folded_value).to eq('d')
	end
end
