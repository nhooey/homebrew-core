class SeleniumServer < Formula
  desc "Browser automation for testing purposes"
  homepage "https://www.selenium.dev/"
  url "https://github.com/SeleniumHQ/selenium/releases/download/selenium-4.14.0/selenium-server-4.14.0.jar"
  sha256 "0a40132b35b9e9b78760d7f427369408c4d26395b51de928bc773f3ab143e26c"
  license "Apache-2.0"

  livecheck do
    url "https://www.selenium.dev/downloads/"
    regex(/href=.*?selenium-server[._-]v?(\d+(?:\.\d+)+)\.jar/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "0d70b3710f0ec6fe6c07cf9f52c202dac54f9dce19a2a8d1d6f25e16fd939659"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "0d70b3710f0ec6fe6c07cf9f52c202dac54f9dce19a2a8d1d6f25e16fd939659"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "0d70b3710f0ec6fe6c07cf9f52c202dac54f9dce19a2a8d1d6f25e16fd939659"
    sha256 cellar: :any_skip_relocation, sonoma:         "0d70b3710f0ec6fe6c07cf9f52c202dac54f9dce19a2a8d1d6f25e16fd939659"
    sha256 cellar: :any_skip_relocation, ventura:        "0d70b3710f0ec6fe6c07cf9f52c202dac54f9dce19a2a8d1d6f25e16fd939659"
    sha256 cellar: :any_skip_relocation, monterey:       "0d70b3710f0ec6fe6c07cf9f52c202dac54f9dce19a2a8d1d6f25e16fd939659"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "00f3eb44b971fae89bc4a4a48625ecf6c9e106e040950bc5bd3341dede36a0ac"
  end

  depends_on "openjdk"

  def install
    libexec.install "selenium-server-#{version}.jar"
    bin.write_jar_script libexec/"selenium-server-#{version}.jar", "selenium-server"
  end

  service do
    run [opt_bin/"selenium-server", "standalone", "--port", "4444"]
    keep_alive false
    log_path var/"log/selenium-output.log"
    error_log_path var/"log/selenium-error.log"
  end

  test do
    port = free_port
    fork { exec "#{bin}/selenium-server standalone --selenium-manager true --port #{port}" }

    parsed_output = nil

    max_attempts = 100
    attempt = 0

    loop do
      attempt += 1
      break if attempt > max_attempts

      sleep 3

      output = Utils.popen_read("curl", "--silent", "localhost:#{port}/status")
      next unless $CHILD_STATUS.exitstatus.zero?

      parsed_output = JSON.parse(output)
      break if parsed_output["value"]["ready"]
    end

    assert !parsed_output.nil?
    assert parsed_output["value"]["ready"]
    assert_match version.to_s, parsed_output["value"]["nodes"].first["version"]
  end
end
