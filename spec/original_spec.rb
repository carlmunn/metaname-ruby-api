describe Metaname::OriginalAPI do
  it 'tests the original code' do

    stub_req("result": "0.00")

    Metaname::OriginalAPI.initialize!(test_params)
    expect(Metaname::OriginalAPI.account_balance).to eql "0.00"
  end
end