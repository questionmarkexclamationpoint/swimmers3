# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

module Comparable
  def clamp(min, max)
    return min if self <= min
    return max if self >= max
    self
  end
end
