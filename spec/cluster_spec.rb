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
end