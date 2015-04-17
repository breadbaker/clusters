class Array
  def safe_transpose
    result = []
    max_size = self.max { |a,b| a.size <=> b.size }.size
    max_size.times do |i|
      result[i] = Array.new(self.first.size)
      self.each_with_index { |r,j| result[i][j] = r[i] }
    end
    result
  end
end

class String
  def is_number?
    true if Float(self) rescue false
  end
end

module Normalizer

  attr_reader :train, :test, :maxes, :fann
  def prepare(opt = {})
    @file_path ||= './winequality-red.csv'
    @results_path ||= './results'
    @pre_scramble ||= false
    @splitter ||= ';'
    @numeric_columns = 0
    @num_lines ||= nil
    @descrete_columns = 0
    @omit_indexes ||= []
    @special_normalize ||= {}
  end

  def get_data
    lines = []
    File.open(@file_path, "r") do |f|
      f.each_line do |line|
        line  = line.split(@splitter)
        @omit_indexes.each do |del|
            line.delete_at(del)
        end
        line = line.map do |i|
          i.delete(' ')
        end
        lines << line
      end
    end

    puts "file loaded #{lines.length} lines"
    puts "line one #{lines[0]}"

    @lines = check_if_title_row(lines)

    @lines = @lines.shuffle if @pre_scramble

    unless @num_lines.nil?
      @lines = @lines.slice(0, @num_lines)
    end
  end

  # works only if dataset has at least on continuous column
  def check_if_title_row(lines)
    drop_line = false
    lines[1].each_with_index do |el, index|
      if el.is_number? && !lines[0][index].is_number?
        drop_line = true
      end
    end
    if drop_line
      puts "dropped row #{lines.shift()}"
    end

    lines
  end

  def normalize(data)
    column_groups = data.safe_transpose
    puts "transposed"

    # puts column_groups[0][0]
    normalized_column_groups = []
    normalized_outputs = []

    @match_index ||= data[0].length - 1
    column_groups.each_with_index do |column, index|
      if index == @match_index
        normalized_outputs = normalize_column(column, index, true)
      else
        normalized_column_groups << normalize_column(column, index, false)
      end

      # puts "normalized #{index}"
    end

    puts "descrete_columns #{@descrete_columns}"
    puts "numeric_columns #{@numeric_columns}"
    puts "retransposing #{normalized_column_groups.length} rows with #{normalized_column_groups[0].length} columns"

    data_groups_normalized = normalized_column_groups.safe_transpose

    puts "retransposed #{data_groups_normalized.length} rows"

    normalized_inputs = data_groups_normalized.map do |group|
      group.flatten.compact
    end

    {
      normalized_outputs: normalized_outputs,
      outputs: column_groups[@match_index],
      normalized_inputs: normalized_inputs
    }
  end

  def normalize_column(data_group, index, match)
    return self.send(@special_normalize[index], data_group, index) if @special_normalize[index]

    return normalize_numeric(data_group, index) if data_group[0].is_number? && !match

    return normalize_descrete(data_group, index)
  end

  def normalize_numeric(data_group, index)
    @numeric_columns += 1
    data_group = data_group.map do |el|
      el.to_f
    end
    max = data_group.max
    min = data_group.min

    # puts "index #{index} max #{max}"
    # puts "index #{index} min #{min}"

    normalized = data_group.map do |el|
      [(el - min) / (max - min)]
    end

    # puts "data #{data_group[0]}  norm #{normalized[0]}"

    normalized
  end

  def normalize_descrete(data_group, index)
    @descrete_columns += 1
    uniq = data_group.uniq

    data_group.map do |el|
      options = Array.new(uniq.length, 0)
      options[uniq.index(el)] = 1

      options
    end
  end

  def log(correct, wrong)
    log_file = File.open(@results_path, "a")
    log_file.puts "ratio #{correct.to_f/(wrong+correct)} neuron setup #{@neuron_setup} epochs #{@epochs} correct #{correct} wrong #{wrong}  #{Time.now}"
    puts "ratio #{correct.to_f/(wrong+correct)} neuron setup #{@neuron_setup} epochs #{@epochs} correct #{correct} wrong #{wrong}  #{Time.now}"
    log_file.close
  end

end