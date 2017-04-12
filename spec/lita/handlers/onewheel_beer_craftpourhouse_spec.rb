require 'spec_helper'

describe Lita::Handlers::OnewheelBeerCraftpourhouse, lita_handler: true do
  it { is_expected.to route_command('craftpourhouse') }
  it { is_expected.to route_command('craftpourhouse 4') }
  it { is_expected.to route_command('craftpourhouse nitro') }
  it { is_expected.to route_command('craftpourhouse CASK') }
  it { is_expected.to route_command('craftpourhouse <$4') }
  it { is_expected.to route_command('craftpourhouse < $4') }
  it { is_expected.to route_command('craftpourhouse <=$4') }
  it { is_expected.to route_command('craftpourhouse <= $4') }
  it { is_expected.to route_command('craftpourhouse >4%') }
  it { is_expected.to route_command('craftpourhouse > 4%') }
  it { is_expected.to route_command('craftpourhouse >=4%') }
  it { is_expected.to route_command('craftpourhouse >= 4%') }
  it { is_expected.to route_command('craftpourhouseabvhigh') }
  it { is_expected.to route_command('craftpourhouseabvlow') }

  before do
    mock = File.open('spec/fixtures/craftpourhouse.html').read
    allow(RestClient).to receive(:get) { mock }
  end

  it 'shows the taps' do
    send_command 'craftpourhouse'
    expect(replies.last).to include('taps: 1) Persnickety Pinot Gris  2) Nectar Creek Apis')
  end

  it 'displays details for tap 4' do
    send_command 'craftpourhouse 4'
    expect(replies.last).to include('Craftpourhouse tap 4) Passion Fruit - , 6.8%')
  end

  it 'doesn\'t explode on 1' do
    send_command 'craftpourhouse 1'
    expect(replies.count).to eq(1)
    expect(replies.last).to eq('Craftpourhouse tap 1) Pinot Gris - , 12.5%')
  end

  it 'searches for ipa' do
    send_command 'craftpourhouse ipa'
    expect(replies.last).to include('Craftpourhouse tap 18) IPA X Series: West Coast - , 6.7%')
  end

  it 'searches for abv >9%' do
    send_command 'craftpourhouse >9%'
    expect(replies.count).to eq(6)
    expect(replies[0]).to eq('Craftpourhouse tap 1) Pinot Gris - , 12.5%')
    expect(replies[1]).to eq('Craftpourhouse tap 10) Sailor Mom - , 9.1%')
  end

  it 'runs a random beer through' do
    send_command 'craftpourhouse roulette'
    expect(replies.count).to eq(1)
    expect(replies.last).to include('Craftpourhouse tap')
  end

  it 'runs a random beer through' do
    send_command 'craftpourhouse random'
    expect(replies.count).to eq(1)
    expect(replies.last).to include('Craftpourhouse tap')
  end

  it 'displays hige abv' do
    send_command 'craftpourhouseabvhigh'
    expect(replies.last).to eq('Craftpourhouse tap 33) Farmhouse Red - , 13.5%')
  end

  it 'displays low abv' do
    send_command 'craftpourhouseabvlow'
    expect(replies.last).to eq('Craftpourhouse tap 8) Cactus Wins the Lottery - , 4.2%')
  end
end
