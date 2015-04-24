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
    # def normalize_numeric(data_group, index)
    #   @numeric_columns += 1
    #   data_group = data_group.map do |el|
    #     el.to_f
    #   end
    #   max = data_group.max
    #   min = data_group.min

    #   # puts "index #{index} max #{max}"
    #   # puts "index #{index} min #{min}"

    #   normalized = data_group.map do |el|
    #     [(el - min) / (max - min)]
    #   end

    #   # puts "data #{data_group[0]}  norm #{normalized[0]}"

    #   normalized.each do |n|
    #     if n[0].nan?
    #       puts "index #{index} #{data_group}"
    #       fail
    #     end
    #   end

    #   normalized
    # end
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
    # def normalize_descrete(data_group, 0)
    #   @descrete_columns += 1
    #   uniq = data_group.uniq

    #   data_group.map do |el|
    #     options = Array.new(uniq.length, 0)
    #     options[uniq.index(el)] = 1

    #     options
    #   end
    # end 

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
      # def get_data
      #   lines = []
      #   File.open(@file_path, "r") do |f|
      #     f.each_line do |line|
      #       line  = line.split(@splitter)
      #       @omit_indexes.each do |del|
      #           line.delete_at(del)
      #       end
      #       line = line.map do |i|
      #         i.delete(' ')
      #       end
      #       lines << line
      #     end
      #   end
      #   @lines = check_if_title_row(lines)

      #   @lines = @lines.shuffle if @pre_scramble

      #   unless @num_lines.nil?
      #     @lines = @lines.slice(0, @num_lines)
      #   end
      # end
      it "read data from file" do
        @obj.get_data

        @obj.lines.length.should eq 31
      end
    end

    describe "normalize" do
      # def normalize(data)
      #   column_groups = data.safe_transpose

      #   normalized_column_groups = []
      #   normalized_outputs = []

      #   @match_index ||= data[0].length - 1
      #   column_groups.each_with_index do |column, index|
      #     if index == @match_index
      #       normalized_outputs = normalize_column(column, index, true)
      #     else
      #       normalized_column_groups << normalize_column(column, index, false)
      #     end
      #   end

      #   data_groups_normalized = normalized_column_groups.safe_transpose

      #   normalized_inputs = data_groups_normalized.map do |group|
      #     group.flatten.compact
      #   end

      #   {
      #     normalized_outputs: normalized_outputs,
      #     outputs: column_groups[@match_index],
      #     normalized_inputs: normalized_inputs
      #   }
      # end
      it "normalize number data" do
        @obj.get_data

        normalized = @obj.normalize(@obj.lines)

        normalized[:normalized_outputs].length.should eq 31

        normalized[:normalized_outputs][0].length.should eq 2
        normalized[:normalized_inputs][0].length.should eq 3

      end
    end
  end
end