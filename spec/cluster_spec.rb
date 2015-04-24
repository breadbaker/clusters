require 'rspec'
require './cluster'

describe Cluster  do
  before :each do
    @cluster = Cluster.new
  end
  describe "create_center" do
      # def create_center(points)
      #   points.times do |i|
      #     @center << Random.rand()
      #   end
      # end
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
end