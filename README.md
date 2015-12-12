# lester

[![Build Status](https://travis-ci.org/mthssdrbrg/lester.svg?branch=master)](https://travis-ci.org/mthssdrbrg/lester)


Lester is a small tool for renewing certificates from Let's Encrypt (or any
ACME-compatible server), for websites set up using S3 and CloudFront.

It uses S3 for storing certificates and expects that the private key for a
registered account is available from S3. Server side encryption is enabled by
default for all objects written by Lester, and it's possible to use KMS as well.

Should be noted that even though only a single domain is passed to `lester`, it
will actually include both the given domain and the `www` subdomain (i.e. `www.<domain>`)
when requesting a new certificate.

# Installation

```shell
gem install lester --pre
```

# Usage

To get started and upload a local private key the following command can be used:

```shell
lester init --domain example.org \
            --storage-bucket example-org-backup \
            --private-key privkey.pem
```

To generate a new certificate, the simplest invocation of `lester` is the
following:

```shell
lester new --domain example.org \
           --site-bucket example-org \
           --storage-bucket example-org-backup \
           --email contact@example.org
```

To enable server side encryption with KMS, one can specify the `-k / --kms-id`
with eiither a key ID or alias:

```shell
lester new --domain example.org \
           --site-bucket example-org \
           --storage-bucket example-org-backup \
           --email contact@example.org \
           --kms-id alias/letsencrypt
```

It's also possible to use `renew` rather than `new` if one prefers, the result
will be the same.

See `lester --help` for information about other command-line parameters.

## Copyright

© 2015 Mathias Söderberg, see LICENSE.txt (MIT).
