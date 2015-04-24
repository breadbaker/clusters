require 'rspec'
require '../cluster'
require '../point'

describe Cluster  do
  before :each do
    @cluster = Cluster.new
  end
  describe "create_center" do
    before :each do 
      @points = 10
      @cluster.create_center(@points)
    end
    it "creates n points" do
      @cluster.center.length.should eq @points
    end
    it "points are floats" do
      @cluster.center.each do |pt|
        pt.class.should eq Float
      end
    end
  end
  describe "calculate_distance_to_cluster" do
    it "can calculate" do
      @cluster.center = [0.0, 0.0, 0.0]
      point = Point.new({
        vectors: [1.0, 1.0, 1.0]
      })
      distance = @cluster.distance_to_point(point)
      distance.should be Math.sqrt(3)
    end
  end
  describe "move_to_center_of_members" do
    it "can calculate center of points together" do
      @cluster.center = [0.0, 0.0, 0.0]
      point_1 = Point.new({
        vectors: [1.0, 1.0, 1.0]
      })
      point_2 = Point.new({
        vectors: [1.0, 1.0, 1.0]
      })
      point_3 = Point.new({
        vectors: [1.0, 1.0, 1.0]
      })
      @cluster.members = [point_1, point_2, point_3]

      @cluster.move_to_center_of_members
      @cluster.moved.should eq true
      @cluster.center.should eq [1.0, 1.0, 1.0]
      @cluster.move_to_center_of_members
      @cluster.moved.should eq false
    end
    it "can calculate center of points separate" do
      @cluster.center = [0.0, 0.0, 0.0]
      point_1 = Point.new({
        vectors: [1.0, 1.0, 1.0]
      })
      point_2 = Point.new({
        vectors: [0.0, 0.0, 0.0]
      })
      @cluster.members = [point_1, point_2]

      @cluster.move_to_center_of_members
      @cluster.moved.should eq true
      @cluster.center.should eq [0.5, 0.5, 0.5]
      @cluster.move_to_center_of_members
      @cluster.moved.should eq false
    end
  end
end