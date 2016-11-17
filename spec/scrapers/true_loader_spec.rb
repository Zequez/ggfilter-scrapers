describe Scrapers::TrueLoader do
  def stub_page(url, status, body)
    Typhoeus.stub(url).and_return(Typhoeus::Response.new(code: status, body: body))
  end

  it 'should allow you to queue pages' do
    loader = Scrapers::TrueLoader.new
    queue1_cb = Proc.new{}
    queue2_cb = Proc.new{}
    loader.queue('http://www.example.com', &queue1_cb)
    loader.queue('http://www.purple.com', &queue2_cb)
    stub_page('http://www.example.com', 200, '<html>Hello!</html>')
    stub_page('http://www.purple.com', 200, '<html>Bye!</html>')

    expect(queue1_cb).to receive(:call){ |response|
      expect(response.request.url).to eq 'http://www.example.com'
      expect(response.code).to eq 200
      expect(response.body).to eq('<html>Hello!</html>')
    }

    expect(queue2_cb).to receive(:call){ |response|
      expect(response.request.url).to eq 'http://www.purple.com'
      expect(response.code).to eq 200
      expect(response.body).to eq('<html>Bye!</html>')
    }

    loader.run{ |response| }
  end

  it 'should not call the queue on failed requests' do
    loader = Scrapers::TrueLoader.new
    queue1_cb = Proc.new{}
    loader.queue('http://www.example.com', &queue1_cb)
    stub_page('http://www.example.com', 403, '<html>Error!</html>')
    stub_page('http://www.example.com', 200, '<html>Hello!</html>')

    expect(queue1_cb).to receive(:call){ |response|
      expect(response.request.url).to eq 'http://www.example.com'
      expect(response.code).to eq 200
      expect(response.body).to eq('<html>Hello!</html>')
    }

    loader.run{ |response| }
  end
end
