class Vec2
  def rotate(a)
    self.x = (self.x * Math.cos(a) - self.y * Math.sin(a))
    self.y = (self.x * Math.sin(a) + self.y * Math.cos(a))
    self
  end
end
