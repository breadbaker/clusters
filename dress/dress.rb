require '../normalizer.rb'
require '../cluster.rb'
require '../clusterer.rb'
require '../point.rb'
# 39, State-gov, 77516, Bachelors, 13, Never-married, Adm-clerical, Not-in-family, White, Male, 2174, 0, 40, United-States, <=50K
class Customer < Clusterer
  def initialize
    read_sales
    @no_match = true
    @splitter ||= ','
    @file_path = './attr.csv'
    puts "new file_path "
    @pre_scramble = false
    @results_path ||= './results'
    @id_attr = 0
    @k = 4
    @num_lines = 3000
    super
  end

  def read_sales
    puts "read sales"
    @file_path = './sales.csv'
    @splitter ||= ','
    @pre_scramble = false
    @omit_indexes = []
    get_data

    l = @lines[0].length
    puts "lines #{@lines[0]}"
    @dresses = @lines.map do |line|
      [line[0], line[l - 6].to_f]
    end

    @dresses_hash = {}

    @dresses.each do |dress|
      @dresses_hash[dress[0]] = dress[1]
    end
  end

  def test
    @clusters.each do |cluster|
      puts cluster.members.length

      # cluster.members.each do |pt|
      #   puts "#{@dresses.index(pt.id)}"
      # 

      total_indexs = cluster.members.inject(0) do |total, member|
        total += @dresses_hash[member.id]

        total
      end

      puts "total #{total_indexs / cluster.members.length}"
    end
  end

end

a = Customer.new
puts "run"
a.run