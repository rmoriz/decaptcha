require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Decaptcha::Client" do
  it "should instantiate" do
    Decaptcha::Client.new(:dbc_http).should be_a_kind_of(Decaptcha::Client)
  end
  
  it "should set a provider by class name" do
    client = Decaptcha::Client.new :dbc_http
    client.provider.should be_a_kind_of(Decaptcha::Provider::DeathByCaptcha::HTTP)
  end
  
  it "should set a provider with provider instance" do
    client = Decaptcha::Client.new :dbc_http
    client.provider.should be_a_kind_of(Decaptcha::Provider::DeathByCaptcha::HTTP)
  end

end
