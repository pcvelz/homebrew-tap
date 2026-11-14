class SplaudeMacOSRequirement < Requirement
  fatal true
  satisfy(build_env: false) { OS.mac? && MacOS.full_version >= "26.4" }

  def message
    "Splash requires macOS 26.4 or newer."
  end
end

class Splaude < Formula
  desc "Local inference engine for Apple silicon, built around the model"
  homepage "https://github.com/pcvelz/splaude"
  url "https://github.com/pcvelz/splaude/releases/download/1.6.2/splash-1.6.2-arm64-macos26.tar.gz"
  sha256 "843b08b8543e26de023663242f9aa2498b979a4adbd5bf8a711741c587ca0e81"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/pcvelz/splaude/releases/download/1.6.2"
    sha256 arm64_golden_gate: "45fd32eb5d6e4f754d0740800945397022f8f8758929466523d00f0408711caf"
  end

  depends_on arch: :arm64
  depends_on macos: :tahoe
  depends_on SplaudeMacOSRequirement

  def install
    libexec.install Dir["*"]
    (bin/"splaude").write <<~SH
      #!/bin/sh
      export PYTHONDONTWRITEBYTECODE=1
      exec "#{opt_libexec}/python/bin/python3" -u "#{opt_libexec}/install/launcher.py" "$@"
    SH
    chmod 0755, bin/"splaude"
    # Transition alias: the command was called splash-claude before the rename.
    bin.install_symlink bin/"splaude" => "splash-claude"
    zsh_completion.install_symlink libexec/"install/completions/_splash" => "_splaude"
    bash_completion.install_symlink libexec/"install/completions/splash.bash" => "splaude"
    fish_completion.install_symlink libexec/"install/completions/splash.fish" => "splaude.fish"
  end

  def caveats
    <<~CAVEAT
      Serve a model:
        splaude serve --model unsloth/Qwen3.8-27B-GGUF:UD-Q4_K_M
    CAVEAT
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/splaude --version")
    assert_match "serve", shell_output("#{bin}/splaude --help")
  end
end
