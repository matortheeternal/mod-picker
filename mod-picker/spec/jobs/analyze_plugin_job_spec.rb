require 'rails_helper'
require 'sucker_punch/testing/inline'

RSpec.describe AnalyzePluginJob, :job do

  it 'should run a valid test' do
    expect(AnalyzePluginJob.perform_async()).to be_valid
  end

end