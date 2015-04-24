class Point
  attr_accessor :vectors, :output, :output_normalized
  def initialize(opt ={})
    @vectors = opt[:vectors]
    @output = opt[:output]
    @output_normalized = opt[:output_normalized]
  end
end
