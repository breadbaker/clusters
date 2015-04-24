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