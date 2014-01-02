require 'net/http'
require 'resolv'
require 'uri'

describe 'my domains' do
  context 'git-tfs.com', :gittfs => true do
    it('uses dnsimple', :dns => true) { dnsimple! 'git-tfs.com' }
    it('gets 200 for apex') { expect(get('http://git-tfs.com/')).to be_200(:title => 'git-tfs') }
    it('gets 200 for www') { expect(get('http://www.git-tfs.com/')).to be_200(:title => 'git-tfs') }
  end

  context 'pickardayune.com', :blog => true do
    it('uses dnsimple', :dns => true) { dnsimple! 'pickardayune.com' }
    it('gets 200 for apex') { expect(get('http://pickardayune.com/')).to be_200(:title => 'the Pickard Ayune') }
    it('gets 200 for www') { expect(get('http://www.pickardayune.com/')).to be_200(:title => 'the Pickard Ayune') }
    it('gets 200 for chickens') { expect(get('http://chickens.pickardayune.com/')).to be_200(:title => 'Chicken Tracker') }
    it('gets 302 for reader') { expect(get('http://reader.pickardayune.com/')).to redirect(:to => 'http://reader.pickardayune.com/login') }
    it('gets 503 for news') { expect(get('http://news.pickardayune.com/')).to be_503 }
  end

  context 'frankfortccc.com', :church => true do
    it('uses dnsimple', :dns => true) { dnsimple! 'frankfortccc.com' }
    it('gets 200 for apex') { expect(get('http://frankfortccc.com/')).to be_200 }
    it('redirects to apex from www') { expect(get('http://www.frankfortccc.com/')).to redirect(:to => 'http://frankfortccc.com/') }
    it('gets redirects for mail') { expect(get('http://mail.frankfortccc.com/')).to redirect(:to => 'https://mail.google.com/a/frankfortccc.com') }
    it('gets 200 for plan-worship') { expect(get('http://plan-worship.frankfortccc.com/2013-09-29')).to be_200 }
  end

  context 'farmtoforkmarket.com', :market => true do
    it('uses dnsimple', :dns => true) { dnsimple! 'farmtoforkmarket.com' }
    it('redirects apex to .org') { expect(get('http://farmtoforkmarket.com')).to redirect(:to => 'http://www.farmtoforkmarket.org/') }
    it('redirects www to .org') { expect(get('http://www.farmtoforkmarket.com')).to redirect(:to => 'http://www.farmtoforkmarket.org/') }
  end

  context 'farmtoforkmarket.org', :market => true do
    it('uses fatcow', :dns => true) { expect(dns('farmtoforkmarket.org')).to be_fatcow }
    it('gets 200 for apex') { expect(get('http://farmtoforkmarket.org')).to be_200(:title => 'Farm to Fork at Normandy Farms') }
    it('gets 200 for www') { expect(get('http://www.farmtoforkmarket.org')).to be_200(:title => 'Farm to Fork at Normandy Farms') }
  end

  # HTTP expectations
  def get(url)
    uri = URI(url)
    Net::HTTP.new(uri.hostname, uri.port).start do |http|
      response = http.request_get(uri.request_uri)
      #if response.is_a?(Net::HTTPRedirection) && (response["Location"] == '/' || response["Location"] == url)
      #  response = http.request_get(uri.request_uri)
      #end
      return ResponseHelper.new(response)
    end
    nil
  end

  class ResponseHelper
    def initialize(http_response)
      @http_response = http_response
    end

    def code
      @http_response.code.to_i
    end

    def ok?
      @http_response.is_a?(Net::HTTPOK)
    end

    def redirection?
      @http_response.is_a?(Net::HTTPRedirection)
    end

    def title?(expected_title)
      return true if expected_title.nil?
      return false unless @http_response.body =~ /<title>([^<]*)<\/title>/
      actual_title = $1.chomp
      expected_title == actual_title
    end

    def location?(expected_location)
      return true if expected_location.nil?
      expected_location == @http_response['Location']
    end

    def to_s
      "<Response #{@http_response.code} #{@http_response.to_hash.inspect} #{@http_response.body}>"
    end
  end

  def be_200(options = {})
    satisfy { |response| response.ok? && response.title?(options[:title]) }
  end

  def be_503
    satisfy { |response| response.code == 503 }
  end

  def redirect(options = {})
    satisfy { |response| response.redirection? && response.location?(options[:to]) }
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
