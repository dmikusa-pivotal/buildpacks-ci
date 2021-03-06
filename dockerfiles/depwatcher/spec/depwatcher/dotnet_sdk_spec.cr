require "spec2"
require "./httpclient_mock"
require "../../src/depwatcher/dotnet_sdk"

Spec2.describe Depwatcher::DotnetSdk do
  let(client) { HTTPClientMock.new }
  subject { described_class.new.tap { |s| s.client = client } }

  before do
    client.stub_get(
      "https://api.github.com/repos/dotnet/cli/tags?per_page=1000",
      nil,
      HTTP::Client::Response.new(
        200,
        File.read(__DIR__ + "/../fixtures/dotnet_tags.json")
      )
    )
    client.stub_get(
      "https://github.com/dotnet/cli/archive/2a1f1c6d30c73c1bce0b557ebbdfba1008e9ae63.tar.gz",
      nil,
      HTTP::Client::Response.new( 200, "hello")
    )
  end

  describe "#check" do
    it "returns dotnet sdk release versions sorted" do
      expect(subject.check(".*\\+dependencies").map(&.ref)).to eq [
        "2.1.103", "2.1.104", "2.1.105", "2.1.200", "2.1.301",
      ]
    end
  end

  describe "#in" do
    it "returns a dotnet sdk release" do
      obj = subject.in("2.1.301", ".*\\+dependencies")
      expect(obj.ref).to eq "2.1.301"
      expect(obj.url).to eq "https://github.com/dotnet/cli"
      expect(obj.git_commit_sha).to eq "2a1f1c6d30c73c1bce0b557ebbdfba1008e9ae63"
      expect(obj.sha256).to eq "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824"
    end
  end
end
