class Cluster
  attr_accessor :members, :center, :outputs, :moved

  def initialize
    @members = []
    @center = []
    @moved = true
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

  def move_to_center_of_members
    @moved = false
    new_cluster_center = []
    @center.each_with_index do |old_vector, index|
      total_at_index = @members.inject(0) do |memo, member|
        memo + member.vectors[index]
      end

      new_vector = total_at_index / @members.length

      @moved = true unless  new_vector == old_vector

      new_cluster_center << new_vector
    end

    @center = new_cluster_center
  end
end