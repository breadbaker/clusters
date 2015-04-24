class Point
  attr_accessor :vectors, :output, :output_normalized
  def initialize(opt ={})
    @vectors = opt[:vectors]
    @output = opt[:output]
    @output_normalized = opt[:output_normalized]
  end
end

class Cluster
  attr_accessor :members, :center, :outputs

  def initialize
    @members = []
    @center = []
  end

  def create_center(num_points)
    num_points.times do |i|
      @center << Random.rand()
    end
  end

  def distance_to_point(point)
    total_distance = 0


    @center.each_with_index do |vector, index|
      distance = (vector - point.vectors[index]) ** 2
      total_distance += distance
    end

    Math.sqrt(total_distance)
  end
end

class Clusterer
  attr_accessor :points, :clusters
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

  def first_assignment
    @clusters.each do |cluster|
      cluster.create_center(@points[0].vectors.length)
    end

    l = @clusters.length

    group = @points.length / l

    @clusters.each_with_index do |cluster, index|
      cluster.members = @points.slice(index * group, (index + 1) * group)
    end
  end

  def cluster
    create_clusters

    first_assignment

    iterations = 0;
    @moved = true


    while @moved do 
      iterations += 1

      recenter_clusters

      reassign_members

      puts "iterations #{iterations}"
    end
  end

  def get_closest_cluster(point)
    cluster_distances = []
    @clusters.each do |cluster|
      cluster_distances << cluster.distance_to_point(point)
    end

    # asign to closest cluster
    @clusters[cluster_distances.index(cluster_distances.max)].members.push(point)
  end

  def reassign_members
    # empty cluster members
    @clusters.each do |cluster|
      cluster.members = []
    end

    # calculate closest cluster
    @points.each do |point|
      closest_cluster = get_closest_cluster(point)
      closest_cluster.members.push(point)
    end
  end

end