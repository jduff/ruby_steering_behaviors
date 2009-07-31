require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Vector2d do
  context "a new vector" do
    before(:each) do
      @vector = Vector2d.new
    end
    
    it "should be zero" do
      @vector.x.should be_zero
      @vector.y.should be_zero
    end

    it "should have length zero" do
      @vector.length.should be_zero
    end

    it "should have length squared zero" do
      @vector.length_sq.should be_zero
    end
  end

  context "a particular (3,4) vector" do
    before(:each) do
      @vector = Vector2d.new(3,4)
    end

    it "should have correct x,y values" do
      @vector.x.should == 3.0
      @vector.y.should == 4.0
    end

    it "should have a length of 5.0" do
      @vector.length.should == 5
    end

    it "should have a length squared of 25" do
      @vector.length_sq.should == 25
    end

    it "should have a length of 1.0 when normalized" do
      @vector.normalize!.length.should == 1
      @vector.normalize!.length.should == 1
    end

    it "should have a length squared of 1.0 when normalized" do
      @vector.normalize!.length_sq.should == 1
      @vector.normalize!.length_sq.should == 1
    end
    
  end
  
end

