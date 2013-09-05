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

	it "parses multiline fields" do
		content = "A: a\n b\n  c\n d\nB: e"
		d = Createdeb::Debdesc.new(content, Logger.new("/dev/null"))

		expect(d.field('A').multiline_value).to eq(['a', "b\n c\nd\n"])
		expect(d.field('B').multiline_value).to eq(['e', ''])
	end

	it "ignores comments" do
		content = "#A: a\nB: b\n#C: c"
		d = Createdeb::Debdesc.new(content, Logger.new("/dev/null"))

		expect(d.fields('A')).to be_empty
		expect(d.field('B').lines).to eq([" b"])
		expect(d.fields('C')).to be_empty
	end

	it "allows fields to be repeated" do
		content = "A: a\nA: b\nA: c"
		d = Createdeb::Debdesc.new(content, Logger.new("/dev/null"))

		expect(d.fields('A')).to have(3).fields
		expect(d.fields('A')[0].simple_value).to eq('a')
		expect(d.fields('A')[1].simple_value).to eq('b')
		expect(d.fields('A')[2].simple_value).to eq('c')
	end
end
