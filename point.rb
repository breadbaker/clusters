class Point
  attr_accessor :vectors, :output, :output_normalized, :id
  def initialize(opt ={})
    @vectors = opt[:vectors]
    @output = opt[:output]
    @id = opt[:id]
    @output_normalized = opt[:output_normalized]
  end
end
