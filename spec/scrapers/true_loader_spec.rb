describe Scrapers::TrueLoader do
  def stub_page(url, status, body)
    Typhoeus.stub(url).and_return(Typhoeus::Response.new(code: status, body: body))
  end

  it 'should allow you to queue pages' do
    loader = Scrapers::TrueLoader.new
    queue1_cb = Proc.new{}
    queue2_cb = Proc.new{}
    loader.queue('http://www.example.com/trueloader', &queue1_cb)
    loader.queue('http://www.purple.com/trueloader', &queue2_cb)
    stub_page('http://www.example.com/trueloader', 200, '<html>Hello!</html>')
    stub_page('http://www.purple.com/trueloader', 200, '<html>Bye!</html>')

    expect(queue1_cb).to receive(:call){ |response|
      expect(response.request.url).to eq 'http://www.example.com/trueloader'
      expect(response.code).to eq 200
      expect(response.body).to eq('<html>Hello!</html>')
    }

    expect(queue2_cb).to receive(:call){ |response|
      expect(response.request.url).to eq 'http://www.purple.com/trueloader'
      expect(response.code).to eq 200
      expect(response.body).to eq('<html>Bye!</html>')
    }

    loader.run{ |response| }
  end
end
