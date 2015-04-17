require

require 'rspec'

RSpec.describ Cluster, "assignment" do
  context "two different clusters" do
    it "know which cluster" do
      cluster = 