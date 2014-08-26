require 'rails_helper'

describe VansController do
  let!( :van ) { FactoryGirl.create :van }

  describe 'GET index' do
    it 'includes all of the vans' do
      get :index
      expect( assigns( :vans ) ).to include van
    end
  end

  describe 'POST create' do
    let :create_van do
      post :create, van: { make: 'Neptune', model: 'Borealis' }
    end

    it 'creates a new van with valid params' do
      expect { create_van }.to change { Van.count }.by 1
    end

    it 'redirects to index on success' do
      create_van
      is_expected.to redirect_to action: :index
    end

    it 'fails and redirects with invalid params' do
      expect do
        post :create, van: { make: 'Neptune', model: '' }
      end.to_not change { Van.count }
      expect do
        post :create, van: { make: 'Neptune' }
      end.to_not change { Van.count }
      post :create, van: { make: 'Neptune' }
      is_expected.to redirect_to action: :new
    end

    it 'parses tags correctly' do
      post :create, van: {
        make: 'Neptune',
        model: 'Borealis',
        tags: 'new, shiny, funky'
      }
      expect( Van.last.tags ).to eq Set[ 'new', 'shiny', 'funky' ]
    end
  end

  describe 'PUT update' do
    let :update_van do
      put :update, { id: van.id, van: { tags: 'reliable, new tires' } }
    end

    it 'updates a van with valid params' do
      update_van
      expect( Van.find( van.id ).tags ).to eq Set[ 'reliable', 'new tires' ]
    end

    it 'redirects to index on success' do
      update_van
      expect( Van.find( van.id ).tags ).to eq Set[ 'reliable', 'new tires' ]
    end

    it 'fails and redirects with invalid params' do
      put :update, { id: van.id, van: { make: '' } }
      is_expected.to redirect_to [ :edit, van ]
      expect( Van.find( van.id ).make ).to eq van.make
    end
  end

  describe 'DELETE destroy' do
    before { request.env[ 'HTTP_REFERER' ] = '/' }
    let( :destroy_van ) { delete :destroy, id: van.id }

    it 'destroys a van' do
      expect { destroy_van }.to change { Van.count }.by -1
    end

    it 'redirects to your last page on success' do
      destroy_van
      is_expected.to redirect_to '/'
    end
  end
end
