RSpec.describe Link, type: :model do
  describe 'associations' do
    it { should belong_to :linkable }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:url) }
    it { should_not allow_value("https://").for(:url) }
    it { should_not allow_value("https://google").for(:url) }
    it { should_not allow_value("google").for(:url) }
    it { should_not allow_value("google.com").for(:url) }
    it { should_not allow_value("ftp://google.com").for(:url) }
    it { should_not allow_value("gopher://google.com").for(:url) }
    it { should allow_value("https://google.com").for(:url) }
    it { should allow_value("http://example.com").for(:url) }
  end

  describe 'gist related tests' do
    let(:gist_links) do
      urls = [ 'https://gist.github.com/cyberfined/68c7bc7e26f4a197e93a4196d9932d28',
               'https://gist.github.com/deyixtan/6822b66ad7792ab2580ba37c450ae79c',
               'https://gist.github.com/CristinaSolana/1885435' ]
      urls.map { |u| Link.new(title: 'link', url: u) }
    end

    let(:not_gist_links) do
      urls = [ 'https://gist.github.com/test',
               'https://gist.github.com/test/1/2',
               'https://gist.github.com/test/1/2/d3',
               'https://google.com' ]
      urls.map { |u| Link.new(title: 'link', url: u) }
    end

    describe 'gist? method' do
      it 'should return true' do
        expect(gist_links).to be_all { |l| l.gist? }
      end

      it 'should return false' do
        expect(not_gist_links).to_not be_any { |l| l.gist? }
      end
    end

    describe 'gist_content method' do
      let(:gist_link) { Link.new(title: 'gist', url: 'https://gist.github.com/cyberfined/3263456890e06a904ac504961322118c') }

      it "should return valid gist's content" do
        files = gist_link.gist_content
        expect(files.count).to eq(2)
        expect(files.first.filename).to eql('Test file 1')
        expect(files.first.content).to eql('Test content 1')
        expect(files.second.filename).to eql('Test file 2')
        expect(files.second.content).to eql('Test content 2')
      end

      it 'should rise exceptions' do
        not_gist_links.each { |l| expect { l.gist_content }.to raise_error(ArgumentError) }
      end
    end
  end

  describe 'as_json method' do
    let(:question) { create(:user).questions.create!(attributes_for(:question)) }

    it "should return json with link's title and url" do
      link = question.links.create!(title: 'example', url: 'https://example.com')
      link_hash = link.as_json
      expect(link_hash[:id]).to eq(link.id)
      expect(link_hash[:title]).to eql(link.title)
      expect(link_hash[:url]).to eql(link.url)
      expect(link_hash[:gist]).to be_falsey
    end

    it "should return json with gist's content" do
      link = question.links.create!(title: 'gist', url: 'https://gist.github.com/cyberfined/3263456890e06a904ac504961322118c')
      link_hash = link.as_json
      expect(link_hash[:id]).to eq(link.id)
      expect(link_hash[:gist]).to be true
      expect(link_hash[:content]).to eql(link.gist_content)
    end
  end
end
