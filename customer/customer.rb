require '../normalizer.rb'
require '../cluster.rb'
require '../clusterer.rb'
require '../point.rb'
# 39, State-gov, 77516, Bachelors, 13, Never-married, Adm-clerical, Not-in-family, White, Male, 2174, 0, 40, United-States, <=50K
class Customer < Clusterer
  def initialize
    @no_match = true
    @splitter ||= ','
    @file_path ||= './wholesale-customer.csv'
    @pre_scramble = true
    @results_path ||= './results'
    @k = 4
    @num_lines = 3000
    super
  end

  def test
    @clusters.each do |cluster|
      puts cluster.members.length
      cluster.center.each do |pt|
        puts "#{pt}"
      end
    end
  end
end

a = Customer.new
a.run