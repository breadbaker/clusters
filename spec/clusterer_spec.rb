require 'rspec'
require '../normalizer.rb'
require '../cluster.rb'

class ClustererWrapNumber < Clusterer
  # 2,2,4,L
  # 8,9,7,H
  def initialize
    @match_index = 3
    @splitter ||= ','
    @file_path ||= './number-test.data'
    @pre_scramble = true
    @results_path ||= './results'
    @k = 2
    super
  end
end

describe ClustererWrapNumber  do
  before :each do
    @clusterer = ClustererWrapNumber.new
    @clusterer.get_data
    @clusterer.get_points
  end
  describe "get_points" do
    it "creates n points" do
      @clusterer.points.length.should eq 31
    end

    it "points are correct" do
      @clusterer.points.each do |pt|
        pt.vectors.each do |v|
          v.class.should eq Float
          v.should be <= 1
          v.should be >= 0
        end

        pt.output.class.should eq String
        pt.output_normalized.class.should eq Array
        pt.output_normalized.length.should eq 2
      end
    end
  end

  describe "create_clusters" do
    it "creates n clusters" do
      @clusterer.create_clusters
      @clusterer.clusters.length.should eq 2
      @clusterer.clusters.each do |cl|
        cl.class.should eq Cluster
      end
    end
  end

  describe "first_assignment" do
    it "points are split amoung clusters" do
      @clusterer.create_clusters
      @clusterer.first_assignment
      num_points = @clusterer.points.length
      @clusterer.clusters[0].members.length.should be >= (num_points / 2 - 1)
      @clusterer.clusters[1].members.length.should be >= (num_points / 2 - 1)
    end
  end

  describe "recenter_clusters" do
    before :each do
      @clusterer.create_clusters
      @clusterer.first_assignment
      @clusterer.recenter_clusters
    end
    it "cluster centers are floats 0-1" do
      @clusterer.clusters.each do |cluster|
        cluster.center.each do |pt|
          pt.class.should eq Float
          pt.should be <= 1.0
          pt.should be >= 0.0
        end
      end
    end
  end

  describe "reassign_members" do

    before :each do
      @clusterer.create_clusters
      @clusterer.first_assignment
      @clusterer.recenter_clusters
      @clusterer.reassign_members
    end
    it "cluster centers have members" do
      @clusterer.clusters.each do |cluster|
        cluster.members.length.should be > 0
      end
    end
  end

  describe "calculate_distance_to_cluster" do
    # def calculate_distance_to_cluster(point, cluster)
    #   total_distance = 0


    #   cluster.center.each_with_index do |vector, index|
    #     total_distance += (vector - point.vectors[index]) ** 2
    #   end

    #   Math.sqrt(total_distance)
    # end
    it "can calculate <distance></distance>" do
      cluster = Cluster.new
      cluster.center = [0.0, 0.0, 0.0]
      point = Point.new({
        vectors: [1.0, 1.0, 1.0]
      })
      distance = @clusterer.calculate_distance_to_cluster(point, cluster)
      distance.should be Math.sqrt(3)
    end
  end
end