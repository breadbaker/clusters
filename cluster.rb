class Array
  def safe_transpose
    result = []
    max_size = self.max { |a,b| a.size <=> b.size }.size
    max_size.times do |i|
      result[i] = Array.new(self.first.size)
      self.each_with_index { |r,j| result[i][j] = r[i] }
    end
    result
  end
end

class String
  def is_number?
    true if Float(self) rescue false
  end
end

module Normalizer

  attr_reader :train, :test, :maxes, :fann
  def prepare(opt = {})
    @file_path ||= './winequality-red.csv'
    @results_path ||= './results'
    @pre_scramble ||= false
    @splitter ||= ';'
    @numeric_columns = 0
    @descrete_columns = 0
    @omit_indexes ||= []
    @num_lines ||= nil
    @special_normalize ||= {}
  end

  def get_data
    lines = []
    File.open(@file_path, "r") do |f|
      f.each_line do |line|
        line  = line.split(@splitter)
        @omit_indexes.each do |del|
            line.delete_at(del)
        end
        line = line.map do |i|
          i.delete(' ')
        end
        lines << line
      end
    end

    puts "file loaded #{lines.length} lines"
    puts "line one #{lines[0]}"

    @lines = check_if_title_row(lines)

    @lines = @lines.shuffle if @pre_scramble

    unless @num_lines.nil?
      @lines = @lines.slice(0, @num_lines)
    end
  end

  # works only if dataset has at least on continuous column
  def check_if_title_row(lines)
    drop_line = false
    lines[1].each_with_index do |el, index|
      if el.is_number? && !lines[0][index].is_number?
        drop_line = true
      end
    end
    if drop_line
      puts "dropped row #{lines.shift()}"
    end

    lines
  end

  def normalize(data)
    column_groups = data.safe_transpose
    puts "transposed"

    # puts column_groups[0][0]
    normalized_column_groups = []
    normalized_outputs = []

    @match_index ||= data[0].length - 1
    column_groups.each_with_index do |column, index|
      if index == @match_index
        normalized_outputs = normalize_column(column, index, true)
      else
        normalized_column_groups << normalize_column(column, index, false)
      end

      # puts "normalized #{index}"
    end

    puts "descrete_columns #{@descrete_columns}"
    puts "numeric_columns #{@numeric_columns}"
    puts "retransposing #{normalized_column_groups.length} rows with #{normalized_column_groups[0].length} columns"

    data_groups_normalized = normalized_column_groups.safe_transpose

    puts "retransposed #{data_groups_normalized.length} rows"

    normalized_inputs = data_groups_normalized.map do |group|
      group.flatten.compact
    end

    {
      normalized_outputs: normalized_outputs,
      outputs: column_groups[@match_index],
      normalized_inputs: normalized_inputs
    }
  end

  def normalize_column(data_group, index, match)
    return self.send(@special_normalize[index], data_group, index) if @special_normalize[index]

    return normalize_numeric(data_group, index) if data_group[0].is_number? && !match

    return normalize_descrete(data_group, index)
  end

  def normalize_numeric(data_group, index)
    @numeric_columns += 1
    data_group = data_group.map do |el|
      el.to_f
    end
    max = data_group.max
    min = data_group.min

    # puts "index #{index} max #{max}"
    # puts "index #{index} min #{min}"

    normalized = data_group.map do |el|
      [(el - min) / (max - min)]
    end

    # puts "data #{data_group[0]}  norm #{normalized[0]}"

    normalized.each do |n|
      if n[0].nan?
        puts "index #{index} #{data_group}"
        fail
      end
    end

    normalized
  end

  def normalize_descrete(data_group, index)
    @descrete_columns += 1
    uniq = data_group.uniq

    data_group.map do |el|
      options = Array.new(uniq.length, 0)
      options[uniq.index(el)] = 1

      options
    end
  end

  def log(correct, wrong)
    log_file = File.open(@results_path, "a")
    log_file.puts "ratio #{correct.to_f/(wrong+correct)} neuron setup #{@neuron_setup} epochs #{@epochs} correct #{correct} wrong #{wrong}  #{Time.now}"
    puts "ratio #{correct.to_f/(wrong+correct)} neuron setup #{@neuron_setup} epochs #{@epochs} correct #{correct} wrong #{wrong}  #{Time.now}"
    log_file.close
  end

end

class Point
  attr_accessor :vectors, :output
  def initialize(opt ={})
    @vectors = opt[:vectors]
    @output = opt[:output]
  end
end

class Cluster
  attr_accessor :members, :center, :outputs

  def initialize
    @members = []
    @center = []
  end

  def create_center(points)
    points.times do |i|
      @center << Random.rand()
    end
  end
end

class Clusterer
  include Normalizer
  def initialize
    @clusters = []
    prepare
  end

  def run
    get_data

    get_points

    cluster

    test
  end

  def get_points
    norm = normalize(@lines)

    @points = []

    norm[:normalized_inputs].each_with_index do |input, index|
      point = Point.new({
        vectors: input,
        output_normalized: norm[:normalized_outputs][index],
        output: norm[:outputs][index]
      })
      @points << point
    end
  end

  def create_clusters
    @k.times do |i|
      cluster = Cluster.new
      @clusters.push(cluster)
    end
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

  def recenter_clusters
    # move each cluster to the center of its members
    @moved = false

    @clusters.each do |cluster|
      new_cluster_center = []
      cluster.center.each_with_index do |old_vector, index|
        new_cluster_center = []
        total = cluster.members.inject(0) do |memo, member|
          memo + member.vectors[index]
        end

        new_vector = total / cluster.members.length

        @moved = true unless  new_vector == old_vector

        new_cluster_center << new_vector
      end

      cluster.center = new_cluster_center
    end
  end

  def cluster
    create_clusters
    @clusters.each do |cluster|
      cluster.create_center(@points[0].vectors.length)
    end

      puts "center #{@clusters[0].center}"


    l = @clusters.length

    group = @points.length / l

    @clusters.each_with_index do |cluster, index|
      cluster.members = @points.slice(index * group, (index + 1) * group)
    end

    iterations = 0;
    @moved = true


    while @moved do 
      iterations += 1

      recenter_clusters

      reassign_members

      puts "iterations #{iterations}"
    end
  end

  def reassign_members
    # empty cluster members
    @clusters.each do |cluster|
      cluster.members = []
    end

    # calculate closest cluster
    @points.each do |point|
      cluster_distances = []
      @clusters.each do |cluster|
        total_distance = 0


        cluster.center.each_with_index do |vector, index|
          total_distance += (vector - point.vectors[index]) ** 2
        end


        cluster_distances << Math.sqrt(total_distance)
      end

      # asign to closest cluster
      puts "cluster distances #{cluster_distances}"
      @clusters[cluster_distances.index(cluster_distances.max)].members.push(point)
    end
  end

end