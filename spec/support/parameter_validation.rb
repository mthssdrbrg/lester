module ParameterValidation
  def parameter_validation(name, error_prefix=nil)
    let :arguments do
      {
        'domain' => 'example.org',
        'endpoint' => 'http://127.0.0.1:4000',
        'site-bucket' => 'example-org-site',
        'storage-bucket' => 'example-org-backup',
        'email' => 'contact@example.org',
        'private-key' => 'path/to/private_key.pem',
      }
    end

    let :argv do
      arguments.flat_map { |k, v| [sprintf('--%s', k), v] }.unshift(command_name)
    end

    context 'when it is missing' do
      before do
        arguments.delete(name.to_s)
      end

      it 'prints an error message' do
        cli.run
        expect(output).to match(/#{error_prefix || name} is required/)
      end

      it 'prints usage' do
        cli.run
        expect(output).to match(/Usage/)
      end

      it 'returns a non-ok exit code' do
        code = cli.run
        expect(code).to eq(1)
      end
    end

    context 'when it is empty' do
      before do
        arguments[name] = ''
      end

      it 'prints an error message' do
        cli.run
        expect(output).to match(/#{error_prefix || name} is required/)
      end

      it 'prints usage' do
        cli.run
        expect(output).to match(/Usage/)
      end

      it 'returns a non-ok exit code' do
        code = cli.run
        expect(code).to eq(1)
      end
    end
  end
end
