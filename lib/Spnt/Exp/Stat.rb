#!usr/bin/ruby

module Enumerable

  #http://www.stat.rice.edu/~dobelman/textfiles/DistributionsHandbook.pdf
  T_DISTRIBUTION_975 = { 1	=> 12.71,
    1=> 	12.71,
    2=>	4.303,
    3=>3.182,
    4=>2.776,
    5=>2.571,
    6=>2.447,
    7=>2.365,
    8=>2.306,
    9=>2.262,
    10=>2.228,
    11=>2.201,
    12=>2.179,
    13=>2.16,
    14=>2.145,
    15=>2.131,
    16=>2.12,
    17=>2.11,
    18=>2.101,
    19=>2.093,
    20=>2.086,
    21=>2.08,
    22=>2.074,
    23=>2.069,
    24=>2.064,
    25=>2.06,
    26=>2.056,
    27=>2.052,
    28=>2.048,
    29=>2.045,
    30=>2.042,
    40=>2.021,
    50=>2.009,
    60=>2,
    70=>1.994,
    80=>1.99,
    90=>1.987,
    100=>1.984,
    110=>1.982,
    120=>1.98,
    -1=>1.960
  }

  class ExpStatService
    def confidence
      confidence = self.find_student_coef() * Math.sqrt(self.sample_variance/self.length)
      confidence
    end

    def find_student_coef
      currentLenght = self.length-1
      tCoef = -1
      if (1..30).include? currentLenght
        tCoef =T_DISTRIBUTION_975[currentLenght]
      elsif (31..120).include? currentLenght
        tCoef =T_DISTRIBUTION_975[currentLenght.div(10)*10]
      else
        tCoef =T_DISTRIBUTION_975[-1]
      end
      tCoef
    end
  end

  def sum
    return self.inject(0){|accum, i| accum + i }
  end

  def mean
    return self.sum / self.length.to_f
  end

  def sample_variance
    m = self.mean
    sum = self.inject(0){|accum, i| accum + (i - m) ** 2 }
    return sum / (self.length - 1).to_f
  end

  def standard_deviation
    return Math.sqrt(self.sample_variance)
  end

end
