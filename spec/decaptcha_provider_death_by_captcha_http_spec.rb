require File.expand_path(File.dirname(__FILE__) + '/spec_helper')



describe "Decaptcha::Provider::DeathByCaptcha" do
  it "should should be able to log in" do
    client = Decaptcha::Client.new('dbc_http', { :login => '', :password => '' })
    
    client.provider.login.should    == ''
    client.provider.password.should == ''
  end
  
  before(:each) do
    @client = Decaptcha::Client.new :dbc_http, :login => '', :password => ''
  end
  
  # it "should be able to upload a captcha filename" do
  #   result = @client.upload :filename => CAPCHTA_FIXTURES_DIR + 'recaptcha1.jpg'
  # end
  # 
  # it "should be able to upload a captcha filename" do
  #   result = @client.upload_and_poll :filename => CAPCHTA_FIXTURES_DIR + 'recaptcha1.jpg'
  # end
  
  it "should query a response" do
    response = @client.result Decaptcha::Response.new_from_location "http://www.deathbycaptcha.com/api/captcha/35703609"
    response.text.should == 'retch vileteed'
  end
  
  it "should query a response which was marked as invalid" do
    response = @client.result Decaptcha::Response.new_from_location "http://www.deathbycaptcha.com/api/captcha/35605900"
    response.text.should == 'Lwis disherve'
    response.status.should be_false
  end
  
  it "should delete a captcha" do
    response = @client.delete Decaptcha::Response.new_from_location "http://www.deathbycaptcha.com/api/captcha/35711664"
    response.deleted.should be_true
  end
  
  #it "should mark a captcha as invalid" do
  #  upload = @client.upload :filename => CAPCHTA_FIXTURES_DIR + 'recaptcha3.jpg'
  #  response = @client.invalid upload
  #  response.invalid.should be_true
  #end
  
  
end