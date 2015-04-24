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
    @clusters.each do |cluster|
      cluster.move_to_center_of_members
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

  def clusters_moved
    @clusters.any? do |cluster|
      cluster.moved
    end
  end

  def cluster
    create_clusters

    first_assignment

    iterations = 0;

    while clusters_moved do 
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
    @clusters[cluster_distances.index(cluster_distances.min)]
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