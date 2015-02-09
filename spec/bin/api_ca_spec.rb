ENV['SPIN_CA_DIR'] = File.expand_path('../../tmp/ca', File.dirname(__FILE__))

load './bin/api-ca'
FileUtils.mkdir_p(SPIN_CA_DIR)

CA_KEY = OpenSSL::PKey::RSA.new(2048)
OTHER_KEY = OpenSSL::PKey::RSA.new(2048)

CA_CERT = OpenSSL::X509::Certificate.new.tap do |cert|
  cert.public_key = CA_KEY.public_key
  cert.not_before = Time.now.utc
  cert.not_after = Time.now.utc + (10 * 365 * 24 * 60 * 60)
  cert.serial = 0
  cert.version = 2

  cn = "Test API CA #{SecureRandom.urlsafe_base64}"
  cert.subject = OpenSSL::X509::Name.parse("/CN=#{cn}/")
  cert.issuer = cert.subject

  cert.sign(CA_KEY, OpenSSL::Digest::SHA256.new)
end

RSpec::Matchers.define :have_same_public_key_as do |expected|
  match do |actual|
    expected.public_key.params == actual.public_key.params
  end

  failure_message do |actual|
    "public keys did not match\n\n" \
      "expected:\n#{expected.public_key.to_text}\n\n" \
      "actual:\n#{actual.public_key.to_text}"
  end
end

