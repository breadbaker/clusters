require 'rspec'
require '../normalizer.rb'

describe Normalizer do

  let(:wrap){
    class NormalzierWrap
      include Normalizer
    end
    NormalzierWrap.new
  }

  describe "normalize_numeric" do
    before :each do 
      wrap.numeric_columns = 0
    end
    it " with integers" do
      data_group = [1.0,5.0,10.0,2.0]

      normalized = wrap.normalize_numeric(data_group, 0)

      normalized.index(normalized.max).should eq 2
      normalized.index(normalized.min).should eq 0
      normalized.length.should eq 4
      normalized.each do |n|
        n[0].should be <= 1.0
        n[0].should be >= 0.0
        n[0].class.should eq Float
      end
    end

    it " with floats" do
      data_group = [0.1,0.5,1.0,0.2]

      normalized = wrap.normalize_numeric(data_group, 0)

      normalized.index(normalized.max).should eq 2
      normalized.index(normalized.min).should eq 0
      normalized.length.should eq 4
      normalized.each do |n|
        n[0].should be <= 1.0
        n[0].should be >= 0.0
        n[0].class.should eq Float
      end
    end

    it " with negatives" do
      data_group = [-0.1,-0.5,1.0,0.2]

      normalized = wrap.normalize_numeric(data_group, 0)

      normalized.index(normalized.max).should eq 2
      normalized.index(normalized.min).should eq 1
      normalized.length.should eq 4
      normalized.each do |n|
        n[0].should be <= 1.0
        n[0].should be >= 0.0
        n[0].class.should eq Float
      end
    end 
  end

  describe "normalize_descrete" do
    before :each do 
      wrap.descrete_columns = 0
    end

    it " with data" do
      data_group = ['A', 'A', 'B', 'C']

      normalized = wrap.normalize_descrete(data_group, 0)

      normalized[0].length.should eq 3 # [A,B,C]

      normalized.each do |n|
        n.inject{|sum,x| sum + x }.should eq 1
      end
    end
  end

  describe "reading in data " do

    before :each do 
      class NormalzierWrap
        include Normalizer
        def initialize
          # 2,2,4,L
          # 8,9,7,H
          @match_index = 3
          @splitter ||= ','
          @file_path ||= './number-test.data'
          @pre_scramble = true
          @clusters = []
          prepare
        end
      end

      @obj = NormalzierWrap.new
    end

    describe "get_data" do
      it "read data from file" do
        @obj.get_data

        @obj.lines.length.should eq 31
      end
    end

    describe "normalize" do
      it "normalize number data" do
        @obj.get_data

        normalized = @obj.normalize(@obj.lines)

        normalized[:normalized_outputs].length.should eq 31

        normalized[:normalized_outputs].each do |output|
          output.length.should eq 2
        end
        normalized[:outputs].uniq.length.should eq 2
        normalized[:normalized_inputs][0].length.should eq 3
      end
    end
  end
end