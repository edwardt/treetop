require 'rubygems'
require 'spec'

dir = File.dirname(__FILE__)
require "#{dir}/../spec_helper"

describe "A !-predicate for a TerminalSymbol" do
  setup do
    @terminal = TerminalSymbol.new("foo")
    @not_predicate = NotPredicate.new(@terminal)
  end
  
  it "fails upon parsing matching input" do
    input = @terminal.prefix
    index = 0
    @not_predicate.parse_at(input, index, parser_with_empty_cache_mock).should be_failure
  end
  
  it "upon parsing non-matching input, returns a SuccessfulParseResult with a zero-length consumed interval" do
    input = "baz"
    index = 0
    result = @not_predicate.parse_at(input, index, parser_with_empty_cache_mock)
    result.should be_success
    result.interval.should == (index...index)
  end
  
  it "has a string representation" do
    @not_predicate.to_s.should == '!("foo")'
  end
end

describe "A sequence with terminal symbol followed by a !-predicate on another terminal symbol" do
  setup do
    @terminal = TerminalSymbol.new("foo")
    @not_predicate = NotPredicate.new(TerminalSymbol.new("bar"))
    @sequence = Sequence.new([@terminal, @not_predicate])
  end
  
  it "fails when look-ahead predicate matches" do
    input = "---" + @terminal.prefix + @not_predicate.expression.prefix
    index = 3
    @sequence.parse_at(input, index, parser_with_empty_cache_mock).should be_failure
  end
  
  it "succeeds when look-ahead does not match, without advancing index beyond end of first terminal" do
    input = "---" + @terminal.prefix + "baz"
    index = 3
    result = @sequence.parse_at(input, index, parser_with_empty_cache_mock)
    result.should be_success
    result.interval.end.should == index + @terminal.prefix.size
  end
end