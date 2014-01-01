require 'net/http'
require 'resolv'
require 'uri'

describe 'my domains' do
  context 'git-tfs.com' do
    it('uses dnsimple', :dns => true) { dnsimple! 'git-tfs.com' }
    it('gets 200 for apex') { expect(get('http://git-tfs.com/')).to be_200(:title => 'git-tfs') }
    it('gets 200 for www') { expect(get('http://www.git-tfs.com/')).to be_200(:title => 'git-tfs') }
  end

  context 'pickardayune.com' do
    it('uses dnsimple', :dns => true) { dnsimple! 'pickardayune.com' }
    it('gets 200 for apex') { expect(get('http://pickardayune.com/')).to be_200(:title => 'the Pickard Ayune') }
    it('gets 200 for www') { expect(get('http://www.pickardayune.com/')).to be_200(:title => 'the Pickard Ayune') }
    it('gets 200 for chickens') { expect(get('http://chickens.pickardayune.com/')).to be_200(:title => 'Chicken Tracker') }
    it('gets 200 for reader') { expect(get('http://reader.pickardayune.com/')).to redirect(:to => 'http://reader.pickardayune.com/login') }
    it('gets 502 for news') { expect(get('http://news.pickardayune.com/')).to be_502 }
  end

  context 'frankfortccc.com' do
    it('uses dnsimple', :dns => true) { dnsimple! 'frankfortccc.com' }
    it('gets 200 for apex') { expect(get('http://frankfortccc.com/')).to be_200 }
    it('redirects to apex from www') { expect(get('http://www.frankfortccc.com/')).to redirect(:to => 'http://frankfortccc.com/') }
    it('gets 200 or redirects for mail') { expect(get('https://mail.frankfortccc.com/')).to be_200 }
    it('gets 200 for plan-worship') { expect(get('http://plan-worship.frankfortccc.com/')).to be_200 }
  end

  context 'farmtoforkmarket.com' do
    it('uses dnsimple', :dns => true) { dnsimple! 'farmtoforkmarket.com' }
    it('redirects apex to .org') { expect(get('http://farmtoforkmarket.com')).to redirect(:to => 'http://www.farmtoforkmarket.org') }
    it('redirects www to .org') { expect(get('http://www.farmtoforkmarket.com')).to redirect(:to => 'http://www.farmtoforkmarket.org') }
  end

  context 'farmtoforkmarket.org' do
    it('uses fatcow', :dns => true) { expect(dns('farmtoforkmarket.org')).to be_fatcow }
    it('gets 200 for apex') { expect(get('http://farmtoforkmarket.org')).to be_200 }
    it('gets 200 for www') { expect(get('http://www.farmtoforkmarket.org')).to be_200 }
  end

  # HTTP expectations
  def get(url)
    uri = URI(url)
    Net::HTTP.new(uri.hostname, uri.port).start do |http|
      response = http.request_get(uri.request_uri)
      debugger unless $skip
#      if response.code >= 300 && response.code < 400
#        debugger
#      end
      return response
    end
    nil
  end

  def be_200(options = {})
    satisfy { |v| v.code == 200 && title?(v.body, options[:title]) }
  end

  def title?(page, expected_title)
    if expected_title.nil?
      true
    elsif page !~ /<title>(.*)<\/title>/
      false
    else
      $1 == expected_title
    end
  end

  def be_502
    pending('is this a 502?')
  end

  def redirect(options = {})
    pending('is this a redirect?')
  end

  # DNS expectations

  def dnsimple!(domain)
    expect(dns(domain)).to be_dnsimple
  end

  def dns(domain)
    Resolv::DNS.open { |dns| dns.getresources domain, Resolv::DNS::Resource::IN::NS }
  end

  def be_dnsimple
    satisfy { |v| v.any? { |ns| ns.name.to_s =~ /dnsimple.com$/ } }
  end

  def be_fatcow
    satisfy { |v| v.any? { |ns| ns.name.to_s =~ /fatcow.com$/ } }
  end
end
