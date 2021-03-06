require '../normalizer.rb'
require '../cluster.rb'
require '../clusterer.rb'
require '../point.rb'
# 39, State-gov, 77516, Bachelors, 13, Never-married, Adm-clerical, Not-in-family, White, Male, 2174, 0, 40, United-States, <=50K
class Adult < Clusterer
  def initialize
    @match_index = 14
    @splitter ||= ','
    @file_path ||= './adult.data.txt'
    @pre_scramble = true
    @results_path ||= './results'
    @k = 2
    @num_lines = 3000
    super
  end

  def test
    @clusters.each do |cluster|
      cluster.outputs = {}
      cluster.members.each do |member|
        if cluster.outputs.has_key?(member.output)
          cluster.outputs[member.output] += 1
        else
          cluster.outputs[member.output] = 1
        end
      end
      puts cluster.outputs
    end
  end
end

a = Adult.new
a.run