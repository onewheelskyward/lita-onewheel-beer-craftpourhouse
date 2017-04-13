require 'spec_helper'

describe Lita::Handlers::OnewheelBeerCraftpourhouse, lita_handler: true do
  it { is_expected.to route_command('cfp') }
  it { is_expected.to route_command('cfp 4') }
  it { is_expected.to route_command('cfp nitro') }
  it { is_expected.to route_command('cfp CASK') }
  it { is_expected.to route_command('cfp <$4') }
  it { is_expected.to route_command('cfp < $4') }
  it { is_expected.to route_command('cfp <=$4') }
  it { is_expected.to route_command('cfp <= $4') }
  it { is_expected.to route_command('cfp >4%') }
  it { is_expected.to route_command('cfp > 4%') }
  it { is_expected.to route_command('cfp >=4%') }
  it { is_expected.to route_command('cfp >= 4%') }
  it { is_expected.to route_command('cfpabvhigh') }
  it { is_expected.to route_command('cfpabvlow') }

  before do
    mock = File.open('spec/fixtures/craftpourhouse.json').read
    allow(RestClient).to receive(:get) { mock }
  end

  it 'shows the taps' do
    send_command 'cfp'
    expect(replies.last).to include('taps: 3) Nectar Creek Mead Apis  4) Atlas Cider Company Hard Apple Cider')
  end

  it 'displays details for tap 4' do
    send_command 'cfp 4'
    expect(replies.last).to include('Craftpourhouse tap 4) Hard Apple Cider - Our flagship apple cider is a celebration of the Northwest')
  end

  it 'searches for ipa' do
    send_command 'cfp ipa'
    expect(replies.last).to include('Craftpourhouse tap 16) Beak Breaker - Beak Breaker is our newest homage to big, aromatic')
  end

  it 'searches for abv >9%' do
    send_command 'cfp >9%'
    expect(replies.count).to eq(3)
    expect(replies[0]).to include('Craftpourhouse tap 16) Beak Breaker - Beak Breaker is our newest homage to big, aromatic')
    expect(replies[1]).to include('Craftpourhouse tap 23) Judgment Day - A massive beer in every sense of the word. A stronger and more')
  end

  it 'runs a random beer through' do
    send_command 'cfp roulette'
    expect(replies.count).to eq(1)
    expect(replies.last).to include('Craftpourhouse tap')
  end

  it 'runs a random beer through' do
    send_command 'cfp random'
    expect(replies.count).to eq(1)
    expect(replies.last).to include('Craftpourhouse tap')
  end

  it 'displays hige abv' do
    send_command 'cfpabvhigh'
    expect(replies.last).to include('Craftpourhouse tap 23) Judgment Day - A massive beer in every sense of the word.')
  end

  it 'displays low abv' do
    send_command 'cfpabvlow'
    expect(replies.last).to include('Craftpourhouse tap 7) Sun Made Cucumber Berliner Weisse')
  end
end
