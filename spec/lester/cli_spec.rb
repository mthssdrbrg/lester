require 'spec_helper'

module Lester
  describe Cli do
    let :cli do
      described_class.new(argv, io)
    end

    let :io do
      StringIO.new
    end

    let :output do
      io.string
    end

    describe 'help|-h' do
      let :argv do
        ['help']
      end

      it 'prints usage' do
        cli.run
        expect(output).to match(/Usage/)
      end

      it 'returns an ok exit code' do
        code = cli.run
        expect(code).to eq(0)
      end
    end

    describe 'init' do
      let :private_key_path do
        'fake/private_key.pem'
      end

      context 'cli-line parameters' do
        context '-d / --domain DOMAIN' do
          context 'when it is missing' do
            let :argv do
              [
                'init',
                '--storage-bucket', 'example-org-backup',
                '--private-key', private_key_path,
              ]
            end

            it 'prints an error message' do
              cli.run
              expect(output).to match(/domain is required/)
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
            let :argv do
              [
                'init',
                '--domain', '',
                '--storage-bucket', 'example-org-backup',
                '--private-key', private_key_path,
              ]
            end

            it 'prints an error message' do
              cli.run
              expect(output).to match(/domain is required/)
            end

            it 'prints usage' do
              cli.run
              expect(output).to match(/Usage/)
            end

            it 'exists with 1 as code' do
              code = cli.run
              expect(code).to eq(1)
            end
          end
        end

        context '-s / --storage-bucket NAME' do
          context 'when it is missing' do
            let :argv do
              [
                'init',
                '--domain', 'example.org',
                '--private-key', private_key_path,
              ]
            end

            it 'prints an error message' do
              cli.run
              expect(output).to match(/storage bucket is required/)
            end

            it 'prints usage' do
              cli.run
              expect(output).to match(/Usage/)
            end

            it 'exists with 1 as code' do
              code = cli.run
              expect(code).to eq(1)
            end
          end

          context 'when it is empty' do
            let :argv do
              [
                'init',
                '--domain', 'example.org',
                '--storage-bucket', '',
                '--private-key', private_key_path,
              ]
            end

            it 'prints an error message' do
              cli.run
              expect(output).to match(/storage bucket is required/)
            end

            it 'prints usage' do
              cli.run
              expect(output).to match(/Usage/)
            end

            it 'exists with 1 as code' do
              code = cli.run
              expect(code).to eq(1)
            end
          end
        end

        context '-p / --private-key PATH' do
          context 'when it is missing' do
            let :argv do
              [
                'init',
                '--domain', 'example.org',
                '--storage-bucket', 'example-org-backup',
              ]
            end

            it 'prints an error message' do
              cli.run
              expect(output).to match(/private key path is required/)
            end

            it 'prints usage' do
              cli.run
              expect(output).to match(/Usage/)
            end

            it 'exists with 1 as code' do
              code = cli.run
              expect(code).to eq(1)
            end
          end

          context 'when it is empty' do
            let :argv do
              [
                'init',
                '--domain', 'example.org',
                '--storage-bucket', 'example-org-backup',
                '--private-key', '',
              ]
            end

            it 'prints an error message' do
              cli.run
              expect(output).to match(/private key path is required/)
            end

            it 'prints usage' do
              cli.run
              expect(output).to match(/Usage/)
            end

            it 'exists with 1 as code' do
              code = cli.run
              expect(code).to eq(1)
            end
          end
        end
      end
    end

    describe 'renew|new' do
      context 'cli-line parameters' do
        let :output do
          io.string
        end

        context '-d / --domain DOMAIN' do
          context 'when it is missing' do
            let :argv do
              [
                'renew',
                '--endpoint', 'http://127.0.0.1:4000',
                '--site-bucket', 'example-org-site',
                '--storage-bucket', 'example-org-backup',
                '--email', 'contact@example.org',
              ]
            end

            it 'prints an error message' do
              cli.run
              expect(output).to match(/domain is required/)
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
            let :argv do
              [
                'renew',
                '--domain', '',
                '--endpoint', 'http://127.0.0.1:4000',
                '--site-bucket', 'example-org-site',
                '--storage-bucket', 'example-org-backup',
                '--email', 'contact@example.org',
              ]
            end

            it 'prints an error message' do
              cli.run
              expect(output).to match(/domain is required/)
            end

            it 'prints usage' do
              cli.run
              expect(output).to match(/Usage/)
            end

            it 'exists with 1 as code' do
              code = cli.run
              expect(code).to eq(1)
            end
          end
        end

        context '-s / --storage-bucket NAME' do
          context 'when it is missing' do
            let :argv do
              [
                'renew',
                '--domain', 'example.org',
                '--endpoint', 'http://127.0.0.1:4000',
                '--site-bucket', 'example-org-site',
                '--email', 'contact@example.org',
              ]
            end

            it 'prints an error message' do
              cli.run
              expect(output).to match(/storage bucket is required/)
            end

            it 'prints usage' do
              cli.run
              expect(output).to match(/Usage/)
            end

            it 'exists with 1 as code' do
              code = cli.run
              expect(code).to eq(1)
            end
          end

          context 'when it is empty' do
            let :argv do
              [
                'renew',
                '--domain', 'example.org',
                '--endpoint', 'http://127.0.0.1:4000',
                '--site-bucket', 'example-org-site',
                '--storage-bucket', '',
                '--email', 'contact@example.org',
              ]
            end

            it 'prints an error message' do
              cli.run
              expect(output).to match(/storage bucket is required/)
            end

            it 'prints usage' do
              cli.run
              expect(output).to match(/Usage/)
            end

            it 'exists with 1 as code' do
              code = cli.run
              expect(code).to eq(1)
            end
          end
        end

        context '-b / --site-bucket NAME' do
          context 'when it is missing' do
            let :argv do
              [
                'renew',
                '--domain', 'example.org',
                '--endpoint', 'http://127.0.0.1:4000',
                '--storage-bucket', 'example-org-backup',
                '--email', 'contact@example.org',
              ]
            end

            it 'prints an error message' do
              cli.run
              expect(output).to match(/site bucket is required/)
            end

            it 'prints usage' do
              cli.run
              expect(output).to match(/Usage/)
            end

            it 'exists with 1 as code' do
              code = cli.run
              expect(code).to eq(1)
            end
          end

          context 'when it is empty' do
            let :argv do
              [
                'renew',
                '--domain', 'example.org',
                '--endpoint', 'http://127.0.0.1:4000',
                '--site-bucket', '',
                '--storage-bucket', 'example-org-backup',
                '--email', 'contact@example.org',
              ]
            end

            it 'prints an error message' do
              cli.run
              expect(output).to match(/site bucket is required/)
            end

            it 'prints usage' do
              cli.run
              expect(output).to match(/Usage/)
            end

            it 'exists with 1 as code' do
              code = cli.run
              expect(code).to eq(1)
            end
          end
        end

        context '-e / --email ADDRESS' do
          context 'when it is missing' do
            let :argv do
              [
                'renew',
                '--domain', 'example.org',
                '--endpoint', 'http://127.0.0.1:4000',
                '--site-bucket', 'example-org-site',
                '--storage-bucket', 'example-org-backup',
              ]
            end

            it 'prints an error message' do
              cli.run
              expect(output).to match(/email is required/)
            end

            it 'prints usage' do
              cli.run
              expect(output).to match(/Usage/)
            end

            it 'exists with 1 as code' do
              code = cli.run
              expect(code).to eq(1)
            end
          end

          context 'when it is empty' do
            let :argv do
              [
                'renew',
                '--domain', 'example.org',
                '--endpoint', 'http://127.0.0.1:4000',
                '--site-bucket', 'example-org-site',
                '--storage-bucket', 'example-org-backup',
                '--email', '',
              ]
            end

            it 'prints an error message' do
              cli.run
              expect(output).to match(/email is required/)
            end

            it 'prints usage' do
              cli.run
              expect(output).to match(/Usage/)
            end

            it 'exists with 1 as code' do
              code = cli.run
              expect(code).to eq(1)
            end
          end
        end
      end
    end

    describe 'any other command' do
      let :argv do
        ['other']
      end

      it 'prints an error message' do
        cli.run
        expect(output).to match(/Unknown command "other"/)
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