RSpec.describe APICertificateAuthority do
  let(:ca_key_file) { File.join(SPIN_CA_DIR, 'ca.key') }
  let(:ca_cert_file) { File.join(SPIN_CA_DIR, 'ca.crt') }
  let(:serial_file) { File.join(SPIN_CA_DIR, 'serial.txt') }
  let(:ca_cert) { OpenSSL::X509::Certificate.new(File.read(ca_cert_file)) }
  let(:ca_key) { OpenSSL::PKey::RSA.new(File.read(ca_key_file)) }
  let(:stderr) { StringIO.new }

  before do
    File.open(ca_key_file, 'w') { |f| f.write(CA_KEY.to_pem) }
    File.open(ca_cert_file, 'w') { |f| f.write(CA_CERT.to_pem) }

    allow($stderr).to receive(:puts) { |*a| stderr.puts(*a) }
    allow($stderr).to receive(:print) { |*a| stderr.print(*a) }
  end

  subject { -> { run } }

  context 'init' do
    let(:cn) { SecureRandom.urlsafe_base64 }

    def run
      # Don't needlessly consume entropy
      allow(OpenSSL::PKey::RSA).to receive(:new).and_return(CA_KEY)

      described_class.start(%w(init --cn) << cn)
    end

    context 'when the ca does not exist' do
      before { FileUtils.rm_f([ca_cert_file, ca_key_file]) }

      it 'creates a valid certificate' do
        expect(subject).to change { File.exist?(ca_cert_file) }.to be_truthy
        expect(ca_cert).to be_a OpenSSL::X509::Certificate
      end

      it 'creates a valid key' do
        expect(subject).to change { File.exist?(ca_key_file) }.to be_truthy
        expect(ca_key).to be_a OpenSSL::PKey::RSA
      end

      it 'sets the key mode to 0600' do
        run
        stat = File.new(ca_key_file).stat
        expect(stat.mode & 0777).to eq(0600)
      end

      it 'uses the provided cn' do
        run
        expect(ca_cert.subject.to_a).to include(['CN', cn, anything])
      end

      it 'creates a CA certificate' do
        run
        expect(ca_cert.extensions.map(&:to_a))
          .to include(['basicConstraints', 'CA:TRUE, pathlen:0', true])
      end

      it 'creates a self-signed certificate' do
        run
        expect(ca_cert.subject).to eq(ca_cert.issuer)
        expect(ca_cert.verify(ca_key.public_key)).to be_truthy
      end

      it 'creates a matching pair' do
        run
        expect(ca_cert).to have_same_public_key_as(ca_key)
      end

      it 'outputs the certificate information' do
        run
        expect(stderr.string)
          .to match(/Generated new CA Certificate\n\nCertificate:/)
      end

      it 'records the serial number' do
        run
        expect(File.read(serial_file).to_i).to eq(ca_cert.serial.to_i)
      end
    end

    context 'when the ca exists' do
      it 'leaves the certificate intact' do
        expect(subject).not_to change { File.read(ca_cert_file) }
      end

      it 'leaves the key intact' do
        expect(subject).not_to change { File.read(ca_key_file) }
      end

      it 'outputs a message' do
        run
        expect(stderr.string).to match(/A CA Certificate already exists/)
      end
    end
  end

  context 'sign' do
    let(:pipe) { IO.pipe }
    let(:stdin) { pipe[1] }

    around do |example|
      old = $stdin
      r, w = IO.pipe

      begin
        t = Thread.new do
          data.split("\n").each { |s| w.puts(s.strip) }
        end

        $stdin = r
        Timeout.timeout(1) { example.run }

        t.join
      ensure
        $stdin = old
      end
    end

    let(:req) do
      req = OpenSSL::X509::Request.new
      req.version = 0
      req.public_key = OTHER_KEY.public_key
      req.subject = OpenSSL::X509::Name.parse('/CN=An irrelevant CN/')
      req.sign(OTHER_KEY, OpenSSL::Digest::SHA256.new)
      req.to_pem
    end

    let(:data) { "#{req}\nyes".squeeze("\n") }
    let(:generated_cn) { SecureRandom.urlsafe_base64 }

    let(:cert_file) { File.join(SPIN_CA_DIR, 'certs', "#{generated_cn}.crt") }
    let(:req_file) { File.join(SPIN_CA_DIR, 'requests', "#{generated_cn}.req") }
    let(:cert) { OpenSSL::X509::Certificate.new(File.read(cert_file)) }

    before do
      allow(SecureRandom).to receive(:urlsafe_base64).with(30)
        .and_return(generated_cn)
    end

    def run
      described_class.start(%w(sign))
    end

    it 'prompts for continuation' do
      run
      expect(stderr.string).to match(/Do you wish to sign this request/)
    end

    it 'enrols the certificate' do
      expect(subject).to change { File.exist?(cert_file) }.to be_truthy
    end

    it 'stores the request' do
      expect(subject).to change { File.exist?(req_file) }.to be_truthy
      expect(File.read(req_file).strip).to eq(req.strip)
    end

    it 'uses the generated cn' do
      run
      expect(cert.subject.to_a).to include(['CN', generated_cn, anything])
    end

    it 'is signed with the CA certificate' do
      run
      expect(cert.verify(ca_cert.public_key)).to be_truthy
    end

    it 'has the CA certificate as issuer' do
      run
      expect(cert.issuer).to eq(ca_cert.subject)
    end

    it 'is not a CA certificate' do
      run
      expect(cert.extensions.map(&:to_a))
        .to include(['basicConstraints', 'CA:FALSE', false])
    end

    it 'increments and records the serial number' do
      n = SecureRandom.random_number(0xFFFFFFFF)
      File.open(serial_file, 'w') { |f| f.write(n.to_s) }
      run
      expect(cert.serial.to_i).to be > n
      expect(File.read(serial_file).to_i).to eq(cert.serial.to_i)
    end

    it 'prints the certificate out' do
      run
      expect(stderr.string).to match(/Certificate:/)
      expect(stderr.string).to match(/Subject: CN=#{generated_cn}/)
      expect(stderr.string).to match(/-----BEGIN CERTIFICATE-----/)
      expect(stderr.string).to match(/-----END CERTIFICATE-----/)
    end

    context 'random identifier collision' do
      before { File.open(cert_file, 'w') { |f| f.write('') } }

      it 'fails creation' do
        expect(subject).to raise_error(/Identifier collision/)
      end
    end

    context 'with no confirmation' do
      let(:data) { "#{req}\nno".squeeze("\n") }

      it 'does not issue the certificate' do
        expect(subject).to raise_error(SystemExit)
        expect(File.exist?(cert_file)).to be_falsey
      end
    end

    context 'with a provided cn' do
      let(:cert_file) { File.join(SPIN_CA_DIR, 'certs', 'provided_cn.crt') }
      let(:req_file) { File.join(SPIN_CA_DIR, 'requests', 'provided_cn.req') }

      before { File.open(cert_file, 'w') { |f| f.write('') } }

      def run
        described_class.start(%w(sign --cn provided_cn))
      end

      it 'creates the certificate with the provided cn' do
        run
        expect(cert.subject.to_a).to include(['CN', 'provided_cn', anything])
      end
    end
  end
end
