shared_context 'acceptance setup' do
  let :io do
    StringIO.new
  end

  let :private_key_path do
    File.expand_path('../../support/resources/privkey.json', __FILE__)
  end

  let :iam do
    FakeIAM.new
  end

  let :buckets do
    {}
  end

  let :site_bucket do
    Aws::S3::Bucket.new('example-org-site')
  end

  let :storage_bucket do
    Aws::S3::Bucket.new('example-org-backup')
  end

  let :cloudfront do
    FakeCloudFront.new
  end

  before do
    allow(Aws::S3::Bucket).to receive(:new) do |name, opts|
      buckets[name] ||= FakeBucket.new(name)
      buckets[name]
    end
    allow(Aws::IAM::Client).to receive(:new).and_return(iam)
    allow(Aws::CloudFront::Client).to receive(:new).and_return(cloudfront)
  end
end
