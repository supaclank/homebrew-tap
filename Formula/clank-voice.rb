# Built from source on the user's machine: the sherpa-onnx Go bindings
# are cgo and link vendored dylibs through an absolute rpath into the Go
# module cache, so a prebuilt binary can't be shipped as a cask. The
# release pipeline in supaclank/clank publishes Casks/clank.rb; this
# file is maintained by hand (bump url + sha256 per release).
class ClankVoice < Formula
  desc "Local push-to-talk dictation engine for clank preview (sherpa-onnx + Parakeet)"
  homepage "https://github.com/supaclank/clank"
  url "https://github.com/supaclank/clank/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "802f48d0fd754043bb55d22a63d4ff43b8e4ba72c8fdca6627e4fe50cdf9623c"
  license "AGPL-3.0-only"
  head "https://github.com/supaclank/clank.git", branch: "main"

  depends_on "go" => :build
  # sherpa-onnx-go-linux vendors .so files with the same ${SRCDIR} rpath;
  # not wired up yet.
  depends_on :macos

  def install
    cd "voice-engine" do
      ENV["CGO_ENABLED"] = "1"
      # Never let a repo-root go.work pull the cgo module into clank proper.
      ENV["GOWORK"] = "off"
      system "go", "build", *std_go_args, "./cmd/clank-voice"

      # The bindings' #cgo LDFLAGS bake -rpath ${SRCDIR}/lib/<arch> (the
      # module cache) into the binary. Ship the dylibs from there and
      # repoint the rpath at them.
      module_dir = Utils.safe_popen_read("go", "list", "-m", "-f", "{{.Dir}}",
                                         "github.com/k2-fsa/sherpa-onnx-go-macos").chomp
      arch = Hardware::CPU.arm? ? "aarch64-apple-darwin" : "x86_64-apple-darwin"
      srcdir = Pathname(module_dir)/"lib"/arch
      (libexec/"lib").mkpath
      cp Dir[srcdir/"*.dylib"], libexec/"lib"
      chmod "u+w", Dir[libexec/"lib/*.dylib"]

      MachO::Tools.change_rpath(bin/"clank-voice", srcdir.to_s, rpath(source: bin, target: libexec/"lib"))
      MachO.codesign!(bin/"clank-voice") if Hardware::CPU.arm?
    end
  end

  def caveats
    <<~EOS
      clank finds clank-voice next to the clank binary or on PATH; nothing
      else to configure. Models (~670 MB) download on first use of voice
      in `clank preview`.
    EOS
  end

  test do
    # Reaching argument validation proves the sherpa/onnxruntime dylibs
    # resolved through the rewritten rpath.
    assert_match "--models is required", shell_output("#{bin}/clank-voice 2>&1", 1)
  end
end
