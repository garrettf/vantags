require 'rails_helper'

describe Van do
  before do
    @van = Van.new(
      make:  'Newsmobile',
      model: 'Shadow'
    )
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

  end


end
