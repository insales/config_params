require 'minitest/autorun'
require './lib/config_params'

describe ConfigParams do
  before do
    class A
      extend ConfigParams
      config_param :param, setter_visibility: :public, getter_visibility: :public
    end

    module TestModule
      def self.included(base)
        base.class_eval do
          extend ConfigParams
          config_param :smth
        end
      end

      def result
        smth
      end
    end

    class B
      include TestModule
    end


  end

  describe 'when class is extended with it' do
    it 'should define setter & getter' do
      A.instance_methods.include?(:param).should be_true
      A.singleton_class.instance_methods.include?(:param).should be_true
    end
  end

  describe 'when it is included in module' do
    it 'should define setter & getter in class' do
      B.private_instance_methods.include?(:smth).should be_true
      B.singleton_class.private_instance_methods.include?(:smth).should be_true
    end
  end

  describe 'setter' do
    it 'should work with block' do
      A.param do
        'block'
      end
      A.new.param.should == 'block'
    end

    it 'should work with proc' do
      A.param -> { 'proc' }
      A.new.param.should == 'proc'
    end

    it 'should work with object' do
      o = Object.new
      A.param o
      A.new.param.should == o
    end

    it 'should work with symbols' do
      class A
        def method
          'from method'
        end
      end
      A.param :method
      A.new.param.should == 'from method'
    end

    describe 'when argument is given as value' do
      before do
        class C < A
        end
        class D < A
        end
        A.param 'a'
      end

      it 'should be inherited' do
        C.new.param.should == 'a'
        C.param 'c'
        A.new.param.should == 'a'
        C.new.param.should == 'c'
      end

      it 'should be called as super' do
        D.param -> { "#{super()} d"}
        D.new.param.should == 'a d'
      end
    end

    describe 'when argument is given as proc' do
      before do
        class E < A
        end
        class F < A
        end
        A.param -> { 'a' }
      end

      it 'should be inherited' do
        E.new.param.should == 'a'
        E.param 'c'
        A.new.param.should == 'a'
        E.new.param.should == 'c'
      end

      it 'should be called as super' do
        F.param -> { "#{super()} d"}
        F.new.param.should == 'a d'
      end
    end
  end
end
