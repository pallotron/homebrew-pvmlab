class Pvmlab < Formula
  desc "CLI for managing provisioning VM labs"
  homepage "https://github.com/pallotron/pvmlab"
  license "Apache-2.0"

  version "0.0.6"

  # Adjust this URL and SHA256 for each release
  url "https://github.com/pallotron/pvmlab/archive/refs/tags/v#{version}.tar.gz"
  # To find the SHA256 for a new version, run:
  # curl -L -s https://github.com/pallotron/pvmlab/archive/refs/tags/v#{version}.tar.gz | shasum -a 256
  sha256 "b1a38000d16ce6d0c9cd009d5687cb419776e7e8825602a919252e7c01cb7711"

  depends_on "go" => :build
  depends_on "qemu"
  depends_on "cdrtools"
  depends_on "socat"
  depends_on "socket_vmnet"

  def install
    # Compile the main pvmlab binary
    ldflags = "-X 'pvmlab/internal/config.Version=#{version}'"
    system "go", "build", *std_go_args(ldflags: ldflags), "./pvmlab"

    # Install supporting files
    libexec.install "launchd/socket_vmnet_wrapper.sh"
    prefix.install "launchd/io.github.pallotron.pvmlab.socket_vmnet.plist"

    # Generate and install shell completions
    generate_completions_from_executable(bin/"pvmlab", "completion", shells: [:bash, :zsh])
  end

  def caveats
    <<~EOS
      To complete the installation and set up the networking service, run the following command:

        sudo pvmlab system setup-launchd
    EOS
  end

  test do
    system "#{bin}/pvmlab", "version"
  end
end
