require 'rails_helper'

RSpec.describe Api::PoemsController, type: :controller do
  let(:source_text) { create(:source_text, :long_content) }
  let(:poem) { create(:poem, source_text: source_text) }

  describe 'GET #index' do
    before do
      # Clear existing poems to get predictable count
      Poem.destroy_all
      @test_poems = create_list(:poem, 3, source_text: source_text)
      get :index
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'returns all poems in JSON format' do
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(3)
    end

    it 'includes required poem attributes' do
      json_response = JSON.parse(response.body)
      poem_data = json_response.first

      expect(poem_data).to have_key('id')
      expect(poem_data).to have_key('title')
      expect(poem_data).to have_key('technique_used')
      expect(poem_data).to have_key('content_preview')
      expect(poem_data).to have_key('source_text')
      expect(poem_data).to have_key('created_at')
    end

    it 'includes source text information' do
      json_response = JSON.parse(response.body)
      poem_data = json_response.first

      expect(poem_data['source_text']).to have_key('id')
      expect(poem_data['source_text']).to have_key('title')
    end

    it 'truncates content preview' do
      Poem.destroy_all
      long_poem = create(:poem, content: 'word ' * 100, source_text: source_text)
      get :index

      json_response = JSON.parse(response.body)
      long_poem_data = json_response.find { |p| p['id'] == long_poem.id }
      
      expect(long_poem_data['content_preview'].length).to be <= 200
    end

    it 'orders poems by creation date descending' do
      json_response = JSON.parse(response.body)
      created_dates = json_response.map { |p| Time.parse(p['created_at']) }
      
      expect(created_dates).to eq(created_dates.sort.reverse)
    end
  end

  describe 'GET #show' do
    context 'with valid poem id' do
      before { get :show, params: { id: poem.id } }

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'returns poem details in JSON format' do
        json_response = JSON.parse(response.body)

        expect(json_response['id']).to eq(poem.id)
        expect(json_response['title']).to eq(poem.title)
        expect(json_response['content']).to eq(poem.content)
        expect(json_response['technique_used']).to eq(poem.technique_used)
      end

      it 'includes full source text information' do
        json_response = JSON.parse(response.body)

        expect(json_response['source_text']['id']).to eq(source_text.id)
        expect(json_response['source_text']['title']).to eq(source_text.title)
      end
    end

    context 'with invalid poem id' do
      it 'raises ActiveRecord::RecordNotFound' do
        expect { get :show, params: { id: 99999 } }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'POST #create' do
    let(:valid_attributes) do
      {
        title: 'Test Poem',
        content: 'This is a test poem',
        technique_used: 'cutup',
        source_text_id: source_text.id
      }
    end

    context 'with valid parameters' do
      before { post :create, params: { poem: valid_attributes } }

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'creates a new poem' do
        expect { post :create, params: { poem: valid_attributes } }.to change(Poem, :count).by(1)
      end

      it 'returns success message and poem data' do
        json_response = JSON.parse(response.body)

        expect(json_response['success']).to be true
        expect(json_response['message']).to eq('Poem was successfully created.')
        expect(json_response['poem']).to have_key('id')
        expect(json_response['poem']['title']).to eq('Test Poem')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) { { title: '', content: '', technique_used: 'invalid' } }

      before { post :create, params: { poem: invalid_attributes } }

      it 'returns unprocessable entity status' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error message and validation errors' do
        json_response = JSON.parse(response.body)

        expect(json_response['success']).to be false
        expect(json_response['errors']).to be_an(Array)
        expect(json_response['errors']).not_to be_empty
      end

      it 'does not create a poem' do
        expect { post :create, params: { poem: invalid_attributes } }.not_to change(Poem, :count)
      end
    end
  end

  describe 'POST #generate_cut_up' do
    let(:valid_params) do
      {
        id: source_text.id,
        method: 'cut_up',
        num_lines: 10,
        words_per_line: 8
      }
    end

    context 'with valid source text' do
      it 'generates and saves a cut-up poem' do
        expect { post :generate_cut_up, params: valid_params }.to change(Poem, :count).by(1)
      end

      it 'returns success response' do
        post :generate_cut_up, params: valid_params
        json_response = JSON.parse(response.body)

        expect(json_response['success']).to be true
        expect(json_response['message']).to include("Cut-up poem successfully generated")
        expect(json_response['poem']).to have_key('id')
        expect(json_response['poem']['technique_used']).to eq('cutup')
      end

      it 'uses CutUpGenerator service' do
        generator_instance = instance_double(CutUpGenerator)
        allow(CutUpGenerator).to receive(:new).with(source_text).and_return(generator_instance)
        allow(generator_instance).to receive(:generate).and_return('Generated poem content')

        post :generate_cut_up, params: valid_params

        expect(CutUpGenerator).to have_received(:new).with(source_text)
        expect(generator_instance).to have_received(:generate).with(
          method: 'cut_up',
          num_lines: 10,
          words_per_line: 8
        )
      end

      it 'generates appropriate poem title' do
        post :generate_cut_up, params: valid_params
        json_response = JSON.parse(response.body)

        expect(json_response['poem']['title']).to include('Cutup:')
        expect(json_response['poem']['title']).to include(source_text.title.split.first(3).join(' '))
      end
    end

    context 'with source text without content' do
      let(:empty_source_text) { 
        text = build(:source_text, content: '')
        text.save(validate: false)
        text
      }

      it 'returns error response' do
        post :generate_cut_up, params: { id: empty_source_text.id }
        json_response = JSON.parse(response.body)
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['success']).to be false
        expect(json_response['message']).to include('Cannot generate poem')
      end
    end

    context 'with default parameters' do
      it 'uses default values when parameters not provided' do
        generator_instance = instance_double(CutUpGenerator)
        allow(CutUpGenerator).to receive(:new).and_return(generator_instance)
        allow(generator_instance).to receive(:generate).and_return('Generated content')

        post :generate_cut_up, params: { id: source_text.id }

        expect(generator_instance).to have_received(:generate).with(
          method: 'cut_up',
          num_lines: 12,
          words_per_line: 6
        )
      end
    end

    context 'when poem save fails' do
      before do
        allow_any_instance_of(Poem).to receive(:save).and_return(false)
        allow_any_instance_of(Poem).to receive(:errors).and_return(
          double('errors', full_messages: ['Title is required'])
        )
      end

      it 'returns error response' do
        post :generate_cut_up, params: valid_params
        json_response = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['success']).to be false
        expect(json_response['message']).to include('Failed to generate poem')
      end
    end
  end

  describe 'POST #generate_erasure' do
    let(:valid_params) do
      {
        id: source_text.id,
        method: 'erasure',
        num_pages: 2,
        words_per_page: 40,
        words_to_keep: 6,
        is_blackout: true
      }
    end

    context 'with valid source text' do
      it 'generates and saves an erasure poem' do
        expect { post :generate_erasure, params: valid_params }.to change(Poem, :count).by(1)
      end

      it 'returns success response' do
        post :generate_erasure, params: valid_params
        json_response = JSON.parse(response.body)

        expect(json_response['success']).to be true
        expect(json_response['message']).to include("Erasure poem successfully generated")
        expect(json_response['poem']).to have_key('id')
      end

      it 'uses ErasureGenerator service' do
        generator_instance = instance_double(ErasureGenerator)
        allow(ErasureGenerator).to receive(:new).with(source_text).and_return(generator_instance)
        allow(generator_instance).to receive(:generate).and_return('{}')

        post :generate_erasure, params: valid_params

        expect(ErasureGenerator).to have_received(:new).with(source_text)
        expect(generator_instance).to have_received(:generate).with(
          method: 'erasure',
          num_pages: 2,
          words_per_page: 40,
          words_to_keep: 6,
          is_blackout: true
        )
      end

      it 'sets technique_used to "blackout" when is_blackout is true' do
        post :generate_erasure, params: valid_params
        json_response = JSON.parse(response.body)

        expect(json_response['poem']['technique_used']).to eq('blackout')
      end

      it 'sets technique_used to "erasure" when is_blackout is false' do
        params = valid_params.merge(is_blackout: false)
        post :generate_erasure, params: params
        json_response = JSON.parse(response.body)

        expect(json_response['poem']['technique_used']).to eq('erasure')
      end
    end

    context 'with default parameters' do
      it 'uses default values when parameters not provided' do
        generator_instance = instance_double(ErasureGenerator)
        allow(ErasureGenerator).to receive(:new).and_return(generator_instance)
        allow(generator_instance).to receive(:generate).and_return('{}')

        post :generate_erasure, params: { id: source_text.id }

        expect(generator_instance).to have_received(:generate).with(
          method: 'erasure',
          num_pages: 3,
          words_per_page: 50,
          words_to_keep: 8,
          is_blackout: false
        )
      end
    end

    context 'with source text without content' do
      let(:empty_source_text) { 
        text = build(:source_text, content: '')
        text.save(validate: false)
        text
      }

      it 'returns error response' do
        post :generate_erasure, params: { id: empty_source_text.id }
        json_response = JSON.parse(response.body)
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['success']).to be false
        expect(json_response['message']).to include('Cannot generate poem')
      end
    end
  end

  describe 'private methods' do
    describe '#generate_poem_title' do
      let(:timestamp_regex) { /\d{2}\/\d{2} \d{2}:\d{2}/ }

      it 'generates appropriate title for cutup technique' do
        title = controller.send(:generate_poem_title, source_text, 'cutup')
        
        expect(title).to include('Cutup:')
        expect(title).to match(timestamp_regex)
        expect(title).to include(source_text.title.split.first(3).join(' '))
      end

      it 'generates appropriate title for erasure technique' do
        title = controller.send(:generate_poem_title, source_text, 'erasure')
        
        expect(title).to include('Erasure:')
        expect(title).to match(timestamp_regex)
      end

      it 'handles technique names with underscores' do
        title = controller.send(:generate_poem_title, source_text, 'blackout_poetry')
        
        expect(title).to include('Blackout-poetry:')
      end
    end

    describe '#set_poem' do
      it 'sets @poem instance variable' do
        controller.params = { id: poem.id }
        controller.send(:set_poem)
        
        expect(controller.instance_variable_get(:@poem)).to eq(poem)
      end
    end

    describe '#set_source_text' do
      it 'sets @source_text instance variable' do
        controller.params = { id: source_text.id }
        controller.send(:set_source_text)
        
        expect(controller.instance_variable_get(:@source_text)).to eq(source_text)
      end
    end

    describe '#poem_params' do
      let(:params) do
        ActionController::Parameters.new(
          poem: {
            title: 'Test',
            content: 'Content',
            technique_used: 'cutup',
            source_text_id: 1,
            forbidden_param: 'should not be permitted'
          }
        )
      end

      it 'permits only allowed parameters' do
        controller.params = params
        permitted = controller.send(:poem_params)
        
        expect(permitted.keys).to contain_exactly('title', 'content', 'technique_used', 'source_text_id')
        expect(permitted).not_to have_key('forbidden_param')
      end
    end
  end
end