require 'rails_helper'

describe Van do
  before do
    # make: 'Newsmobile', model: 'Shadow'
    @van = FactoryGirl.build :van
  end

  subject { @van }

  it { is_expected.to respond_to :make }
  it { is_expected.to respond_to :model }
  it { is_expected.to respond_to :tags }
  it { expect( subject.tags ).to be_nil }
  it { is_expected.to be_valid }

  describe 'when make is not present' do
    before { subject.make = nil }
    it { is_expected.to_not be_valid }
  end

  describe 'when model is not present' do
    before { subject.model = nil }
    it { is_expected.to_not be_valid }
  end

  context 'tags' do
    it 'can be stored via Set' do
      subject.update! tags: Set[ 'new', 'shiny' ]
      subject.reload
      expect( subject.tags ).to eq Set[ 'new', 'shiny' ]
    end

    it 'can be stored via Array' do
      subject.update! tags: [ 'new', 'shiny' ]
      subject.reload
      expect( subject.tags ).to eq Set[ 'new', 'shiny' ]
    end

    it 'can be erased' do
      subject.update! tags: [ 'new', 'shiny' ]
      subject.update! tags: nil
      subject.reload
      expect( subject.tags ).to be_nil
    end

    it 'can be easily added to' do
      subject.update! tags: [ 'new', 'shiny' ]
      expect( subject.tags ).to eq Set[ 'new', 'shiny' ]
      subject.tags << 'sedan'
      subject.save!
      subject.reload
      expect( subject.tags ).to eq Set[ 'new', 'sedan', 'shiny' ]
    end
  end
end
