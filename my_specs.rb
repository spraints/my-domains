describe 'my domains' do
  context 'git-tfs.com' do
    it('uses dnsimple')
    it('gets 200 for apex')
    it('gets 200 or redirect to apex for www')
  end

  context 'pickardayune.com' do
    it('uses dnsimple')
    it('gets 200 for apex')
    it('gets 200 or redirect to apex for www')
    it('gets 200 for chickens')
    it('gets 200 for reader')
    it('gets 502 for news')
  end

  context 'frankfortccc.com' do
    it('uses dnsimple')
    it('gets 200 for apex')
    it('redirects to apex from www')
    it('gets 200 or redirects for mail')
    it('gets 200 for plan-worship')
  end

  context 'farmtoforkmarket.com' do
    it('uses dnsimple')
    it('redirects apex to .org')
    it('redirects www to .org')
  end
end
