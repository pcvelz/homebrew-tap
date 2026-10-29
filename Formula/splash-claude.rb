class SplashClaudeMacOSRequirement < Requirement
  fatal true
  satisfy(build_env: false) { OS.mac? && MacOS.full_version >= "26.4" }

  def message
    "Splash requires macOS 26.4 or newer."
  end
end

class SplashClaude < Formula
  desc "Local inference engine for Apple silicon, built around the model"
  homepage "https://github.com/pcvelz/splash-claude"
  url "https://github.com/pcvelz/splash-claude/releases/download/1.5.0.1/splash-1.5.0.1-arm64-macos26.tar.gz"
  sha256 "7d14a6620aaa1e52c44dcbe6328aa1eb4792f253f89bdd607a2de9be06532ace"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/pcvelz/splash-claude/releases/download/1.5.0.1"
    sha256 arm64_golden_gate: "c6de1ac59397e70b83f8f79c059bdc86cca01c44d3e77afe24e4577f15b3794e"
  end

  depends_on arch: :arm64
  depends_on macos: :tahoe
  depends_on SplashClaudeMacOSRequirement

  def install
    libexec.install Dir["*"]
    (bin/"splash-claude").write <<~SH
      #!/bin/sh
      export PYTHONDONTWRITEBYTECODE=1
      exec "#{opt_libexec}/python/bin/python3" -u "#{opt_libexec}/install/launcher.py" "$@"
    SH
    chmod 0755, bin/"splash-claude"
    zsh_completion.install_symlink libexec/"install/completions/_splash" => "_splash-claude"
    bash_completion.install_symlink libexec/"install/completions/splash.bash" => "splash-claude"
    fish_completion.install_symlink libexec/"install/completions/splash.fish" => "splash-claude.fish"
  end

  def caveats
    <<~CAVEAT
      Serve a model:
        splash-claude serve --model unsloth/Qwen3.8-27B-GGUF:UD-Q4_K_M
    CAVEAT
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/splash-claude --version")
    assert_match "serve", shell_output("#{bin}/splash-claude --help")
  end
end
