require 'spec_helper'

class SpecModel < Sequel::Model(:spec)
  plugin :bit_fields, :status_bits, [ :started, :finished, :reviewed ]
  plugin :bit_fields, :paranoid_bits, [ :allow_mail ]
end

describe Sequel::Plugins::BitFields do
  it "declares the method started= and started?" do
    SpecModel.create.should respond_to(:started=)
    SpecModel.create.should respond_to(:started?)
  end

  it "declares the method finished= and finished?" do
    SpecModel.create.should respond_to(:finished=)
    SpecModel.create.should respond_to(:finished?)
  end

  it "declares the method reviewed= and reviewed?" do
    SpecModel.create.should respond_to(:reviewed=)
    SpecModel.create.should respond_to(:reviewed?)
  end

  it "stores the bit fields" do
    SpecModel.bit_fields[:status_bits].should   == [ :started, :finished, :reviewed ]
    SpecModel.bit_fields(:status_bits).should   == [ :started, :finished, :reviewed ]
    SpecModel.bit_fields[:paranoid_bits].should == [ :allow_mail ]
    SpecModel.bit_fields(:paranoid_bits).should == [ :allow_mail ]
  end

  describe :field= do
    context "a freshly created object without any bits" do
      before do
        @model = SpecModel.create
      end

      it "sets status_bits to 0" do
        @model.status_bits.should == 0
      end

      it "sets status_bits to 1 if started is set to true" do
        @model.started = true
        @model.status_bits.should == 1
      end

      it "sets status_bits to 2 if finished is set to true" do
        @model.finished = true
        @model.status_bits.should == 2
      end

      it "sets status_bits to 4 if reviewed is set to true" do
        @model.reviewed = true
        @model.status_bits.should == 4
      end

      it "sets status_bits to 3 if started and finished is set to true" do
        @model.started = true
        @model.finished = true
        @model.status_bits.should == 3
      end

      it "sets status bits to 7 if started and finished and reviewed is set to true" do
        @model.started = true
        @model.finished = true
        @model.reviewed = true
        @model.status_bits.should == 7
      end
    end

    context "an instance with finished set to true" do
      before do
        @model = SpecModel.create
        @model.finished = true
      end

      it "sets the status bits to 2" do
        @model.status_bits.should == 2
      end

      it "sets the status_bits to 0 if finished was set to false" do
        @model.finished = false
        @model.status_bits.should == 0
      end
    end
  end

  describe :field? do
    context "a freshly created object without any bits" do
      before do
        @model = SpecModel.create
      end

      it "returns false for all status_bits" do
        @model.started?.should be_false
        @model.finished?.should be_false
        @model.reviewed?.should be_false
      end
    end

    context "an object with started set to true" do
      before do
        @model = SpecModel.create
        @model.started = true
      end

      it "returns true for started?" do
        @model.started?.should be_true
      end

      it "returns false for started? if started was set to false" do
        @model.started = false
        @model.started?.should be_false
      end
    end
  end

  describe :field_sql do
    it "returns the sql for truthy comparison of started" do
      SpecModel.started_sql.should == "status_bits & 1 = 1"
    end

    it "returns the sql for falsy comparison of started" do
      SpecModel.started_sql(false).should == "status_bits & 1 != 1"
    end

    it "returns the sql for truthy comparison of finished" do
      SpecModel.finished_sql.should == "status_bits & 2 = 2"
    end

    it "returns the sql for falsy comparison of finished" do
      SpecModel.finished_sql(false).should == "status_bits & 2 != 2"
    end

    it "returns the sql for truthy comparison of reviewed" do
      SpecModel.reviewed_sql.should == "status_bits & 4 = 4"
    end

    it "returns the sql for falsy comparison of reviewed" do
      SpecModel.reviewed_sql(false).should == "status_bits & 4 != 4"
    end
  end

  describe :status_bits do
    context "an object with finished set to true" do
      before do
        @model = SpecModel.create
        @model.finished = true
      end

      it "returns false for finished? if status_bits was set to 0" do
        @model.status_bits = 0
        @model.finished?.should be_false
      end
    end
  end
end
